;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INVALID-RARITY (err u2))
(define-constant ERR-INSUFFICIENT-FUNDS (err u3))
(define-constant ERR-NO-REWARDS (err u4))
(define-constant ERR-INVALID-REWARD (err u5))
(define-constant ERR-UPDATE-FAILED (err u6))
(define-constant MAX-REWARD-VALUE u1000000000)
(define-constant MAX-LEADERBOARD-SIZE u100)

;; NFT Definition
(define-non-fungible-token mystic-box uint)

;; Data Maps and Variables
(define-map rarity-probabilities
  {rarity: (string-ascii 20)}
  {probability: uint}
)

(define-map rewards-pool
  {rarity: (string-ascii 20)}
  {rewards: (list 100 uint)}
)

;; Leaderboard Data Structures
(define-map user-stats
  principal
  {
    boxes-opened: uint,
    legendary-found: uint,
    rare-found: uint,
    uncommon-found: uint,
    common-found: uint,
    total-rewards: uint
  }
)

(define-map leaderboard-map
  uint  ;; position
  {user: principal, boxes-opened: uint}
)

(define-data-var leaderboard-size uint u0)

;; Data Variables
(define-data-var randomness-nonce uint u0)

;; Initialize Rarity Probabilities
(map-set rarity-probabilities {rarity: "common"} {probability: u60})
(map-set rarity-probabilities {rarity: "uncommon"} {probability: u25})
(map-set rarity-probabilities {rarity: "rare"} {probability: u10})
(map-set rarity-probabilities {rarity: "legendary"} {probability: u5})

;; Helper Functions
(define-private (generate-random-number)
  (begin
    (var-set randomness-nonce (+ (var-get randomness-nonce) u1))
    (mod (+ burn-block-height (var-get randomness-nonce)) u100)
  )
)

(define-private (is-valid-rarity (rarity (string-ascii 20)))
  (is-some (map-get? rarity-probabilities {rarity: rarity}))
)

(define-private (is-valid-reward (reward uint))
  (and 
    (> reward u0)
    (<= reward MAX-REWARD-VALUE)
  )
)

(define-private (validate-and-update-rewards (current-rewards (list 100 uint)) (new-reward uint))
  (begin
    (asserts! (is-valid-reward new-reward) ERR-INVALID-REWARD)
    (ok (unwrap! (as-max-len? (append current-rewards new-reward) u100) ERR-INVALID-RARITY))
  )
)

;; Leaderboard Helper Functions
(define-private (update-user-stats (user principal) (rarity (string-ascii 20)) (reward uint))
  (let
    (
      (current-stats (default-to
        {
          boxes-opened: u0,
          legendary-found: u0,
          rare-found: u0,
          uncommon-found: u0,
          common-found: u0,
          total-rewards: u0
        }
        (map-get? user-stats user)))
      (new-boxes-opened (+ (get boxes-opened current-stats) u1))
    )
    (begin
      (map-set user-stats user
        (merge current-stats
          {
            boxes-opened: new-boxes-opened,
            total-rewards: (+ (get total-rewards current-stats) reward),
            legendary-found: (+ (get legendary-found current-stats) (if (is-eq rarity "legendary") u1 u0)),
            rare-found: (+ (get rare-found current-stats) (if (is-eq rarity "rare") u1 u0)),
            uncommon-found: (+ (get uncommon-found current-stats) (if (is-eq rarity "uncommon") u1 u0)),
            common-found: (+ (get common-found current-stats) (if (is-eq rarity "common") u1 u0))
          }
        ))
      (map-set leaderboard-map (var-get leaderboard-size) {user: user, boxes-opened: new-boxes-opened})
      (if (< (var-get leaderboard-size) MAX-LEADERBOARD-SIZE)
        (var-set leaderboard-size (+ (var-get leaderboard-size) u1))
        true
      )
      (if (is-some (map-get? user-stats user))
        (ok true)
        ERR-UPDATE-FAILED)
    )
  )
)

;; Public Functions
(define-public (add-reward-to-pool 
  (rarity (string-ascii 20)) 
  (reward uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-valid-rarity rarity) ERR-INVALID-RARITY)
    (asserts! (is-valid-reward reward) ERR-INVALID-REWARD)
    
    (match (map-get? rewards-pool {rarity: rarity})
      existing-rewards (ok (map-set rewards-pool {rarity: rarity} {rewards: (unwrap! (validate-and-update-rewards (get rewards existing-rewards) reward) ERR-INVALID-REWARD)}))
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
  (begin
    (asserts! (is-eq (unwrap! (nft-get-owner? mystic-box box-id) ERR-UNAUTHORIZED) tx-sender) ERR-UNAUTHORIZED)
    
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
              (try! (update-user-stats tx-sender rarity selected-reward))
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

;; Read-only Functions
(define-read-only (get-rarity-probability (rarity (string-ascii 20)))
  (map-get? rarity-probabilities {rarity: rarity})
)

(define-read-only (get-rewards-by-rarity (rarity (string-ascii 20)))
  (map-get? rewards-pool {rarity: rarity})
)

(define-read-only (get-user-stats (user principal))
  (map-get? user-stats user)
)

(define-read-only (get-leaderboard-entry (position uint))
  (map-get? leaderboard-map position)
)

(define-read-only (get-leaderboard-size)
  (var-get leaderboard-size)
)

(define-read-only (get-user-rank (user principal))
  (let
    ((user-boxes (get boxes-opened (default-to {boxes-opened: u0} (map-get? user-stats user)))))
    (+ u1 (fold rank-calculator
      (list user-boxes)
      u0))
  )
)

(define-private (rank-calculator (score uint) (acc uint))
  (if (> score acc)
    (+ acc u1)
    acc)
)