// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ODINQuantumRouting
 * @dev Secure quantum-resistant communication routing for $HEAL ecosystem
 * @notice Implements ODIN (Omnidirectional Distributed Intelligence Network) architecture
 * Links to $HEAL Tokenomics and Tier 4B recognition system
 */
contract ODINQuantumRouting {
    
    // ============ Structs ============
    
    /// @notice Quantum-secure communication channel
    struct QuantumChannel {
        bytes32 channelId;              // Unique channel identifier
        address initiator;              // Channel initiator
        address recipient;              // Channel recipient
        uint256 securityLevel;          // Security level (1-5)
        uint256 tier4bRequirement;      // Required Tier 4B level
        bool isActive;                  // Channel status
        uint256 createdAt;              // Creation timestamp
        uint256 lastActivity;           // Last activity timestamp
        bytes32[] messageHistory;       // Message hash history
    }
    
    /// @notice Quantum-routed message structure
    struct QuantumMessage {
        bytes32 messageId;              // Unique message identifier
        bytes32 channelId;              // Channel identifier
        address sender;                 // Message sender
        address recipient;              // Message recipient
        bytes32 contentHash;            // Hash of encrypted content
        uint256 timestamp;              // Message timestamp
        uint256 routingHops;            // Number of routing hops
        bool isDelivered;               // Delivery status
        bool isVerified;                // Quantum verification status
        uint256 resonanceAlignment;     // 963 Hz alignment score
    }
    
    /// @notice Routing node in ODIN network
    struct RoutingNode {
        address nodeAddress;            // Node operator address
        uint256 reliability;            // Reliability score (0-100)
        uint256 messagesRouted;         // Total messages routed
        uint256 tier4bLevel;            // Tier 4B recognition level
        bool isActive;                  // Node active status
        uint256 lastPing;               // Last heartbeat timestamp
    }
    
    // ============ State Variables ============
    
    /// @notice Contract owner
    address public owner;
    
    /// @notice $HEAL Tokenomics contract reference
    address public healTokenomics;
    
    /// @notice Total channels created
    uint256 public totalChannels;
    
    /// @notice Total messages routed
    uint256 public totalMessagesRouted;
    
    /// @notice Active routing nodes count
    uint256 public activeNodesCount;
    
    /// @notice Resonance frequency target (963 Hz)
    uint256 public constant RESONANCE_FREQUENCY = 963;
    
    /// @notice Minimum Tier 4B level for quantum routing
    uint256 public constant MIN_TIER4B_LEVEL = 25;
    
    // ============ Mappings ============
    
    /// @notice Quantum channels by ID
    mapping(bytes32 => QuantumChannel) public quantumChannels;
    
    /// @notice Quantum messages by ID
    mapping(bytes32 => QuantumMessage) public quantumMessages;
    
    /// @notice Routing nodes by address
    mapping(address => RoutingNode) public routingNodes;
    
    /// @notice User channel list
    mapping(address => bytes32[]) public userChannels;
    
    /// @notice Tier 4B recognition levels
    mapping(address => uint256) public tier4bRecognition;
    
    /// @notice Channel access control
    mapping(bytes32 => mapping(address => bool)) public channelAccess;
    
    // ============ Events ============
    
    event QuantumChannelCreated(
        bytes32 indexed channelId,
        address indexed initiator,
        address indexed recipient,
        uint256 securityLevel
    );
    
    event QuantumMessageRouted(
        bytes32 indexed messageId,
        bytes32 indexed channelId,
        address indexed sender,
        address recipient,
        uint256 routingHops
    );
    
    event QuantumMessageDelivered(
        bytes32 indexed messageId,
        uint256 deliveryTime,
        bool isVerified
    );
    
    event RoutingNodeRegistered(
        address indexed nodeAddress,
        uint256 tier4bLevel
    );
    
    event RoutingNodeUpdated(
        address indexed nodeAddress,
        uint256 reliability,
        uint256 messagesRouted
    );
    
    event Tier4bRecognitionGranted(
        address indexed participant,
        uint256 recognitionLevel
    );
    
    event ResonanceVerified(
        bytes32 indexed messageId,
        uint256 alignmentScore,
        bool isOptimal
    );
    
    event ChannelSecurityUpgraded(
        bytes32 indexed channelId,
        uint256 oldLevel,
        uint256 newLevel
    );
    
    // ============ Modifiers ============
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    modifier onlyActiveNode() {
        require(routingNodes[msg.sender].isActive, "Not an active node");
        _;
    }
    
    modifier channelExists(bytes32 channelId) {
        require(quantumChannels[channelId].channelId == channelId, "Channel not found");
        _;
    }
    
    // ============ Constructor ============
    
    constructor(address _healTokenomics) {
        require(_healTokenomics != address(0), "Invalid tokenomics address");
        owner = msg.sender;
        healTokenomics = _healTokenomics;
    }
    
    // ============ Core Routing Functions ============
    
    /**
     * @dev Create quantum-secure communication channel
     * @param recipient Channel recipient address
     * @param securityLevel Security level (1-5)
     * @param tier4bRequirement Required Tier 4B level for access
     */
    function createQuantumChannel(
        address recipient,
        uint256 securityLevel,
        uint256 tier4bRequirement
    ) external returns (bytes32 channelId) {
        require(recipient != address(0), "Invalid recipient");
        require(securityLevel >= 1 && securityLevel <= 5, "Invalid security level");
        require(tier4bRequirement <= 100, "Invalid Tier 4B requirement");
        require(
            tier4bRecognition[msg.sender] >= tier4bRequirement,
            "Insufficient Tier 4B recognition"
        );
        
        // Generate unique channel ID
        channelId = keccak256(abi.encodePacked(
            msg.sender,
            recipient,
            block.timestamp,
            totalChannels
        ));
        
        // Create channel
        QuantumChannel storage channel = quantumChannels[channelId];
        channel.channelId = channelId;
        channel.initiator = msg.sender;
        channel.recipient = recipient;
        channel.securityLevel = securityLevel;
        channel.tier4bRequirement = tier4bRequirement;
        channel.isActive = true;
        channel.createdAt = block.timestamp;
        channel.lastActivity = block.timestamp;
        
        // Grant access
        channelAccess[channelId][msg.sender] = true;
        channelAccess[channelId][recipient] = true;
        
        // Update user channels
        userChannels[msg.sender].push(channelId);
        userChannels[recipient].push(channelId);
        
        totalChannels++;
        
        emit QuantumChannelCreated(channelId, msg.sender, recipient, securityLevel);
        
        return channelId;
    }
    
    /**
     * @dev Route quantum-secured message through ODIN network
     * @param channelId Target channel identifier
     * @param recipient Message recipient
     * @param contentHash Hash of encrypted message content
     * @param routingHops Number of routing hops for enhanced security
     */
    function routeQuantumMessage(
        bytes32 channelId,
        address recipient,
        bytes32 contentHash,
        uint256 routingHops
    ) external channelExists(channelId) returns (bytes32 messageId) {
        QuantumChannel storage channel = quantumChannels[channelId];
        
        require(channel.isActive, "Channel inactive");
        require(channelAccess[channelId][msg.sender], "No channel access");
        require(recipient != address(0), "Invalid recipient");
        require(routingHops > 0 && routingHops <= 10, "Invalid routing hops");
        require(
            tier4bRecognition[msg.sender] >= channel.tier4bRequirement,
            "Insufficient Tier 4B recognition"
        );
        
        // Generate message ID
        messageId = keccak256(abi.encodePacked(
            channelId,
            msg.sender,
            recipient,
            contentHash,
            block.timestamp
        ));
        
        // Create quantum message
        QuantumMessage storage message = quantumMessages[messageId];
        message.messageId = messageId;
        message.channelId = channelId;
        message.sender = msg.sender;
        message.recipient = recipient;
        message.contentHash = contentHash;
        message.timestamp = block.timestamp;
        message.routingHops = routingHops;
        message.isDelivered = false;
        message.isVerified = false;
        message.resonanceAlignment = RESONANCE_FREQUENCY;
        
        // Update channel
        channel.lastActivity = block.timestamp;
        channel.messageHistory.push(messageId);
        
        totalMessagesRouted++;
        
        emit QuantumMessageRouted(messageId, channelId, msg.sender, recipient, routingHops);
        
        return messageId;
    }
    
    /**
     * @dev Confirm message delivery and verify quantum security
     * @param messageId Message identifier
     * @param resonanceScore Measured resonance alignment (0-1000)
     */
    function confirmMessageDelivery(
        bytes32 messageId,
        uint256 resonanceScore
    ) external onlyActiveNode {
        QuantumMessage storage message = quantumMessages[messageId];
        
        require(message.messageId == messageId, "Message not found");
        require(!message.isDelivered, "Already delivered");
        
        message.isDelivered = true;
        message.resonanceAlignment = resonanceScore;
        
        // Verify resonance alignment (optimal: 963 ± 5)
        bool isOptimal = (resonanceScore >= 958 && resonanceScore <= 968);
        message.isVerified = isOptimal;
        
        // Update routing node stats
        RoutingNode storage node = routingNodes[msg.sender];
        node.messagesRouted++;
        node.lastPing = block.timestamp;
        
        emit QuantumMessageDelivered(messageId, block.timestamp, isOptimal);
        emit ResonanceVerified(messageId, resonanceScore, isOptimal);
        
        // Update node reliability based on verification success
        if (isOptimal && node.reliability < 100) {
            node.reliability = node.reliability + 1;
        }
    }
    
    // ============ Node Management Functions ============
    
    /**
     * @dev Register as ODIN routing node
     * @param tier4bLevel Initial Tier 4B recognition level
     */
    function registerRoutingNode(uint256 tier4bLevel) external {
        require(!routingNodes[msg.sender].isActive, "Already registered");
        require(tier4bLevel >= MIN_TIER4B_LEVEL, "Insufficient Tier 4B level");
        
        RoutingNode storage node = routingNodes[msg.sender];
        node.nodeAddress = msg.sender;
        node.reliability = 50; // Start at 50% reliability
        node.messagesRouted = 0;
        node.tier4bLevel = tier4bLevel;
        node.isActive = true;
        node.lastPing = block.timestamp;
        
        activeNodesCount++;
        
        emit RoutingNodeRegistered(msg.sender, tier4bLevel);
    }
    
    /**
     * @dev Send heartbeat to maintain node active status
     */
    function sendNodeHeartbeat() external onlyActiveNode {
        RoutingNode storage node = routingNodes[msg.sender];
        node.lastPing = block.timestamp;
    }
    
    /**
     * @dev Deactivate routing node
     */
    function deactivateNode() external onlyActiveNode {
        routingNodes[msg.sender].isActive = false;
        activeNodesCount--;
    }
    
    // ============ Administrative Functions ============
    
    /**
     * @dev Grant Tier 4B recognition to participant
     * @param participant Participant address
     * @param recognitionLevel Recognition level (0-100)
     */
    function grantTier4bRecognition(
        address participant,
        uint256 recognitionLevel
    ) external onlyOwner {
        require(participant != address(0), "Invalid participant");
        require(recognitionLevel <= 100, "Invalid recognition level");
        
        tier4bRecognition[participant] = recognitionLevel;
        
        // Update node if participant is a routing node
        if (routingNodes[participant].isActive) {
            routingNodes[participant].tier4bLevel = recognitionLevel;
        }
        
        emit Tier4bRecognitionGranted(participant, recognitionLevel);
    }
    
    /**
     * @dev Upgrade channel security level
     * @param channelId Channel identifier
     * @param newSecurityLevel New security level (1-5)
     */
    function upgradeChannelSecurity(
        bytes32 channelId,
        uint256 newSecurityLevel
    ) external channelExists(channelId) {
        QuantumChannel storage channel = quantumChannels[channelId];
        
        require(
            msg.sender == channel.initiator || msg.sender == owner,
            "Not authorized"
        );
        require(newSecurityLevel >= 1 && newSecurityLevel <= 5, "Invalid security level");
        require(newSecurityLevel > channel.securityLevel, "Cannot downgrade");
        
        uint256 oldLevel = channel.securityLevel;
        channel.securityLevel = newSecurityLevel;
        
        emit ChannelSecurityUpgraded(channelId, oldLevel, newSecurityLevel);
    }
    
    /**
     * @dev Grant channel access to additional participant
     * @param channelId Channel identifier
     * @param participant Participant address
     */
    function grantChannelAccess(
        bytes32 channelId,
        address participant
    ) external channelExists(channelId) {
        QuantumChannel storage channel = quantumChannels[channelId];
        
        require(
            msg.sender == channel.initiator || msg.sender == owner,
            "Not authorized"
        );
        require(participant != address(0), "Invalid participant");
        require(
            tier4bRecognition[participant] >= channel.tier4bRequirement,
            "Insufficient Tier 4B recognition"
        );
        
        channelAccess[channelId][participant] = true;
        userChannels[participant].push(channelId);
    }
    
    /**
     * @dev Revoke channel access from participant
     * @param channelId Channel identifier
     * @param participant Participant address
     */
    function revokeChannelAccess(
        bytes32 channelId,
        address participant
    ) external channelExists(channelId) {
        QuantumChannel storage channel = quantumChannels[channelId];
        
        require(
            msg.sender == channel.initiator || msg.sender == owner,
            "Not authorized"
        );
        require(participant != channel.initiator, "Cannot revoke initiator");
        
        channelAccess[channelId][participant] = false;
    }
    
    /**
     * @dev Deactivate quantum channel
     * @param channelId Channel identifier
     */
    function deactivateChannel(bytes32 channelId) external channelExists(channelId) {
        QuantumChannel storage channel = quantumChannels[channelId];
        
        require(
            msg.sender == channel.initiator || msg.sender == owner,
            "Not authorized"
        );
        
        channel.isActive = false;
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get quantum channel details
     * @param channelId Channel identifier
     */
    function getQuantumChannel(bytes32 channelId) 
        external 
        view 
        returns (QuantumChannel memory) 
    {
        return quantumChannels[channelId];
    }
    
    /**
     * @dev Get quantum message details
     * @param messageId Message identifier
     */
    function getQuantumMessage(bytes32 messageId) 
        external 
        view 
        returns (QuantumMessage memory) 
    {
        return quantumMessages[messageId];
    }
    
    /**
     * @dev Get routing node details
     * @param nodeAddress Node address
     */
    function getRoutingNode(address nodeAddress) 
        external 
        view 
        returns (RoutingNode memory) 
    {
        return routingNodes[nodeAddress];
    }
    
    /**
     * @dev Get user's channels
     * @param user User address
     */
    function getUserChannels(address user) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        return userChannels[user];
    }
    
    /**
     * @dev Get channel message history
     * @param channelId Channel identifier
     */
    function getChannelMessages(bytes32 channelId) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        return quantumChannels[channelId].messageHistory;
    }
    
    /**
     * @dev Check channel access for participant
     * @param channelId Channel identifier
     * @param participant Participant address
     */
    function hasChannelAccess(bytes32 channelId, address participant) 
        external 
        view 
        returns (bool) 
    {
        return channelAccess[channelId][participant];
    }
    
    /**
     * @dev Get network statistics
     */
    function getNetworkStats() 
        external 
        view 
        returns (
            uint256 _totalChannels,
            uint256 _totalMessagesRouted,
            uint256 _activeNodesCount
        ) 
    {
        return (totalChannels, totalMessagesRouted, activeNodesCount);
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
