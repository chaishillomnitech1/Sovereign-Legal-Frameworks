import { useState, useEffect } from 'react';
import Web3 from 'web3';
import './Web3Provider.css';

// Contract ABIs (simplified for demo)
const STAKING_CONTRACT_ABI = [
  {
    "inputs": [{"internalType": "uint256", "name": "amount", "type": "uint256"}],
    "name": "stake",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "uint256", "name": "amount", "type": "uint256"}],
    "name": "unstake",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "claimRewards",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "address", "name": "user", "type": "address"}],
    "name": "getStakeInfo",
    "outputs": [
      {"internalType": "uint256", "name": "amount", "type": "uint256"},
      {"internalType": "uint256", "name": "startTime", "type": "uint256"},
      {"internalType": "uint256", "name": "lastRewardClaim", "type": "uint256"},
      {"internalType": "uint256", "name": "resonanceScore", "type": "uint256"},
      {"internalType": "bool", "name": "isSovereignParticipant", "type": "bool"},
      {"internalType": "uint256", "name": "pendingRewards", "type": "uint256"},
      {"internalType": "uint256", "name": "effectiveAPY", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getContractStats",
    "outputs": [
      {"internalType": "uint256", "name": "_totalStaked", "type": "uint256"},
      {"internalType": "uint256", "name": "_totalRewardsDistributed", "type": "uint256"},
      {"internalType": "uint256", "name": "_rewardsPool", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
];

const TOKEN_ABI = [
  {
    "inputs": [{"internalType": "address", "name": "spender", "type": "address"}, {"internalType": "uint256", "name": "amount", "type": "uint256"}],
    "name": "approve",
    "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "address", "name": "account", "type": "address"}],
    "name": "balanceOf",
    "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
    "stateMutability": "view",
    "type": "function"
  }
];

function Web3Provider({ setAccount, setContract, setTokenContract, setWeb3 }) {
  const [isConnecting, setIsConnecting] = useState(false);
  const [error, setError] = useState('');
  const [connected, setConnected] = useState(false);
  const [connectedAccount, setConnectedAccount] = useState(null);

  // For demo purposes - these would be actual deployed contract addresses
  const STAKING_CONTRACT_ADDRESS = '0x0000000000000000000000000000000000000000';
  const TOKEN_CONTRACT_ADDRESS = '0x0000000000000000000000000000000000000000';

  const connectWallet = async () => {
    setIsConnecting(true);
    setError('');

    try {
      // Check if contract addresses are configured
      if (STAKING_CONTRACT_ADDRESS === '0x0000000000000000000000000000000000000000' ||
          TOKEN_CONTRACT_ADDRESS === '0x0000000000000000000000000000000000000000') {
        setError('Contract addresses not configured. Please deploy contracts and update Web3Provider.jsx');
        setIsConnecting(false);
        return;
      }

      if (typeof window.ethereum !== 'undefined') {
        const web3Instance = new Web3(window.ethereum);
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        
        const accounts = await web3Instance.eth.getAccounts();
        const account = accounts[0];

        // Initialize contracts (would use actual addresses in production)
        const stakingContract = new web3Instance.eth.Contract(
          STAKING_CONTRACT_ABI,
          STAKING_CONTRACT_ADDRESS
        );
        
        const tokenContract = new web3Instance.eth.Contract(
          TOKEN_ABI,
          TOKEN_CONTRACT_ADDRESS
        );

        setWeb3(web3Instance);
        setAccount(account);
        setConnectedAccount(account);
        setContract(stakingContract);
        setTokenContract(tokenContract);
        setConnected(true);

      } else {
        setError('Please install MetaMask to use this dApp');
      }
    } catch (err) {
      setError(err.message || 'Failed to connect wallet');
    } finally {
      setIsConnecting(false);
    }
  };

  return (
    <div className="web3-provider">
      <div className="wallet-section">
        {!connected ? (
          <button 
            className="connect-button"
            onClick={connectWallet}
            disabled={isConnecting}
          >
            {isConnecting ? 'Connecting...' : '🔗 Connect Wallet'}
          </button>
        ) : (
          <div className="connected-info">
            <span className="status-indicator"></span>
            <span className="account-address">
              {connectedAccount ? `${connectedAccount.slice(0, 6)}...${connectedAccount.slice(-4)}` : 'Connected'}
            </span>
          </div>
        )}
        {error && <div className="error-message">{error}</div>}
      </div>
    </div>
  );
}

export default Web3Provider;
