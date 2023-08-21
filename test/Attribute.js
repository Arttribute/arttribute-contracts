// test/Arttribute.js

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Arttribute", function () {
  let Arttribute, arttribute, owner, addr1, addr2;
  let item1 = ["Artwork1", "Description", false];

  beforeEach(async function () {
    Arttribute = await ethers.getContractFactory("Arttribute");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    arttribute = await Arttribute.deploy();
  });

  it("should allow creation of an item", async function () {
    await arttribute.createItem(...item1);
    const item = await arttribute.getItem(1);
    expect(item.title).to.equal(item1[0]);
    expect(item.details).to.equal(item1[1]);
    expect(item.requiresPayment).to.equal(item1[2]);
  });

  it("should not mint a certificate for non-existent item", async function () {
    await expect(
      arttribute.mintCertificate(addr1.address, 2, "Certificate for Artwork2")
    ).to.be.revertedWith("Item does not exist");
  });

  it("should mint a certificate for an existing item", async function () {
    await arttribute.createItem(...item1);
    await arttribute.mintCertificate(
      addr1.address,
      1,
      "Certificate for Artwork1"
    );
    const certificate = await arttribute.getCertificate(1);
    expect(certificate.details).to.equal("Certificate for Artwork1");
  });

  it("should not mint a certificate if required payment is not sent", async function () {
    await arttribute.createItem("Artwork2", "Description for Artwork2", true);
    await expect(
      arttribute.mintCertificate(addr1.address, 1, "Certificate for Artwork2")
    ).to.be.revertedWith("No amount sent");
  });

  it("should mint a certificate if required payment is sent", async function () {
    await arttribute.createItem("Artwork2", "Description for Artwork2", true);
    await arttribute.mintCertificate(
      addr1.address,
      1,
      "Certificate for Artwork2",
      {
        value: ethers.parseEther("0.1"),
      }
    );
    const certificate = await arttribute.getCertificate(1);
    expect(certificate.details).to.equal("Certificate for Artwork2");
  });
});
