import { ethers } from 'hardhat';
import { BBTOKEN_SEPOLIA, LOCKED_SAVINGS_SEPOLIA } from '../addresses';
import { mintData } from './data';

async function main() {
  const lockedSavings = await ethers.getContractAt('LockedSavings', LOCKED_SAVINGS_SEPOLIA);

  // console.info('\nApproving locked savings to bb token...');
  // const token = await ethers.getContractAt('BBToken', BBTOKEN_SEPOLIA);
  // await token.approve(lockedSavings.address, ethers.constants.MaxUint256);
  // console.info('Done!');

  console.info('\nTrying to mint...');
  await lockedSavings.createLockedSavings([mintData.attributes], mintData.referrer);
  console.info('Done!');
}

main();
