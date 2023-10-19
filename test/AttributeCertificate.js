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
