// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title FrequencyStakingEngine
 * @dev 963 Hz Frequency-Enforced Staking Engine for $HEAL token
 * Implements staking rewards with resonance synchronization
 * APY Structure: Base 50% + Resonance Bonus 25% + Sovereign Participation 15%
 */
contract FrequencyStakingEngine {
    // Token interface
    interface IERC20 {
        function transfer(address to, uint256 amount) external returns (bool);
        function transferFrom(address from, address to, uint256 amount) external returns (bool);
        function balanceOf(address account) external view returns (uint256);
    }

    // Staking information for each user
    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        uint256 lastRewardClaim;
        uint256 resonanceScore; // 0-1000 (represents 0-100% resonance)
        bool isSovereignParticipant;
    }

    // Constants for APY calculations (in basis points, 10000 = 100%)
    uint256 public constant BASE_APY = 5000; // 50%
    uint256 public constant RESONANCE_BONUS = 2500; // 25%
    uint256 public constant SOVEREIGN_BONUS = 1500; // 15%
    uint256 public constant MAX_APY = 9000; // 90% (50% + 25% + 15%)
    uint256 public constant RESONANCE_FREQUENCY = 963; // Hz
    uint256 public constant SECONDS_PER_YEAR = 365 days;

    // Contract state
    IERC20 public healToken;
    address public owner;
    uint256 public totalStaked;
    uint256 public totalRewardsDistributed;
    uint256 public rewardsPool;
    
    mapping(address => StakeInfo) public stakes;
    
    // Reentrancy guard
    bool private locked;

    // Events
    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    event Unstaked(address indexed user, uint256 amount, uint256 timestamp);
    event RewardsClaimed(address indexed user, uint256 amount, uint256 timestamp);
    event ResonanceSynced(address indexed user, uint256 resonanceScore, uint256 timestamp);
    event SovereignStatusUpdated(address indexed user, bool status);
    event RewardsPoolFunded(uint256 amount, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    constructor(address _healToken) {
        require(_healToken != address(0), "Invalid token address");
        healToken = IERC20(_healToken);
        owner = msg.sender;
    }

    /**
     * @dev Stake $HEAL tokens
     * @param amount Amount of tokens to stake
     */
    function stake(uint256 amount) external noReentrant {
        require(amount > 0, "Cannot stake 0");
        require(healToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        StakeInfo storage stakeInfo = stakes[msg.sender];
        
        // Claim pending rewards before updating stake
        if (stakeInfo.amount > 0) {
            _claimRewards(msg.sender);
        }

        stakeInfo.amount += amount;
        stakeInfo.startTime = block.timestamp;
        stakeInfo.lastRewardClaim = block.timestamp;
        
        // Initialize resonance score if new staker
        if (stakeInfo.resonanceScore == 0) {
            stakeInfo.resonanceScore = 500; // Start at 50% resonance
        }

        totalStaked += amount;

        emit Staked(msg.sender, amount, block.timestamp);
    }

    /**
     * @dev Unstake $HEAL tokens
     * @param amount Amount of tokens to unstake
     */
    function unstake(uint256 amount) external noReentrant {
        StakeInfo storage stakeInfo = stakes[msg.sender];
        require(stakeInfo.amount >= amount, "Insufficient stake");
        require(amount > 0, "Cannot unstake 0");

        // Claim pending rewards before unstaking
        _claimRewards(msg.sender);

        stakeInfo.amount -= amount;
        totalStaked -= amount;

        require(healToken.transfer(msg.sender, amount), "Transfer failed");

        emit Unstaked(msg.sender, amount, block.timestamp);
    }

    /**
     * @dev Claim accumulated staking rewards
     */
    function claimRewards() external noReentrant {
        _claimRewards(msg.sender);
    }

    /**
     * @dev Internal function to claim rewards
     */
    function _claimRewards(address user) private {
        StakeInfo storage stakeInfo = stakes[user];
        require(stakeInfo.amount > 0, "No active stake");

        uint256 rewards = calculateRewards(user);
        
        if (rewards > 0) {
            require(rewardsPool >= rewards, "Insufficient rewards pool");
            
            stakeInfo.lastRewardClaim = block.timestamp;
            rewardsPool -= rewards;
            totalRewardsDistributed += rewards;

            require(healToken.transfer(user, rewards), "Reward transfer failed");

            emit RewardsClaimed(user, rewards, block.timestamp);
        }
    }

    /**
     * @dev Sync resonance to 963 Hz frequency
     * @param user Address of the user
     * @param resonanceScore Score from 0-1000 representing resonance alignment
     */
    function syncResonance(address user, uint256 resonanceScore) external onlyOwner {
        require(resonanceScore <= 1000, "Invalid resonance score");
        require(stakes[user].amount > 0, "User has no stake");

        stakes[user].resonanceScore = resonanceScore;

        emit ResonanceSynced(user, resonanceScore, block.timestamp);
    }

    /**
     * @dev Set sovereign participant status
     * @param user Address of the user
     * @param status Whether user is a sovereign participant
     */
    function setSovereignParticipant(address user, bool status) external onlyOwner {
        stakes[user].isSovereignParticipant = status;

        emit SovereignStatusUpdated(user, status);
    }

    /**
     * @dev Calculate current rewards for a user
     * @param user Address of the user
     * @return rewards The amount of rewards earned
     */
    function calculateRewards(address user) public view returns (uint256) {
        StakeInfo memory stakeInfo = stakes[user];
        
        if (stakeInfo.amount == 0) {
            return 0;
        }

        uint256 stakingDuration = block.timestamp - stakeInfo.lastRewardClaim;
        uint256 effectiveAPY = calculateEffectiveAPY(user);

        // Calculate rewards: (amount * APY * duration) / (SECONDS_PER_YEAR * 10000)
        uint256 rewards = (stakeInfo.amount * effectiveAPY * stakingDuration) / (SECONDS_PER_YEAR * 10000);

        return rewards;
    }

    /**
     * @dev Calculate effective APY for a user based on bonuses
     * @param user Address of the user
     * @return effectiveAPY The effective APY in basis points
     */
    function calculateEffectiveAPY(address user) public view returns (uint256) {
        StakeInfo memory stakeInfo = stakes[user];
        
        uint256 apy = BASE_APY; // Start with 50% base APY

        // Add resonance bonus (0-25% based on resonance score)
        uint256 resonanceBonus = (RESONANCE_BONUS * stakeInfo.resonanceScore) / 1000;
        apy += resonanceBonus;

        // Add sovereign participation bonus (15% if participant)
        if (stakeInfo.isSovereignParticipant) {
            apy += SOVEREIGN_BONUS;
        }

        return apy;
    }

    /**
     * @dev Get staking information for a user
     * @param user Address of the user
     * @return amount Staked amount
     * @return startTime Staking start time
     * @return lastRewardClaim Last reward claim time
     * @return resonanceScore Current resonance score
     * @return isSovereignParticipant Sovereign participation status
     * @return pendingRewards Pending rewards
     * @return effectiveAPY Current effective APY
     */
    function getStakeInfo(address user) external view returns (
        uint256 amount,
        uint256 startTime,
        uint256 lastRewardClaim,
        uint256 resonanceScore,
        bool isSovereignParticipant,
        uint256 pendingRewards,
        uint256 effectiveAPY
    ) {
        StakeInfo memory stakeInfo = stakes[user];
        return (
            stakeInfo.amount,
            stakeInfo.startTime,
            stakeInfo.lastRewardClaim,
            stakeInfo.resonanceScore,
            stakeInfo.isSovereignParticipant,
            calculateRewards(user),
            calculateEffectiveAPY(user)
        );
    }

    /**
     * @dev Fund the rewards pool
     * @param amount Amount to add to rewards pool
     */
    function fundRewardsPool(uint256 amount) external onlyOwner {
        require(amount > 0, "Cannot fund 0");
        require(healToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        
        rewardsPool += amount;

        emit RewardsPoolFunded(amount, block.timestamp);
    }

    /**
     * @dev Get contract statistics
     * @return _totalStaked Total amount staked
     * @return _totalRewardsDistributed Total rewards distributed
     * @return _rewardsPool Current rewards pool
     */
    function getContractStats() external view returns (
        uint256 _totalStaked,
        uint256 _totalRewardsDistributed,
        uint256 _rewardsPool
    ) {
        return (totalStaked, totalRewardsDistributed, rewardsPool);
    }

    /**
     * @dev Transfer ownership
     * @param newOwner Address of the new owner
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
}
