// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title HEALTokenMining
 * @dev Smart contract for $HEAL Token mining with 963 Hz resonance frequency optimization
 * @notice Implements perpetual integration, Everforge Security Layer, and zero-effect integrity
 */
contract HEALTokenMining is Ownable, ReentrancyGuard, Pausable {
    
    // ============ State Variables ============
    
    /// @notice The $HEAL token contract
    ERC20 public healToken;
    
    /// @notice Resonance frequency target (963 Hz scaled by 1e18 for precision)
    uint256 public constant RESONANCE_FREQUENCY = 963e18;
    
    /// @notice Frequency tolerance (0.5 Hz scaled by 1e18)
    uint256 public constant FREQUENCY_TOLERANCE = 5e17; // 0.5 * 1e18
    
    /// @notice Perpetual integration timestamp (241,200 years in seconds)
    uint256 public constant PERPETUAL_DURATION = 241200 * 365.25 days;
    
    /// @notice Mining start timestamp
    uint256 public miningStartTime;
    
    /// @notice Total mining allocation (400M tokens)
    uint256 public constant TOTAL_MINING_ALLOCATION = 400_000_000 * 1e18;
    
    /// @notice Tokens mined so far
    uint256 public totalMined;
    
    /// @notice Base mining rate (tokens per second)
    uint256 public baseMiningRate;
    
    /// @notice Frequency optimization multiplier (scaled by 1e18)
    uint256 public frequencyMultiplier = 1e18;
    
    // ============ Structs ============
    
    /// @notice Miner information
    struct Miner {
        uint256 hashPower;              // Computational power contributed
        uint256 energyOptimization;     // Energy efficiency score (0-100)
        uint256 frequencyAlignment;     // Current frequency alignment (Hz * 1e18)
        uint256 totalMined;             // Total tokens mined
        uint256 lastMiningTime;         // Last mining timestamp
        uint256 pendingRewards;         // Unclaimed rewards
        bool isActive;                  // Active miner status
    }
    
    /// @notice Frequency measurement data
    struct FrequencyData {
        uint256 timestamp;
        uint256 frequency;              // Measured frequency (Hz * 1e18)
        uint256 harmonic;               // Harmonic index
        bool isOptimized;               // Within tolerance
    }
    
    // ============ Mappings ============
    
    /// @notice Miner data by address
    mapping(address => Miner) public miners;
    
    /// @notice Frequency history
    mapping(uint256 => FrequencyData) public frequencyHistory;
    
    /// @notice Number of frequency measurements
    uint256 public frequencyMeasurementCount;
    
    /// @notice Whitelist of approved miners
    mapping(address => bool) public approvedMiners;
    
    // ============ Events ============
    
    event MinerRegistered(address indexed miner, uint256 hashPower);
    event TokensMined(address indexed miner, uint256 amount, uint256 frequency);
    event FrequencyOptimized(uint256 indexed measurementId, uint256 frequency, bool isOptimized);
    event RewardsClaimed(address indexed miner, uint256 amount);
    event FrequencyMultiplierUpdated(uint256 newMultiplier);
    event EverforgeSecurity(uint256 indexed timestamp, bytes32 integrityHash);
    
    // ============ Modifiers ============
    
    modifier onlyApprovedMiner() {
        require(approvedMiners[msg.sender], "Not approved miner");
        _;
    }
    
    modifier frequencyOptimized() {
        require(isFrequencyOptimized(), "Frequency not optimized");
        _;
    }
    
    // ============ Constructor ============
    
    constructor(address _healToken) {
        healToken = ERC20(_healToken);
        miningStartTime = block.timestamp;
        
        // Calculate base mining rate to distribute over perpetual duration
        baseMiningRate = TOTAL_MINING_ALLOCATION / PERPETUAL_DURATION;
    }
    
    // ============ Mining Functions ============
    
    /**
     * @notice Register as a miner with initial hash power
     * @param _hashPower Initial computational power
     * @param _energyOptimization Initial energy efficiency score (0-100)
     */
    function registerMiner(uint256 _hashPower, uint256 _energyOptimization) 
        external 
        whenNotPaused 
    {
        require(_hashPower > 0, "Hash power must be positive");
        require(_energyOptimization <= 100, "Energy optimization out of range");
        require(!miners[msg.sender].isActive, "Already registered");
        
        miners[msg.sender] = Miner({
            hashPower: _hashPower,
            energyOptimization: _energyOptimization,
            frequencyAlignment: RESONANCE_FREQUENCY,
            totalMined: 0,
            lastMiningTime: block.timestamp,
            pendingRewards: 0,
            isActive: true
        });
        
        approvedMiners[msg.sender] = true;
        
        emit MinerRegistered(msg.sender, _hashPower);
    }
    
    /**
     * @notice Mine tokens with frequency optimization
     * @param _currentFrequency Current measured frequency (Hz * 1e18)
     */
    function mine(uint256 _currentFrequency) 
        external 
        onlyApprovedMiner 
        whenNotPaused 
        nonReentrant 
    {
        Miner storage miner = miners[msg.sender];
        require(miner.isActive, "Miner not active");
        
        // Update frequency alignment
        miner.frequencyAlignment = _currentFrequency;
        
        // Record frequency measurement
        _recordFrequencyMeasurement(_currentFrequency);
        
        // Calculate mining rewards
        uint256 timeSinceLastMining = block.timestamp - miner.lastMiningTime;
        uint256 baseReward = baseMiningRate * timeSinceLastMining;
        
        // Apply frequency optimization multiplier
        uint256 frequencyBonus = _calculateFrequencyBonus(_currentFrequency);
        
        // Apply energy optimization bonus
        uint256 energyBonus = (baseReward * miner.energyOptimization) / 100;
        
        // Apply hash power multiplier
        uint256 hashPowerMultiplier = (miner.hashPower * 1e18) / 1000; // Normalize to 1e18
        uint256 totalReward = ((baseReward + energyBonus) * hashPowerMultiplier) / 1e18;
        totalReward = (totalReward * frequencyBonus) / 1e18;
        
        // Check mining allocation limit
        require(totalMined + totalReward <= TOTAL_MINING_ALLOCATION, "Mining allocation exceeded");
        
        // Update state
        miner.pendingRewards += totalReward;
        miner.lastMiningTime = block.timestamp;
        miner.totalMined += totalReward;
        totalMined += totalReward;
        
        // Everforge Security Layer: Zero-effect integrity check
        bytes32 integrityHash = keccak256(abi.encodePacked(
            msg.sender,
            totalReward,
            _currentFrequency,
            block.timestamp
        ));
        emit EverforgeSecurity(block.timestamp, integrityHash);
        
        emit TokensMined(msg.sender, totalReward, _currentFrequency);
    }
    
    /**
     * @notice Claim pending mining rewards
     */
    function claimRewards() 
        external 
        onlyApprovedMiner 
        nonReentrant 
    {
        Miner storage miner = miners[msg.sender];
        uint256 rewards = miner.pendingRewards;
        require(rewards > 0, "No pending rewards");
        
        miner.pendingRewards = 0;
        
        // Transfer tokens
        require(healToken.transfer(msg.sender, rewards), "Transfer failed");
        
        emit RewardsClaimed(msg.sender, rewards);
    }
    
    // ============ Frequency Optimization Functions ============
    
    /**
     * @notice Check if system frequency is optimized
     * @return bool True if within tolerance
     */
    function isFrequencyOptimized() public view returns (bool) {
        if (frequencyMeasurementCount == 0) return true;
        
        FrequencyData memory latestData = frequencyHistory[frequencyMeasurementCount - 1];
        uint256 deviation = latestData.frequency > RESONANCE_FREQUENCY 
            ? latestData.frequency - RESONANCE_FREQUENCY 
            : RESONANCE_FREQUENCY - latestData.frequency;
            
        return deviation <= FREQUENCY_TOLERANCE;
    }
    
    /**
     * @notice Calculate frequency optimization bonus
     * @param _frequency Measured frequency (Hz * 1e18)
     * @return uint256 Frequency bonus multiplier (scaled by 1e18)
     */
    function _calculateFrequencyBonus(uint256 _frequency) 
        internal 
        view 
        returns (uint256) 
    {
        uint256 deviation = _frequency > RESONANCE_FREQUENCY 
            ? _frequency - RESONANCE_FREQUENCY 
            : RESONANCE_FREQUENCY - _frequency;
        
        if (deviation <= FREQUENCY_TOLERANCE) {
            // Perfect alignment: 2x multiplier
            return 2e18;
        } else if (deviation <= FREQUENCY_TOLERANCE * 2) {
            // Good alignment: 1.5x multiplier
            return 15e17;
        } else if (deviation <= FREQUENCY_TOLERANCE * 5) {
            // Acceptable alignment: 1.2x multiplier
            return 12e17;
        } else {
            // Poor alignment: 0.8x multiplier (penalty)
            return 8e17;
        }
    }
    
    /**
     * @notice Record frequency measurement
     * @param _frequency Measured frequency (Hz * 1e18)
     */
    function _recordFrequencyMeasurement(uint256 _frequency) internal {
        uint256 deviation = _frequency > RESONANCE_FREQUENCY 
            ? _frequency - RESONANCE_FREQUENCY 
            : RESONANCE_FREQUENCY - _frequency;
        
        bool isOptimized = deviation <= FREQUENCY_TOLERANCE;
        
        frequencyHistory[frequencyMeasurementCount] = FrequencyData({
            timestamp: block.timestamp,
            frequency: _frequency,
            harmonic: _frequency / RESONANCE_FREQUENCY, // Calculate harmonic index
            isOptimized: isOptimized
        });
        
        emit FrequencyOptimized(frequencyMeasurementCount, _frequency, isOptimized);
        frequencyMeasurementCount++;
    }
    
    // ============ Admin Functions ============
    
    /**
     * @notice Update frequency multiplier (automated dynamic adjustment)
     * @param _newMultiplier New multiplier value (scaled by 1e18)
     */
    function updateFrequencyMultiplier(uint256 _newMultiplier) 
        external 
        onlyOwner 
    {
        require(_newMultiplier > 0, "Multiplier must be positive");
        frequencyMultiplier = _newMultiplier;
        emit FrequencyMultiplierUpdated(_newMultiplier);
    }
    
    /**
     * @notice Approve a new miner
     * @param _miner Address of the miner
     */
    function approveMiner(address _miner) external onlyOwner {
        approvedMiners[_miner] = true;
    }
    
    /**
     * @notice Revoke miner approval
     * @param _miner Address of the miner
     */
    function revokeMiner(address _miner) external onlyOwner {
        approvedMiners[_miner] = false;
        miners[_miner].isActive = false;
    }
    
    /**
     * @notice Pause mining (emergency)
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @notice Unpause mining
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    // ============ View Functions ============
    
    /**
     * @notice Get miner information
     * @param _miner Address of the miner
     * @return Miner struct
     */
    function getMinerInfo(address _miner) 
        external 
        view 
        returns (Miner memory) 
    {
        return miners[_miner];
    }
    
    /**
     * @notice Get latest frequency data
     * @return FrequencyData struct
     */
    function getLatestFrequencyData() 
        external 
        view 
        returns (FrequencyData memory) 
    {
        require(frequencyMeasurementCount > 0, "No measurements");
        return frequencyHistory[frequencyMeasurementCount - 1];
    }
    
    /**
     * @notice Calculate current mining rewards for a miner
     * @param _miner Address of the miner
     * @return uint256 Estimated pending rewards
     */
    function calculatePendingRewards(address _miner) 
        external 
        view 
        returns (uint256) 
    {
        Miner memory miner = miners[_miner];
        if (!miner.isActive) return 0;
        
        uint256 timeSinceLastMining = block.timestamp - miner.lastMiningTime;
        uint256 baseReward = baseMiningRate * timeSinceLastMining;
        
        uint256 frequencyBonus = _calculateFrequencyBonus(miner.frequencyAlignment);
        uint256 energyBonus = (baseReward * miner.energyOptimization) / 100;
        
        uint256 hashPowerMultiplier = (miner.hashPower * 1e18) / 1000;
        uint256 totalReward = ((baseReward + energyBonus) * hashPowerMultiplier) / 1e18;
        totalReward = (totalReward * frequencyBonus) / 1e18;
        
        return miner.pendingRewards + totalReward;
    }
    
    /**
     * @notice Get perpetual integration expiry timestamp
     * @return uint256 Timestamp when perpetual duration ends
     */
    function getPerpetualExpiry() external view returns (uint256) {
        return miningStartTime + PERPETUAL_DURATION;
    }
    
    /**
     * @notice Get remaining mining allocation
     * @return uint256 Tokens remaining to be mined
     */
    function getRemainingAllocation() external view returns (uint256) {
        return TOTAL_MINING_ALLOCATION - totalMined;
    }
}
