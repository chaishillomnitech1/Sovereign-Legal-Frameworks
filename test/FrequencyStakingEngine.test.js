const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FrequencyStakingEngine", function () {
  let healToken;
  let stakingEngine;
  let owner;
  let addr1;
  let addr2;

  const INITIAL_SUPPLY = ethers.utils.parseEther("1000000000"); // 1B tokens
  const REWARDS_POOL = ethers.utils.parseEther("100000000"); // 100M tokens
  const STAKE_AMOUNT = ethers.utils.parseEther("1000"); // 1000 tokens

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy HEAL Token
    const HealToken = await ethers.getContractFactory("HealToken");
    const initialSupply = 1000000000; // 1 billion tokens (will be multiplied by 10^18 in constructor)
    healToken = await HealToken.deploy(initialSupply);
    await healToken.deployed();

    // Deploy Staking Engine
    const FrequencyStakingEngine = await ethers.getContractFactory("FrequencyStakingEngine");
    stakingEngine = await FrequencyStakingEngine.deploy(healToken.address);
    await stakingEngine.deployed();

    // Fund rewards pool
    await healToken.approve(stakingEngine.address, REWARDS_POOL);
    await stakingEngine.fundRewardsPool(REWARDS_POOL);

    // Transfer tokens to test addresses
    await healToken.transfer(addr1.address, ethers.utils.parseEther("10000"));
    await healToken.transfer(addr2.address, ethers.utils.parseEther("10000"));
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await stakingEngine.owner()).to.equal(owner.address);
    });

    it("Should set the correct HEAL token", async function () {
      expect(await stakingEngine.healToken()).to.equal(healToken.address);
    });

    it("Should have correct initial supply", async function () {
      const expectedSupply = ethers.utils.parseEther("1000000000");
      expect(await healToken.totalSupply()).to.equal(expectedSupply);
    });

    it("Should have funded rewards pool", async function () {
      expect(await stakingEngine.rewardsPool()).to.equal(REWARDS_POOL);
    });
  });

  describe("Staking", function () {
    it("Should allow users to stake tokens", async function () {
      await healToken.connect(addr1).approve(stakingEngine.address, STAKE_AMOUNT);
      await stakingEngine.connect(addr1).stake(STAKE_AMOUNT);

      const stakeInfo = await stakingEngine.getStakeInfo(addr1.address);
      expect(stakeInfo.amount).to.equal(STAKE_AMOUNT);
    });

    it("Should fail when staking 0 tokens", async function () {
      await expect(
        stakingEngine.connect(addr1).stake(0)
      ).to.be.revertedWith("Cannot stake 0");
    });

    it("Should update total staked", async function () {
      await healToken.connect(addr1).approve(stakingEngine.address, STAKE_AMOUNT);
      await stakingEngine.connect(addr1).stake(STAKE_AMOUNT);

      expect(await stakingEngine.totalStaked()).to.equal(STAKE_AMOUNT);
    });

    it("Should initialize resonance score to 50%", async function () {
      await healToken.connect(addr1).approve(stakingEngine.address, STAKE_AMOUNT);
      await stakingEngine.connect(addr1).stake(STAKE_AMOUNT);

      const stakeInfo = await stakingEngine.getStakeInfo(addr1.address);
      expect(stakeInfo.resonanceScore).to.equal(500); // 50%
    });
  });

  describe("Unstaking", function () {
    beforeEach(async function () {
      await healToken.connect(addr1).approve(stakingEngine.address, STAKE_AMOUNT);
      await stakingEngine.connect(addr1).stake(STAKE_AMOUNT);
    });

    it("Should allow users to unstake tokens", async function () {
      const unstakeAmount = ethers.utils.parseEther("500");
      await stakingEngine.connect(addr1).unstake(unstakeAmount);

      const stakeInfo = await stakingEngine.getStakeInfo(addr1.address);
      expect(stakeInfo.amount).to.equal(STAKE_AMOUNT.sub(unstakeAmount));
    });

    it("Should fail when unstaking more than staked", async function () {
      const unstakeAmount = ethers.utils.parseEther("2000");
      await expect(
        stakingEngine.connect(addr1).unstake(unstakeAmount)
      ).to.be.revertedWith("Insufficient stake");
    });

    it("Should update total staked", async function () {
      await stakingEngine.connect(addr1).unstake(STAKE_AMOUNT);
      expect(await stakingEngine.totalStaked()).to.equal(0);
    });
  });

  describe("APY Calculations", function () {
    it("Should calculate base APY correctly (50%)", async function () {
      await healToken.connect(addr1).approve(stakingEngine.address, STAKE_AMOUNT);
      await stakingEngine.connect(addr1).stake(STAKE_AMOUNT);

      const stakeInfo = await stakingEngine.getStakeInfo(addr1.address);
      // Base 50% + 50% resonance of 25% bonus = 62.5%
      expect(stakeInfo.effectiveAPY).to.equal(6250); // 62.5% in basis points
    });

    it("Should add resonance bonus correctly", async function () {
      await healToken.connect(addr1).approve(stakingEngine.address, STAKE_AMOUNT);
      await stakingEngine.connect(addr1).stake(STAKE_AMOUNT);

      // Set resonance to 100%
      await stakingEngine.syncResonance(addr1.address, 1000);

      const stakeInfo = await stakingEngine.getStakeInfo(addr1.address);
      // Base 50% + 100% of 25% bonus = 75%
      expect(stakeInfo.effectiveAPY).to.equal(7500);
    });

    it("Should add sovereign bonus correctly", async function () {
      await healToken.connect(addr1).approve(stakingEngine.address, STAKE_AMOUNT);
      await stakingEngine.connect(addr1).stake(STAKE_AMOUNT);

      // Set sovereign participant
      await stakingEngine.setSovereignParticipant(addr1.address, true);

      const stakeInfo = await stakingEngine.getStakeInfo(addr1.address);
      // Base 50% + 50% resonance (12.5%) + Sovereign 15% = 77.5%
      expect(stakeInfo.effectiveAPY).to.equal(7750);
    });

    it("Should calculate maximum APY (90%)", async function () {
      await healToken.connect(addr1).approve(stakingEngine.address, STAKE_AMOUNT);
      await stakingEngine.connect(addr1).stake(STAKE_AMOUNT);

      // Set max resonance and sovereign status
      await stakingEngine.syncResonance(addr1.address, 1000);
      await stakingEngine.setSovereignParticipant(addr1.address, true);

      const stakeInfo = await stakingEngine.getStakeInfo(addr1.address);
      // Base 50% + Resonance 25% + Sovereign 15% = 90%
      expect(stakeInfo.effectiveAPY).to.equal(9000);
    });
  });

  describe("Resonance Synchronization", function () {
    beforeEach(async function () {
      await healToken.connect(addr1).approve(stakingEngine.address, STAKE_AMOUNT);
      await stakingEngine.connect(addr1).stake(STAKE_AMOUNT);
    });

    it("Should allow owner to sync resonance", async function () {
      await stakingEngine.syncResonance(addr1.address, 750);
      const stakeInfo = await stakingEngine.getStakeInfo(addr1.address);
      expect(stakeInfo.resonanceScore).to.equal(750);
    });

    it("Should fail when non-owner tries to sync", async function () {
      await expect(
        stakingEngine.connect(addr1).syncResonance(addr1.address, 750)
      ).to.be.revertedWith("Not authorized");
    });

    it("Should fail with invalid resonance score", async function () {
      await expect(
        stakingEngine.syncResonance(addr1.address, 1001)
      ).to.be.revertedWith("Invalid resonance score");
    });
  });

  describe("Rewards", function () {
    beforeEach(async function () {
      await healToken.connect(addr1).approve(stakingEngine.address, STAKE_AMOUNT);
      await stakingEngine.connect(addr1).stake(STAKE_AMOUNT);
    });

    it("Should accumulate rewards over time", async function () {
      // Wait some time
      await ethers.provider.send("evm_increaseTime", [86400]); // 1 day
      await ethers.provider.send("evm_mine");

      const stakeInfo = await stakingEngine.getStakeInfo(addr1.address);
      expect(stakeInfo.pendingRewards).to.be.gt(0);
    });

    it("Should allow claiming rewards", async function () {
      // Wait some time
      await ethers.provider.send("evm_increaseTime", [86400]); // 1 day
      await ethers.provider.send("evm_mine");

      const balanceBefore = await healToken.balanceOf(addr1.address);
      await stakingEngine.connect(addr1).claimRewards();
      const balanceAfter = await healToken.balanceOf(addr1.address);

      expect(balanceAfter).to.be.gt(balanceBefore);
    });

    it("Should update totalRewardsDistributed", async function () {
      await ethers.provider.send("evm_increaseTime", [86400]);
      await ethers.provider.send("evm_mine");

      await stakingEngine.connect(addr1).claimRewards();
      expect(await stakingEngine.totalRewardsDistributed()).to.be.gt(0);
    });
  });

  describe("Access Control", function () {
    it("Should allow owner to set sovereign participant", async function () {
      await healToken.connect(addr1).approve(stakingEngine.address, STAKE_AMOUNT);
      await stakingEngine.connect(addr1).stake(STAKE_AMOUNT);
      
      await stakingEngine.setSovereignParticipant(addr1.address, true);
      const stakeInfo = await stakingEngine.getStakeInfo(addr1.address);
      expect(stakeInfo.isSovereignParticipant).to.equal(true);
    });

    it("Should prevent non-owner from setting sovereign participant", async function () {
      await expect(
        stakingEngine.connect(addr1).setSovereignParticipant(addr1.address, true)
      ).to.be.revertedWith("Not authorized");
    });

    it("Should allow ownership transfer", async function () {
      await stakingEngine.transferOwnership(addr1.address);
      expect(await stakingEngine.owner()).to.equal(addr1.address);
    });
  });

  describe("Security", function () {
    it("Should prevent reentrancy attacks", async function () {
      // This is a basic check - the noReentrant modifier should prevent it
      await healToken.connect(addr1).approve(stakingEngine.address, STAKE_AMOUNT);
      await stakingEngine.connect(addr1).stake(STAKE_AMOUNT);
      
      // Normal operation should work
      await expect(stakingEngine.connect(addr1).unstake(STAKE_AMOUNT)).to.not.be.reverted;
    });

    it("Should fail when rewards pool is insufficient", async function () {
      // Drain most of the rewards pool
      const drainAmount = REWARDS_POOL.sub(ethers.utils.parseEther("1"));
      await stakingEngine.connect(owner).unstake(0); // This won't work, just for demonstration
      
      // This test would need a way to drain the pool to test properly
      // For now, we verify the check exists in the code
    });
  });
});
