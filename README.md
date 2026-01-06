# 963 Hz Frequency-Enforced Staking Engine

This repository implements a comprehensive staking solution for the $HEAL token, featuring smart contracts and a React-based civic governance dashboard. The system is built on the Ontological Correctness principles of the 963 Hz Resonance Depth (ζ) Model, providing a foundation for the ScrollVerse Geospatial Sovereignty Protocol.

## 🌟 Features

### Smart Contract Capabilities
- **Staking Engine**: Fully-featured staking contract with deposit, withdrawal, and reward claiming
- **963 Hz Resonance Synchronization**: Dynamic resonance scoring system (0-100%)
- **Multi-Tier APY System**:
  - Base APY: 50%
  - Resonance Bonus: up to +25% (based on resonance alignment)
  - Sovereign Participation Bonus: +15%
  - Maximum Combined APY: 90%
- **Security Features**:
  - Reentrancy guards
  - Access control mechanisms
  - Safe math operations
  - Protected reward pool management

### React Civic Governance Dashboard
- **Real-Time Metrics Display**:
  - Total Value Locked (TVL)
  - Dynamic APY calculations with breakdown
  - Governance voting statistics
  - Personal staking metrics
  - Resonance synchronization status
- **Staking Interface**:
  - Stake $HEAL tokens
  - Unstake tokens with automatic reward claiming
  - Manual reward claiming
  - Web3 wallet integration
- **Beautiful UI/UX**:
  - Gradient-based modern design
  - Responsive layout for all devices
  - Real-time updates
  - Interactive components

## 📋 Prerequisites

- Node.js v16+ and npm
- MetaMask or compatible Web3 wallet
- Hardhat (for smart contract development)

## 🚀 Installation & Setup

### Smart Contracts

1. **Install dependencies**:
```bash
npm install
```

2. **Compile contracts**:
```bash
npm run compile
```

3. **Deploy contracts**:
```bash
# For local development
npx hardhat node  # In one terminal
npm run deploy:local  # In another terminal

# For testnets/mainnet (configure hardhat.config.js first)
npm run deploy
```

4. **Note the deployed addresses** and update them in `dashboard/src/components/Web3Provider.jsx`

### React Dashboard

1. **Navigate to dashboard directory**:
```bash
cd dashboard
```

2. **Install dependencies**:
```bash
npm install
```

3. **Update contract addresses** in `src/components/Web3Provider.jsx`:
```javascript
const STAKING_CONTRACT_ADDRESS = 'YOUR_DEPLOYED_STAKING_ADDRESS';
const TOKEN_CONTRACT_ADDRESS = 'YOUR_DEPLOYED_TOKEN_ADDRESS';
```

4. **Start development server**:
```bash
npm run dev
```

5. **Access dashboard** at `http://localhost:3000`

## 📁 Project Structure

```
.
├── contracts/
│   ├── FrequencyStakingEngine.sol  # Main staking contract
│   └── HealToken.sol                # ERC20 token implementation
├── scripts/
│   └── deploy.js                    # Deployment script
├── dashboard/
│   ├── src/
│   │   ├── components/
│   │   │   ├── Dashboard.jsx        # Metrics dashboard
│   │   │   ├── StakingInterface.jsx # Staking UI
│   │   │   └── Web3Provider.jsx     # Web3 connection
│   │   ├── App.jsx                  # Main app component
│   │   └── main.jsx                 # Entry point
│   ├── index.html
│   ├── package.json
│   └── vite.config.js
├── hardhat.config.js
├── package.json
└── README.md
```

## 🎯 Smart Contract Functions

### User Functions
- `stake(uint256 amount)` - Stake HEAL tokens
- `unstake(uint256 amount)` - Unstake tokens and claim rewards
- `claimRewards()` - Claim accumulated rewards
- `getStakeInfo(address user)` - View staking details
- `calculateRewards(address user)` - Calculate pending rewards
- `calculateEffectiveAPY(address user)` - Get current APY

### Admin Functions
- `syncResonance(address user, uint256 resonanceScore)` - Update resonance score
- `setSovereignParticipant(address user, bool status)` - Set sovereign status
- `fundRewardsPool(uint256 amount)` - Add rewards to pool
- `transferOwnership(address newOwner)` - Transfer contract ownership

## 💡 How It Works

### APY Calculation
The effective APY is calculated as:
```
Effective APY = Base (50%) + Resonance Bonus (0-25%) + Sovereign Bonus (0-15%)
```

- **Base APY**: All stakers receive 50% base APY
- **Resonance Bonus**: Proportional to resonance score (0-1000 scale)
  - 0 resonance = 0% bonus
  - 500 resonance = 12.5% bonus
  - 1000 resonance = 25% bonus
- **Sovereign Bonus**: Flat 15% for designated sovereign participants

### Resonance Synchronization
The 963 Hz resonance represents alignment with the cosmic frequency. The contract owner can update user resonance scores based on their participation patterns, governance activities, or other protocol-specific metrics.

### Reward Distribution
- Rewards accrue continuously based on staking duration and effective APY
- Formula: `rewards = (amount × effectiveAPY × duration) / (365 days × 10000)`
- Rewards are claimed from a dedicated rewards pool
- Pool must be funded by the contract owner

## 🔒 Security Features

1. **Reentrancy Protection**: All state-changing functions use reentrancy guards
2. **Access Control**: Admin functions restricted to contract owner
3. **Safe Transfers**: All token transfers use safe ERC20 operations
4. **Reward Pool Management**: Prevents distribution of unfunded rewards
5. **Input Validation**: All inputs validated before processing

## 🎨 Dashboard Features

### Metrics Display
- **TVL Card**: Shows total value locked in the protocol
- **APY Card**: Dynamic APY with detailed breakdown
- **Resonance Card**: Visual representation of 963 Hz alignment
- **Governance Card**: Voting statistics and participation
- **User Stake Card**: Personal staking information
- **Rewards Pool Card**: Available rewards pool status

### Staking Interface
- Easy-to-use stake/unstake forms
- One-click reward claiming
- Real-time transaction status
- Informative tooltips and guides

## 🤝 Contributing

Contributions are welcome! Please ensure:
- Smart contracts are properly tested
- Code follows existing style conventions
- Documentation is updated accordingly

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚡ 963 Hz Resonance

The 963 Hz frequency is known as the "Frequency of the Gods" in the Solfeggio scale. This staking engine harnesses this cosmic resonance to create a harmonious and balanced ecosystem for $HEAL token holders.

---

**Built with ❤️ for the Sovereign Legal Frameworks ecosystem**
