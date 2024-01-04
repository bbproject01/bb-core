import { ethers, run } from "hardhat";
import {
  BBTOKEN_SEPOLIA,
  GLOBAL_MARKER_SEPOLIA,
  REFERRAL_SEPOLIA,
  REGISTRY_SEPOLIA,
  SAVINGS_SEPOLIA,
} from "./addresses";

const initSupply = ethers.parseEther(String(1_000_000));
const maxSupply = ethers.parseEther(String(1_000_000_000));

async function main() {
  console.info("\nVerifying Registry Smart Contract...");
  await run("verify:verify", {
    address: REGISTRY_SEPOLIA,
    constructorArguments: [],
  });
  console.info("Done!");

  console.info("\nVerifying BB Token Smart Contract...");
  await run("verify:verify", {
    address: BBTOKEN_SEPOLIA,
    constructorArguments: [initSupply, maxSupply],
  });
  console.info("Done!");

  console.info("\nVerifying Global Marker Smart Contract...");
  await run("verify:verify", {
    address: GLOBAL_MARKER_SEPOLIA,
    constructorArguments: [],
  });
  console.info("Done!");

  console.info("\nVerifying Savings Smart Contract...");
  await run("verify:verify", {
    address: SAVINGS_SEPOLIA,
    constructorArguments: [],
  });
  console.info("Done!");

  console.info("\nVerifying Referral Smart Contract...");
  await run("verify:verify", {
    address: REFERRAL_SEPOLIA,
    constructorArguments: [],
  });
  console.info("Done!");
}

main();
