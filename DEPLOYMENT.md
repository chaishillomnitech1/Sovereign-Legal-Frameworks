# Deployment Guide

## Prerequisites

1. **Node.js and npm**
   ```bash
   node --version  # Should be v16+
   npm --version
   ```

2. **Hardhat**
   ```bash
   npm install --save-dev hardhat
   ```

3. **Wallet with funds**
   - For testnet: Get test ETH from faucets
   - For mainnet: Ensure sufficient ETH for gas

## Step 1: Environment Setup

1. **Create .env file** in the project root:
   ```bash
   # Network RPC URLs
   SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
   MAINNET_RPC_URL=https://mainnet.infura.io/v3/YOUR_INFURA_KEY
   
   # Private key (NEVER commit this!)
   PRIVATE_KEY=your_private_key_here
   
   # Etherscan API key (for verification)
   ETHERSCAN_API_KEY=your_etherscan_api_key
   ```

2. **Update hardhat.config.js** with your networks:
   ```javascript
   networks: {
     sepolia: {
       url: process.env.SEPOLIA_RPC_URL,
       accounts: [process.env.PRIVATE_KEY]
     },
     mainnet: {
       url: process.env.MAINNET_RPC_URL,
       accounts: [process.env.PRIVATE_KEY]
     }
   }
   ```

## Step 2: Install Dependencies

```bash
# Install contract dependencies
npm install

# Install dashboard dependencies
cd dashboard
npm install
cd ..
```

## Step 3: Compile Contracts

```bash
npm run compile
```

Expected output:
```
Compiled 2 Solidity files successfully
```

## Step 4: Deploy to Local Network (Testing)

1. **Start local Hardhat network**:
   ```bash
   npx hardhat node
   ```
   
   This will:
   - Start a local Ethereum network on http://127.0.0.1:8545
   - Create test accounts with 10,000 ETH each
   - Display account addresses and private keys

2. **Deploy contracts** (in a new terminal):
   ```bash
   npm run deploy:local
   ```

3. **Note the contract addresses** from the output:
   ```
   HEAL Token deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
   FrequencyStakingEngine deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
   ```

## Step 5: Configure Dashboard

1. **Update contract addresses** in `dashboard/src/components/Web3Provider.jsx`:
   ```javascript
   const STAKING_CONTRACT_ADDRESS = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512';
   const TOKEN_CONTRACT_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
   ```

2. **Start the dashboard**:
   ```bash
   cd dashboard
   npm run dev
   ```

3. **Configure MetaMask**:
   - Add local network: http://127.0.0.1:8545
   - Chain ID: 31337
   - Import one of the test accounts using the private key from Hardhat node output

4. **Access dashboard** at http://localhost:3000

## Step 6: Deploy to Testnet (Sepolia)

1. **Get test ETH** from a Sepolia faucet:
   - https://sepoliafaucet.com/
   - https://faucet.sepolia.dev/

2. **Deploy to Sepolia**:
   ```bash
   npx hardhat run scripts/deploy.js --network sepolia
   ```

3. **Verify contracts** on Etherscan:
   ```bash
   npx hardhat verify --network sepolia HEAL_TOKEN_ADDRESS "1000000000"
   npx hardhat verify --network sepolia STAKING_ENGINE_ADDRESS "HEAL_TOKEN_ADDRESS"
   ```

4. **Update dashboard configuration** with Sepolia addresses

## Step 7: Deploy to Mainnet (Production)

⚠️ **WARNING**: Deploying to mainnet requires real ETH. Double-check everything!

1. **Final security audit**:
   - Review all contract code
   - Run comprehensive tests
   - Consider professional audit

2. **Deploy to mainnet**:
   ```bash
   npx hardhat run scripts/deploy.js --network mainnet
   ```

3. **Verify contracts**:
   ```bash
   npx hardhat verify --network mainnet HEAL_TOKEN_ADDRESS "1000000000"
   npx hardhat verify --network mainnet STAKING_ENGINE_ADDRESS "HEAL_TOKEN_ADDRESS"
   ```

4. **Update production dashboard**:
   - Set mainnet contract addresses
   - Build for production: `npm run build`
   - Deploy to hosting (Vercel, Netlify, etc.)

## Post-Deployment Tasks

### 1. Fund Rewards Pool
```javascript
// Using Hardhat console
npx hardhat console --network <network>

const HealToken = await ethers.getContractAt("HealToken", "TOKEN_ADDRESS");
const StakingEngine = await ethers.getContractAt("FrequencyStakingEngine", "STAKING_ADDRESS");

// Approve and fund with 100M tokens
const amount = ethers.utils.parseEther("100000000");
await HealToken.approve(StakingEngine.address, amount);
await StakingEngine.fundRewardsPool(amount);
```

### 2. Set Initial Sovereign Participants
```javascript
await StakingEngine.setSovereignParticipant("USER_ADDRESS", true);
```

### 3. Configure Resonance Scores
```javascript
// Set resonance score (0-1000)
await StakingEngine.syncResonance("USER_ADDRESS", 750); // 75%
```

### 4. Transfer Ownership (if needed)
```javascript
await StakingEngine.transferOwnership("NEW_OWNER_ADDRESS");
```

## Monitoring & Maintenance

### Check Contract Stats
```javascript
const stats = await StakingEngine.getContractStats();
console.log("Total Staked:", ethers.utils.formatEther(stats._totalStaked));
console.log("Rewards Pool:", ethers.utils.formatEther(stats._rewardsPool));
console.log("Total Distributed:", ethers.utils.formatEther(stats._totalRewardsDistributed));
```

### Monitor Events
Set up event listeners for:
- Staked events
- Unstaked events
- RewardsClaimed events
- ResonanceSynced events

### Regular Tasks
1. **Fund rewards pool** when running low
2. **Update resonance scores** based on participation
3. **Monitor gas prices** for cost optimization
4. **Track TVL and APY metrics**
5. **Review security alerts**

## Troubleshooting

### Contract deployment fails
- Check account has sufficient ETH for gas
- Verify network RPC URL is correct
- Ensure private key is valid

### Dashboard can't connect to contracts
- Verify contract addresses are correct
- Check network ID matches (31337 for local, 1 for mainnet)
- Ensure MetaMask is on correct network
- Clear browser cache and reload

### Transactions fail
- Check gas limit is sufficient
- Verify contract has enough rewards pool
- Ensure user has approved tokens
- Check user has sufficient token balance

## Security Checklist

- [ ] Private keys stored securely (never in code)
- [ ] .env file added to .gitignore
- [ ] Contracts audited (for mainnet)
- [ ] Test deployment successful
- [ ] Access controls verified
- [ ] Reentrancy protection tested
- [ ] Rewards pool adequately funded
- [ ] Emergency procedures documented
- [ ] Ownership transfer plan ready

## Support

For issues or questions:
1. Check the README.md and ARCHITECTURE.md
2. Review Hardhat documentation
3. Check contract events for error details
4. Review transaction on block explorer

---

**Remember**: Always test thoroughly on testnet before mainnet deployment!
