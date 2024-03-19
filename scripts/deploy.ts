const hre = require("hardhat");

async function main() {
  const ArttributeCertificate = await hre.ethers.getContractFactory(
    "ArttributeCertificate"
  );
  const contract = await ArttributeCertificate.deploy();
  await contract.waitForDeployment();
  console.log(
    "ArttributeCertificate contract deployed to:",
    await contract.getAddress()
  );

  const AIModelRegistry = await hre.ethers.getContractFactory(
    "AIModelRegistry"
  );
  const aiModelRegistry = await AIModelRegistry.deploy();

  await aiModelRegistry.waitForDeployment();
  console.log(
    "AIModelRegistry contract deployed to:",
    await aiModelRegistry.getAddress()
  );

  const aiModelRegistryAddress = await aiModelRegistry.getAddress();
  const AIArtNFT = await hre.ethers.getContractFactory("AIArtNFT");
  const aiArtNFT = await AIArtNFT.deploy(aiModelRegistryAddress);

  await aiArtNFT.waitForDeployment();
  console.log("AIArtNFT contract deployed to:", await aiArtNFT.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
