# Utility Token 
Smart contract project for a decentralized platform that allows users to invest and trade FNFT Platform (Financial Non-Fungible Tokens) representing various financial products. The platform will use its own native token for transactions and offer a unique value proposition to users through a dividend distribution mechanism.

## Prerequisites

---------------

- [Node.js](https://nodejs.org/es/download/)
- [Yarn](https://classic.yarnpkg.com/en/docs/install#mac-stable)
- [HardHat](https://hardhat.org/hardhat-runner/docs/getting-started#installation/)

## Intalled Libraries

| Tool | Versión | yarn install |
| -------- | ------- | --------------------- |
| Hardhat | 2.6.4 | `yarn add --dev hardhat` |
| TypeScript | 4.5.2 | `yarn add --dev typescript` |
| Mocha | 9.1.1 | `yarn add --dev mocha` |
| Chai | 4.3.4 | `yarn add --dev chai` |
| Ethers | 5.5.3 | `yarn add ethers` |
| Hardhat Ethers | 2.0.2 | `yarn add --dev @nomiclabs/hardhat-ethers` |
| Hardhat Waffle | 2.0.2 | `yarn add --dev @nomiclabs/hardhat-waffle` |
| Waffle | 3.0.0 | `yarn add --dev @ethereum-waffle/waffle` |
| @typechain/hardhat | 1.3.0 | `yarn add --dev @typechain/hardhat` |
| @typechain/ethers-v5 | 5.5.0 | `yarn add --dev @typechain/ethers-v5` |
| OpenZeppelin Contracts | 4.4.0 | `yarn add @openzeppelin/contracts` |
| Solhint | 3.4.0 | `yarn add --dev solhint` |
| Dotenv | 10.0.0 | `yarn add --dev dotenv` |
| Hardhat ABI Exporter | 2.0.0 | `yarn add --dev @nomiclabs/hardhat-abi-exporter` |
| Hardhat Contract Sizer | 0.4.0 | `yarn add --dev @jdutton/hardhat-contract-sizer` |
| Prettier | 2.4.1 | `yarn add --dev prettier` |
| Prettier Plugin Solidity | 1.1.0 | `yarn add --dev prettier-plugin-solidity` |
## Prerequisites

You will need to have Node.js and Yarn (or npm) installed on your machine. Additionally, you will need to have a private key and an Ethereum node URL compatible with Ethereum (for example, through QuickNode or Alchemy) to deploy the contract.

## Installation

Clone the repository to your local machine and install project dependencies:

```bash
git clone https://github.com/bbproject01/bb-core.git
cd bb-core
yarn
```

## Compilation
Create a configuration file (.env) with the following variables:

RCP_URL_API_KEY=HERE_GOES_THE_QUICKNODE_URL
PRIVATE_KEY=HERE_GOES_THE_PRIVATE_KEY
To compile the contract, run the following command in your terminal:
```bash
yarn hardhat compile
```

## Deploy 
To deploy the ERC20 and FNFT smart contracts, run only the deploy.ts script:
```bash
yarn hardhat run scripts/deploy.ts --network mumbai
```

To deploy only the FNFT smart contract, add the following variable to the configuration file (.env):

- **ADDRESS_TOKEN_BNB**=AQUI_VA_EL_ADDRESS_DEL_SMARTCONTRAC_ERC20

```bash
yarn hardhat run scripts/FNFT.deploy.ts --network mumbai 
```
## Testing

### Local Tests

For local tests with HardHat and time increase on the blockchain, run the local network and do not close the window:
```bash
npx hardhat node --network hardhat
```

Run all files in the test folder:
```bash
npx hardhat test test/*.ts
```

Run file by file:
```bash
npx hardhat test test/erc20.ts
npx hardhat test test/fnftTests.ts
```

### Tests with Custom Networks

Have the network running.

Run tests with a specific network in the Hardhat configuration file:
```bash
npx hardhat test test/*.ts --network NOMBRE_RED
```

Run file by file:
```bash
npx hardhat test test/erc20.ts --network NOMBRE_RED
npx hardhat test test/erc1155Lock.test.ts --network NOMBRE_RED
npx hardhat test test/fnftTests.ts --network NOMBRE_RED
```

### Note
Tests that involve modifying time will only work with the internal Ganache network that runs in the terminal.

## Address SmartContracts
BBTOKEN: 0x62ba02826ef23F4ce9Ac11B72CB31Aadb85878F9
FNFT:    0xe1140DdE4F1Bacdc7aBf0DDf80eb5adbD39989DC