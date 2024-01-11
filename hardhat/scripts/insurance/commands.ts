import { ethers, upgrades } from "hardhat";
import { BBTOKEN_SEPOLIA, INSURANCE_SEPOLIA } from "../addresses";

async function main() {
  const insurance = await ethers.getContractAt("Insurance", INSURANCE_SEPOLIA);

  console.info("\nApproving...");
  const token = await ethers.getContractAt("BBToken", BBTOKEN_SEPOLIA);
  await token.approve(await insurance.getAddress(), ethers.MaxUint256);
  console.info("Done!");
}

main();
