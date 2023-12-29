import { ethers, upgrades } from "hardhat";
import {
  supplyMarkers,
  interests,
  numberOfReferrals,
  discountForReferred,
} from "./data";
import { REGISTRY_SEPOLIA } from "../addresses";
async function main() {
  const Referral = await ethers.getContractFactory("Referral");
  const referral = await upgrades.deployProxy(Referral, []);

  console.info("\nDeploying Referral contract...");
  await referral.waitForDeployment();
  console.info("Referral contract deployed to:", await referral.getAddress());

  console.info("\nSetting up registry to Referral...");
  await referral.setRegistry(REGISTRY_SEPOLIA);
  console.info("Done!");

  console.info("\nSetting up supply markers...");
  await referral.setSupplyMarkers(supplyMarkers);
  console.info("Done!");

  console.info("\nSetting up interest rates...");
  await referral.setInterestRate(interests);
  console.info("Done!");

  console.info("\nSetting up referral requirements...");
  await referral.setAmtReferredBracket(numberOfReferrals);
  console.info("Done!");

  console.info("\nSetting up discounts for referred...");
  await referral.setReferredRewards(discountForReferred);
  console.info("Done!");

  console.info("\nSetting up referral to registry...");
  const registry = await ethers.getContractAt("Registry", REGISTRY_SEPOLIA);
  await registry.setContractAddress("Referral", await referral.getAddress());
  console.info("Done!");
}

main();
