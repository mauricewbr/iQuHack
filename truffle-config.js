require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');
const { INFURA_API_KEY, MNEMONIC } = process.env;

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },
    goerli: {
      provider: () => new HDWalletProvider(MNEMONIC, INFURA_API_KEY),
      network_id: '5',
      gas: 4465030
    }
  },
  compilers: {
    solc: {
      version: "^0.7.0",
      settings: {
        optimizer: {
          enabled: true,
          runs: 5
        }
      }
    }
  },
  contracts_directory: ["./libraries/Utils"],
};
