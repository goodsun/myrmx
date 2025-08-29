require("@nomiclabs/hardhat-waffle");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      outputSelection: {
        "*": {
          "*": [
            "abi",
            "evm.bytecode",
            "evm.deployedBytecode",
            "evm.methodIdentifiers",
            "metadata"
          ],
          "": [
            "ast"
          ]
        }
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 1337,
      gas: 30000000, // 30M gas limit
      blockGasLimit: 30000000,
      allowUnlimitedContractSize: true
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      gas: 30000000, // 30M gas limit
      blockGasLimit: 30000000
    }
  },
  gasReporter: {
    enabled: true,
    currency: 'USD'
  }
};