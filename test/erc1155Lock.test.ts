import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";

import type { BBTOKEN } from "./typechain-types";

describe("ERC1155Lockable", function () {
  
  let myToken: BBTOKEN;
  let FNFT : Contract;
  
  const NAME = 'B&B';
  const SYMBOL = 'B&B';
  const DECIMALS = 18  
  const MILLON = Math.pow(10, 6);
  const BILLON = Math.pow(10, 12);
  const URI = '';


  beforeEach(async function () {
    const [owner] = await ethers.getSigners();

    // ERC20 
    const MyToken = await ethers.getContractFactory("BBTOKEN");
    myToken = await MyToken.deploy(NAME, SYMBOL, DECIMALS, MILLON, BILLON);
    await myToken.deployed();
    await myToken.mint(await owner.getAddress(), ethers.utils.parseEther("1000"));


    // ERC1155
    const FNFTFactory = await ethers.getContractFactory("FNFT");    
    FNFT = await FNFTFactory.deploy(URI, myToken.address);
    await FNFT.deployed();

    // Mint some ERC20 tokens to the first account
    await myToken.mint(owner.address, ethers.utils.parseEther("1000"));

    // Approve the ERC1155 contract to spend the first account's ERC20 tokens
    await myToken.approve(FNFT.address, ethers.utils.parseEther("1000"));
  });

  it("debería permitir la creación de un bloqueo", async function () {
  
    const [owner] = await ethers.getSigners();
    await FNFT.createLock(1, Math.floor(Date.now() / 1000) + 60 * 60 * 24);
    const lock = await FNFT.locks(1);
    expect(lock.endTime).to.be.above(0);
    expect(lock.admin).to.equal(owner.address);
    expect(lock.unlocked).to.equal(false);
  });

  it("no debería permitir la creación de un bloqueo si ya existe uno", async function () {
    await FNFT.createLock(1, Math.floor(Date.now() / 1000) + 60 * 60 * 24);
    await expect(FNFT.createLock(1, Math.floor(Date.now() / 1000) + 60 * 60 * 24)).to.be.revertedWith("Lock already exists for this token");
  });

  it("no debería permitir la transferencia de un token bloqueado", async function () {
    const [owner, account1] = await ethers.getSigners();    
    const t = await FNFT.getTokensOwner();
    console.log("t", t);

    await FNFT.createLock(1, Math.floor(Date.now() / 1000) + 60 * 60 * 24);

    await expect(FNFT.connect(owner).transfer(account1.address, 1)).to.be.revertedWith("Token is locked");
  });

  it("no debería permitir desbloquear un token antes del tiempo final", async function () {
    const [owner] = await ethers.getSigners();
    await FNFT.createLock(1, Math.floor(Date.now() / 1000) + 60 * 60 * 24, owner.address);
    await expect(FNFT.unlock(1)).to.be.revertedWith("Token cannot be unlocked before the end time");
  });

  it("debería permitir desbloquear y transferir un token después del tiempo final", async function () {
    const [owner, account1] = await ethers.getSigners();
    
    await FNFT.mint(owner.address, 1, ethers.utils.parseEther("100"), "0x");
    await ethers.provider.send("evm_increaseTime", [60 * 60 * 24]); // Increase time by 24 hours
    await ethers.provider.send("evm_mine", []);                     // Mine the next block
    await FNFT.unlock(1);
    await FNFT.safeTransferFrom(owner.address, account1.address, 1, ethers.utils.parseEther("10"), "0x");
    expect(await FNFT.balanceOf(account1.address, 1)).to.equal(ethers.utils.parseEther("10"));
  });
});
