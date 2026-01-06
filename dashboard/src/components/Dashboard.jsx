import { useState, useEffect } from 'react';
import './Dashboard.css';

function Dashboard({ account, contract, web3 }) {
  const [stats, setStats] = useState({
    totalStaked: '0',
    totalRewardsDistributed: '0',
    rewardsPool: '0',
    userStake: '0',
    userResonance: 0,
    userAPY: 0,
    pendingRewards: '0',
    isSovereignParticipant: false
  });

  const [governanceData, setGovernanceData] = useState({
    totalVotes: 1247,
    activeProposals: 3,
    participationRate: 68.5
  });

  useEffect(() => {
    if (account && contract) {
      loadData();
      const interval = setInterval(loadData, 10000); // Update every 10 seconds
      return () => clearInterval(interval);
    } else {
      // Set demo data when not connected
      setStats({
        totalStaked: '1250000',
        totalRewardsDistributed: '425000',
        rewardsPool: '500000',
        userStake: '0',
        userResonance: 0,
        userAPY: 0,
        pendingRewards: '0',
        isSovereignParticipant: false
      });
    }
  }, [account, contract]);

  const loadData = async () => {
    try {
      // Load contract stats
      const contractStats = await contract.methods.getContractStats().call();
      
      // Load user stake info
      const stakeInfo = await contract.methods.getStakeInfo(account).call();

      setStats({
        totalStaked: web3.utils.fromWei(contractStats._totalStaked, 'ether'),
        totalRewardsDistributed: web3.utils.fromWei(contractStats._totalRewardsDistributed, 'ether'),
        rewardsPool: web3.utils.fromWei(contractStats._rewardsPool, 'ether'),
        userStake: web3.utils.fromWei(stakeInfo.amount, 'ether'),
        userResonance: Number(stakeInfo.resonanceScore) / 10, // Convert to percentage
        userAPY: Number(stakeInfo.effectiveAPY) / 100, // Convert from basis points
        pendingRewards: web3.utils.fromWei(stakeInfo.pendingRewards, 'ether'),
        isSovereignParticipant: stakeInfo.isSovereignParticipant
      });
    } catch (error) {
      console.error('Error loading data:', error);
    }
  };

  const formatNumber = (num) => {
    const number = parseFloat(num);
    if (number >= 1000000) {
      return (number / 1000000).toFixed(2) + 'M';
    } else if (number >= 1000) {
      return (number / 1000).toFixed(2) + 'K';
    }
    return number.toFixed(2);
  };

  return (
    <div className="dashboard">
      <h2 className="dashboard-title">📊 Dashboard Metrics</h2>
      
      <div className="metrics-grid">
        {/* TVL Card */}
        <div className="metric-card tvl-card">
          <div className="metric-icon">💰</div>
          <div className="metric-content">
            <h3>Total Value Locked</h3>
            <p className="metric-value">{formatNumber(stats.totalStaked)} HEAL</p>
            <p className="metric-subtitle">~${formatNumber(parseFloat(stats.totalStaked) * 1.5)} USD</p>
          </div>
        </div>

        {/* APY Card */}
        <div className="metric-card apy-card">
          <div className="metric-icon">📈</div>
          <div className="metric-content">
            <h3>Current APY</h3>
            <p className="metric-value">{stats.userAPY.toFixed(1)}%</p>
            <div className="apy-breakdown">
              <span className="apy-item">Base: 50%</span>
              <span className="apy-item">Resonance: +{(stats.userResonance / 4).toFixed(1)}%</span>
              {stats.isSovereignParticipant && (
                <span className="apy-item sovereign">Sovereign: +15%</span>
              )}
            </div>
          </div>
        </div>

        {/* Resonance Card */}
        <div className="metric-card resonance-card">
          <div className="metric-icon">⚡</div>
          <div className="metric-content">
            <h3>963 Hz Resonance</h3>
            <div className="resonance-bar">
              <div 
                className="resonance-fill" 
                style={{ width: `${stats.userResonance}%` }}
              ></div>
            </div>
            <p className="metric-value">{stats.userResonance.toFixed(1)}%</p>
            <p className="metric-subtitle">Sync Status: {stats.userResonance >= 70 ? 'High' : stats.userResonance >= 40 ? 'Medium' : 'Low'}</p>
          </div>
        </div>

        {/* Governance Card */}
        <div className="metric-card governance-card">
          <div className="metric-icon">🗳️</div>
          <div className="metric-content">
            <h3>Governance Votes</h3>
            <p className="metric-value">{governanceData.totalVotes}</p>
            <div className="governance-stats">
              <span>Active Proposals: {governanceData.activeProposals}</span>
              <span>Participation: {governanceData.participationRate}%</span>
            </div>
          </div>
        </div>

        {/* User Stake Card */}
        <div className="metric-card stake-card">
          <div className="metric-icon">💎</div>
          <div className="metric-content">
            <h3>Your Stake</h3>
            <p className="metric-value">{formatNumber(stats.userStake)} HEAL</p>
            <p className="metric-subtitle">Pending Rewards: {parseFloat(stats.pendingRewards).toFixed(4)} HEAL</p>
          </div>
        </div>

        {/* Rewards Pool Card */}
        <div className="metric-card pool-card">
          <div className="metric-icon">🏦</div>
          <div className="metric-content">
            <h3>Rewards Pool</h3>
            <p className="metric-value">{formatNumber(stats.rewardsPool)} HEAL</p>
            <p className="metric-subtitle">Distributed: {formatNumber(stats.totalRewardsDistributed)} HEAL</p>
          </div>
        </div>
      </div>

      {stats.isSovereignParticipant && (
        <div className="sovereign-badge">
          <span className="badge-icon">👑</span>
          <span>Sovereign Participant - +15% APY Bonus</span>
        </div>
      )}
    </div>
  );
}

export default Dashboard;
