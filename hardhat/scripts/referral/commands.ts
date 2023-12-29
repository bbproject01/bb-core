import { ethers } from "hardhat";
import { REFERRAL_SEPOLIA } from "../addresses";
import { trueMarkers } from "./data";

async function main() {
const referral = await ethers.getContractAt("Referral", REFERRAL_SEPOLIA);

console.info("Updating referral interest and markers");
await referral.setSupplyMarkers(trueMarkers());

console.info("Done!");
}
main()