import { ethers } from 'hardhat';
import { BBTOKEN_SEPOLIA, REGISTRY_SEPOLIA } from '../addresses';
import { sampleAttributes } from './data';

async function main() {
  const Income = await ethers.getContractFactory('Income');
  const income = await Income.deploy();

  console.info('Deploying Income contract...');
  await income.deployed();
  console.info('Income deployed to:', income.address);

  console.info('\nSettings registry to income...');
  await income.setRegistry(REGISTRY_SEPOLIA);
  console.info('Done!');

  console.info('\nApproving income to spend tokens...');
  const token = await ethers.getContractAt('BBToken', BBTOKEN_SEPOLIA);
  await token.approve(income.address, ethers.constants.MaxUint256);
  console.info('Done!');

  console.info('\nSetting income to registry...');
  const registry = await ethers.getContractAt('Registry', REGISTRY_SEPOLIA);
  await registry.setAddress('Income', income.address);
  console.info('Done!');
}

main();
