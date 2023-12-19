import { ethers } from 'hardhat';
import { SAVINGS_SEPOLIA } from '../addresses';

async function main() {
  const savings = await ethers.getContractAt('Savings', SAVINGS_SEPOLIA);

  console.info('Minting...');
  await savings.mintSavings([['0', '31556926', '0', '1000000000000000000000', '0']]);
  console.info('Done!');
}

main();
