import { HardhatUserConfig } from 'hardhat/config';
import dotenv from 'dotenv';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-solhint';
import '@nomiclabs/hardhat-truffle5';
import '@nomiclabs/hardhat-waffle';
require('hardhat-abi-exporter');
import 'hardhat-contract-sizer';
import 'hardhat-deploy';
import 'hardhat-gas-reporter';
// import 'hardhat-typechain'

dotenv.config({ debug: false });

let real_accounts = undefined;
if (process.env.DEPLOYER_KEY) {
  real_accounts = [process.env.DEPLOYER_KEY, process.env.OWNER_KEY || process.env.DEPLOYER_KEY];
}

const { RCP_URL_API_KEY, PRIVATE_KEY } = process.env;

// hack
interface ExtendedHardhatUserConfig extends HardhatUserConfig {
  abiExporter?: {
    path: string;
    clear?: boolean;
    flat?: boolean;
    only?: boolean;
    spacing?: number;
    runOnCompile?: boolean;
  };
  // typechain: {
  //   outDir: string;
  //   target: string;
  // };
}

const config: ExtendedHardhatUserConfig = {
  defaultNetwork: 'localhost',
  networks: {
    hardhat: {
      gas: 100000000, // Ajusta el límite de gas según sea necesario
    },
    localhost: {
      url: 'http://127.0.0.1:8545',
      chainId: 31337,
    },
    // mumbai: {
    //   url: RCP_URL_API_KEY,
    //   accounts: [`0x${PRIVATE_KEY}`],
    // },
    // goerli: {
    //   url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
    //   chainId: 5,
    // },
    sepolia: {
      url: 'https://eth-sepolia.g.alchemy.com/v2/5vjC3Fw2meujUNzb4SMJuD9wJ41rFnqW',
      accounts: [process.env.PRIVATE_KEY_TESTNET ?? ''],
    },
    ganache: {
      url: 'http://127.0.0.1:7545',
      chainId: 1337,
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
  },
  abiExporter: {
    path: './data/abi', // ruta de exportación para los ABI
    clear: true, // borrar la carpeta existente antes de generar nuevos ABI
    flat: true, // poner todos los ABI en la misma carpeta, sin importar el nombre del contrato
    runOnCompile: true,
  },
  // typechain: {
  //   outDir: "typechain",
  //   target: "ethers-v5", // Ajusta esto a tu biblioteca de Ethereum preferida si no estás usando ethers.js
  // },
};

export default config;
