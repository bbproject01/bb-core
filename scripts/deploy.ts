import { ethers } from "hardhat";

async function main() {
    const ERC20Address = 'CONTRACT_ADDRESS';  // <-- Reemplaza esto con la dirección del ERC20
    const FNFT = await ethers.getContractFactory("FNFT");
    const instance = await FNFT.deploy(ERC20Address);

    console.log("El contrato FNFT fue desplegado con éxito en la dirección:" + instance.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
