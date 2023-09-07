require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: __dirname + "/.env" });
const projectId = process.env.PROJECT_ID;
const privateKey = process.env.PRIVATE_KEY;
module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
    },
    alfajores: {
      chainId: 44787,
      url: `https://celo-alfajores.infura.io/v3/${projectId}`,
      accounts: [privateKey],
    },
    celo: {
      chainId: 42220,
      url: "https://forno.celo.org",
      accounts: [privateKey],
    },
  },
  solidity: "0.8.4",
};
