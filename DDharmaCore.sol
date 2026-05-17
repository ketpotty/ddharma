// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DDharmaCore
 * @dev Core smart contract for the Distributed Dharma (DDharma) Protocol.
 * Implements Soulbound moral credits, non-commercial Karma governance, and automated liquidity demurrage.
 */
contract DDharmaCore {
    
    struct Profile {
        uint256 permanentGiftCredit; // Soulbound moral prestige (non-transferable)
        uint256 liquidCapital;       // Deployed capital awaiting allocation
        uint256 karmaMultiplier;     // Verification & governance weight (Base 100 = 1.0x)
        uint256 lastActivityTimestamp; // Used to calculate precise mathematical demurrage
    }

    address public protocolGenesisInception;
    mapping(address => Profile) public networkRegistry;
    mapping(string => uint256) public ecologicalStressMap; // Coordinate-bound crisis index (0-100)

    // Events for radical on-chain transparency
    event CapitalDeposited(address indexed actor, uint256 amount);
    event KarmaUpdated(address indexed actor, uint256 newKarma);
    event GiftCreditMinted(address indexed actor, uint256 amount);
    event EcologicalMapUpdated(string coordinate, uint256 structuralCrisisLevel);

    modifier onlyGenesisInception() {
        require(msg.sender == protocolGenesisInception, "DDharma Error: Only genesis contract address authorized.");
        _;
    }

    constructor() {
        protocolGenesisInception = msg.sender;
    }

    /**
     * @notice Rule 1: Capital Influx. Deployed funds enter the liquid pool. Demurrage clock starts.
     */
    function depositCapital() external payable {
        require(msg.value > 0, "DDharma Error: Zero-value deployments rejected.");
        
        Profile storage actor = networkRegistry[msg.sender];
        
        if (actor.karmaMultiplier == 0) {
            actor.karmaMultiplier = 100; 
        }

        if (actor.liquidCapital > 0) {
            uint256 burnAmount = calculateDemurrage(msg.sender);
            actor.liquidCapital -= burnAmount;
        }

        actor.liquidCapital += msg.value;
        actor.lastActivityTimestamp = block.timestamp;

        emit CapitalDeposited(msg.sender, msg.value);
    }

    /**
     * @notice Rule 2: Physical Field Allocation. Conversion of liquid funds into physical reality.
     */
    function allocateToProject(string memory coordinate, uint256 amount) external {
        Profile storage actor = networkRegistry[msg.sender];
        
        uint256 burnAmount = calculateDemurrage(msg.sender);
        if (burnAmount > 0) {
            actor.liquidCapital -= burnAmount;
        }
        actor.lastActivityTimestamp = block.timestamp;

        require(actor.liquidCapital >= amount, "DDharma Error: Insufficient active liquid capital.");
        
        actor.liquidCapital -= amount;

        uint256 crisisWeight = ecologicalStressMap[coordinate] == 0 ? 10 : ecologicalStressMap[coordinate];
        uint256 mintedCredits = (amount * crisisWeight) / 10;

        actor.permanentGiftCredit += mintedCredits;
        actor.karmaMultiplier += 5; 

        emit GiftCreditMinted(msg.sender, mintedCredits);
        emit KarmaUpdated(msg.sender, actor.karmaMultiplier);
    }

    function calculateDemurrage(address actorAddress) public view returns (uint256) {
        Profile memory actor = networkRegistry[actorAddress];
        if (actor.liquidCapital == 0 || block.timestamp <= actor.lastActivityTimestamp + 30 days) {
            return 0;
        }
        return (actor.liquidCapital * 15) / 100;
    }

    /**
     * @notice Automated Oracle Hook: Automated synchronization with independent satellite data streams.
     */
    function syncSatelliteData(string memory coordinate, uint256 newCrisisLevel) external onlyGenesisInception {
        require(newCrisisLevel <= 100, "DDharma Error: Crisis boundary condition overflow.");
        ecologicalStressMap[coordinate] = newCrisisLevel;
        emit EcologicalMapUpdated(coordinate, newCrisisLevel);
    }
}
