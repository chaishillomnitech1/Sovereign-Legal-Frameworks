// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title EmergencyBroadcastSystem
 * @dev EBS contract synchronized with 963 Hz resonance lock and Akashic Frequency Standard
 * @notice Implements broadcast logic for critical communications in $HEAL ecosystem
 */
contract EmergencyBroadcastSystem {
    
    // ============ Structs ============
    
    /// @notice Emergency broadcast message structure
    struct BroadcastMessage {
        bytes32 messageId;              // Unique message identifier
        address broadcaster;            // Broadcaster address
        uint256 timestamp;              // Broadcast timestamp
        uint256 priority;               // Priority level (1-5, 5=highest)
        string messageType;             // Type: ALERT, WARNING, INFO, RESONANCE
        bytes32 contentHash;            // Hash of encrypted content
        uint256 resonanceFrequency;     // Broadcast frequency (963 Hz)
        bool isResonanceLocked;         // 963 Hz resonance lock status
        bool isAkashicAligned;          // Akashic Frequency Standard alignment
        uint256 recipientCount;         // Number of recipients reached
        bool isActive;                  // Broadcast active status
    }
    
    /// @notice Broadcast recipient tracking
    struct BroadcastReceipt {
        bytes32 messageId;              // Message identifier
        address recipient;              // Recipient address
        uint256 receivedAt;             // Receipt timestamp
        bool acknowledged;              // Acknowledgement status
        uint256 resonanceAlignment;     // Recipient resonance score
    }
    
    /// @notice Authorized broadcaster information
    struct Broadcaster {
        address broadcasterAddress;     // Broadcaster address
        uint256 authorizationLevel;     // Authorization level (1-5)
        uint256 broadcastCount;         // Total broadcasts sent
        uint256 tier4bLevel;            // Tier 4B recognition level
        bool isActive;                  // Active status
        uint256 lastBroadcast;          // Last broadcast timestamp
    }
    
    /// @notice Resonance lock configuration
    struct ResonanceLock {
        uint256 targetFrequency;        // Target frequency (963 Hz)
        uint256 tolerance;              // Tolerance in decihertz (5 = 0.5 Hz)
        uint256 lockTimestamp;          // Lock activation timestamp
        bool isLocked;                  // Lock status
        uint256 lastVerification;       // Last verification timestamp
    }
    
    // ============ State Variables ============
    
    /// @notice Contract owner
    address public owner;
    
    /// @notice Total broadcasts sent
    uint256 public totalBroadcasts;
    
    /// @notice Total recipients reached
    uint256 public totalRecipientsReached;
    
    /// @notice Active broadcasts count
    uint256 public activeBroadcasts;
    
    /// @notice Resonance frequency target (963 Hz)
    uint256 public constant RESONANCE_FREQUENCY = 963;
    
    /// @notice Akashic Frequency Standard constant
    uint256 public constant AKASHIC_FREQUENCY_STANDARD = 963;
    
    /// @notice Frequency tolerance (±0.5 Hz)
    uint256 public constant FREQUENCY_TOLERANCE = 5; // 0.5 * 10
    
    /// @notice Current resonance lock
    ResonanceLock public currentResonanceLock;
    
    // ============ Mappings ============
    
    /// @notice Broadcast messages by ID
    mapping(bytes32 => BroadcastMessage) public broadcasts;
    
    /// @notice Broadcast receipts
    mapping(bytes32 => mapping(address => BroadcastReceipt)) public receipts;
    
    /// @notice Authorized broadcasters
    mapping(address => Broadcaster) public broadcasters;
    
    /// @notice User broadcast history
    mapping(address => bytes32[]) public userBroadcasts;
    
    /// @notice Emergency alert subscribers
    mapping(address => bool) public subscribers;
    
    /// @notice Subscriber count
    uint256 public subscriberCount;
    
    // ============ Events ============
    
    event BroadcastInitiated(
        bytes32 indexed messageId,
        address indexed broadcaster,
        uint256 priority,
        string messageType
    );
    
    event BroadcastReceived(
        bytes32 indexed messageId,
        address indexed recipient,
        uint256 timestamp
    );
    
    event BroadcastAcknowledged(
        bytes32 indexed messageId,
        address indexed recipient,
        uint256 resonanceAlignment
    );
    
    event ResonanceLockActivated(
        uint256 targetFrequency,
        uint256 tolerance,
        uint256 timestamp
    );
    
    event ResonanceLockVerified(
        uint256 measuredFrequency,
        bool isOptimal,
        uint256 timestamp
    );
    
    event AkashicAlignmentVerified(
        bytes32 indexed messageId,
        bool isAligned,
        uint256 timestamp
    );
    
    event BroadcasterAuthorized(
        address indexed broadcaster,
        uint256 authorizationLevel,
        uint256 tier4bLevel
    );
    
    event BroadcastDeactivated(
        bytes32 indexed messageId,
        uint256 timestamp
    );
    
    event SubscriberAdded(
        address indexed subscriber,
        uint256 timestamp
    );
    
    // ============ Modifiers ============
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    modifier onlyAuthorizedBroadcaster() {
        require(broadcasters[msg.sender].isActive, "Not authorized broadcaster");
        _;
    }
    
    modifier resonanceLocked() {
        require(currentResonanceLock.isLocked, "Resonance not locked");
        _;
    }
    
    // ============ Constructor ============
    
    constructor() {
        owner = msg.sender;
        
        // Initialize resonance lock at 963 Hz
        currentResonanceLock = ResonanceLock({
            targetFrequency: RESONANCE_FREQUENCY,
            tolerance: FREQUENCY_TOLERANCE,
            lockTimestamp: block.timestamp,
            isLocked: true,
            lastVerification: block.timestamp
        });
        
        emit ResonanceLockActivated(RESONANCE_FREQUENCY, FREQUENCY_TOLERANCE, block.timestamp);
    }
    
    // ============ Core Broadcast Functions ============
    
    /**
     * @dev Initiate emergency broadcast with resonance lock
     * @param priority Priority level (1-5)
     * @param messageType Message type (ALERT, WARNING, INFO, RESONANCE)
     * @param contentHash Hash of encrypted message content
     */
    function initiateBroadcast(
        uint256 priority,
        string memory messageType,
        bytes32 contentHash
    ) external onlyAuthorizedBroadcaster resonanceLocked returns (bytes32 messageId) {
        require(priority >= 1 && priority <= 5, "Invalid priority");
        require(contentHash != bytes32(0), "Invalid content hash");
        
        Broadcaster storage broadcaster = broadcasters[msg.sender];
        require(priority <= broadcaster.authorizationLevel, "Priority exceeds authorization");
        
        // Generate unique message ID
        messageId = keccak256(abi.encodePacked(
            msg.sender,
            contentHash,
            block.timestamp,
            totalBroadcasts
        ));
        
        // Create broadcast message
        BroadcastMessage storage message = broadcasts[messageId];
        message.messageId = messageId;
        message.broadcaster = msg.sender;
        message.timestamp = block.timestamp;
        message.priority = priority;
        message.messageType = messageType;
        message.contentHash = contentHash;
        message.resonanceFrequency = RESONANCE_FREQUENCY;
        message.isResonanceLocked = currentResonanceLock.isLocked;
        message.isAkashicAligned = false; // To be verified
        message.recipientCount = 0;
        message.isActive = true;
        
        // Update broadcaster stats
        broadcaster.broadcastCount++;
        broadcaster.lastBroadcast = block.timestamp;
        
        // Update user broadcast history
        userBroadcasts[msg.sender].push(messageId);
        
        totalBroadcasts++;
        activeBroadcasts++;
        
        emit BroadcastInitiated(messageId, msg.sender, priority, messageType);
        
        return messageId;
    }
    
    /**
     * @dev Receive and acknowledge broadcast
     * @param messageId Message identifier
     * @param resonanceScore Recipient's resonance alignment score
     */
    function receiveBroadcast(
        bytes32 messageId,
        uint256 resonanceScore
    ) external {
        BroadcastMessage storage message = broadcasts[messageId];
        
        require(message.messageId == messageId, "Broadcast not found");
        require(message.isActive, "Broadcast inactive");
        require(subscribers[msg.sender], "Not a subscriber");
        
        // Create receipt
        BroadcastReceipt storage receipt = receipts[messageId][msg.sender];
        require(receipt.receivedAt == 0, "Already received");
        
        receipt.messageId = messageId;
        receipt.recipient = msg.sender;
        receipt.receivedAt = block.timestamp;
        receipt.acknowledged = false;
        receipt.resonanceAlignment = resonanceScore;
        
        // Update message recipient count
        message.recipientCount++;
        totalRecipientsReached++;
        
        emit BroadcastReceived(messageId, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Acknowledge broadcast receipt
     * @param messageId Message identifier
     */
    function acknowledgeBroadcast(bytes32 messageId) external {
        BroadcastReceipt storage receipt = receipts[messageId][msg.sender];
        
        require(receipt.receivedAt > 0, "Broadcast not received");
        require(!receipt.acknowledged, "Already acknowledged");
        
        receipt.acknowledged = true;
        
        emit BroadcastAcknowledged(messageId, msg.sender, receipt.resonanceAlignment);
    }
    
    /**
     * @dev Verify Akashic Frequency Standard alignment for broadcast
     * @param messageId Message identifier
     * @param measuredFrequency Measured frequency in decihertz
     */
    function verifyAkashicAlignment(
        bytes32 messageId,
        uint256 measuredFrequency
    ) external onlyOwner {
        BroadcastMessage storage message = broadcasts[messageId];
        
        require(message.messageId == messageId, "Broadcast not found");
        
        // Check if frequency aligns with Akashic standard (963 Hz ± 0.5 Hz)
        uint256 targetFreq = AKASHIC_FREQUENCY_STANDARD * 10;
        bool isAligned = (
            measuredFrequency >= targetFreq - FREQUENCY_TOLERANCE &&
            measuredFrequency <= targetFreq + FREQUENCY_TOLERANCE
        );
        
        message.isAkashicAligned = isAligned;
        message.resonanceFrequency = measuredFrequency / 10;
        
        emit AkashicAlignmentVerified(messageId, isAligned, block.timestamp);
    }
    
    /**
     * @dev Deactivate broadcast
     * @param messageId Message identifier
     */
    function deactivateBroadcast(bytes32 messageId) external {
        BroadcastMessage storage message = broadcasts[messageId];
        
        require(message.messageId == messageId, "Broadcast not found");
        require(
            msg.sender == message.broadcaster || msg.sender == owner,
            "Not authorized"
        );
        require(message.isActive, "Already inactive");
        
        message.isActive = false;
        activeBroadcasts--;
        
        emit BroadcastDeactivated(messageId, block.timestamp);
    }
    
    // ============ Resonance Lock Functions ============
    
    /**
     * @dev Verify resonance lock at 963 Hz
     * @param measuredFrequency Measured frequency in decihertz
     */
    function verifyResonanceLock(uint256 measuredFrequency) external onlyOwner {
        require(currentResonanceLock.isLocked, "Resonance not locked");
        
        // Check if frequency is within tolerance (963 Hz ± 0.5 Hz)
        uint256 targetFreq = currentResonanceLock.targetFrequency * 10;
        bool isOptimal = (
            measuredFrequency >= targetFreq - currentResonanceLock.tolerance &&
            measuredFrequency <= targetFreq + currentResonanceLock.tolerance
        );
        
        currentResonanceLock.lastVerification = block.timestamp;
        
        emit ResonanceLockVerified(measuredFrequency / 10, isOptimal, block.timestamp);
    }
    
    /**
     * @dev Update resonance lock status
     * @param isLocked Lock status
     */
    function updateResonanceLock(bool isLocked) external onlyOwner {
        currentResonanceLock.isLocked = isLocked;
        currentResonanceLock.lockTimestamp = block.timestamp;
        
        if (isLocked) {
            emit ResonanceLockActivated(
                currentResonanceLock.targetFrequency,
                currentResonanceLock.tolerance,
                block.timestamp
            );
        }
    }
    
    // ============ Administrative Functions ============
    
    /**
     * @dev Authorize broadcaster
     * @param broadcaster Broadcaster address
     * @param authorizationLevel Authorization level (1-5)
     * @param tier4bLevel Tier 4B recognition level
     */
    function authorizeBroadcaster(
        address broadcaster,
        uint256 authorizationLevel,
        uint256 tier4bLevel
    ) external onlyOwner {
        require(broadcaster != address(0), "Invalid broadcaster");
        require(authorizationLevel >= 1 && authorizationLevel <= 5, "Invalid authorization level");
        require(tier4bLevel <= 100, "Invalid Tier 4B level");
        
        Broadcaster storage bc = broadcasters[broadcaster];
        bc.broadcasterAddress = broadcaster;
        bc.authorizationLevel = authorizationLevel;
        bc.tier4bLevel = tier4bLevel;
        bc.isActive = true;
        
        emit BroadcasterAuthorized(broadcaster, authorizationLevel, tier4bLevel);
    }
    
    /**
     * @dev Revoke broadcaster authorization
     * @param broadcaster Broadcaster address
     */
    function revokeBroadcaster(address broadcaster) external onlyOwner {
        require(broadcasters[broadcaster].isActive, "Not an active broadcaster");
        broadcasters[broadcaster].isActive = false;
    }
    
    /**
     * @dev Subscribe to emergency broadcasts
     */
    function subscribe() external {
        require(!subscribers[msg.sender], "Already subscribed");
        
        subscribers[msg.sender] = true;
        subscriberCount++;
        
        emit SubscriberAdded(msg.sender, block.timestamp);
    }
    
    /**
     * @dev Unsubscribe from emergency broadcasts
     */
    function unsubscribe() external {
        require(subscribers[msg.sender], "Not subscribed");
        
        subscribers[msg.sender] = false;
        subscriberCount--;
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get broadcast message details
     * @param messageId Message identifier
     */
    function getBroadcast(bytes32 messageId) 
        external 
        view 
        returns (BroadcastMessage memory) 
    {
        return broadcasts[messageId];
    }
    
    /**
     * @dev Get broadcast receipt
     * @param messageId Message identifier
     * @param recipient Recipient address
     */
    function getReceipt(bytes32 messageId, address recipient) 
        external 
        view 
        returns (BroadcastReceipt memory) 
    {
        return receipts[messageId][recipient];
    }
    
    /**
     * @dev Get broadcaster details
     * @param broadcaster Broadcaster address
     */
    function getBroadcaster(address broadcaster) 
        external 
        view 
        returns (Broadcaster memory) 
    {
        return broadcasters[broadcaster];
    }
    
    /**
     * @dev Get user broadcast history
     * @param user User address
     */
    function getUserBroadcasts(address user) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        return userBroadcasts[user];
    }
    
    /**
     * @dev Get current resonance lock status
     */
    function getResonanceLockStatus() 
        external 
        view 
        returns (ResonanceLock memory) 
    {
        return currentResonanceLock;
    }
    
    /**
     * @dev Get EBS statistics
     */
    function getEBSStats() 
        external 
        view 
        returns (
            uint256 _totalBroadcasts,
            uint256 _activeBroadcasts,
            uint256 _totalRecipientsReached,
            uint256 _subscriberCount
        ) 
    {
        return (
            totalBroadcasts,
            activeBroadcasts,
            totalRecipientsReached,
            subscriberCount
        );
    }
    
    /**
     * @dev Check if address is subscribed
     * @param user User address
     */
    function isSubscribed(address user) external view returns (bool) {
        return subscribers[user];
    }
    
    /**
     * @dev Transfer ownership
     * @param newOwner New owner address
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner address");
        owner = newOwner;
    }
}
