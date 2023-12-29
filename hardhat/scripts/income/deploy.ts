import { ethers } from 'hardhat';
import { BBTOKEN_SEPOLIA, REGISTRY_SEPOLIA } from '../addresses';
import { images, metadata } from './data';

async function main() {
  const Income = await ethers.getContractFactory('Income');
  const income = await Income.deploy();

  console.info('Deploying Income contract...');
  await income.deployed();
  console.info('Income deployed to:', income.address);

  console.info('\nSettings registry to income...');
  await income.setRegistry(REGISTRY_SEPOLIA);
  console.info('Done!');

  console.info('\nSetting image...');
  await income.setImage(images);
  console.info('Done!');

  console.info('\nSetting metadata...');
  await income.setMetadata(metadata[0], metadata[1]);
  console.info('Done!');

  console.info('\nApproving income to spend tokens...');
  const token = await ethers.getContractAt('BBToken', BBTOKEN_SEPOLIA);
  await token.approve(income.address, ethers.constants.MaxUint256);
  console.info('Done!');

  console.info('\nSetting income to registry...');
  const registry = await ethers.getContractAt('Registry', REGISTRY_SEPOLIA);
  await registry.setContractAddress('Income', income.address);
  console.info('Done!');
}

main();
