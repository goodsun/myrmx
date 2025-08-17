require("@nomiclabs/hardhat-waffle");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    custom: {
      url: "YOUR_RPC_URL", // Chain ID 21201のRPC URLを設定
      chainId: 21201,
      accounts: [] // プライベートキーを設定
    }
  }
};