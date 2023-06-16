import { ethers } from "hardhat";
import dotenv from 'dotenv'

dotenv.config({ debug: false })

const { ADDRESS_TOKEN_BNB } = process.env;

async function main() {
    
    const FNFT = await ethers.getContractFactory("FNFT");
    const instance = await FNFT.deploy( "https://token-uri.com/", ADDRESS_TOKEN_BNB);

    console.log("El contrato FNFT fue desplegado con éxito en la dirección: " + instance.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
