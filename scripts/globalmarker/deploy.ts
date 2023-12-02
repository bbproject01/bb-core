import { ethers } from 'hardhat';
import { REGISTRY_SEPOLIA } from '../addresses';

async function main() {
  const GlobalMarker = await ethers.getContractFactory('Savings');
  const globalMarker = await GlobalMarker.deploy();

  console.log('Deploying Global Marker...');
  await globalMarker.deployed();
  console.log('Global Marker deployed to:', globalMarker.address);

  console.log('Setting up Global Marker to registry...');
  const registry = await ethers.getContractAt('Registry', REGISTRY_SEPOLIA);
  await registry.setAddress('GlobalMarker', globalMarker.address);
  console.log('Done!');
}

main();
