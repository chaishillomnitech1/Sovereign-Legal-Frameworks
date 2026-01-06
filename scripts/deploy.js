// Deployment script for the FrequencyStakingEngine
// This script can be used with Hardhat or Truffle

const hre = require("hardhat");

async function main() {
  console.log("Deploying 963 Hz Frequency-Enforced Staking Engine...");

  // Deploy HEAL Token first
  const HealToken = await hre.ethers.getContractFactory("HealToken");
  const initialSupply = 1000000000; // 1 billion tokens
  const healToken = await HealToken.deploy(initialSupply);
  await healToken.deployed();
  console.log("HEAL Token deployed to:", healToken.address);

  // Deploy Staking Engine
  const FrequencyStakingEngine = await hre.ethers.getContractFactory("FrequencyStakingEngine");
  const stakingEngine = await FrequencyStakingEngine.deploy(healToken.address);
  await stakingEngine.deployed();
  console.log("FrequencyStakingEngine deployed to:", stakingEngine.address);

  // Fund the rewards pool
  const rewardsAmount = hre.ethers.utils.parseEther("100000000"); // 100M tokens for rewards
  await healToken.approve(stakingEngine.address, rewardsAmount);
  await stakingEngine.fundRewardsPool(rewardsAmount);
  console.log("Rewards pool funded with 100M HEAL tokens");

  console.log("\n=== Deployment Summary ===");
  console.log("HEAL Token:", healToken.address);
  console.log("Staking Engine:", stakingEngine.address);
  console.log("\nUpdate these addresses in dashboard/src/components/Web3Provider.jsx");
  console.log("==========================\n");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
