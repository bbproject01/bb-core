import { ethers } from 'hardhat';
import { GLOBAL_MARKER_SEPOLIA, REGISTRY_SEPOLIA } from '../addresses';
import { interests, trueMarkers } from './data';

const markers = trueMarkers();

async function main() {
  const globalMarker = await ethers.getContractAt('GlobalMarker', GLOBAL_MARKER_SEPOLIA);

  // console.log('Setting interest...');
  // await globalMarker.setInterest(markers, interests);
  // console.log('Interest set!');

  // console.log('\nSetting up Global Marker to registry...');
  // const registry = await ethers.getContractAt('Registry', REGISTRY_SEPOLIA);
  // await registry.setContractAddress('GlobalMarker', globalMarker.address);
  // console.log('Done!');
}

main();
