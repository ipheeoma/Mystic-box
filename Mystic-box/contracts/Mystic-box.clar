;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INVALID-RARITY (err u2))
(define-constant ERR-INSUFFICIENT-FUNDS (err u3))
(define-constant ERR-NO-REWARDS (err u4))

;; NFT Definition
(define-non-fungible-token mystic-box uint)

;; Data Maps
(define-map rarity-probabilities
  {rarity: (string-ascii 20)}
  {probability: uint}
)

(define-map rewards-pool
  {rarity: (string-ascii 20)}
  {rewards: (list 100 uint)}
)

;; Data Variables
(define-data-var randomness-nonce uint u0)

;; Initialize Rarity Probabilities
(map-set rarity-probabilities {rarity: "common"} {probability: u60})
(map-set rarity-probabilities {rarity: "uncommon"} {probability: u25})
(map-set rarity-probabilities {rarity: "rare"} {probability: u10})
(map-set rarity-probabilities {rarity: "legendary"} {probability: u5})

;; Helper Functions
(define-private (generate-random-number)
  (let 
    (
      (nonce (var-get randomness-nonce))
    )
    (begin
      (var-set randomness-nonce (+ nonce u1))
      (mod (+ burn-block-height nonce) u100)
    )
  )
)

(define-private (get-rarity (roll uint))
  (if (<= roll u5) 
    "legendary"
    (if (<= roll u15) 
      "rare"
      (if (<= roll u40) 
        "uncommon"
        "common"
      )
    )
  )
)

;; Public Functions
(define-public (add-reward-to-pool 
  (rarity (string-ascii 20)) 
  (reward uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (match (map-get? rewards-pool {rarity: rarity})
      existing-rewards
        (let 
          (
            (current-rewards (get rewards existing-rewards))
            (updated-rewards (unwrap! (as-max-len? (append current-rewards reward) u100) ERR-INVALID-RARITY))
          )
          (ok (map-set rewards-pool {rarity: rarity} {rewards: updated-rewards})))
      (ok (map-set rewards-pool {rarity: rarity} {rewards: (list reward)}))
    )
  )
)

(define-public (mint-mystic-box)
  (let 
    (
      (box-id (+ (var-get randomness-nonce) burn-block-height))
    )
    (try! (nft-mint? mystic-box box-id tx-sender))
    (ok box-id)
  )
)

(define-public (open-mystic-box (box-id uint))
  (let 
    (
      (owner (unwrap! (nft-get-owner? mystic-box box-id) ERR-UNAUTHORIZED))
    )
    (asserts! (is-eq owner tx-sender) ERR-UNAUTHORIZED)
    
    (let 
      (
        (rarity-roll (generate-random-number))
        (rarity (get-rarity rarity-roll))
      )
      
      (match (map-get? rewards-pool {rarity: rarity})
        available-rewards
          (let 
            (
              (rewards-list (get rewards available-rewards))
              (reward-count (len rewards-list))
            )
            (asserts! (> reward-count u0) ERR-NO-REWARDS)
            (let
              (
                (reward-index (mod (generate-random-number) reward-count))
                (selected-reward (unwrap! (element-at rewards-list reward-index) ERR-INVALID-RARITY))
              )
              (try! (nft-burn? mystic-box box-id tx-sender))
              (ok {
                rarity: rarity,
                reward: selected-reward
              })
            )
          )
        ERR-INVALID-RARITY
      )
    )
  )
)

;; Read-only Functions
(define-read-only (get-rarity-probability (rarity (string-ascii 20)))
  (map-get? rarity-probabilities {rarity: rarity})
)

(define-read-only (get-rewards-by-rarity (rarity (string-ascii 20)))
  (map-get? rewards-pool {rarity: rarity})
)