import { useState } from 'react';
import './StakingInterface.css';

function StakingInterface({ account, contract, tokenContract, web3 }) {
  const [stakeAmount, setStakeAmount] = useState('');
  const [unstakeAmount, setUnstakeAmount] = useState('');
  const [isProcessing, setIsProcessing] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });

  const showMessage = (type, text) => {
    setMessage({ type, text });
    setTimeout(() => setMessage({ type: '', text: '' }), 5000);
  };

  const handleStake = async () => {
    if (!account || !contract || !tokenContract) {
      showMessage('error', 'Please connect your wallet first');
      return;
    }

    if (!stakeAmount || parseFloat(stakeAmount) <= 0) {
      showMessage('error', 'Please enter a valid amount');
      return;
    }

    setIsProcessing(true);
    try {
      const amount = web3.utils.toWei(stakeAmount, 'ether');
      
      // First approve the staking contract
      await tokenContract.methods
        .approve(contract._address, amount)
        .send({ from: account });

      // Then stake
      await contract.methods
        .stake(amount)
        .send({ from: account });

      showMessage('success', `Successfully staked ${stakeAmount} HEAL tokens!`);
      setStakeAmount('');
    } catch (error) {
      showMessage('error', error.message || 'Staking failed');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleUnstake = async () => {
    if (!account || !contract) {
      showMessage('error', 'Please connect your wallet first');
      return;
    }

    if (!unstakeAmount || parseFloat(unstakeAmount) <= 0) {
      showMessage('error', 'Please enter a valid amount');
      return;
    }

    setIsProcessing(true);
    try {
      const amount = web3.utils.toWei(unstakeAmount, 'ether');
      
      await contract.methods
        .unstake(amount)
        .send({ from: account });

      showMessage('success', `Successfully unstaked ${unstakeAmount} HEAL tokens!`);
      setUnstakeAmount('');
    } catch (error) {
      showMessage('error', error.message || 'Unstaking failed');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleClaimRewards = async () => {
    if (!account || !contract) {
      showMessage('error', 'Please connect your wallet first');
      return;
    }

    setIsProcessing(true);
    try {
      await contract.methods
        .claimRewards()
        .send({ from: account });

      showMessage('success', 'Rewards claimed successfully!');
    } catch (error) {
      showMessage('error', error.message || 'Claim failed');
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div className="staking-interface">
      <h2 className="interface-title">⚙️ Staking Interface</h2>

      {message.text && (
        <div className={`message ${message.type}`}>
          {message.text}
        </div>
      )}

      <div className="interface-grid">
        {/* Stake Card */}
        <div className="action-card">
          <div className="card-header">
            <h3>🔒 Stake HEAL</h3>
            <p>Earn rewards through 963 Hz resonance</p>
          </div>
          <div className="card-body">
            <div className="input-group">
              <input
                type="number"
                placeholder="0.00"
                value={stakeAmount}
                onChange={(e) => setStakeAmount(e.target.value)}
                disabled={isProcessing || !account}
              />
              <span className="input-label">HEAL</span>
            </div>
            <button
              className="action-button stake-button"
              onClick={handleStake}
              disabled={isProcessing || !account || !stakeAmount}
            >
              {isProcessing ? 'Processing...' : 'Stake Tokens'}
            </button>
            <div className="info-box">
              <p className="info-title">APY Breakdown:</p>
              <ul className="info-list">
                <li>Base APY: 50%</li>
                <li>Resonance Bonus: up to +25%</li>
                <li>Sovereign Bonus: +15%</li>
                <li className="info-highlight">Maximum APY: 90%</li>
              </ul>
            </div>
          </div>
        </div>

        {/* Unstake Card */}
        <div className="action-card">
          <div className="card-header">
            <h3>🔓 Unstake HEAL</h3>
            <p>Withdraw your staked tokens</p>
          </div>
          <div className="card-body">
            <div className="input-group">
              <input
                type="number"
                placeholder="0.00"
                value={unstakeAmount}
                onChange={(e) => setUnstakeAmount(e.target.value)}
                disabled={isProcessing || !account}
              />
              <span className="input-label">HEAL</span>
            </div>
            <button
              className="action-button unstake-button"
              onClick={handleUnstake}
              disabled={isProcessing || !account || !unstakeAmount}
            >
              {isProcessing ? 'Processing...' : 'Unstake Tokens'}
            </button>
            <div className="info-box">
              <p className="info-title">Note:</p>
              <p className="info-text">
                Unstaking will automatically claim your pending rewards.
                Make sure you have enough gas for the transaction.
              </p>
            </div>
          </div>
        </div>

        {/* Claim Rewards Card */}
        <div className="action-card full-width">
          <div className="card-header">
            <h3>💰 Claim Rewards</h3>
            <p>Collect your earned staking rewards</p>
          </div>
          <div className="card-body">
            <button
              className="action-button claim-button"
              onClick={handleClaimRewards}
              disabled={isProcessing || !account}
            >
              {isProcessing ? 'Processing...' : '💎 Claim Rewards'}
            </button>
            <div className="info-box">
              <p className="info-title">Reward Calculation:</p>
              <p className="info-text">
                Rewards are calculated based on your staked amount, time staked,
                and your 963 Hz resonance alignment. Higher resonance scores
                earn higher APY bonuses. Sovereign participants receive an
                additional 15% boost.
              </p>
            </div>
          </div>
        </div>
      </div>

      <div className="frequency-info">
        <h3>🌊 About 963 Hz Resonance</h3>
        <p>
          The 963 Hz frequency is known as the "Frequency of the Gods" and represents
          the highest frequency in the Solfeggio scale. Our staking engine aligns
          your participation with this cosmic frequency to maximize rewards and
          ensure harmonic balance in the ecosystem.
        </p>
        <div className="frequency-benefits">
          <div className="benefit-item">
            <span className="benefit-icon">✨</span>
            <span>Higher resonance = Higher APY</span>
          </div>
          <div className="benefit-item">
            <span className="benefit-icon">🎯</span>
            <span>Automated frequency synchronization</span>
          </div>
          <div className="benefit-item">
            <span className="benefit-icon">🛡️</span>
            <span>Protected against exploits</span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default StakingInterface;
