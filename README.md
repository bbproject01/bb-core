# bb-base-core
Proyecto base de contratos inteligentes para una plataforma 
descentralizada que permita a los usuarios 
invertir e intercambiar FNFT Platform (Financial Non-Fungible Tokens) 
que representan diversos productos financieros. La plataforma 
utilizará su propio token nativo para las transacciones y ofrecerá 
una propuesta de valor única para los usuarios mediante un mecanismo 
de distribución de dividendos.

## Prerequisites

---------------

- [Node.js](https://nodejs.org/es/download/)
- [Yarn](https://classic.yarnpkg.com/en/docs/install#mac-stable)
- [Ganache](https://trufflesuite.com/ganache/)

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

Clona el repositorio en tu máquina local e instalar las dependencias del proyecto:

```bash
git clone https://github.com/bbproject01/bb-core.git
cd bb-core
yarn
```

## Compilación
Cear un archivo de configuración (.env) con las siguientes variables:

- **RCP_URL_API_KEY**=AQUI_VA_EL_URL_DEL_QUICKNODE
- **PRIVATE_KEY**=AQUI_VA_LA_LLAVE_PRIVADA


Para compilar el contrato, ejecuta el siguiente comando en tu terminal:
```bash
yarn hardhat compile
```

## Deploy 
Para desplegar los contratos inteligentes ERC20 y FNFT ejecute solo el script deploy.ts
```bash
yarn hardhat run scripts/deploy.ts --network mumbai
```

Para desplegar solo el contrato inteligente FNFT agregar la siguiente variable al archivo de configuración (.env)

- **ADDRESS_TOKEN_BNB**=AQUI_VA_EL_ADDRESS_DEL_SMARTCONTRAC_ERC20

```bash
yarn hardhat run scripts/FNFT.deploy.ts --network mumbai 
```
## Pruebas

Para pruebas locales con ganache-cli y aumento de tiempo en la blockchain

Ejecutar todas los archivos en la carpeta test
```bash
npx hardhat test test/*.ts
```

Ejecutar archivo por archivo
```bash
npx hardhat test test/erc20.ts
npx hardhat test test/erc1155Lock.test.ts
npx hardhat test test/fnftTests.ts
```

Ejecutar pruebas con alguna red en el archivo de configuracion de Hardhat
```bash
npx hardhat test test/*.ts --network NOMBRE_RED
```

## Address SmartContracts
BBTOKEN: 0x62ba02826ef23F4ce9Ac11B72CB31Aadb85878F9
FNFT:    0xEFFB8345449eDC15Ef791e7AB84440080488A58f