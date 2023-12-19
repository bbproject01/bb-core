import { ethers } from 'hardhat';
import { REGISTRY_SEPOLIA } from '../addresses';
import { interests, trueMarkers } from './data';

const markers = trueMarkers();

async function main() {
  const GlobalMarker = await ethers.getContractFactory('GlobalMarker');
  const globalMarker = await GlobalMarker.deploy();

  console.log('Deploying Global Marker...');
  await globalMarker.deployed();
  console.log('Global Marker deployed to:', globalMarker.address);

  console.info('\nSetting up registry to Global Marker...');
  await globalMarker.setRegistry(REGISTRY_SEPOLIA);
  console.info('Done!');

  console.log('Setting interest...');
  await globalMarker.setInterest(markers, interests);
  console.log('Interest set!');

  console.log('\nSetting up Global Marker to registry...');
  const registry = await ethers.getContractAt('Registry', REGISTRY_SEPOLIA);
  await registry.setContractAddress('GlobalMarker', globalMarker.address);
  console.log('Done!');
}

main();
