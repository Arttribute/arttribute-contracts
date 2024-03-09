const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("ArttributeCertificate", function () {
  let ArttributeCertificate, arttributeCertificate, owner, addr1;

  beforeEach(async function () {
    ArttributeCertificate = await ethers.getContractFactory(
      "ArttributeCertificate"
    );
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    arttributeCertificate = await ArttributeCertificate.deploy();
  });

  describe("Minting certificates", function () {
    it("Should mint a new certificate", async function () {
      const itemId = 1;
      const details = "Test certificate details";
      const tokenUri = "Test token URI";
      await arttributeCertificate
        .connect(owner)
        .mintCertificate(addr1.address, itemId, details, tokenUri);

      const tokenId = 1;
      // Verify that the certificate was correctly minted
      const certificate = await arttributeCertificate.getCertificate(tokenId);
      expect(certificate.licensedItemId).to.equal(itemId);
      expect(certificate.details).to.equal(details);
    });

    it("Should emit the CertificateMinted event upon minting", async function () {
      const itemId = 1;
      const details = "Test certificate details";
      const tokenUri = "Test token URI";
      await expect(
        arttributeCertificate
          .connect(owner)
          .mintCertificate(addr1.address, itemId, details, tokenUri)
      )
        .to.emit(arttributeCertificate, "CertificateMinted")
        .withArgs(1, addr1.address, itemId, details, tokenUri);
    });
  });

  describe("Querying certificates", function () {
    it("Should revert if querying a non-existent certificate", async function () {
      await expect(
        arttributeCertificate.getCertificate(999)
      ).to.be.revertedWith("Certificate does not exist");
    });
  });
});

describe("AIModelRegistry", function () {
  let AIModelRegistry;
  let aiModelRegistry;
  let owner, addr1;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    AIModelRegistry = await ethers.getContractFactory("AIModelRegistry");
    aiModelRegistry = await AIModelRegistry.deploy();
    aiModelRegistry.waitForDeployment();
  });

  it("Should deploy successfully with correct name and symbol", async function () {
    expect(await aiModelRegistry.name()).to.equal("AI Model");
    expect(await aiModelRegistry.symbol()).to.equal("AIMDL");
  });

  it("Should mint a model and set royalty correctly", async function () {
    const mintTx = await aiModelRegistry.mintModel(
      addr1.address,
      "http://example.com/model1",
      1000
    ); // 10% royalty
    await mintTx.wait();

    const newModelId = 1;
    expect(await aiModelRegistry.ownerOf(newModelId)).to.equal(addr1.address);
    expect(await aiModelRegistry.getModelRoyalty(newModelId)).to.equal(1000);
  });

  it("Should revert minting with royalty percentage out of bounds", async function () {
    await expect(
      aiModelRegistry.mintModel(
        addr1.address,
        "http://example.com/model2",
        10001
      )
    ).to.be.revertedWith("Royalty percentage out of bounds");
  });
});

describe("AIArtNFT", function () {
  let AIArtNFT, AIModelRegistry;
  let aiArtNFT, aiModelRegistry;
  let owner, addr1;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    AIModelRegistry = await ethers.getContractFactory("AIModelRegistry");
    aiModelRegistry = await AIModelRegistry.deploy();

    aiModelRegistry.waitForDeployment();
    aiModelRegistryAddress = await aiModelRegistry.getAddress();
    AIArtNFT = await ethers.getContractFactory("AIArtNFT");
    aiArtNFT = await AIArtNFT.deploy(aiModelRegistryAddress);
  });

  it("Should mint AI Art NFT with correct royalties from AI Model", async function () {
    // First, mint a model
    await aiModelRegistry
      .connect(owner)
      .mintModel(owner.address, "http://example.com/model1", 500); // 5% royalty
    const modelId = 1;

    // Now, mint AI Art NFT using the model
    await aiArtNFT
      .connect(owner)
      .mintAIArt(modelId, addr1.address, "http://example.com/art1");
    const newArtId = 1;

    expect(await aiArtNFT.ownerOf(newArtId)).to.equal(addr1.address);
    expect(await aiArtNFT.tokenURI(newArtId)).to.equal(
      "http://example.com/art1"
    );
  });
});
