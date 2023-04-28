require("@nomicfoundation/hardhat-toolbox");
require("dotenv/config")
require("@nomiclabs/hardhat-etherscan")
//npm install @nomiclabs/hardhat-etherscan
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    
    // for mainnet
    'optimism': {
      url: "https://mainnet.optimism.io",
      accounts: [process.env.pvtKey]
    },
    // for testnet
    'optimisticGoerli': {
      url: "https://goerli.optimism.io",
      accounts: [process.env.pvtKey]
    },
    // for the local dev environment
    'local': {
      url: "http://localhost:8545",
      accounts: [process.env.pvtKey]
    },
    'sepolia': {
      url: `https://rpc2.sepolia.org`,
      accounts: [process.env.pvtKey]
    }

  },
  etherscan: {
    apiKey: 'GI8ETREFKCXVRETF9W56YVXZVFA4C5R5AK',
  },
  solidity: {
  compilers: [
    {version: "0.5.16",},
    {version: "0.8.4",},
    {version: "0.6.6",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,},},},
    {version: "0.6.2",},
    {version: "0.4.18",},
    {version: "0.8.9",},

  ]}
};