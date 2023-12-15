import { ethers } from 'hardhat';
import { BBTOKEN_SEPOLIA, SAVINGS_SEPOLIA } from '../addresses';

async function main() {
  const token = await ethers.getContractAt('BBToken', BBTOKEN_SEPOLIA);

  console.info('Approving savings to spend...');
  await token.approve(SAVINGS_SEPOLIA, ethers.constants.MaxUint256);
  console.info('Done!');

  // console.info('Minting supply...');
  // await token.mint('0xed4fa635dd404e2914955f96b2f79ea9d63733d7', ethers.utils.parseEther(String(40_000_000)));
  // console.info('Done!');
}

main();
