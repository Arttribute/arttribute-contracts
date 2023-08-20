const { ethers } = require("hardhat");

describe("Arttribute Items", function () {
  it("Handles item creation", async function () {
    //Deploying ArttributeRegistry contract
    const ArttributeRegistry = await ethers.getContractFactory(
      "ArttributeRegistry"
    );
    const arttributeRegistryContract = await ArttributeRegistry.deploy();

    //Create new Item
    await arttributeRegistryContract.createItem("testItem", "testUrl");
    await arttributeRegistryContract.createItem("testItem", "testUrl");
    await arttributeRegistryContract.createItem("testItem", "testUrl");
    await arttributeRegistryContract.createItem("testItem", "testUrl");

    //Get Items
    const items = await arttributeRegistryContract.getAllItems();
    console.log(items);
    //Get Items by owner
    const itemsByOwner = await arttributeRegistryContract.getItemsByOwner(
      "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
    );
    console.log(itemsByOwner);
  });
});

describe("Arttribute Certificates", function () {
  it("Handles certificates", async function () {
    //Deploying ArttributeCertificates contract
    const ArttributeCertificates = await ethers.getContractFactory(
      "ArttributeCertificates"
    );
    const arttributeCertificatesContract =
      await ArttributeCertificates.deploy();

    //Minting certificate
    await arttributeCertificatesContract.mintCertificate(
      "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
      0,
      "testDetails"
    );

    await arttributeCertificatesContract.mintCertificate(
      "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
      1,
      "testDetails"
    );

    await arttributeCertificatesContract.mintCertificate(
      "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
      2,
      "testDetails"
    );

    await arttributeCertificatesContract.mintCertificate(
      "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
      3,
      "testDetails"
    );

    //Get Certificate
    const certificate = await arttributeCertificatesContract.getCertificate(1);
    console.log(certificate);

    //Get certifcate by owner
    const certificateByOwner =
      await arttributeCertificatesContract.getCertificatesByOwner(
        "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
      );
    console.log(certificateByOwner);
  });
});
