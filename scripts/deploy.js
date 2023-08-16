const hre = require("hardhat");

async function main() {
  const Attribution = await hre.ethers.getContractFactory("Attribution");
  const contract = await Attribution.deploy();
  await contract.deployed();
  console.log("Attribution contract deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
