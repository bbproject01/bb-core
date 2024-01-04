import { ethers } from "hardhat";
import { BBTOKEN_SEPOLIA, INCOME_SEPOLIA } from "../addresses";
import { sampleAttributes } from "./data";

async function main() {
  const income = await ethers.getContractAt("Income", INCOME_SEPOLIA);

  console.info("\nTrying to mint income cfa...");
  await income.mintIncome([sampleAttributes as any], ethers.ZeroAddress);
  console.info("Done!");

  // console.info("\nChanging time to '1668069940'...");
  // await income.setTimeCreated('2  ', '1668069940');
  // console.info('Done!');

  // console.info('\nGettings indexes...');
  // let rawIndexes = await income.getIndexes('1');
  // console.info(rawIndexes);

  // console.info('Getting data...');
  // let data = await income.attributes('1');
  // console.info(data);

  // console.info('Check balance...');
  // let balance = await income.balanceOf('0xed4FA635Dd404E2914955F96B2F79Ea9D63733d7', '2');
  // console.info(balance.toString());

  // console.info('Trying to withdraw...');
  // await income.withdrawIncome('1', '100000000000');
  // console.info('Done!');

  // console.info('Trying to loan...');
  // await income.createLoan('1', ethers.utils.parseEther(String(Number(100))));
  // console.info('Done!');
}

main();
