const { ethers } = require("hardhat");

describe("Attribution", function () {
  it("Handless Attribution", async function () {
    //Deploying ArtAttribution contract
    const ArtAttribution = await ethers.getContractFactory("Attribution");
    const artAttributionContract = await ArtAttribution.deploy();
    await artAttributionContract.deployed();

    const [_, firstMemberAddress] = await ethers.getSigners();
  });
});
