import { ethers } from 'hardhat';
import { BBTOKEN_SEPOLIA, SAVINGS_SEPOLIA } from '../addresses';

async function main() {
  const token = await ethers.getContractAt('BBToken', BBTOKEN_SEPOLIA);

  console.info('Approving savings to spend...');
  await token.approve(SAVINGS_SEPOLIA, ethers.constants.MaxUint256);
  console.info('Done!');
}

main();
