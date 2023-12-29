import { ethers, run, upgrades } from "hardhat";
import { REGISTRY_SEPOLIA } from "../addresses";

const initSupply = ethers.parseEther(String(1_000_000));
const maxSupply = ethers.parseEther(String(1_000_000_000));

async function main() {
  // const BbToken = await ethers.deployContract("BBToken", [
  //   initSupply,
  //   maxSupply,
  // ]);

  const BBToken = await ethers.getContractFactory("BBToken");
  const BbToken = await upgrades.deployProxy(BBToken, [initSupply, maxSupply]);

  console.info("\nDeplying BB Token...");
  await BbToken.waitForDeployment();
  console.info("BB Token deployed to:", await BbToken.getAddress());

  console.info("Setting up registry to BBToken...");
  await BbToken.setRegistry(REGISTRY_SEPOLIA);
  console.info("Done!");

  console.info("\nSetting up Token to Registry...");
  const reg = await ethers.getContractAt("Registry", REGISTRY_SEPOLIA);
  await reg.setContractAddress("BbToken", await BbToken.getAddress());
  console.info("Done!");

  // console.info('\nVerifying BB Token Smart Contract...');
  // run('verify:verify', {
  //   address: BbToken.address,
  //   constructorArguments: [initSupply, maxSupply],
  // });
  // console.info('Done!');
}

main();
