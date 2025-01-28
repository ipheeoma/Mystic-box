# Mystic Box NFT Smart Contract

## Overview
The Mystic Box NFT Smart Contract implements a gamified NFT system where users can mint and open mystery boxes to receive rewards. Each box has a chance to contain items of different rarities (common, uncommon, rare, or legendary) with associated probabilities and rewards.

## Features
- NFT minting and burning mechanics
- Rarity-based reward system
- User statistics tracking
- Global leaderboard functionality
- Randomized reward distribution
- Owner-controlled reward pool management

## Core Components

### Rarity System
The contract implements four rarity tiers with the following probabilities:
- Common: 60%
- Uncommon: 25%
- Rare: 10%
- Legendary: 5%

### Data Structures
- `rarity-probabilities`: Maps rarity levels to their probabilities
- `rewards-pool`: Stores available rewards for each rarity level
- `user-stats`: Tracks individual user statistics
- `leaderboard-map`: Maintains global leaderboard rankings

## Public Functions

### For Users
1. `mint-mystic-box()`
   - Mints a new Mystic Box NFT
   - Returns the unique box ID

2. `open-mystic-box(box-id: uint)`
   - Opens a Mystic Box and reveals its contents
   - Burns the NFT
   - Updates user statistics
   - Returns the rarity and reward

### For Contract Owner
1. `add-reward-to-pool(rarity: string-ascii, reward: uint)`
   - Adds new rewards to the specified rarity pool
   - Only callable by contract owner
   - Maximum reward value: 1,000,000,000

### Read-Only Functions
1. `get-rarity-probability(rarity: string-ascii)`
   - Returns the probability for a specific rarity

2. `get-rewards-by-rarity(rarity: string-ascii)`
   - Returns available rewards for a specific rarity

3. `get-user-stats(user: principal)`
   - Returns user's statistics:
     - Boxes opened
     - Legendary items found
     - Rare items found
     - Uncommon items found
     - Common items found
     - Total rewards

4. `get-leaderboard-entry(position: uint)`
   - Returns the user and score at the specified leaderboard position

5. `get-leaderboard-size()`
   - Returns the current size of the leaderboard

6. `get-user-rank(user: principal)`
   - Returns the user's current rank on the leaderboard

## Constants
- Maximum reward value: 1,000,000,000
- Maximum leaderboard size: 100 entries

## Error Codes
- `ERR-UNAUTHORIZED (u1)`: Unauthorized access attempt
- `ERR-INVALID-RARITY (u2)`: Invalid rarity specification
- `ERR-INSUFFICIENT-FUNDS (u3)`: Insufficient funds for operation
- `ERR-NO-REWARDS (u4)`: No rewards available in pool
- `ERR-INVALID-REWARD (u5)`: Invalid reward value
- `ERR-UPDATE-FAILED (u6)`: Failed to update user statistics

## Security Features
- Ownership controls for administrative functions
- Validation checks for rewards and rarity values
- Authorization checks for NFT operations
- Maximum value constraints for rewards

## Usage Example
```clarity
;; Mint a new Mystic Box
(contract-call? .mystic-box mint-mystic-box)

;; Open a Mystic Box
(contract-call? .mystic-box open-mystic-box u1)

;; Check user stats
(contract-call? .mystic-box get-user-stats tx-sender)
```

## Notes
- The random number generation uses block height and a nonce for entropy
- The leaderboard is automatically updated when users open boxes
- Rewards are distributed randomly from the available pool for each rarity level
- The contract maintains a maximum of 100 entries in the leaderboard