import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/s-hdjLqITCIC-0yx948QMzzi7v-43Sss",
      accounts: [process.env.TESTNET_PRIV_KEY ?? ""],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: "1T7UC6DGWNA36AVHC4IGIRRE1MTGCSKE74",
    },
  },
};

export default config;
