import { ethers } from "hardhat";
import dotenv from 'dotenv'

dotenv.config({ debug: false })

async function main() {
    const ERC20Address = process.env.ERC20_ADDRESS;  // <-- Reemplaza esto con la dirección del ERC20
    const FNFT = await ethers.getContractFactory("FNFT");
    const instance = await FNFT.deploy(ERC20Address);

    console.log("El contrato FNFT fue desplegado con éxito en la dirección:" + instance.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
