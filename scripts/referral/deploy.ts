import { ethers } from 'hardhat';
import { supplyMarkers, interests, numberOfReferrals, discountForReferred } from './data';
async function main() {
  const Referral = await ethers.getContractFactory('Referral');
  const referral = await Referral.deploy();

  console.info('Deploying Referral contract...');
  await referral.deployed();
  console.info('Referral contract deployed to:', referral.address);

  console.info('\nSetting up supply markers...');
  await referral.setSupplyMarkers(supplyMarkers);
  console.info('Done!');

  console.info('\nSetting up interest rates...');
  await referral.setInterestRate(interests);
  console.info('Done!');

  console.info('\nSetting up referral requirements...');
  await referral.setAmtReferredBracket(numberOfReferrals);
  console.info('Done!');

  console.info('\nSetting up discounts for referred...');
  await referral.setReferredRewards(discountForReferred);
  console.info('Done!');
}


main();
