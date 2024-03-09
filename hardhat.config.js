require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: __dirname + "/.env" });

const projectId = process.env.PROJECT_ID;
const privateKey = process.env.PRIVATE_KEY;
module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
    },
    //Celo
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
    //Base
    basemainnet: {
      url: "https://mainnet.base.org",
      accounts: [privateKey],
      gasPrice: 1000000000,
    },
    basegoerli: {
      url: "https://goerli.base.org",
      accounts: [privateKey],
      gasPrice: 1000000000,
    },
    baselocal: {
      url: "http://localhost:8545",
      accounts: [privateKey],
      gasPrice: 1000000000,
    },
    //Filecoin
    calibration: {
      chainId: 314159,
      url: "https://api.calibration.node.glif.io/rpc/v1",
      accounts: [privateKey],
    },
  },
  solidity: "0.8.4",
};
