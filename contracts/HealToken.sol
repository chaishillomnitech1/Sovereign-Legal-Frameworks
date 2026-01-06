// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title HealToken
 * @dev Enhanced ERC20 token implementation for the $HEAL token
 * @notice Integrated with ISO 20022 Settlement Layer, ODIN Quantum Routing, and EBS
 */
contract HealToken {
    string public constant name = "HEAL Token";
    string public constant symbol = "HEAL";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    address public owner;
    
    // ============ ISO 20022 Integration ============
    address public iso20022SettlementLayer;
    address public odinQuantumRouting;
    address public emergencyBroadcastSystem;
    
    // Settlement metadata tracking
    mapping(bytes32 => bool) public settlementExecuted;
    uint256 public totalSettlementVolume;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    // New events for ISO 20022 integration
    event SettlementLayerUpdated(address indexed settlementLayer);
    event ODINRoutingUpdated(address indexed odinRouting);
    event EBSUpdated(address indexed ebs);
    event SettlementTransfer(
        address indexed from,
        address indexed to,
        uint256 value,
        bytes32 indexed settlementId
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * 10**decimals;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");

        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid address");
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }
    
    // ============ ISO 20022 Settlement Integration ============
    
    /**
     * @dev Set ISO 20022 Settlement Layer contract address
     * @param _settlementLayer Settlement layer contract address
     */
    function setISO20022SettlementLayer(address _settlementLayer) external onlyOwner {
        require(_settlementLayer != address(0), "Invalid settlement layer address");
        iso20022SettlementLayer = _settlementLayer;
        emit SettlementLayerUpdated(_settlementLayer);
    }
    
    /**
     * @dev Set ODIN Quantum Routing contract address
     * @param _odinRouting ODIN routing contract address
     */
    function setODINQuantumRouting(address _odinRouting) external onlyOwner {
        require(_odinRouting != address(0), "Invalid ODIN routing address");
        odinQuantumRouting = _odinRouting;
        emit ODINRoutingUpdated(_odinRouting);
    }
    
    /**
     * @dev Set Emergency Broadcast System contract address
     * @param _ebs EBS contract address
     */
    function setEmergencyBroadcastSystem(address _ebs) external onlyOwner {
        require(_ebs != address(0), "Invalid EBS address");
        emergencyBroadcastSystem = _ebs;
        emit EBSUpdated(_ebs);
    }
    
    /**
     * @dev Execute settlement transfer (callable by ISO 20022 Settlement Layer)
     * @param from Sender address
     * @param to Recipient address
     * @param amount Transfer amount
     * @param settlementId Unique settlement identifier
     */
    function executeSettlementTransfer(
        address from,
        address to,
        uint256 amount,
        bytes32 settlementId
    ) external returns (bool) {
        require(msg.sender == iso20022SettlementLayer, "Not authorized settlement layer");
        require(to != address(0), "Invalid address");
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(!settlementExecuted[settlementId], "Settlement already executed");
        
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        
        settlementExecuted[settlementId] = true;
        totalSettlementVolume += amount;
        
        emit Transfer(from, to, amount);
        emit SettlementTransfer(from, to, amount, settlementId);
        
        return true;
    }
    
    /**
     * @dev Get settlement volume statistics
     */
    function getSettlementStats() external view returns (uint256) {
        return totalSettlementVolume;
    }
    
    /**
     * @dev Check if settlement was executed
     * @param settlementId Settlement identifier
     */
    function isSettlementExecuted(bytes32 settlementId) external view returns (bool) {
        return settlementExecuted[settlementId];
    }
}
