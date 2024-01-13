import { ethers, upgrades } from "hardhat";
import { BBTOKEN_SEPOLIA, INSURANCE_SEPOLIA } from "../addresses";
import { interests, periods } from "./data";

async function main() {
  const insurance = await ethers.getContractAt("Insurance", INSURANCE_SEPOLIA);

  //   console.info("\nApproving...");
  //   const token = await ethers.getContractAt("BBToken", BBTOKEN_SEPOLIA);
  //   await token.approve(await insurance.getAddress(), ethers.MaxUint256);
  //   console.info("Done!");

  console.info("\nSetting up interest rates...");
  await insurance.setInterestRate(periods, interests);
  console.info("Done!");
}

main();
