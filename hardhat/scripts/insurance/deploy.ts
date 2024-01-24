import { ethers, upgrades } from "hardhat";
import { BBTOKEN_SEPOLIA, REGISTRY_SEPOLIA } from "../addresses";
import { interests, periods, metadata, images } from "./data";

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

  console.info("\nApproving Insurance contract to spend BB Token...");
  const token = await ethers.getContractAt("BBToken", BBTOKEN_SEPOLIA);
  await token.approve(await insurance.getAddress(), ethers.MaxUint256);
  console.info("Done!");

  console.info("\nSetting Up Insurance's name and description...");
  await insurance.setMetadata(metadata[0], metadata[1]);
  console.info("Done!");

  console.info("\nSetting image...");
  await insurance.setImage(images);
  console.info("Done!");
}

main();
