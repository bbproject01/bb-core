import { ethers, run } from 'hardhat';

const bbToken = '0x52f74a639567B0BED22Be195F8c5d559e06fE810';
const minBalance = ethers.utils.parseEther(String(1000));

async function main() {
  const cfa = await ethers.deployContract('CFAv2', [bbToken, minBalance]);

  console.info('\nDeplying CFA...');
  await cfa.deployed();
  console.info('CFA deployed at address: ', cfa.address);

  console.info("\nVerifying CFA's source code...");
  await run('verify:verify', {
    address: cfa.address,
    constructorArguments: [bbToken, minBalance],
  });
  console.info('Done!');
}

main();
