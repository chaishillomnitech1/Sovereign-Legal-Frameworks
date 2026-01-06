# Smart Contract Architecture

## Overview
The 963 Hz Frequency-Enforced Staking Engine consists of two main contracts:

1. **HealToken.sol** - ERC20 token implementation
2. **FrequencyStakingEngine.sol** - Core staking logic

## FrequencyStakingEngine Contract

### State Variables

```solidity
IERC20 public healToken;           // Reference to HEAL token
address public owner;               // Contract owner
uint256 public totalStaked;         // Total tokens staked
uint256 public totalRewardsDistributed; // Cumulative rewards distributed
uint256 public rewardsPool;         // Available rewards
```

### Constants

```solidity
uint256 public constant BASE_APY = 5000;        // 50% (in basis points)
uint256 public constant RESONANCE_BONUS = 2500; // 25% (in basis points)
uint256 public constant SOVEREIGN_BONUS = 1500; // 15% (in basis points)
uint256 public constant RESONANCE_FREQUENCY = 963; // Hz
```

### Data Structures

```solidity
struct StakeInfo {
    uint256 amount;              // Staked amount
    uint256 startTime;           // When staking began
    uint256 lastRewardClaim;     // Last reward claim timestamp
    uint256 resonanceScore;      // 0-1000 (0-100%)
    bool isSovereignParticipant; // Sovereign status
}
```

## Key Functions

### Staking Flow

1. **User approves tokens**
   - `healToken.approve(stakingAddress, amount)`

2. **User stakes tokens**
   - `stake(uint256 amount)`
   - Transfers tokens to contract
   - Records stake information
   - Claims any pending rewards first

3. **Rewards accrue automatically**
   - Based on time elapsed
   - Calculated using effective APY
   - No action needed from user

4. **User claims rewards**
   - `claimRewards()`
   - Transfers accumulated rewards
   - Updates lastRewardClaim timestamp

5. **User unstakes**
   - `unstake(uint256 amount)`
   - Claims pending rewards automatically
   - Returns staked tokens to user

### APY Calculation Formula

```javascript
function calculateEffectiveAPY(address user) {
    // Start with base 50%
    uint256 apy = 5000;
    
    // Add resonance bonus (0-25%)
    // resonanceScore ranges from 0-1000
    uint256 resonanceBonus = (2500 * resonanceScore) / 1000;
    apy += resonanceBonus;
    
    // Add sovereign bonus (15% if applicable)
    if (isSovereignParticipant) {
        apy += 1500;
    }
    
    return apy; // Returns basis points (10000 = 100%)
}
```

### Reward Calculation Formula

```javascript
function calculateRewards(address user) {
    // Time staked in seconds
    uint256 duration = block.timestamp - lastRewardClaim;
    
    // Get effective APY (in basis points)
    uint256 effectiveAPY = calculateEffectiveAPY(user);
    
    // Calculate rewards
    // rewards = (amount * APY * duration) / (365 days * 10000)
    uint256 rewards = (amount * effectiveAPY * duration) / (31536000 * 10000);
    
    return rewards;
}
```

## Security Mechanisms

### 1. Reentrancy Guard
```solidity
bool private locked;

modifier noReentrant() {
    require(!locked, "No reentrancy");
    locked = true;
    _;
    locked = false;
}
```

Applied to all functions that transfer tokens or modify state.

### 2. Access Control
```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Not authorized");
    _;
}
```

Protects admin functions from unauthorized access.

### 3. Input Validation
- All amounts checked for > 0
- Addresses validated against zero address
- Resonance scores limited to 0-1000 range
- Balance checks before transfers

### 4. Rewards Pool Management
- Rewards only distributed if pool has sufficient balance
- Pool must be funded before rewards can be claimed
- Prevents contract from making unfunded promises

## Events

```solidity
event Staked(address indexed user, uint256 amount, uint256 timestamp);
event Unstaked(address indexed user, uint256 amount, uint256 timestamp);
event RewardsClaimed(address indexed user, uint256 amount, uint256 timestamp);
event ResonanceSynced(address indexed user, uint256 resonanceScore, uint256 timestamp);
event SovereignStatusUpdated(address indexed user, bool status);
event RewardsPoolFunded(uint256 amount, uint256 timestamp);
```

Events enable:
- Transaction tracking
- Off-chain indexing
- Dashboard updates
- Analytics

## Admin Operations

### Managing Resonance Scores
The contract owner can update user resonance scores based on:
- Governance participation
- Protocol contribution
- Ecosystem alignment
- Community engagement

### Setting Sovereign Participants
Sovereign participants receive a flat 15% bonus. Criteria might include:
- Long-term commitment
- Governance voting history
- Protocol development contributions
- Community leadership

### Funding Rewards Pool
The owner must regularly fund the rewards pool to ensure:
- Continuous reward distribution
- Sustainable APY rates
- User confidence in the system

## Gas Optimization

1. **Batch operations when possible**
   - Claim rewards automatically during unstake
   - Reduces transaction count

2. **Efficient storage**
   - Packed structs where appropriate
   - Minimized storage writes

3. **View functions for calculations**
   - No gas cost for reading data
   - Enable off-chain computation

## Upgrade Path

Current contract is not upgradeable. For future versions:
- Consider proxy pattern (UUPS or Transparent)
- Implement migration mechanism
- Plan for state transition
- Maintain backward compatibility

## Testing Checklist

- [ ] Stake tokens successfully
- [ ] Unstake tokens successfully
- [ ] Claim rewards correctly
- [ ] APY calculation accuracy
- [ ] Resonance bonus application
- [ ] Sovereign bonus application
- [ ] Reentrancy attack prevention
- [ ] Access control enforcement
- [ ] Rewards pool depletion handling
- [ ] Edge cases (zero amounts, etc.)
- [ ] Gas optimization verification
- [ ] Event emission correctness
