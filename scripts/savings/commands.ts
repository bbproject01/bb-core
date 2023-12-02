import { ethers } from 'hardhat';
import { SAVINGS_SEPOLIA } from '../addresses';
import { mintData } from './data';

async function main() {
  const savings = await ethers.getContractAt('Savings', SAVINGS_SEPOLIA);

  console.info('Trying to mint...');
  await savings.mintSavings(mintData, '0xbeDD99eF4dc976A3682550A6a65B86b9eCba1b4f');
  console.info('Done!');

  // console.info('Setting up life ...');
  // await savings.setLife('1', '30');
  // console.info('Done!');
}

main();
