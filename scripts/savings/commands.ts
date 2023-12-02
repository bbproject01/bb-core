import { ethers } from 'hardhat';
import { SAVINGS_SEPOLIA } from '../addresses';
import { mintData } from './data';

async function main() {
  const savings = await ethers.getContractAt('Savings', SAVINGS_SEPOLIA);

  console.info('Trying to mint...');
  await savings.mintSavings(mintData, ethers.constants.AddressZero);
  console.info('Done!');

  // console.info('Setting up life ...');
  // await savings.setLife('1', '30');
  // console.info('Done!');
}

main();
