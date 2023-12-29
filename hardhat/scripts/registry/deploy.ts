import { ethers, upgrades } from "hardhat";

async function main() {
  const Registry = await ethers.getContractFactory("Registry");
  const registry = await upgrades.deployProxy(Registry, []);

  console.info("\nDeploying Registry contract...");
  await registry.waitForDeployment();
  console.info("Registry contract deployed to:", await registry.getAddress());
}

main();
