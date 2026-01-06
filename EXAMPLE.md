# Quick Start Example

This guide demonstrates a complete workflow for using the 963 Hz Frequency-Enforced Staking Engine.

## Scenario: Alice Stakes 1000 HEAL Tokens

### Step 1: Initial Setup

Alice has received 1000 HEAL tokens and wants to stake them to earn rewards.

**Initial State:**
- Alice's HEAL balance: 1000 tokens
- Alice's staked amount: 0 tokens
- Alice's resonance score: Not set
- Alice's sovereign status: Not set

### Step 2: Connect Wallet

1. Alice visits the dashboard at `http://localhost:3000`
2. Clicks "Connect Wallet"
3. Approves connection in MetaMask
4. Dashboard shows: "Connected: 0x1234...5678"

### Step 3: Review Dashboard Metrics

Alice sees the current protocol status:
```
Total Value Locked: 1.25M HEAL (~$1.87M USD)
Current APY: 0% (not staking yet)
963 Hz Resonance: 0% (not set)
Governance Votes: 1,247 total
Your Stake: 0 HEAL
Rewards Pool: 500K HEAL
```

### Step 4: Stake Tokens

1. Alice navigates to "Stake HEAL" section
2. Enters amount: `1000`
3. Clicks "Stake Tokens"
4. MetaMask popup appears:
   - First transaction: Approve HEAL token
   - Alice confirms approval
   - Second transaction: Stake 1000 HEAL
   - Alice confirms staking

**Transaction Details:**
```javascript
// Approval transaction
healToken.approve(stakingEngineAddress, "1000000000000000000000");

// Staking transaction
stakingEngine.stake("1000000000000000000000");
```

### Step 5: View Updated Metrics

After transactions confirm, Alice sees:
```
Your Stake: 1,000 HEAL
Pending Rewards: 0 HEAL (just started)
Current APY: 62.5%
  - Base APY: 50%
  - Resonance Bonus: +12.5% (50% resonance)
  - Sovereign Bonus: +0% (not a participant)
963 Hz Resonance: 50% (Medium)
```

**Why 62.5% APY?**
- Base: 50% (everyone gets this)
- Resonance: Default starts at 50% → (2500 * 500) / 1000 = 12.5%
- Sovereign: 0% (not designated yet)
- Total: 50% + 12.5% = 62.5%

### Step 6: Time Passes (30 Days)

Alice checks back after 30 days:

**Reward Calculation:**
```
Staked: 1000 HEAL
APY: 62.5% (6250 basis points)
Time: 30 days (2,592,000 seconds)

Rewards = (1000 * 6250 * 2,592,000) / (31,536,000 * 10,000)
Rewards = 16,200,000,000 / 315,360,000,000
Rewards ≈ 51.37 HEAL
```

Dashboard shows:
```
Your Stake: 1,000 HEAL
Pending Rewards: 51.37 HEAL
Total Value: 1,051.37 HEAL
```

### Step 7: Alice Becomes Active in Governance

Alice participates in governance votes and contributes to the community.

The protocol owner updates her status:
```javascript
// Owner updates Alice's resonance to 80%
stakingEngine.syncResonance(aliceAddress, 800);

// Owner makes Alice a sovereign participant
stakingEngine.setSovereignParticipant(aliceAddress, true);
```

**New APY Calculation:**
```
Base: 50%
Resonance: (2500 * 800) / 1000 = 20%
Sovereign: 15%
Total: 50% + 20% + 15% = 85%
```

Dashboard updates:
```
Current APY: 85%
  - Base APY: 50%
  - Resonance Bonus: +20% (80% resonance)
  - Sovereign Bonus: +15% ✓
963 Hz Resonance: 80% (High)

[👑 Sovereign Participant - +15% APY Bonus]
```

### Step 8: Claim Rewards (After 60 Days Total)

After another 30 days with 85% APY:

**Additional Rewards (Days 31-60):**
```
Rewards = (1000 * 8500 * 2,592,000) / (31,536,000 * 10,000)
Rewards ≈ 69.86 HEAL
```

**Total Rewards:**
- First 30 days @ 62.5%: 51.37 HEAL
- Next 30 days @ 85%: 69.86 HEAL
- Total: 121.23 HEAL

Alice claims rewards:
1. Clicks "💎 Claim Rewards"
2. Confirms transaction
3. Receives 121.23 HEAL in wallet

**New State:**
```
Wallet Balance: 121.23 HEAL
Staked Amount: 1,000 HEAL (unchanged)
Pending Rewards: 0 HEAL (just claimed)
```

### Step 9: Alice Stakes More

Alice stakes her rewards plus additional tokens:

1. Enters amount: `2000` (her 121.23 rewards + 1878.77 more)
2. Approves and stakes
3. New total stake: 3,000 HEAL

**Updated Earnings:**
With 3,000 HEAL staked at 85% APY:
- Daily rewards: ~7.0 HEAL
- Monthly rewards: ~212.5 HEAL
- Yearly rewards: ~2,550 HEAL

### Step 10: Partial Unstake

After 90 days, Alice needs 1,000 HEAL for other purposes:

1. Goes to "Unstake HEAL" section
2. Enters amount: `1000`
3. Clicks "Unstake Tokens"
4. Confirms transaction

**What Happens:**
- Pending rewards automatically claimed (~212.5 HEAL)
- 1,000 HEAL returned to wallet
- Remaining stake: 2,000 HEAL
- Continues earning on remaining 2,000 HEAL

**Final State:**
```
Wallet Balance: 1,212.5 HEAL
Staked Amount: 2,000 HEAL
Pending Rewards: 0 HEAL
Lifetime Rewards Earned: ~333.73 HEAL
```

## Key Takeaways

### For Users
1. **Staking is flexible**: Stake and unstake anytime
2. **Rewards compound**: Restake rewards to maximize returns
3. **Higher engagement = Higher rewards**: Increase resonance through participation
4. **Sovereign status valuable**: Extra 15% boost is significant
5. **No lock-up period**: Access your funds anytime

### For Developers
1. **Clear workflow**: Approve → Stake → Earn → Claim/Unstake
2. **Automatic calculations**: Rewards computed on-chain
3. **Secure design**: Reentrancy guards protect users
4. **Flexible admin controls**: Update resonance and sovereign status
5. **Event-driven**: All actions emit events for tracking

## Advanced Scenarios

### Scenario A: Compound Staking Strategy
Alice claims rewards every 30 days and restakes them:
```
Month 1: 1,000 → earn 51.37
Month 2: 1,051.37 → earn 54.01
Month 3: 1,105.38 → earn 56.77
Month 4: 1,162.15 → earn 59.66
...
After 12 months: ~1,835 HEAL (83.5% effective return)
```

### Scenario B: Maximizing APY
Bob wants the highest APY possible:
1. Stakes tokens
2. Actively participates in governance
3. Contributes to protocol development
4. Achieves 100% resonance
5. Becomes sovereign participant
6. **Result**: 90% APY (maximum)

### Scenario C: Pool Management
Protocol owner ensures sustainability:
1. Monitors rewards pool balance
2. Funds pool when balance < 10% of total staked
3. Adjusts resonance scores based on participation
4. Reviews sovereign participants quarterly

## Common Patterns

### Pattern 1: Long-Term Holder
```javascript
// Stake once, hold forever
stake(largeAmount);
// Claim periodically
claimRewards(); // Monthly or quarterly
// Restake rewards
stake(rewardsAmount);
```

### Pattern 2: Active Trader
```javascript
// Stake short-term
stake(amount);
// Wait for target return
// Unstake when needed
unstake(amount); // Auto-claims rewards
```

### Pattern 3: Compound Maximizer
```javascript
// Automate with external tools
every30Days(() => {
  const rewards = calculateRewards(user);
  claimRewards();
  stake(rewards);
});
```

## Testing Your Setup

Use these commands to verify everything works:

```bash
# 1. Compile contracts
npm run compile

# 2. Run tests
npm test

# 3. Start local blockchain
npx hardhat node

# 4. Deploy contracts (new terminal)
npm run deploy:local

# 5. Start dashboard (new terminal)
cd dashboard
npm run dev

# 6. Open http://localhost:3000
# 7. Connect MetaMask to localhost:8545
# 8. Try staking!
```

---

This example demonstrates the complete lifecycle of staking in the 963 Hz Frequency-Enforced Staking Engine!
