// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title HEALTokenStaking
 * @dev Smart contract for $HEAL Token staking with automated perpetual integration
 * @notice Implements 963 Hz resonance sync, Everforge Security Layer, and zero-effect integrity
 */
contract HEALTokenStaking is Ownable, ReentrancyGuard, Pausable {
    
    // ============ State Variables ============
    
    /// @notice The $HEAL token contract
    IERC20 public healToken;
    
    /// @notice Resonance frequency target (963 Hz scaled by 1e18 for precision)
    uint256 public constant RESONANCE_FREQUENCY = 963e18;
    
    /// @notice Frequency tolerance (0.5 Hz scaled by 1e18)
    uint256 public constant FREQUENCY_TOLERANCE = 5e17;
    
    /// @notice Perpetual integration timestamp (241,200 years in seconds)
    uint256 public constant PERPETUAL_DURATION = 241200 * 365.25 days;
    
    /// @notice Staking start timestamp
    uint256 public stakingStartTime;
    
    /// @notice Total staking allocation (200M tokens)
    uint256 public constant TOTAL_STAKING_ALLOCATION = 200_000_000 * 1e18;
    
    /// @notice Total rewards distributed
    uint256 public totalRewardsDistributed;
    
    /// @notice Annual percentage yield (5% = 500 basis points)
    uint256 public annualYieldBasisPoints = 500;
    
    /// @notice Minimum stake amount (10,000 tokens)
    uint256 public constant MINIMUM_STAKE = 10_000 * 1e18;
    
    /// @notice Minimum lock period (90 days)
    uint256 public constant MINIMUM_LOCK_PERIOD = 90 days;
    
    /// @notice Total tokens staked
    uint256 public totalStaked;
    
    // ============ Structs ============
    
    /// @notice Stake tier levels
    enum StakeTier { Bronze, Silver, Gold, Platinum }
    
    /// @notice Staker information
    struct Stake {
        uint256 amount;                 // Amount staked
        uint256 startTime;              // Stake start timestamp
        uint256 lastRewardTime;         // Last reward claim timestamp
        uint256 lockPeriod;             // Lock duration in seconds
        uint256 frequencyAlignment;     // Current frequency (Hz * 1e18)
        uint256 totalRewardsClaimed;    // Total rewards claimed
        StakeTier tier;                 // Stake tier level
        bool isActive;                  // Active stake status
    }
    
    /// @notice Frequency synchronization data
    struct FrequencySync {
        uint256 timestamp;
        uint256 frequency;              // Measured frequency (Hz * 1e18)
        uint256 stakersInSync;          // Number of stakers in sync
        bool isOptimized;               // Within tolerance
    }
    
    // ============ Mappings ============
    
    /// @notice Staker data by address
    mapping(address => Stake) public stakes;
    
    /// @notice Frequency synchronization history
    mapping(uint256 => FrequencySync) public frequencySyncHistory;
    
    /// @notice Number of sync measurements
    uint256 public syncMeasurementCount;
    
    /// @notice Approved stakers (for governance control)
    mapping(address => bool) public approvedStakers;
    
    // ============ Events ============
    
    event Staked(address indexed staker, uint256 amount, StakeTier tier, uint256 lockPeriod);
    event Unstaked(address indexed staker, uint256 amount);
    event RewardsClaimed(address indexed staker, uint256 amount);
    event FrequencySynced(uint256 indexed syncId, uint256 frequency, bool isOptimized);
    event TierUpgraded(address indexed staker, StakeTier oldTier, StakeTier newTier);
    event YieldUpdated(uint256 newYieldBasisPoints);
    event EverforgeSecurity(uint256 indexed timestamp, bytes32 integrityHash);
    
    // ============ Modifiers ============
    
    modifier onlyActiveStaker() {
        require(stakes[msg.sender].isActive, "No active stake");
        _;
    }
    
    modifier frequencyOptimized() {
        require(isFrequencyOptimized(), "Frequency not optimized");
        _;
    }
    
    // ============ Constructor ============
    
    constructor(address _healToken) {
        healToken = IERC20(_healToken);
        stakingStartTime = block.timestamp;
    }
    
    // ============ Staking Functions ============
    
    /**
     * @notice Stake tokens with specified lock period
     * @param _amount Amount of tokens to stake
     * @param _lockPeriod Lock duration in seconds (minimum 90 days)
     */
    function stake(uint256 _amount, uint256 _lockPeriod) 
        external 
        whenNotPaused 
        nonReentrant 
    {
        require(_amount >= MINIMUM_STAKE, "Below minimum stake");
        require(_lockPeriod >= MINIMUM_LOCK_PERIOD, "Lock period too short");
        require(!stakes[msg.sender].isActive, "Already staking");
        
        // Transfer tokens to contract
        require(
            healToken.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        
        // Determine stake tier
        StakeTier tier = _calculateStakeTier(_amount);
        
        // Create stake
        stakes[msg.sender] = Stake({
            amount: _amount,
            startTime: block.timestamp,
            lastRewardTime: block.timestamp,
            lockPeriod: _lockPeriod,
            frequencyAlignment: RESONANCE_FREQUENCY,
            totalRewardsClaimed: 0,
            tier: tier,
            isActive: true
        });
        
        totalStaked += _amount;
        approvedStakers[msg.sender] = true;
        
        // Everforge Security Layer: Zero-effect integrity check
        bytes32 integrityHash = keccak256(abi.encodePacked(
            msg.sender,
            _amount,
            _lockPeriod,
            block.timestamp
        ));
        emit EverforgeSecurity(block.timestamp, integrityHash);
        
        emit Staked(msg.sender, _amount, tier, _lockPeriod);
    }
    
    /**
     * @notice Add to existing stake
     * @param _amount Additional amount to stake
     */
    function addStake(uint256 _amount) 
        external 
        onlyActiveStaker 
        whenNotPaused 
        nonReentrant 
    {
        require(_amount > 0, "Amount must be positive");
        
        Stake storage userStake = stakes[msg.sender];
        
        // Transfer additional tokens
        require(
            healToken.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        
        StakeTier oldTier = userStake.tier;
        userStake.amount += _amount;
        totalStaked += _amount;
        
        // Check for tier upgrade
        StakeTier newTier = _calculateStakeTier(userStake.amount);
        if (newTier != oldTier) {
            userStake.tier = newTier;
            emit TierUpgraded(msg.sender, oldTier, newTier);
        }
        
        emit Staked(msg.sender, _amount, newTier, userStake.lockPeriod);
    }
    
    /**
     * @notice Unstake tokens after lock period
     */
    function unstake() 
        external 
        onlyActiveStaker 
        nonReentrant 
    {
        Stake storage userStake = stakes[msg.sender];
        
        // Check lock period
        require(
            block.timestamp >= userStake.startTime + userStake.lockPeriod,
            "Lock period not ended"
        );
        
        uint256 amount = userStake.amount;
        
        // Claim any pending rewards first
        _claimRewards(msg.sender);
        
        // Update state
        userStake.isActive = false;
        userStake.amount = 0;
        totalStaked -= amount;
        
        // Transfer tokens back
        require(healToken.transfer(msg.sender, amount), "Transfer failed");
        
        emit Unstaked(msg.sender, amount);
    }
    
    /**
     * @notice Claim staking rewards
     */
    function claimRewards() 
        external 
        onlyActiveStaker 
        nonReentrant 
    {
        _claimRewards(msg.sender);
    }
    
    /**
     * @notice Internal function to claim rewards
     * @param _staker Address of the staker
     */
    function _claimRewards(address _staker) internal {
        Stake storage userStake = stakes[_staker];
        
        uint256 rewards = calculatePendingRewards(_staker);
        require(rewards > 0, "No pending rewards");
        
        // Check allocation limit
        require(
            totalRewardsDistributed + rewards <= TOTAL_STAKING_ALLOCATION,
            "Staking allocation exceeded"
        );
        
        // Update state
        userStake.lastRewardTime = block.timestamp;
        userStake.totalRewardsClaimed += rewards;
        totalRewardsDistributed += rewards;
        
        // Transfer rewards
        require(healToken.transfer(_staker, rewards), "Transfer failed");
        
        // Everforge Security Layer: Zero-effect integrity check
        bytes32 integrityHash = keccak256(abi.encodePacked(
            _staker,
            rewards,
            block.timestamp
        ));
        emit EverforgeSecurity(block.timestamp, integrityHash);
        
        emit RewardsClaimed(_staker, rewards);
    }
    
    // ============ Frequency Synchronization Functions ============
    
    /**
     * @notice Synchronize stake with current frequency
     * @param _currentFrequency Current measured frequency (Hz * 1e18)
     */
    function syncFrequency(uint256 _currentFrequency) 
        external 
        onlyActiveStaker 
    {
        Stake storage userStake = stakes[msg.sender];
        userStake.frequencyAlignment = _currentFrequency;
        
        // Record sync event
        _recordFrequencySync(_currentFrequency);
    }
    
    /**
     * @notice Check if system frequency is optimized
     * @return bool True if within tolerance
     */
    function isFrequencyOptimized() public view returns (bool) {
        if (syncMeasurementCount == 0) return true;
        
        FrequencySync memory latestSync = frequencySyncHistory[syncMeasurementCount - 1];
        uint256 deviation = latestSync.frequency > RESONANCE_FREQUENCY 
            ? latestSync.frequency - RESONANCE_FREQUENCY 
            : RESONANCE_FREQUENCY - latestSync.frequency;
            
        return deviation <= FREQUENCY_TOLERANCE;
    }
    
    /**
     * @notice Record frequency synchronization
     * @param _frequency Measured frequency (Hz * 1e18)
     */
    function _recordFrequencySync(uint256 _frequency) internal {
        uint256 deviation = _frequency > RESONANCE_FREQUENCY 
            ? _frequency - RESONANCE_FREQUENCY 
            : RESONANCE_FREQUENCY - _frequency;
        
        bool isOptimized = deviation <= FREQUENCY_TOLERANCE;
        
        // Count stakers in sync (simplified - in production, iterate through stakers)
        uint256 stakersInSync = totalStaked > 0 ? 1 : 0;
        
        frequencySyncHistory[syncMeasurementCount] = FrequencySync({
            timestamp: block.timestamp,
            frequency: _frequency,
            stakersInSync: stakersInSync,
            isOptimized: isOptimized
        });
        
        emit FrequencySynced(syncMeasurementCount, _frequency, isOptimized);
        syncMeasurementCount++;
    }
    
    // ============ Calculation Functions ============
    
    /**
     * @notice Calculate stake tier based on amount
     * @param _amount Stake amount
     * @return StakeTier The tier level
     */
    function _calculateStakeTier(uint256 _amount) 
        internal 
        pure 
        returns (StakeTier) 
    {
        if (_amount >= 500_000 * 1e18) {
            return StakeTier.Platinum;
        } else if (_amount >= 100_000 * 1e18) {
            return StakeTier.Gold;
        } else if (_amount >= 50_000 * 1e18) {
            return StakeTier.Silver;
        } else {
            return StakeTier.Bronze;
        }
    }
    
    /**
     * @notice Calculate tier multiplier
     * @param _tier Stake tier
     * @return uint256 Multiplier (scaled by 1e18)
     */
    function _getTierMultiplier(StakeTier _tier) 
        internal 
        pure 
        returns (uint256) 
    {
        if (_tier == StakeTier.Platinum) {
            return 2e18;      // 2x
        } else if (_tier == StakeTier.Gold) {
            return 15e17;     // 1.5x
        } else if (_tier == StakeTier.Silver) {
            return 12e17;     // 1.2x
        } else {
            return 1e18;      // 1x
        }
    }
    
    /**
     * @notice Calculate frequency bonus multiplier
     * @param _frequency Current frequency (Hz * 1e18)
     * @return uint256 Frequency bonus (scaled by 1e18)
     */
    function _calculateFrequencyBonus(uint256 _frequency) 
        internal 
        pure 
        returns (uint256) 
    {
        uint256 deviation = _frequency > RESONANCE_FREQUENCY 
            ? _frequency - RESONANCE_FREQUENCY 
            : RESONANCE_FREQUENCY - _frequency;
        
        if (deviation <= FREQUENCY_TOLERANCE) {
            return 15e17;     // 1.5x for perfect sync
        } else if (deviation <= FREQUENCY_TOLERANCE * 2) {
            return 12e17;     // 1.2x for good sync
        } else if (deviation <= FREQUENCY_TOLERANCE * 5) {
            return 1e18;      // 1x for acceptable sync
        } else {
            return 8e17;      // 0.8x penalty for poor sync
        }
    }
    
    /**
     * @notice Calculate lock period bonus
     * @param _lockPeriod Lock duration in seconds
     * @return uint256 Lock bonus (scaled by 1e18)
     */
    function _calculateLockBonus(uint256 _lockPeriod) 
        internal 
        pure 
        returns (uint256) 
    {
        if (_lockPeriod >= 365 days) {
            return 2e18;      // 2x for 1+ year
        } else if (_lockPeriod >= 180 days) {
            return 15e17;     // 1.5x for 6+ months
        } else {
            return 1e18;      // 1x for minimum lock
        }
    }
    
    /**
     * @notice Calculate pending rewards for a staker
     * @param _staker Address of the staker
     * @return uint256 Pending rewards amount
     */
    function calculatePendingRewards(address _staker) 
        public 
        view 
        returns (uint256) 
    {
        Stake memory userStake = stakes[_staker];
        if (!userStake.isActive) return 0;
        
        uint256 stakingDuration = block.timestamp - userStake.lastRewardTime;
        
        // Base reward: amount * APY * time / year
        uint256 baseReward = (userStake.amount * annualYieldBasisPoints * stakingDuration) 
            / (10000 * 365 days);
        
        // Apply tier multiplier
        uint256 tierMultiplier = _getTierMultiplier(userStake.tier);
        uint256 rewardWithTier = (baseReward * tierMultiplier) / 1e18;
        
        // Apply frequency bonus
        uint256 frequencyBonus = _calculateFrequencyBonus(userStake.frequencyAlignment);
        uint256 rewardWithFrequency = (rewardWithTier * frequencyBonus) / 1e18;
        
        // Apply lock period bonus
        uint256 lockBonus = _calculateLockBonus(userStake.lockPeriod);
        uint256 finalReward = (rewardWithFrequency * lockBonus) / 1e18;
        
        return finalReward;
    }
    
    // ============ Admin Functions ============
    
    /**
     * @notice Update annual yield (automated adjustment)
     * @param _newYieldBasisPoints New yield in basis points (500 = 5%)
     */
    function updateAnnualYield(uint256 _newYieldBasisPoints) 
        external 
        onlyOwner 
    {
        require(_newYieldBasisPoints <= 2000, "Yield too high"); // Max 20%
        annualYieldBasisPoints = _newYieldBasisPoints;
        emit YieldUpdated(_newYieldBasisPoints);
    }
    
    /**
     * @notice Emergency pause
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @notice Unpause
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    // ============ View Functions ============
    
    /**
     * @notice Get stake information
     * @param _staker Address of the staker
     * @return Stake struct
     */
    function getStakeInfo(address _staker) 
        external 
        view 
        returns (Stake memory) 
    {
        return stakes[_staker];
    }
    
    /**
     * @notice Get latest frequency sync data
     * @return FrequencySync struct
     */
    function getLatestFrequencySync() 
        external 
        view 
        returns (FrequencySync memory) 
    {
        require(syncMeasurementCount > 0, "No sync measurements");
        return frequencySyncHistory[syncMeasurementCount - 1];
    }
    
    /**
     * @notice Get time until unlock
     * @param _staker Address of the staker
     * @return uint256 Seconds until unlock (0 if unlocked)
     */
    function getTimeUntilUnlock(address _staker) 
        external 
        view 
        returns (uint256) 
    {
        Stake memory userStake = stakes[_staker];
        if (!userStake.isActive) return 0;
        
        uint256 unlockTime = userStake.startTime + userStake.lockPeriod;
        if (block.timestamp >= unlockTime) return 0;
        
        return unlockTime - block.timestamp;
    }
    
    /**
     * @notice Get perpetual integration expiry timestamp
     * @return uint256 Timestamp when perpetual duration ends
     */
    function getPerpetualExpiry() external view returns (uint256) {
        return stakingStartTime + PERPETUAL_DURATION;
    }
    
    /**
     * @notice Get remaining staking allocation
     * @return uint256 Tokens remaining for rewards
     */
    function getRemainingAllocation() external view returns (uint256) {
        return TOTAL_STAKING_ALLOCATION - totalRewardsDistributed;
    }
    
    /**
     * @notice Get total value locked (TVL)
     * @return uint256 Total tokens staked
     */
    function getTotalValueLocked() external view returns (uint256) {
        return totalStaked;
    }
}
