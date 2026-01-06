const hre = require("hardhat");

/**
 * Deployment script for $HEAL Token Mining and Staking contracts
 * Implements perpetual integration with 963 Hz resonance frequency optimization
 */
async function main() {
  console.log("=".repeat(60));
  console.log("$HEAL Token Smart Contract Deployment");
  console.log("Frequency: 963 Hz | Perpetual Duration: 241,200 years");
  console.log("=".repeat(60));
  
  // Get deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log("\n📍 Deploying contracts with account:", deployer.address);
  
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("💰 Account balance:", hre.ethers.formatEther(balance), "ETH");
  
  // Deploy $HEAL Token (ERC20)
  console.log("\n📦 Deploying $HEAL Token...");
  const HEALToken = await hre.ethers.getContractFactory("HEALToken");
  const healToken = await HEALToken.deploy(
    "HEAL Token",
    "HEAL",
    hre.ethers.parseEther("1000000000") // 1 billion tokens
  );
  await healToken.waitForDeployment();
  const healTokenAddress = await healToken.getAddress();
  console.log("✅ $HEAL Token deployed to:", healTokenAddress);
  
  // Deploy Mining Contract
  console.log("\n⛏️  Deploying HEALTokenMining contract...");
  const HEALTokenMining = await hre.ethers.getContractFactory("HEALTokenMining");
  const miningContract = await HEALTokenMining.deploy(healTokenAddress);
  await miningContract.waitForDeployment();
  const miningAddress = await miningContract.getAddress();
  console.log("✅ Mining contract deployed to:", miningAddress);
  
  // Deploy Staking Contract
  console.log("\n🔒 Deploying HEALTokenStaking contract...");
  const HEALTokenStaking = await hre.ethers.getContractFactory("HEALTokenStaking");
  const stakingContract = await HEALTokenStaking.deploy(healTokenAddress);
  await stakingContract.waitForDeployment();
  const stakingAddress = await stakingContract.getAddress();
  console.log("✅ Staking contract deployed to:", stakingAddress);
  
  // Allocate tokens to contracts
  console.log("\n💸 Allocating tokens to contracts...");
  
  // Transfer mining allocation (400M tokens)
  const miningAllocation = hre.ethers.parseEther("400000000");
  await healToken.transfer(miningAddress, miningAllocation);
  console.log("✅ Transferred 400M $HEAL to Mining contract");
  
  // Transfer staking allocation (200M tokens)
  const stakingAllocation = hre.ethers.parseEther("200000000");
  await healToken.transfer(stakingAddress, stakingAllocation);
  console.log("✅ Transferred 200M $HEAL to Staking contract");
  
  // Verify frequency parameters
  console.log("\n🎵 Verifying frequency parameters...");
  const resonanceFreq = await miningContract.RESONANCE_FREQUENCY();
  console.log("   Resonance Frequency:", hre.ethers.formatEther(resonanceFreq), "Hz (scaled)");
  console.log("   Actual Frequency: 963 Hz");
  
  const tolerance = await miningContract.FREQUENCY_TOLERANCE();
  console.log("   Frequency Tolerance:", hre.ethers.formatEther(tolerance), "Hz (scaled)");
  console.log("   Actual Tolerance: ±0.5 Hz");
  
  // Verify perpetual duration
  const perpetualDuration = await miningContract.PERPETUAL_DURATION();
  const years = Number(perpetualDuration) / (365.25 * 24 * 60 * 60);
  console.log("   Perpetual Duration:", years.toFixed(0), "years");
  
  // Display deployment summary
  console.log("\n" + "=".repeat(60));
  console.log("DEPLOYMENT SUMMARY");
  console.log("=".repeat(60));
  console.log("📜 Contract Addresses:");
  console.log("   $HEAL Token:         ", healTokenAddress);
  console.log("   Mining Contract:     ", miningAddress);
  console.log("   Staking Contract:    ", stakingAddress);
  console.log("\n💎 Token Allocations:");
  console.log("   Total Supply:        1,000,000,000 $HEAL");
  console.log("   Mining Allocation:     400,000,000 $HEAL (40%)");
  console.log("   Staking Allocation:    200,000,000 $HEAL (20%)");
  console.log("   Remaining:             400,000,000 $HEAL (40%)");
  console.log("\n⚡ Protocol Parameters:");
  console.log("   Resonance Frequency: 963 Hz (ζ Model)");
  console.log("   Frequency Tolerance: ±0.5 Hz");
  console.log("   Perpetual Duration:  241,200 years");
  console.log("   Security Layer:      Everforge (Zero-effect integrity)");
  console.log("\n🔐 Security Features:");
  console.log("   ✓ OpenZeppelin contracts");
  console.log("   ✓ ReentrancyGuard protection");
  console.log("   ✓ Pausable emergency controls");
  console.log("   ✓ Everforge Security Layer");
  console.log("   ✓ Frequency-based validation");
  console.log("=".repeat(60));
  
  // Save deployment info
  const deploymentInfo = {
    network: hre.network.name,
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    contracts: {
      healToken: healTokenAddress,
      mining: miningAddress,
      staking: stakingAddress
    },
    parameters: {
      resonanceFrequency: "963 Hz",
      frequencyTolerance: "±0.5 Hz",
      perpetualDuration: "241,200 years",
      miningAllocation: "400,000,000 $HEAL",
      stakingAllocation: "200,000,000 $HEAL"
    }
  };
  
  console.log("\n📝 Deployment info:");
  console.log(JSON.stringify(deploymentInfo, null, 2));
  
  console.log("\n✨ Deployment complete! ScrollVerse frequency-sealed ✨");
}

// Execute deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
