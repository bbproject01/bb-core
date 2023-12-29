import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/5vjC3Fw2meujUNzb4SMJuD9wJ41rFnqW",
      accounts: [
        "7008c7ceaa8ef18f98f960d15c5becd51a312f3da59aabfb05f293f019f91fa6",
      ],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: "1T7UC6DGWNA36AVHC4IGIRRE1MTGCSKE74",
    },
  },
};

export default config;
