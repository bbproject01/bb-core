import { ethers, upgrades } from "hardhat";
import { images } from "./data";
import {
  BBTOKEN_SEPOLIA,
  REGISTRY_SEPOLIA,
  SAVINGS_SEPOLIA,
} from "../addresses";

// const markers = trueMarkers();

async function main() {
  const Savings = await ethers.getContractFactory("Savings");
  const savings = await upgrades.deployProxy(Savings, []);

  // const savings = await ethers.getContractAt('Savings', SAVINGS_SEPOLIA);

  console.info("Deploying Savings contract...");
  await savings.waitForDeployment();
  console.info("Savings contract deployed to:", await savings.getAddress());

  // console.info("\nSetting up Savings's interest rate and markers...");
  // await savings.setInterest(markers, interests);
  // console.info('Done!');

  console.info("\nSetting Up Savings's registry...");
  await savings.setRegistry(REGISTRY_SEPOLIA);
  console.info("Done!");

  console.info("\nSetting Up max and min life...");
  await savings.setLife("1", "30");
  console.info("Done!");

  console.info("\nSetting Up Savings's images...");
  await savings.setImage(images);
  console.info("Done!");

  console.info("\nSetting Up Savings's name and description...");
  await savings.setMetadata("Savings", "Savings CFA that will make you rich");
  console.info("Done!");

  console.info("\nApproving allowance...");
  const bbToken = await ethers.getContractAt("BBToken", BBTOKEN_SEPOLIA);
  await bbToken.approve(await savings.getAddress(), String(ethers.MaxUint256));
  console.info("Done!");

  console.info("\nSetting up Savings to registry...");
  const registry = await ethers.getContractAt("Registry", REGISTRY_SEPOLIA);
  await registry.setContractAddress("Savings", await savings.getAddress());
  console.info("Done!");

  // console.info("\nVerifying Savings's source code...");
}

main();
