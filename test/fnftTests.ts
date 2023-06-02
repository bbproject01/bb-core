import { expect } from "chai";
import { ethers, waffle } from "hardhat";
import { Contract, Signer } from "ethers";

const { provider } = waffle;
import type { BBTOKEN } from "./typechain-types";

describe("FNFT Contract", function () {
  let FNFT: Contract;
  let myToken: BBTOKEN;

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

  });

  describe("mint()", function () {

    it("should mint a new FNFT token", async function () {
      const TIEMPO_MESES = 4;       // el plazo
      const REDUCION_MAXIMA = 25;   // el pct de reduccion
      const PRICE = ethers.utils.parseUnits("100", 18) // 100 tokens BBToken

      const [owner] = await ethers.getSigners();
      await FNFT.mint(TIEMPO_MESES, REDUCION_MAXIMA, PRICE);      
      expect((await FNFT.balanceOf(await owner.getAddress(), 1)).eq(PRICE)).to.be.true;
    });
  });

  describe("setMinimumErc20Balance()", function () {

    it("should update the minimum ERC20 balance required to mint", async function () {
      const newMinimumBalance = ethers.utils.parseEther("2");
      await FNFT.setMinimumErc20Balance(newMinimumBalance);
      const minimumBalance = await FNFT.minimumErc20Balance();
      expect(minimumBalance).to.equal(newMinimumBalance);
    });

  });

  describe("safeTransferFrom()", function () {
    it("should transfer FNFT tokens from one account to another", async function () {4

      const [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

      // Asegúrate de que el propietario tiene tokens FNFT para transferir
      await FNFT.mint(12, 25, ethers.utils.parseEther("1"));
  
      const initialBalanceOwner = await FNFT.balanceOf(await owner.getAddress(), 0);
      const initialBalanceAddr1 = await FNFT.balanceOf(await addr1.getAddress(), 0);
      expect(initialBalanceOwner).to.equal(1);
      expect(initialBalanceAddr1).to.equal(0);
  
      // Transfiere tokens del propietario a addr1
      await FNFT.connect(owner).safeTransferFrom(await owner.getAddress(), await addr1.getAddress(), 0, 1, "0x0");
  
      const finalBalanceOwner = await FNFT.balanceOf(await owner.getAddress(), 0);
      const finalBalanceAddr1 = await FNFT.balanceOf(await addr1.getAddress(), 0);
      expect(finalBalanceOwner).to.equal(0);
      expect(finalBalanceAddr1).to.equal(1);
    });
  });
  
});
