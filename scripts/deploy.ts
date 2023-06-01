import { ethers } from "hardhat";
import dotenv from 'dotenv'

dotenv.config({ debug: false })

async function main() {
    
    const NAME = 'B&B';
    const SYMBOL = 'B&B';
    const DECIMALS = 18
    const UN_BILLON = Math.pow(10, 12);

    const ERC20 = await ethers.getContractFactory("ERC20");
    const erc20contract = await ERC20.deploy(
        NAME,
        SYMBOL,
        DECIMALS,
        UN_BILLON,
        UN_BILLON
    );
    const FNFT = await ethers.getContractFactory("FNFT");
    const instance = await FNFT.deploy( erc20contract.address);

    console.log("El contrato FNFT fue desplegado con éxito en la dirección:" + instance.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
