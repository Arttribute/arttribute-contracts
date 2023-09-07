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
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
