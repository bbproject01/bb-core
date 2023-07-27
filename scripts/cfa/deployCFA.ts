import { ethers, run } from 'hardhat';

const bbToken = '0x62ba02826ef23F4ce9Ac11B72CB31Aadb85878F9';
const minBalance = ethers.utils.parseEther(String(1000));
const uri = '';

async function main() {
  const cfa = await ethers.deployContract('CFAv2', [bbToken, minBalance, uri]);

  console.info('\nDeplying CFA...');
  await cfa.deployed();
  console.info('CFA deployed at address: ', cfa.address);

  console.info("\nVerifying CFA's source code...");
  await run('verify:verify', {
    address: cfa.address,
    constructorArguments: [bbToken, minBalance, uri],
  });
  console.info('Done!');
}

main();
