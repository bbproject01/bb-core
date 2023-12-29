import { ethers, run } from 'hardhat';
import { interestRate } from './savingsData';

const bbToken = '0x52f74a639567B0BED22Be195F8c5d559e06fE810';
const registry = '0x9CaA2DdaFE2305eEA01875E63fA412eE1d8606D2';
const minBalance = ethers.utils.parseEther(String(1000));

async function main() {
  const cfa = await ethers.deployContract('CFAv2', [bbToken, minBalance]);

  console.info('\nDeplying CFA...');
  await cfa.deployed();
  console.info('CFA deployed at address: ', cfa.address);

  console.info('\nSetting interest rate...');
  for (let i = 0; i < 30; i++) {
    await cfa.setInterest(interestRate[i][0], interestRate[i][1]);
  }
  console.info('Done!');

  console.info('\nSetting life...');
  await cfa.setLife(31104000, 933120000);
  console.info('Done!');

  console.info('\nSetting registry address...');
  await cfa.setRegistry(registry);
  console.info('Done!');

  const tokenInstance = await ethers.getContractAt('BBToken', bbToken);
  console.info('\nApproving token...');
  await tokenInstance.approve(cfa.address, ethers.constants.MaxUint256);
  console.info('Done!');

  console.info('trying to mint...');
  await cfa.mint(['0', '31104000', '0', '100000000000000000000', '0']);
  console.info('Done!');

  console.info("\nVerifying CFA's source code...");
  await run('verify:verify', {
    address: cfa.address,
    constructorArguments: [bbToken, minBalance],
  });
  console.info('Done!');

  const registryInstance = await ethers.getContractAt('Registry', registry);
  console.info('\nSetting CFA address in registry...');
  registryInstance.updateRegistry('Savings', cfa.address);
  console.info('Done!');
}

main();
