import { ethers, upgrades } from "hardhat";
import { SAVINGS_SEPOLIA } from "../addresses";

async function main() {
  const Savings = await ethers.getContractFactory("Savings");
  const savings = await upgrades.upgradeProxy(SAVINGS_SEPOLIA, Savings);

  console.info("Upgrading Savings contract...");
  await savings.waitForDeployment();
  console.info("Upgrade Done!");
}

main();
