import { ethers } from 'hardhat';

async function main() {
  const Registry = await ethers.getContractFactory('Registry');
  const registry = await Registry.deploy();

  console.info('\nDeploying Registry contract...');
  await registry.deployed();
  console.info('Registry contract deployed to:', registry.address);
}

main();
