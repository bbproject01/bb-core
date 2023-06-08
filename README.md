# bb-base-core
This blockchain base project provides a basic and solid infrastructure for developers to build blockchain applications more easily. The base project includes a basic setup of the blockchain infrastructure, smart contracts, libraries and dependencies, documentation, and continuous integration tools.


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
## Prerequisitos

Necesitarás tener instalado Node.js y Yarn (o npm) en tu máquina. Además, necesitarás tener una clave privada y una URL de nodo compatible con Ethereum (por ejemplo, a través de QuickNode o Alchemy) para desplegar el contrato.

## Instalación

Clona el repositorio en tu máquina local:

```bash
git clone https://github.com/bbproject01/bb-core.git
cd bb-core
```
## Compilación
Para compilar el contrato, ejecuta el siguiente comando en tu terminal:
```bash
yarn hardhat compile
```
## Deploy 
```bash
yarn hardhat run scripts/deploy.ts --network mumbai 
```
## Pruebas
```bash
npx hardhat node --network hardhat  
# in another shell
yarn hardhat test
```

## Address SmartContracts
BBTOKEN: 0x62ba02826ef23F4ce9Ac11B72CB31Aadb85878F9
FNFT:    0xDA6B5508E7cd46B238a2B2b9D9EdA8Eb0cD8a40C