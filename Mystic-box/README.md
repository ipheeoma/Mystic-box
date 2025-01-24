# Mystic Box Smart Contract

A Clarity smart contract implementing a mystery box NFT system with rarity-based rewards.

## Overview

The Mystic Box contract implements a "gacha" or "loot box" system on the Stacks blockchain. Users can mint mystery boxes as NFTs and open them to receive rewards of varying rarities. Each box, when opened, provides a reward based on a probability system.

## Features

- **NFT-Based Mystery Boxes**: Each box is minted as a unique NFT
- **Rarity System**: Four rarity tiers with different probabilities:
  - Legendary (5%)
  - Rare (10%)
  - Uncommon (25%)
  - Common (60%)
- **Dynamic Reward Pool**: Contract owner can add rewards to different rarity pools
- **Verifiable Randomness**: Uses block height and nonce for randomization
- **Burn on Open**: Boxes are burned after being opened

## Functions

### Public Functions

#### `mint-mystic-box()`
- Mints a new Mystic Box NFT to the caller's address
- Returns the unique box ID

#### `open-mystic-box(box-id: uint)`
- Opens a specific Mystic Box and returns a reward
- Burns the box NFT after opening
- Returns: `{rarity: string-ascii, reward: uint}`

#### `add-reward-to-pool(rarity: string-ascii, reward: uint)`
- Adds a new reward to a specific rarity pool
- Only callable by contract owner

### Read-Only Functions

#### `get-rarity-probability(rarity: string-ascii)`
- Returns the probability for a given rarity tier

#### `get-rewards-by-rarity(rarity: string-ascii)`
- Returns the available rewards for a given rarity tier

## Error Codes

- `ERR-UNAUTHORIZED (u1)`: Caller is not authorized to perform the action
- `ERR-INVALID-RARITY (u2)`: Invalid rarity tier specified
- `ERR-INSUFFICIENT-FUNDS (u3)`: Insufficient funds for the operation
- `ERR-NO-REWARDS (u4)`: No rewards available in the specified pool

## Usage Example

```clarity
;; Mint a new mystic box
(contract-call? .mystic-box mint-mystic-box)

;; Open a mystic box
(contract-call? .mystic-box open-mystic-box u1)

;; Add a reward to the legendary pool (contract owner only)
(contract-call? .mystic-box add-reward-to-pool "legendary" u100)
```

## Security Considerations

1. Only the contract owner can add rewards to the pool
2. Users can only open boxes they own
3. Boxes are burned after opening to prevent reuse
4. Randomization uses block height and nonce for entropy

## Development

The contract is written in Clarity, the smart contract language for the Stacks blockchain. It uses native Clarity features for:
- NFT management
- Data maps for storing probabilities and rewards
- Block information for randomization

## Testing

To test the contract, ensure you:
1. Deploy the contract
2. Add rewards to different rarity pools
3. Test minting and opening boxes
4. Verify rarity distributions
5. Test error conditions and unauthorized access
