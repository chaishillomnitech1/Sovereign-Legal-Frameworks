const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EmergencyBroadcastSystem", function () {
  let ebs;
  let owner;
  let broadcaster;
  let subscriber1;
  let subscriber2;

  beforeEach(async function () {
    [owner, broadcaster, subscriber1, subscriber2] = await ethers.getSigners();

    // Deploy Emergency Broadcast System
    const EmergencyBroadcastSystem = await ethers.getContractFactory("EmergencyBroadcastSystem");
    ebs = await EmergencyBroadcastSystem.deploy();
    await ebs.deployed();

    // Authorize broadcaster
    await ebs.authorizeBroadcaster(broadcaster.address, 5, 100);

    // Subscribe users
    await ebs.connect(subscriber1).subscribe();
    await ebs.connect(subscriber2).subscribe();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await ebs.owner()).to.equal(owner.address);
    });

    it("Should initialize resonance lock", async function () {
      const lockStatus = await ebs.getResonanceLockStatus();
      expect(lockStatus.isLocked).to.be.true;
      expect(lockStatus.targetFrequency).to.equal(963);
    });

    it("Should set correct constants", async function () {
      expect(await ebs.RESONANCE_FREQUENCY()).to.equal(963);
      expect(await ebs.AKASHIC_FREQUENCY_STANDARD()).to.equal(963);
    });
  });

  describe("Broadcaster Authorization", function () {
    it("Should authorize broadcaster successfully", async function () {
      const [, , , , newBroadcaster] = await ethers.getSigners();
      
      await ebs.authorizeBroadcaster(newBroadcaster.address, 3, 75);

      const broadcasterInfo = await ebs.getBroadcaster(newBroadcaster.address);
      expect(broadcasterInfo.isActive).to.be.true;
      expect(broadcasterInfo.authorizationLevel).to.equal(3);
      expect(broadcasterInfo.tier4bLevel).to.equal(75);
    });

    it("Should reject invalid authorization level", async function () {
      const [, , , , newBroadcaster] = await ethers.getSigners();
      
      await expect(
        ebs.authorizeBroadcaster(newBroadcaster.address, 6, 75)
      ).to.be.revertedWith("Invalid authorization level");
    });

    it("Should revoke broadcaster", async function () {
      await ebs.revokeBroadcaster(broadcaster.address);

      const broadcasterInfo = await ebs.getBroadcaster(broadcaster.address);
      expect(broadcasterInfo.isActive).to.be.false;
    });
  });

  describe("Subscription Management", function () {
    it("Should subscribe successfully", async function () {
      const [, , , , newUser] = await ethers.getSigners();
      
      await ebs.connect(newUser).subscribe();
      
      expect(await ebs.isSubscribed(newUser.address)).to.be.true;
      expect(await ebs.subscriberCount()).to.equal(3); // 2 in beforeEach + 1 new
    });

    it("Should reject duplicate subscription", async function () {
      await expect(
        ebs.connect(subscriber1).subscribe()
      ).to.be.revertedWith("Already subscribed");
    });

    it("Should unsubscribe successfully", async function () {
      await ebs.connect(subscriber1).unsubscribe();
      
      expect(await ebs.isSubscribed(subscriber1.address)).to.be.false;
      expect(await ebs.subscriberCount()).to.equal(1);
    });
  });

  describe("Broadcast Initiation", function () {
    it("Should initiate broadcast successfully", async function () {
      const contentHash = ethers.utils.id("Emergency Alert");
      
      const tx = await ebs.connect(broadcaster).initiateBroadcast(
        5, // highest priority
        "ALERT",
        contentHash
      );

      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "BroadcastInitiated");

      expect(event).to.not.be.undefined;
      expect(event.args.broadcaster).to.equal(broadcaster.address);
      expect(event.args.priority).to.equal(5);
      expect(event.args.messageType).to.equal("ALERT");
    });

    it("Should set resonance lock on broadcast", async function () {
      const contentHash = ethers.utils.id("Emergency Alert");
      
      const tx = await ebs.connect(broadcaster).initiateBroadcast(
        5,
        "ALERT",
        contentHash
      );

      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "BroadcastInitiated");
      const messageId = event.args.messageId;

      const broadcast = await ebs.getBroadcast(messageId);
      expect(broadcast.isResonanceLocked).to.be.true;
      expect(broadcast.resonanceFrequency).to.equal(963);
    });

    it("Should reject broadcast from unauthorized user", async function () {
      const contentHash = ethers.utils.id("Alert");
      
      await expect(
        ebs.connect(subscriber1).initiateBroadcast(5, "ALERT", contentHash)
      ).to.be.revertedWith("Not authorized broadcaster");
    });

    it("Should reject priority exceeding authorization", async function () {
      // Authorize broadcaster with level 3
      const [, , , , lowAuthBroadcaster] = await ethers.getSigners();
      await ebs.authorizeBroadcaster(lowAuthBroadcaster.address, 3, 50);
      
      const contentHash = ethers.utils.id("Alert");
      
      await expect(
        ebs.connect(lowAuthBroadcaster).initiateBroadcast(5, "ALERT", contentHash)
      ).to.be.revertedWith("Priority exceeds authorization");
    });

    it("Should update broadcaster statistics", async function () {
      const contentHash = ethers.utils.id("Alert");
      
      await ebs.connect(broadcaster).initiateBroadcast(5, "ALERT", contentHash);

      const broadcasterInfo = await ebs.getBroadcaster(broadcaster.address);
      expect(broadcasterInfo.broadcastCount).to.equal(1);
    });
  });

  describe("Broadcast Reception", function () {
    let messageId;

    beforeEach(async function () {
      const contentHash = ethers.utils.id("Emergency Alert");
      const tx = await ebs.connect(broadcaster).initiateBroadcast(
        5,
        "ALERT",
        contentHash
      );

      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "BroadcastInitiated");
      messageId = event.args.messageId;
    });

    it("Should receive broadcast successfully", async function () {
      await ebs.connect(subscriber1).receiveBroadcast(messageId, 963);

      const receipt = await ebs.getReceipt(messageId, subscriber1.address);
      expect(receipt.recipient).to.equal(subscriber1.address);
      expect(receipt.resonanceAlignment).to.equal(963);
    });

    it("Should update recipient count", async function () {
      await ebs.connect(subscriber1).receiveBroadcast(messageId, 963);
      await ebs.connect(subscriber2).receiveBroadcast(messageId, 965);

      const broadcast = await ebs.getBroadcast(messageId);
      expect(broadcast.recipientCount).to.equal(2);

      const stats = await ebs.getEBSStats();
      expect(stats._totalRecipientsReached).to.equal(2);
    });

    it("Should reject non-subscriber", async function () {
      const [, , , , nonSubscriber] = await ethers.getSigners();
      
      await expect(
        ebs.connect(nonSubscriber).receiveBroadcast(messageId, 963)
      ).to.be.revertedWith("Not a subscriber");
    });

    it("Should reject duplicate reception", async function () {
      await ebs.connect(subscriber1).receiveBroadcast(messageId, 963);
      
      await expect(
        ebs.connect(subscriber1).receiveBroadcast(messageId, 963)
      ).to.be.revertedWith("Already received");
    });
  });

  describe("Broadcast Acknowledgement", function () {
    let messageId;

    beforeEach(async function () {
      const contentHash = ethers.utils.id("Emergency Alert");
      const tx = await ebs.connect(broadcaster).initiateBroadcast(
        5,
        "ALERT",
        contentHash
      );

      const receipt = await tx.wait();
      messageId = receipt.events.find(e => e.event === "BroadcastInitiated").args.messageId;

      await ebs.connect(subscriber1).receiveBroadcast(messageId, 963);
    });

    it("Should acknowledge broadcast successfully", async function () {
      await ebs.connect(subscriber1).acknowledgeBroadcast(messageId);

      const receipt = await ebs.getReceipt(messageId, subscriber1.address);
      expect(receipt.acknowledged).to.be.true;
    });

    it("Should reject acknowledgement without reception", async function () {
      await expect(
        ebs.connect(subscriber2).acknowledgeBroadcast(messageId)
      ).to.be.revertedWith("Broadcast not received");
    });

    it("Should reject duplicate acknowledgement", async function () {
      await ebs.connect(subscriber1).acknowledgeBroadcast(messageId);
      
      await expect(
        ebs.connect(subscriber1).acknowledgeBroadcast(messageId)
      ).to.be.revertedWith("Already acknowledged");
    });
  });

  describe("Akashic Alignment Verification", function () {
    let messageId;

    beforeEach(async function () {
      const contentHash = ethers.utils.id("Emergency Alert");
      const tx = await ebs.connect(broadcaster).initiateBroadcast(
        5,
        "ALERT",
        contentHash
      );

      const receipt = await tx.wait();
      messageId = receipt.events.find(e => e.event === "BroadcastInitiated").args.messageId;
    });

    it("Should verify Akashic alignment successfully", async function () {
      await ebs.verifyAkashicAlignment(messageId, 9630); // 963.0 Hz in decihertz

      const broadcast = await ebs.getBroadcast(messageId);
      expect(broadcast.isAkashicAligned).to.be.true;
    });

    it("Should detect misalignment", async function () {
      await ebs.verifyAkashicAlignment(messageId, 9700); // Outside tolerance

      const broadcast = await ebs.getBroadcast(messageId);
      expect(broadcast.isAkashicAligned).to.be.false;
    });

    it("Should emit alignment event", async function () {
      const tx = await ebs.verifyAkashicAlignment(messageId, 9630);
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "AkashicAlignmentVerified");

      expect(event.args.isAligned).to.be.true;
    });
  });

  describe("Resonance Lock Management", function () {
    it("Should verify resonance lock", async function () {
      const tx = await ebs.verifyResonanceLock(9635); // 963.5 Hz
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "ResonanceLockVerified");

      expect(event.args.isOptimal).to.be.true;
    });

    it("Should detect frequency deviation", async function () {
      const tx = await ebs.verifyResonanceLock(9700); // 970 Hz - outside tolerance
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "ResonanceLockVerified");

      expect(event.args.isOptimal).to.be.false;
    });

    it("Should update resonance lock status", async function () {
      await ebs.updateResonanceLock(false);

      const lockStatus = await ebs.getResonanceLockStatus();
      expect(lockStatus.isLocked).to.be.false;
    });

    it("Should emit activation event when enabling lock", async function () {
      await ebs.updateResonanceLock(false);
      
      const tx = await ebs.updateResonanceLock(true);
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "ResonanceLockActivated");

      expect(event).to.not.be.undefined;
    });
  });

  describe("Broadcast Deactivation", function () {
    let messageId;

    beforeEach(async function () {
      const contentHash = ethers.utils.id("Emergency Alert");
      const tx = await ebs.connect(broadcaster).initiateBroadcast(
        5,
        "ALERT",
        contentHash
      );

      const receipt = await tx.wait();
      messageId = receipt.events.find(e => e.event === "BroadcastInitiated").args.messageId;
    });

    it("Should deactivate broadcast by broadcaster", async function () {
      await ebs.connect(broadcaster).deactivateBroadcast(messageId);

      const broadcast = await ebs.getBroadcast(messageId);
      expect(broadcast.isActive).to.be.false;
    });

    it("Should deactivate broadcast by owner", async function () {
      await ebs.deactivateBroadcast(messageId);

      const broadcast = await ebs.getBroadcast(messageId);
      expect(broadcast.isActive).to.be.false;
    });

    it("Should reject unauthorized deactivation", async function () {
      await expect(
        ebs.connect(subscriber1).deactivateBroadcast(messageId)
      ).to.be.revertedWith("Not authorized");
    });
  });

  describe("View Functions", function () {
    it("Should return EBS statistics", async function () {
      const stats = await ebs.getEBSStats();
      
      expect(stats._subscriberCount).to.equal(2);
      expect(stats._activeBroadcasts).to.equal(0);
    });

    it("Should return user broadcast history", async function () {
      const contentHash = ethers.utils.id("Alert");
      await ebs.connect(broadcaster).initiateBroadcast(5, "ALERT", contentHash);

      const history = await ebs.getUserBroadcasts(broadcaster.address);
      expect(history.length).to.equal(1);
    });
  });
});
