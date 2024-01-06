import { ethers } from "hardhat";
import { BBTOKEN_SEPOLIA, SAVINGS_SEPOLIA } from "../addresses";

async function main() {
  const token = await ethers.getContractAt("BBToken", BBTOKEN_SEPOLIA);

  // console.info('Approving savings to spend...');
  // await token.approve(SAVINGS_SEPOLIA, ethers.constants.MaxUint256);
  // console.info('Done!');

  console.info("Minting supply...");
  await token.testMint(
    "0xA99C2a688D4C8412b2D1cbf19C2fd36C335C6f61",
    ethers.parseEther(String(40_000_000)) as any
  );
  console.info("Done!");
}

main();
