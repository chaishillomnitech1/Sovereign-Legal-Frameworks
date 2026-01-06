import { useState, useEffect } from 'react';
import Dashboard from './components/Dashboard';
import StakingInterface from './components/StakingInterface';
import Web3Provider from './components/Web3Provider';
import './App.css';

function App() {
  const [account, setAccount] = useState(null);
  const [contract, setContract] = useState(null);
  const [tokenContract, setTokenContract] = useState(null);
  const [web3, setWeb3] = useState(null);

  return (
    <div className="App">
      <header className="app-header">
        <div className="header-content">
          <h1>⚡ 963 Hz Frequency Staking Engine</h1>
          <p className="subtitle">Sovereign Legal Frameworks • $HEAL Token</p>
        </div>
      </header>
      
      <Web3Provider
        setAccount={setAccount}
        setContract={setContract}
        setTokenContract={setTokenContract}
        setWeb3={setWeb3}
      />

      <main className="main-content">
        <Dashboard 
          account={account}
          contract={contract}
          web3={web3}
        />
        
        <StakingInterface
          account={account}
          contract={contract}
          tokenContract={tokenContract}
          web3={web3}
        />
      </main>

      <footer className="app-footer">
        <p>Powered by 963 Hz Resonance Depth (ζ) Model</p>
      </footer>
    </div>
  );
}

export default App;
