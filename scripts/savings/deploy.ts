import { ethers } from 'hardhat';
import { images, interests, trueMarkers } from './data';
import { BBTOKEN_SEPOLIA, REGISTRY_SEPOLIA, SAVINGS_SEPOLIA } from '../addresses';

const markers = trueMarkers();

async function main() {
  const Savings = await ethers.getContractFactory('Savings');
  const savings = await Savings.deploy();

  // const savings = await ethers.getContractAt('Savings', SAVINGS_SEPOLIA);

  console.info('Deploying Savings contract...');
  await savings.deployed();
  console.info('Savings contract deployed to:', savings.address);

  console.info("\nSetting up Savings's interest rate and markers...");
  await savings.setInterest(markers, interests);
  console.info('Done!');

  console.info("\nSetting Up Savings's images...");
  await savings.setImage(images);
  console.info('Done!');

  console.info("\nSetting Up Savings's registry...");
  await savings.setRegsitry(REGISTRY_SEPOLIA);
  console.info('Done!');

  console.info('\nApproving allowance...');
  const bbToken = await ethers.getContractAt('BBToken', BBTOKEN_SEPOLIA);
  await bbToken.approve(savings.address, ethers.constants.MaxUint256);
  console.info('Done!');

  // console.info("\nVerifying Savings's source code...");
}

main();
