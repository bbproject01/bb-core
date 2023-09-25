import { ethers } from 'hardhat';

async function main() {
  const Referral = await ethers.getContractFactory('Referral');
  const referral = await Referral.deploy();

  console.info('Deploying Referral contract...');
  await referral.deployed();
  console.info('Referral contract deployed to:', referral.address);
}

main();
