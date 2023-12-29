import { ethers } from 'hardhat';
import { markers, months, multipliers } from './data';
import { BBTOKEN_SEPOLIA, REGISTRY_SEPOLIA } from '../addresses';

async function main() {
  const LockedSavings = await ethers.getContractFactory('LockedSavings');
  const lockedSavings = await LockedSavings.deploy();

  console.info('\ndeploying locked savings...');
  await lockedSavings.deployed();
  console.info('Locked savings deployed with address:', lockedSavings.address);

  console.info('\nSetting multipliers...');
  for (let i = 0; i < multipliers.length; i++) {
    await lockedSavings.setMultiplier(multipliers[i], markers, months[i]);
  }
  console.info('Done!');

  console.info('\nSetting up min and max marker...');
  await lockedSavings.setMinMaxMarker(1, 100);
  console.info('Done!');

  console.info('\nSetting up registry...');
  await lockedSavings.setRegistry(REGISTRY_SEPOLIA);
  console.info('Done!');

  console.info('\nSetting locked savings to registry...');
  const registry = await ethers.getContractAt('Registry', REGISTRY_SEPOLIA);
  await registry.setContractAddress('LockedSavings', lockedSavings.address);
  console.info('Done!');

  console.info('\nApproving locked savings to bb token...');
  const token = await ethers.getContractAt('BBToken', BBTOKEN_SEPOLIA);
  await token.approve(lockedSavings.address, ethers.constants.MaxUint256);
  console.info('Done!');
}

main();
