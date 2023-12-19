import { ethers } from "hardhat";
import { SAVINGS_SEPOLIA } from "../addresses";
import { mintData } from "./data";

async function main() {
  const savings = await ethers.getContractAt("Savings", SAVINGS_SEPOLIA);

  console.info("\nTrying to mint...");
  await savings.mintSavings(
    [mintData as any],
    "0xbeDD99eF4dc976A3682550A6a65B86b9eCba1b4f"
  );
  console.info("Done!");

  // console.info('\nTrying to create loan...');
  // await savings.createLoan('1', '0');
  // console.info('Done!');

  // console.info('Getting balance...');
  // const balance = await savings.balanceOf('0xed4FA635Dd404E2914955F96B2F79Ea9D63733d7', '1');
  // console.info(balance.toString());

  // console.info('Getting loan balance...');
  // const loanBalance = await savings.getLoanBalance('2');
  // console.info(loanBalance.toString());

  // console.info('Setting up life ...');
  // await savings.setLife('1', '30');
  // console.info('Done!');
}

main();
