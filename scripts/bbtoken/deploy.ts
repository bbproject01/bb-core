import { ethers, run } from 'hardhat';
import { REGISTRY_SEPOLIA } from '../addresses';

const initSupply = ethers.utils.parseEther(String(1_000_000));
const maxSupply = ethers.utils.parseEther(String(1_000_000_000));

async function main() {
  const BbToken = await ethers.deployContract('BBToken', [initSupply, maxSupply]);

  console.info('\nDeplying BB Token...');
  await BbToken.deployed();
  console.info('BB Token deployed to:', BbToken.address);

  console.info("\nSetting up BB Token's registry...");
  const reg = await ethers.getContractAt('Registry', REGISTRY_SEPOLIA);
  await reg.setAddress('BbToken', BbToken.address);
  console.info('Done!');

  console.info('\nVerifying BB Token Smart Contract...');
  run('verify:verify', {
    address: BbToken.address,
    constructorArguments: [initSupply, maxSupply],
  });
  console.info('Done!');
}

main();
