import { ethers } from "ethers";

export const sampleAttributes = [
  "0", // time created
  ethers.parseEther(String(10_000)), // principal
  "1", // payment frequency
  "1", // principal lock time
  "0", // last claim time
  "0", // interest
  "0", // cfa life
  "0", // income paid
];
export const timeCreated = "1668069940";
export const images =
  "https://magenta-protestant-falcon-171.mypinata.cloud/ipfs/QmdL8nW1NrnmKkvSx7wHC8EBtNyYgHnR24ARaQLXYysnKa";

export const metadata = ["Income", "Income CFA will be your best friend"];
