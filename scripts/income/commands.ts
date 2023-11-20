import { ethers } from 'hardhat';
import { BBTOKEN_SEPOLIA, INCOME_SEPOLIA } from '../addresses';
import { sampleAttributes } from './data';

async function main() {
  const income = await ethers.getContractAt('Income', INCOME_SEPOLIA);

  // console.info('\nTrying to mint income cfa...');
  // await income.mintIncome([sampleAttributes]);
  // console.info('Done!');

  // console.info("\nChanging time to '1668069940'...");
  // await income.setTimeCreated('1', '1668069940');
  // console.info('Done!');

  console.info('\nGettings indexes...');
  let rawIndexes = await income.getIndexes('1');
  console.info(rawIndexes);

  console.info('Getting data...');
  let data = await income.attributes('1');
  console.info(data);
}

main();
