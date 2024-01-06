import { ethers, upgrades } from "hardhat";
import { INCOME_SEPOLIA } from "../addresses";

async function main() {
  const Income = await ethers.getContractFactory("Income");
  const income = await upgrades.upgradeProxy(INCOME_SEPOLIA, Income);

  console.info("\nUpgrading Income Smart Contract...");
  await income.waitForDeployment();
  console.info("Income Smart Contract upgraded successfully!\n");
}

main();
