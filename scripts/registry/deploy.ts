import { ethers } from 'hardhat';

async function main() {
  const Registry = await ethers.getContractFactory('Registry');
  const registry = await Registry.deploy();

  console.info('Deploying Registry contract...');
  await registry.deployed();
  console.info('Referral contract deployed to:', registry.address);
}

main();
