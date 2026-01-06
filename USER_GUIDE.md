# Dashboard User Guide

## Getting Started

The 963 Hz Frequency-Enforced Staking Dashboard provides a user-friendly interface for managing your $HEAL token staking and monitoring your rewards.

## Connecting Your Wallet

1. **Install MetaMask**
   - Download from [metamask.io](https://metamask.io)
   - Create or import a wallet
   - Secure your seed phrase

2. **Add the Network**
   - For local testing: Add localhost network (http://127.0.0.1:8545, Chain ID: 31337)
   - For mainnet: Ensure you're on Ethereum Mainnet
   - For testnet: Add Sepolia testnet

3. **Connect to Dashboard**
   - Click "Connect Wallet" button
   - Approve the connection in MetaMask
   - Your address will appear once connected

## Dashboard Overview

### Main Metrics

#### 💰 Total Value Locked (TVL)
- Shows total amount of HEAL tokens staked across all users
- Updates in real-time as users stake/unstake
- USD value displayed below (calculated at current market rate)

#### 📈 Current APY
- Your personal effective APY rate
- Breakdown shows:
  - **Base APY**: 50% (everyone gets this)
  - **Resonance Bonus**: 0-25% based on your resonance score
  - **Sovereign Bonus**: +15% if you're a sovereign participant
- Maximum possible APY: 90%

#### ⚡ 963 Hz Resonance
- Visual bar showing your resonance alignment (0-100%)
- Higher resonance = higher APY bonus
- Sync status indicator:
  - **High**: 70-100% (excellent alignment)
  - **Medium**: 40-69% (good alignment)
  - **Low**: 0-39% (needs improvement)

#### 🗳️ Governance Votes
- Total number of governance votes cast
- Active proposals count
- Overall participation rate

#### 💎 Your Stake
- Amount of HEAL tokens you currently have staked
- Pending rewards ready to claim
- Updates every 10 seconds

#### 🏦 Rewards Pool
- Total rewards available in the pool
- Total rewards distributed to all users
- Helps gauge pool sustainability

### Sovereign Participant Badge
If you're designated as a sovereign participant, you'll see a special badge displaying your status and the +15% APY bonus.

## Staking Interface

### How to Stake

1. **Prepare Your Tokens**
   - Ensure you have HEAL tokens in your wallet
   - Check you have ETH for gas fees

2. **Stake Tokens**
   - Enter the amount you want to stake
   - Click "Stake Tokens"
   - Approve the token transfer in MetaMask (first time only)
   - Confirm the staking transaction
   - Wait for confirmation

3. **What Happens**
   - Your tokens are transferred to the staking contract
   - Staking starts immediately
   - Rewards begin accumulating based on your APY
   - Initial resonance score set to 50%

### How to Unstake

1. **Unstake Tokens**
   - Enter the amount you want to unstake
   - Click "Unstake Tokens"
   - Confirm the transaction in MetaMask
   - Wait for confirmation

2. **What Happens**
   - Your pending rewards are automatically claimed
   - The unstaked tokens are returned to your wallet
   - Rewards from the unstaked amount stop accumulating
   - Remaining stake continues earning

### How to Claim Rewards

1. **Claim Rewards**
   - No need to enter an amount
   - Click "💎 Claim Rewards"
   - Confirm the transaction
   - Rewards transferred to your wallet

2. **Reward Calculation**
   - Based on: staked amount × effective APY × time staked
   - Calculated every second
   - Claimed rewards reset the timer for next calculation
   - Does not affect your staked principal

## Understanding APY

### Base APY (50%)
Everyone receives 50% base APY regardless of other factors. This is the foundation of the reward system.

### Resonance Bonus (0-25%)
Your resonance score determines your bonus:
- **0% resonance** = 0% bonus
- **25% resonance** = 6.25% bonus
- **50% resonance** = 12.5% bonus
- **75% resonance** = 18.75% bonus
- **100% resonance** = 25% bonus

Resonance is updated by the protocol based on:
- Governance participation
- Community engagement
- Protocol contribution
- Ecosystem alignment

### Sovereign Participation Bonus (15%)
A flat 15% bonus for designated sovereign participants who:
- Demonstrate long-term commitment
- Actively participate in governance
- Contribute to protocol development
- Show leadership in the community

## 963 Hz Frequency Explained

The 963 Hz frequency represents the highest note in the Solfeggio scale, known as the "Frequency of the Gods." In this staking system:

- **Alignment**: Your actions are measured against this harmonic frequency
- **Synchronization**: The protocol monitors your resonance with the frequency
- **Rewards**: Higher alignment = higher rewards
- **Balance**: Promotes harmony in the ecosystem

### Benefits of High Resonance
- ✨ **Higher APY**: Up to 25% additional rewards
- 🎯 **Better Positioning**: Priority in future features
- 🛡️ **Enhanced Security**: Aligned with protocol goals
- 🌟 **Community Recognition**: Shows commitment level

## Tips for Maximizing Rewards

1. **Stake Early**
   - Rewards start accumulating immediately
   - Compound effect over time

2. **Increase Resonance**
   - Participate in governance
   - Engage with community
   - Contribute to ecosystem

3. **Maintain Stake**
   - Longer stakes earn more
   - Unstaking stops rewards

4. **Claim Regularly**
   - Restake rewards to compound
   - Monitor gas fees for optimal timing

5. **Become Sovereign Participant**
   - Demonstrate commitment
   - Earn the 15% bonus
   - Join leadership community

## Transaction Types & Gas Costs

### Stake Transaction
- **Gas**: ~100,000-150,000 units
- **Approval Required**: First time only
- **Time**: 1-2 minutes

### Unstake Transaction
- **Gas**: ~80,000-120,000 units
- **Auto-Claims**: Pending rewards included
- **Time**: 1-2 minutes

### Claim Rewards
- **Gas**: ~60,000-90,000 units
- **No Approval**: Direct transfer
- **Time**: 1 minute

### Best Practices
- Check gas prices at [etherscan.io/gastracker](https://etherscan.io/gastracker)
- Transact during low-traffic times
- Combine operations when possible

## Security & Safety

### Protecting Your Assets

1. **Never Share**
   - Seed phrase
   - Private keys
   - Password

2. **Verify Contracts**
   - Check contract addresses
   - Use official dashboard only
   - Verify on Etherscan

3. **Monitor Transactions**
   - Review before confirming
   - Check recipient address
   - Verify amounts

4. **Stay Updated**
   - Follow official announcements
   - Check for updates
   - Report suspicious activity

### Common Scams to Avoid
- ❌ Fake dashboard websites
- ❌ Unsolicited DMs offering help
- ❌ Requests for private keys
- ❌ Too-good-to-be-true APY promises

## Troubleshooting

### Can't Connect Wallet
- Ensure MetaMask is installed
- Check you're on the correct network
- Try refreshing the page
- Clear browser cache

### Transaction Failing
- Check you have enough HEAL tokens
- Ensure sufficient ETH for gas
- Verify allowance has been set
- Try increasing gas limit

### Rewards Not Showing
- Wait for next update (10 seconds)
- Check you have an active stake
- Verify contract is funded
- Refresh the page

### Wrong Balance Displayed
- Wait for blockchain confirmation
- Check transaction status
- Verify on Etherscan
- Contact support if persistent

## FAQ

**Q: How often are rewards calculated?**
A: Rewards accumulate every second, displayed updates every 10 seconds.

**Q: Can I lose my staked tokens?**
A: No, your principal is safe. Only rewards depend on APY and time.

**Q: What happens if the rewards pool runs out?**
A: New rewards stop accumulating until the pool is refunded. Your stake remains safe.

**Q: How is resonance determined?**
A: The protocol owner updates resonance based on your participation and contribution.

**Q: Can I stake more after initial stake?**
A: Yes, you can stake additional tokens anytime. Previous rewards are claimed automatically.

**Q: Is there a minimum stake amount?**
A: No minimum, but consider gas costs for very small amounts.

**Q: Is there a lock-up period?**
A: No, you can unstake anytime without penalties.

**Q: How do I become a sovereign participant?**
A: Active participation and contribution. The protocol owner designates participants.

## Support & Resources

- **Documentation**: Check README.md and ARCHITECTURE.md
- **Contract Code**: Available on GitHub
- **Etherscan**: Verify transactions and contract
- **Community**: Join official channels

---

**Remember**: Always do your own research and never invest more than you can afford to lose!
