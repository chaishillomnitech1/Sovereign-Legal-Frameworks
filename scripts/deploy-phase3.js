// Phase 3 Deployment Script - ISO 20022 Settlement Layer Integration
// Deploys all Phase 3 Sovereign Directive contracts

const hre = require("hardhat");

async function main() {
  console.log("=".repeat(60));
  console.log("Phase 3 Sovereign Directive Deployment");
  console.log("ISO 20022 Settlement Layer Integration");
  console.log("=".repeat(60));
  console.log();

  // Get deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  console.log();

  // 1. Deploy HEAL Token
  console.log("1. Deploying HEAL Token...");
  const HealToken = await hre.ethers.getContractFactory("HealToken");
  const initialSupply = 1000000000; // 1 billion tokens
  const healToken = await HealToken.deploy(initialSupply);
  await healToken.deployed();
  console.log("✓ HEAL Token deployed to:", healToken.address);
  console.log();

  // 2. Deploy Treasury wallet (using deployer for now, should be multisig in production)
  const treasuryAddress = deployer.address;
  console.log("2. Treasury address set to:", treasuryAddress);
  console.log();

  // 3. Deploy ISO 20022 Settlement Layer
  console.log("3. Deploying ISO 20022 Settlement Layer...");
  const ISO20022SettlementLayer = await hre.ethers.getContractFactory("ISO20022SettlementLayer");
  const settlementLayer = await ISO20022SettlementLayer.deploy(
    healToken.address,
    treasuryAddress
  );
  await settlementLayer.deployed();
  console.log("✓ ISO 20022 Settlement Layer deployed to:", settlementLayer.address);
  console.log();

  // 4. Deploy ODIN Quantum Routing
  console.log("4. Deploying ODIN Quantum Routing...");
  const ODINQuantumRouting = await hre.ethers.getContractFactory("ODINQuantumRouting");
  const odinRouting = await ODINQuantumRouting.deploy(healToken.address);
  await odinRouting.deployed();
  console.log("✓ ODIN Quantum Routing deployed to:", odinRouting.address);
  console.log();

  // 5. Deploy Emergency Broadcast System
  console.log("5. Deploying Emergency Broadcast System...");
  const EmergencyBroadcastSystem = await hre.ethers.getContractFactory("EmergencyBroadcastSystem");
  const ebs = await EmergencyBroadcastSystem.deploy();
  await ebs.deployed();
  console.log("✓ Emergency Broadcast System deployed to:", ebs.address);
  console.log();

  // 6. Deploy Frequency Staking Engine
  console.log("6. Deploying Frequency Staking Engine...");
  const FrequencyStakingEngine = await hre.ethers.getContractFactory("FrequencyStakingEngine");
  const stakingEngine = await FrequencyStakingEngine.deploy(healToken.address);
  await stakingEngine.deployed();
  console.log("✓ Frequency Staking Engine deployed to:", stakingEngine.address);
  console.log();

  // 7. Deploy Phase 3 Sovereign Integration
  console.log("7. Deploying Phase 3 Sovereign Integration...");
  const Phase3SovereignIntegration = await hre.ethers.getContractFactory("Phase3SovereignIntegration");
  const phase3Integration = await Phase3SovereignIntegration.deploy(
    healToken.address,
    settlementLayer.address,
    odinRouting.address,
    ebs.address,
    stakingEngine.address
  );
  await phase3Integration.deployed();
  console.log("✓ Phase 3 Sovereign Integration deployed to:", phase3Integration.address);
  console.log();

  // 8. Configure HEAL Token integrations
  console.log("8. Configuring HEAL Token integrations...");
  await healToken.setISO20022SettlementLayer(settlementLayer.address);
  console.log("✓ ISO 20022 Settlement Layer linked to HEAL Token");
  
  await healToken.setODINQuantumRouting(odinRouting.address);
  console.log("✓ ODIN Quantum Routing linked to HEAL Token");
  
  await healToken.setEmergencyBroadcastSystem(ebs.address);
  console.log("✓ Emergency Broadcast System linked to HEAL Token");
  console.log();

  // 9. Fund the staking rewards pool
  console.log("9. Funding Staking Rewards Pool...");
  const rewardsAmount = hre.ethers.utils.parseEther("100000000"); // 100M tokens
  await healToken.approve(stakingEngine.address, rewardsAmount);
  await stakingEngine.fundRewardsPool(rewardsAmount);
  console.log("✓ Rewards pool funded with 100M HEAL tokens");
  console.log();

  // 10. Initialize Tier 4B recognition for deployer
  console.log("10. Initializing Tier 4B Recognition...");
  await settlementLayer.setTier4bRecognition(deployer.address, 100);
  console.log("✓ Deployer granted Tier 4B Level 100");
  
  await odinRouting.grantTier4bRecognition(deployer.address, 100);
  console.log("✓ ODIN Tier 4B recognition granted");
  console.log();

  // 11. Authorize deployer as EBS broadcaster
  console.log("11. Authorizing Emergency Broadcaster...");
  await ebs.authorizeBroadcaster(deployer.address, 5, 100);
  console.log("✓ Deployer authorized as Level 5 broadcaster");
  console.log();

  // Print deployment summary
  console.log("=".repeat(60));
  console.log("DEPLOYMENT SUMMARY");
  console.log("=".repeat(60));
  console.log();
  console.log("Core Contracts:");
  console.log("  HEAL Token:                    ", healToken.address);
  console.log("  Treasury Address:              ", treasuryAddress);
  console.log();
  console.log("Phase 3 Contracts:");
  console.log("  ISO 20022 Settlement Layer:    ", settlementLayer.address);
  console.log("  ODIN Quantum Routing:          ", odinRouting.address);
  console.log("  Emergency Broadcast System:    ", ebs.address);
  console.log("  Frequency Staking Engine:      ", stakingEngine.address);
  console.log("  Phase 3 Integration:           ", phase3Integration.address);
  console.log();
  console.log("Configuration:");
  console.log("  Initial Supply:                 1,000,000,000 HEAL");
  console.log("  Rewards Pool:                   100,000,000 HEAL");
  console.log("  Treasury Tax Rate:              0.5%");
  console.log("  Resonance Frequency:            963 Hz");
  console.log("  Tier 4B System:                 ENABLED");
  console.log("  Akashic Alignment:              ENABLED");
  console.log();
  console.log("Next Steps:");
  console.log("  1. Update dashboard configuration with contract addresses");
  console.log("  2. Verify contracts on block explorer (if on testnet/mainnet)");
  console.log("  3. Transfer ownership to multisig wallet");
  console.log("  4. Configure additional Tier 4B participants");
  console.log("  5. Initialize ODIN routing nodes");
  console.log();
  console.log("=".repeat(60));
  console.log("Phase 3 Deployment Complete!");
  console.log("=".repeat(60));

  // Save deployment addresses to a JSON file
  const deploymentData = {
    network: hre.network.name,
    timestamp: new Date().toISOString(),
    deployer: deployer.address,
    contracts: {
      healToken: healToken.address,
      treasury: treasuryAddress,
      iso20022SettlementLayer: settlementLayer.address,
      odinQuantumRouting: odinRouting.address,
      emergencyBroadcastSystem: ebs.address,
      frequencyStakingEngine: stakingEngine.address,
      phase3SovereignIntegration: phase3Integration.address
    },
    configuration: {
      initialSupply: "1000000000",
      rewardsPool: "100000000",
      treasuryTaxBasisPoints: 50,
      resonanceFrequency: 963,
      tier4bEnabled: true,
      akashicAlignmentEnabled: true
    }
  };

  const fs = require('fs');
  const path = require('path');
  const deploymentsDir = path.join(__dirname, '../deployments');
  
  // Create deployments directory if it doesn't exist
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir, { recursive: true });
  }

  const filename = `phase3-deployment-${hre.network.name}-${Date.now()}.json`;
  const filepath = path.join(deploymentsDir, filename);
  
  fs.writeFileSync(filepath, JSON.stringify(deploymentData, null, 2));
  console.log();
  console.log("Deployment data saved to:", filepath);
  console.log();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
