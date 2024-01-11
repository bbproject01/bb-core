import { ethers, upgrades } from "hardhat";
import { INSURANCE_SEPOLIA } from "../addresses";

async function main() {
  const Insurance = await ethers.getContractFactory("Insurance");
  const insurance = await upgrades.upgradeProxy(INSURANCE_SEPOLIA, Insurance);

  console.info("Upgrading Insurance...");
  await insurance.waitForDeployment();
  console.info("Upgrade Done!");
}

main();
