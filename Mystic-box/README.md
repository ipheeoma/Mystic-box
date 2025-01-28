# Mystic Box Smart Contract

A Clarity smart contract for a blockchain-based mystery box (gacha) system that allows users to mint NFT boxes and open them to receive rewards of varying rarities.

## Overview

The Mystic Box smart contract implements a mystery box system where users can:
- Mint NFT boxes
- Open boxes to receive rewards
- Each box has a chance to contain rewards of different rarities: common, uncommon, rare, and legendary
- Contract owner can manage the rewards pool for each rarity level

## Rarity Distribution

The contract implements the following rarity probabilities:
- Legendary: 5%
- Rare: 10%
- Uncommon: 25%
- Common: 60%

## Functions

### Public Functions

#### `mint-mystic-box()`
Mints a new Mystic Box NFT to the caller's address.
- Returns: uint (box ID)
- Requires: None

#### `open-mystic-box(box-id: uint)`
Opens a Mystic Box and returns a reward based on random rarity.
- Parameters:
  - `box-id`: The ID of the box to open
- Returns: Object containing rarity and reward value
- Requires: Caller must be the owner of the box

#### `add-reward-to-pool(rarity: string-ascii, reward: uint)`
Adds a new reward to the specified rarity pool.
- Parameters:
  - `rarity`: Rarity level ("common", "uncommon", "rare", "legendary")
  - `reward`: Reward value (must be > 0 and <= MAX_REWARD_VALUE)
- Returns: Success/failure response
- Requires: Caller must be contract owner

### Read-Only Functions

#### `get-rarity-probability(rarity: string-ascii)`
Returns the probability for the specified rarity level.
- Parameters:
  - `rarity`: Rarity level to query
- Returns: Optional probability value

#### `get-rewards-by-rarity(rarity: string-ascii)`
Returns the list of available rewards for the specified rarity level.
- Parameters:
  - `rarity`: Rarity level to query
- Returns: Optional list of rewards

## Error Codes

- `ERR-UNAUTHORIZED (u1)`: Caller is not authorized to perform the action
- `ERR-INVALID-RARITY (u2)`: Invalid rarity level specified
- `ERR-INSUFFICIENT-FUNDS (u3)`: Insufficient funds for the operation
- `ERR-NO-REWARDS (u4)`: No rewards available in the specified pool
- `ERR-INVALID-REWARD (u5)`: Invalid reward value specified

## Security Features

- Reward value validation with upper and lower bounds
- Owner-only access for reward pool management
- Secure random number generation using block height and nonce
- Protected NFT operations with ownership verification
- Maximum list length protection for rewards pool
- Input validation for all public functions

## Usage Example

```clarity
;; Mint a new Mystic Box
(contract-call? .mystic-box mint-mystic-box)

;; Open a Mystic Box
(contract-call? .mystic-box open-mystic-box u1)

;; Add reward to pool (contract owner only)
(contract-call? .mystic-box add-reward-to-pool "legendary" u1000)
```

## Limitations

- Maximum 100 rewards per rarity pool
- Maximum reward value is capped at 1,000,000,000
- Randomness is pseudo-random and based on block height
- Rarity probabilities are fixed and cannot be modified after deployment

## Development and Testing

To deploy and test this contract:

1. Install Clarinet
2. Create a new project and add the contract
3. Run the test suite:
```bash
clarinet test
```

## Security Considerations

- The contract uses block height for randomness, which is predictable
- Ensure proper access control when deploying
- Monitor reward pools to ensure sufficient rewards are available
- Consider gas costs when managing large reward pools
