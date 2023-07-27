import { ethers } from 'hardhat';

const initSupply = ethers.utils.parseEther('100_000_000');
const maxSupply = ethers.utils.parseEther('1_000_000_000');

async function main() {
  const BbToken = await ethers.deployContract('BbToken', [initSupply, maxSupply]);

  console.info('Deplying BB Token...');
  await BbToken.deployed();
  console.info('BB Token deployed to:', BbToken.address);
}
