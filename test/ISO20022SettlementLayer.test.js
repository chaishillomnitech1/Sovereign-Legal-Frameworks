const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ISO20022SettlementLayer", function () {
  let healToken;
  let settlementLayer;
  let owner;
  let treasury;
  let debtor;
  let creditor;

  const INITIAL_SUPPLY = ethers.utils.parseEther("1000000000"); // 1B tokens

  beforeEach(async function () {
    [owner, treasury, debtor, creditor] = await ethers.getSigners();

    // Deploy HEAL Token
    const HealToken = await ethers.getContractFactory("HealToken");
    healToken = await HealToken.deploy(1000000000);
    await healToken.deployed();

    // Deploy ISO 20022 Settlement Layer
    const ISO20022SettlementLayer = await ethers.getContractFactory("ISO20022SettlementLayer");
    settlementLayer = await ISO20022SettlementLayer.deploy(
      healToken.address,
      treasury.address
    );
    await settlementLayer.deployed();

    // Transfer tokens to debtor
    await healToken.transfer(debtor.address, ethers.utils.parseEther("10000"));
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await settlementLayer.owner()).to.equal(owner.address);
    });

    it("Should set the correct HEAL token", async function () {
      expect(await settlementLayer.healToken()).to.equal(healToken.address);
    });

    it("Should set the correct treasury", async function () {
      expect(await settlementLayer.treasury()).to.equal(treasury.address);
    });

    it("Should set default treasury tax rate", async function () {
      expect(await settlementLayer.treasuryTaxBasisPoints()).to.equal(50); // 0.5%
    });
  });

  describe("Payment Initiation", function () {
    it("Should initiate payment successfully", async function () {
      const paymentInfoId = "PMT-001";
      const amount = ethers.utils.parseEther("1000");
      const endToEndId = "E2E-001";
      const purpose = "PAYMENT";
      const xmlStructure = "pain.001.001.03";

      const tx = await settlementLayer.connect(debtor).initiatePayment(
        paymentInfoId,
        creditor.address,
        amount,
        endToEndId,
        purpose,
        xmlStructure
      );

      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "PaymentInitiated");
      
      expect(event).to.not.be.undefined;
      expect(event.args.debtor).to.equal(debtor.address);
      expect(event.args.creditor).to.equal(creditor.address);
      expect(event.args.amount).to.equal(amount);
    });

    it("Should reject payment with invalid creditor", async function () {
      await expect(
        settlementLayer.connect(debtor).initiatePayment(
          "PMT-001",
          ethers.constants.AddressZero,
          ethers.utils.parseEther("1000"),
          "E2E-001",
          "PAYMENT",
          "pain.001.001.03"
        )
      ).to.be.revertedWith("Invalid creditor");
    });

    it("Should reject payment with zero amount", async function () {
      await expect(
        settlementLayer.connect(debtor).initiatePayment(
          "PMT-001",
          creditor.address,
          0,
          "E2E-001",
          "PAYMENT",
          "pain.001.001.03"
        )
      ).to.be.revertedWith("Invalid amount");
    });
  });

  describe("Settlement Execution", function () {
    let messageId;

    beforeEach(async function () {
      // Initiate payment first
      const tx = await settlementLayer.connect(debtor).initiatePayment(
        "PMT-001",
        creditor.address,
        ethers.utils.parseEther("1000"),
        "E2E-001",
        "PAYMENT",
        "pain.001.001.03"
      );

      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "PaymentInitiated");
      messageId = event.args.messageId;

      // Approve settlement layer to spend tokens
      await healToken.connect(debtor).approve(
        settlementLayer.address,
        ethers.utils.parseEther("10000")
      );
    });

    it("Should execute settlement successfully", async function () {
      const debtorBalanceBefore = await healToken.balanceOf(debtor.address);
      const creditorBalanceBefore = await healToken.balanceOf(creditor.address);
      const treasuryBalanceBefore = await healToken.balanceOf(treasury.address);

      await settlementLayer.connect(debtor).executeSettlement(messageId, true);

      const debtorBalanceAfter = await healToken.balanceOf(debtor.address);
      const creditorBalanceAfter = await healToken.balanceOf(creditor.address);
      const treasuryBalanceAfter = await healToken.balanceOf(treasury.address);

      // Calculate expected amounts (0.5% tax)
      const amount = ethers.utils.parseEther("1000");
      const tax = amount.mul(50).div(10000); // 0.5%
      const netAmount = amount.sub(tax);

      expect(debtorBalanceAfter).to.equal(debtorBalanceBefore.sub(amount));
      expect(creditorBalanceAfter).to.equal(creditorBalanceBefore.add(netAmount));
      expect(treasuryBalanceAfter).to.equal(treasuryBalanceBefore.add(tax));
    });

    it("Should update settlement statistics", async function () {
      await settlementLayer.connect(debtor).executeSettlement(messageId, true);

      const stats = await settlementLayer.getSettlementStats();
      expect(stats._totalSettlements).to.equal(1);
      expect(stats._totalVolumeSettled).to.equal(ethers.utils.parseEther("1000"));
    });

    it("Should prevent double execution", async function () {
      await settlementLayer.connect(debtor).executeSettlement(messageId, true);

      await expect(
        settlementLayer.connect(debtor).executeSettlement(messageId, true)
      ).to.be.revertedWith("Already executed");
    });

    it("Should only allow debtor to execute settlement", async function () {
      await expect(
        settlementLayer.connect(creditor).executeSettlement(messageId, true)
      ).to.be.revertedWith("Not authorized");
    });
  });

  describe("Tier 4B Recognition", function () {
    it("Should set Tier 4B recognition", async function () {
      await settlementLayer.setTier4bRecognition(debtor.address, 75);
      expect(await settlementLayer.tier4bRecognitionLevel(debtor.address)).to.equal(75);
    });

    it("Should reject invalid recognition level", async function () {
      await expect(
        settlementLayer.setTier4bRecognition(debtor.address, 101)
      ).to.be.revertedWith("Invalid recognition level");
    });

    it("Should only allow owner to set recognition", async function () {
      await expect(
        settlementLayer.connect(debtor).setTier4bRecognition(creditor.address, 50)
      ).to.be.revertedWith("Not authorized");
    });
  });

  describe("Treasury Tax Management", function () {
    it("Should update treasury tax rate", async function () {
      await settlementLayer.setTreasuryTaxRate(100); // 1%
      expect(await settlementLayer.treasuryTaxBasisPoints()).to.equal(100);
    });

    it("Should reject tax rate above 10%", async function () {
      await expect(
        settlementLayer.setTreasuryTaxRate(1001)
      ).to.be.revertedWith("Tax rate too high");
    });

    it("Should update treasury address", async function () {
      const newTreasury = creditor.address;
      await settlementLayer.setTreasury(newTreasury);
      expect(await settlementLayer.treasury()).to.equal(newTreasury);
    });
  });

  describe("View Functions", function () {
    it("Should return payment initiation details", async function () {
      const tx = await settlementLayer.connect(debtor).initiatePayment(
        "PMT-001",
        creditor.address,
        ethers.utils.parseEther("1000"),
        "E2E-001",
        "PAYMENT",
        "pain.001.001.03"
      );

      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "PaymentInitiated");
      const messageId = event.args.messageId;

      const payment = await settlementLayer.getPaymentInitiation(messageId);
      expect(payment.debtor).to.equal(debtor.address);
      expect(payment.creditor).to.equal(creditor.address);
      expect(payment.amount).to.equal(ethers.utils.parseEther("1000"));
    });

    it("Should return payment status", async function () {
      const tx = await settlementLayer.connect(debtor).initiatePayment(
        "PMT-001",
        creditor.address,
        ethers.utils.parseEther("1000"),
        "E2E-001",
        "PAYMENT",
        "pain.001.001.03"
      );

      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "PaymentInitiated");
      const messageId = event.args.messageId;

      const status = await settlementLayer.getPaymentStatus(messageId);
      expect(status.statusCode).to.equal("PDNG");
    });
  });
});
