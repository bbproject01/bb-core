import { ethers } from 'hardhat';
import { Signer, Contract } from "ethers";
import { expect } from 'chai';

describe('FNFT', function() {

  let FNFT, ERC20;
  let erc20: Contract;
  let fnft: Contract;
  let dev: Signer, alice: Signer, bob: Signer;

  beforeEach(async function() {
    [dev, alice, bob] = await ethers.getSigners();

    ERC20 = await ethers.getContractFactory('ERC20');
    erc20 = await ERC20.connect(dev).deploy(alice.getAddress(), ethers.utils.parseEther('10000'));
    await erc20.deployed();

    FNFT = await ethers.getContractFactory('FNFT');
    fnft = await FNFT.connect(dev).deploy(erc20.address);
    await fnft.deployed();
  });

  it('Se debería poder acuñar FNFTs si el balance ERC20 es suficiente', async function() {
    await erc20.connect(alice).transfer(bob.getAddress(), ethers.utils.parseEther('1000'));
    await fnft.connect(bob).mint(1, 10, 0.25);
    expect(await fnft.balanceOf(bob.getAddress(), 0)).to.equal(1);
  });

  it('No se debería poder acuñar FNFTs si el balance ERC20 es insuficiente', async function() {
    await expect(fnft.connect(bob).mint(1, 10, 0.25)).to.be.rejectedWith('ERC20 balance too low');
  });

  it('El período de devolución revisado debería ser menor que el plazo original después de un tiempo', async function() {
    await fnft.connect(alice).mint(1, 10, 0.25);
    await fnft.connect(alice).updateTimePassed(0, 1);
    expect(await fnft.revisedReturnPeriod(0)).to.be.lessThan(10);
  });
});
