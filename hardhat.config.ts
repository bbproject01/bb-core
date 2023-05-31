import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-solhint'
import '@nomiclabs/hardhat-truffle5'
import '@nomiclabs/hardhat-waffle'
import dotenv from 'dotenv'
import 'hardhat-abi-exporter'
import 'hardhat-contract-sizer'
import 'hardhat-deploy'
import 'hardhat-gas-reporter'
import { HardhatUserConfig } from 'hardhat/config'

dotenv.config({ debug: false })

let real_accounts = undefined
if (process.env.DEPLOYER_KEY) {
  real_accounts = [
    process.env.DEPLOYER_KEY,
    process.env.OWNER_KEY || process.env.DEPLOYER_KEY,
  ]
}

const { RCP_URL_API_KEY, PRIVATE_KEY } = process.env;
console.log("🚀 ~ file: hardhat.config.ts:23 ~  RCP_URL_API_KEY, PRIVATE_KEY:",  RCP_URL_API_KEY, PRIVATE_KEY)




const config: HardhatUserConfig = {
  defaultNetwork: "mumbai",
  networks: {    
    localhost: {
      url: 'http://127.0.0.1:8545',            
    },
    mumbai: {
      url: RCP_URL_API_KEY,
      accounts: [`0x${PRIVATE_KEY}`]
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,      
      chainId: 5,      
    },    
  },
  mocha: {},
  solidity: {
    compilers: [
      {
        version: '0.8.17',
        settings: {
          optimizer: {
            enabled: true,
            runs: 1300,
          },
        },
      },            
    ],
  }
};

export default config;
