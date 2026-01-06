const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ODINQuantumRouting", function () {
  let healToken;
  let odinRouting;
  let owner;
  let alice;
  let bob;
  let node1;

  beforeEach(async function () {
    [owner, alice, bob, node1] = await ethers.getSigners();

    // Deploy HEAL Token
    const HealToken = await ethers.getContractFactory("HealToken");
    healToken = await HealToken.deploy(1000000000);
    await healToken.deployed();

    // Deploy ODIN Quantum Routing
    const ODINQuantumRouting = await ethers.getContractFactory("ODINQuantumRouting");
    odinRouting = await ODINQuantumRouting.deploy(healToken.address);
    await odinRouting.deployed();

    // Grant Tier 4B recognition
    await odinRouting.grantTier4bRecognition(alice.address, 100);
    await odinRouting.grantTier4bRecognition(bob.address, 50);
    await odinRouting.grantTier4bRecognition(node1.address, 75);
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await odinRouting.owner()).to.equal(owner.address);
    });

    it("Should set the correct HEAL tokenomics address", async function () {
      expect(await odinRouting.healTokenomics()).to.equal(healToken.address);
    });
  });

  describe("Quantum Channel Creation", function () {
    it("Should create quantum channel successfully", async function () {
      const tx = await odinRouting.connect(alice).createQuantumChannel(
        bob.address,
        3, // security level
        50  // tier4b requirement
      );

      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "QuantumChannelCreated");

      expect(event).to.not.be.undefined;
      expect(event.args.initiator).to.equal(alice.address);
      expect(event.args.recipient).to.equal(bob.address);
      expect(event.args.securityLevel).to.equal(3);
    });

    it("Should grant access to both parties", async function () {
      const tx = await odinRouting.connect(alice).createQuantumChannel(
        bob.address,
        3,
        50
      );

      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "QuantumChannelCreated");
      const channelId = event.args.channelId;

      expect(await odinRouting.hasChannelAccess(channelId, alice.address)).to.be.true;
      expect(await odinRouting.hasChannelAccess(channelId, bob.address)).to.be.true;
    });

    it("Should reject channel with insufficient Tier 4B", async function () {
      // Bob has Tier 4B level 50, trying to create channel requiring 75
      await expect(
        odinRouting.connect(bob).createQuantumChannel(
          alice.address,
          3,
          75
        )
      ).to.be.revertedWith("Insufficient Tier 4B recognition");
    });

    it("Should reject invalid security level", async function () {
      await expect(
        odinRouting.connect(alice).createQuantumChannel(
          bob.address,
          6, // invalid: must be 1-5
          50
        )
      ).to.be.revertedWith("Invalid security level");
    });
  });

  describe("Quantum Message Routing", function () {
    let channelId;

    beforeEach(async function () {
      // Create channel first
      const tx = await odinRouting.connect(alice).createQuantumChannel(
        bob.address,
        3,
        50
      );

      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "QuantumChannelCreated");
      channelId = event.args.channelId;
    });

    it("Should route quantum message successfully", async function () {
      const contentHash = ethers.utils.id("Secret Message");
      
      const tx = await odinRouting.connect(alice).routeQuantumMessage(
        channelId,
        bob.address,
        contentHash,
        5 // routing hops
      );

      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "QuantumMessageRouted");

      expect(event).to.not.be.undefined;
      expect(event.args.sender).to.equal(alice.address);
      expect(event.args.recipient).to.equal(bob.address);
      expect(event.args.routingHops).to.equal(5);
    });

    it("Should update total messages routed", async function () {
      const contentHash = ethers.utils.id("Secret Message");
      
      await odinRouting.connect(alice).routeQuantumMessage(
        channelId,
        bob.address,
        contentHash,
        5
      );

      const stats = await odinRouting.getNetworkStats();
      expect(stats._totalMessagesRouted).to.equal(1);
    });

    it("Should reject message without channel access", async function () {
      const contentHash = ethers.utils.id("Secret Message");
      
      await expect(
        odinRouting.connect(node1).routeQuantumMessage(
          channelId,
          bob.address,
          contentHash,
          5
        )
      ).to.be.revertedWith("No channel access");
    });

    it("Should reject invalid routing hops", async function () {
      const contentHash = ethers.utils.id("Secret Message");
      
      await expect(
        odinRouting.connect(alice).routeQuantumMessage(
          channelId,
          bob.address,
          contentHash,
          11 // too many hops
        )
      ).to.be.revertedWith("Invalid routing hops");
    });
  });

  describe("Routing Node Management", function () {
    it("Should register routing node successfully", async function () {
      await odinRouting.connect(node1).registerRoutingNode(75);

      const nodeInfo = await odinRouting.getRoutingNode(node1.address);
      expect(nodeInfo.isActive).to.be.true;
      expect(nodeInfo.tier4bLevel).to.equal(75);
      expect(nodeInfo.reliability).to.equal(50); // starts at 50%
    });

    it("Should reject node with insufficient Tier 4B", async function () {
      // Create a user with low Tier 4B
      const [, , , , lowTierUser] = await ethers.getSigners();
      await odinRouting.grantTier4bRecognition(lowTierUser.address, 20);

      await expect(
        odinRouting.connect(lowTierUser).registerRoutingNode(20)
      ).to.be.revertedWith("Insufficient Tier 4B level");
    });

    it("Should send heartbeat successfully", async function () {
      await odinRouting.connect(node1).registerRoutingNode(75);
      
      await expect(
        odinRouting.connect(node1).sendNodeHeartbeat()
      ).to.not.be.reverted;
    });

    it("Should deactivate node", async function () {
      await odinRouting.connect(node1).registerRoutingNode(75);
      await odinRouting.connect(node1).deactivateNode();

      const nodeInfo = await odinRouting.getRoutingNode(node1.address);
      expect(nodeInfo.isActive).to.be.false;
    });
  });

  describe("Message Delivery Confirmation", function () {
    let channelId;
    let messageId;

    beforeEach(async function () {
      // Register node
      await odinRouting.connect(node1).registerRoutingNode(75);

      // Create channel
      const tx1 = await odinRouting.connect(alice).createQuantumChannel(
        bob.address,
        3,
        50
      );
      const receipt1 = await tx1.wait();
      channelId = receipt1.events.find(e => e.event === "QuantumChannelCreated").args.channelId;

      // Route message
      const contentHash = ethers.utils.id("Secret Message");
      const tx2 = await odinRouting.connect(alice).routeQuantumMessage(
        channelId,
        bob.address,
        contentHash,
        5
      );
      const receipt2 = await tx2.wait();
      messageId = receipt2.events.find(e => e.event === "QuantumMessageRouted").args.messageId;
    });

    it("Should confirm message delivery", async function () {
      await odinRouting.connect(node1).confirmMessageDelivery(
        messageId,
        963 // optimal resonance
      );

      const message = await odinRouting.getQuantumMessage(messageId);
      expect(message.isDelivered).to.be.true;
      expect(message.isVerified).to.be.true; // within tolerance
    });

    it("Should verify resonance alignment", async function () {
      const tx = await odinRouting.connect(node1).confirmMessageDelivery(
        messageId,
        965 // within tolerance
      );

      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "ResonanceVerified");
      expect(event.args.isOptimal).to.be.true;
    });

    it("Should update node reliability on successful delivery", async function () {
      await odinRouting.connect(node1).confirmMessageDelivery(
        messageId,
        963
      );

      const nodeInfo = await odinRouting.getRoutingNode(node1.address);
      expect(nodeInfo.messagesRouted).to.equal(1);
      expect(nodeInfo.reliability).to.equal(51); // increased by 1
    });
  });

  describe("Administrative Functions", function () {
    it("Should upgrade channel security", async function () {
      const tx = await odinRouting.connect(alice).createQuantumChannel(
        bob.address,
        2,
        50
      );
      const receipt = await tx.wait();
      const channelId = receipt.events.find(e => e.event === "QuantumChannelCreated").args.channelId;

      await odinRouting.connect(alice).upgradeChannelSecurity(channelId, 4);

      const channel = await odinRouting.getQuantumChannel(channelId);
      expect(channel.securityLevel).to.equal(4);
    });

    it("Should grant additional channel access", async function () {
      const tx = await odinRouting.connect(alice).createQuantumChannel(
        bob.address,
        3,
        50
      );
      const receipt = await tx.wait();
      const channelId = receipt.events.find(e => e.event === "QuantumChannelCreated").args.channelId;

      await odinRouting.connect(alice).grantChannelAccess(channelId, node1.address);

      expect(await odinRouting.hasChannelAccess(channelId, node1.address)).to.be.true;
    });

    it("Should revoke channel access", async function () {
      const tx = await odinRouting.connect(alice).createQuantumChannel(
        bob.address,
        3,
        50
      );
      const receipt = await tx.wait();
      const channelId = receipt.events.find(e => e.event === "QuantumChannelCreated").args.channelId;

      await odinRouting.connect(alice).revokeChannelAccess(channelId, bob.address);

      expect(await odinRouting.hasChannelAccess(channelId, bob.address)).to.be.false;
    });
  });

  describe("Tier 4B Recognition", function () {
    it("Should grant Tier 4B recognition", async function () {
      const [, , , , newUser] = await ethers.getSigners();
      
      await odinRouting.grantTier4bRecognition(newUser.address, 80);
      expect(await odinRouting.tier4bRecognition(newUser.address)).to.equal(80);
    });

    it("Should update node Tier 4B when recognized", async function () {
      await odinRouting.connect(node1).registerRoutingNode(75);
      
      await odinRouting.grantTier4bRecognition(node1.address, 90);
      
      const nodeInfo = await odinRouting.getRoutingNode(node1.address);
      expect(nodeInfo.tier4bLevel).to.equal(90);
    });
  });
});
