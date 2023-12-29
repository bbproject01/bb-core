import { ethers, upgrades } from "hardhat";
import { REGISTRY_SEPOLIA } from "../addresses";
import { interests, trueMarkers } from "./data";

const markers = trueMarkers();

async function main() {
  const GlobalMarker = await ethers.getContractFactory("GlobalMarker");
  const globalMarker = await upgrades.deployProxy(GlobalMarker, [
    REGISTRY_SEPOLIA,
  ]);

  console.log("\nDeploying Global Marker...");
  await globalMarker.waitForDeployment();
  console.log("Global Marker deployed to:", await globalMarker.getAddress());

  console.log("\nSetting interest...");
  await globalMarker.setInterest(markers, interests);
  console.log("Interest set!");

  console.log("\nSetting up Global Marker to registry...");
  const registry = await ethers.getContractAt("Registry", REGISTRY_SEPOLIA);
  await registry.setContractAddress(
    "GlobalMarker",
    await globalMarker.getAddress()
  );
  console.log("Done!");
}

main();
