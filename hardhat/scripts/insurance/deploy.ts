import { ethers, upgrades } from "hardhat";
import { REGISTRY_SEPOLIA } from "../addresses";
import { interests, periods } from "./data";

async function main() {
  const Insurance = await ethers.getContractFactory("Insurance");
  const insurance = await upgrades.deployProxy(Insurance, []);

  // const insurance = await ethers.getContractAt('Insurance', '0x9Ca285202C717580F5DbaE19C327d2f0a295b64b');

  console.info("Deploying Insurance contract...");
  await insurance.waitForDeployment();
  console.info("Insurance contract deployed to:", await insurance.getAddress());

  console.info("\nSetting Up Insurance's registry...");
  const registry = await ethers.getContractAt("Registry", REGISTRY_SEPOLIA);
  await registry.setContractAddress("Insurance", await insurance.getAddress());
  console.info("Done!");

  console.info("\nSetting Registry address...");
  await insurance.setRegistry(REGISTRY_SEPOLIA);
  console.info("Done!");

  console.info("\nSetting up interest rates...");
  await insurance.setInterestRate(periods, interests);
  console.info("Done!");
}

main();
