import chai from "chai";
import chaiAsPromised from "chai-as-promised";
import { ethers, waffle } from "hardhat";
import { BigNumber, Contract, Signer } from "ethers";
import { time } from "@nomicfoundation/hardhat-network-helpers";


chai.use(chaiAsPromised);
const expect = chai.expect;

describe("FNFTv2 Contract", function () {
  let FNFTv2: Contract;
  let myToken: Contract;

  const NAME = 'B&B';
  const SYMBOL = 'B&B';
  const DECIMALS = 18  
  const MILLON = Math.pow(10, 6);
  const BILLON = Math.pow(10, 12);
  const URI = '';

  beforeEach(async function () {
    
    const [owner] = await ethers.getSigners();
    const minimumErc20Balance = ethers.utils.parseEther("100");
    // ERC20 
    const MyToken = await ethers.getContractFactory("BBTOKEN");
    myToken = await MyToken.deploy(NAME, SYMBOL, DECIMALS, MILLON, BILLON);
    await myToken.deployed();
    await myToken.mint(await owner.getAddress(), ethers.utils.parseEther("1000"));

    // ERC1155
    const FNFTv2Factory = await ethers.getContractFactory("FNFTv2");    
    FNFTv2 = await FNFTv2Factory.deploy(myToken.address, minimumErc20Balance, URI);
    await FNFTv2.deployed();

    // Set the ERC20 token address in the FNFTv2 contract
    await FNFTv2.setERC20Token(myToken.address);
  });

  describe("mint()", function () {
        it("should mint a new FNFT token", async function () {
          const [owner] = await ethers.getSigners();
          const AttributesData = {
            product: 0,// The type of FNFT Product
            timeCreated: Math.floor(Date.now() / 1000), // The time the FNFT was minted
            fnftLife: 30 * 24 * 60 * 60, // The time the FNFT was locked     
            soulBoundTerm: 365, // Reduction
            amount: ethers.utils.parseEther("100"), // The amount of B&B tokens locked (100)
            interestRate: ethers.utils.parseUnits("0.05", 18) // The interest rate of the FNFT
          }

          // Approve that the smart contract spend our tokens to be able to mint FNFT's
          await myToken.connect(owner).approve(FNFTv2.address, AttributesData.amount);
          // Perform the Mint
          await FNFTv2.connect(owner).mint(AttributesData);
          // Check the balances and other outcomes
          expect((await FNFTv2.balanceOf(await owner.getAddress(), 0)));
          expect((await myToken.connect(owner).balanceOf(await owner.getAddress())));
        });

        it("should throw an error if ERC20 balance is insufficient", async function () {
            const [owner] = await ethers.getSigners();
            const AttributesData = {
                product: 0,// The type of FNFT Product
                timeCreated: Math.floor(Date.now() / 1000), // The time the FNFT was minted
                fnftLife: 30 * 24 * 60 * 60, // The time the FNFT was locked     
                soulBoundTerm: 365, // Reduction
                amount: ethers.utils.parseEther("100000000"), // The amount of B&B tokens locked (100)
                interestRate: ethers.utils.parseUnits("0.05", 18) // The interest rate of the FNFT
              }
    
            // Mock an insufficient ERC20 balance by setting it to a lower value than `minimumErc20Balance`
            await myToken.connect(owner).approve(FNFTv2.address, 0);
            // Perform the Mint and expect it to revert with the custom error
            await expect(FNFTv2.connect(owner).mint(AttributesData)).to.be.revertedWith("NotEnoughERC20Balance");
        });
   });

   describe("mintBatch1()", function () {
        it("should mint multiple new FNFT token", async function () {
        const [owner] = await ethers.getSigners();
        const AttributesData = [
            {
                product: 0,// The type of FNFT Product
                timeCreated: Math.floor(Date.now() / 1000), // The time the FNFT was minted
                fnftLife: 30 * 24 * 60 * 60, // The time the FNFT was locked     
                soulBoundTerm: 365, // Reduction
                amount: ethers.utils.parseEther("100"), // The amount of B&B tokens locked (100)
                interestRate: ethers.utils.parseUnits("0.05", 18) // The interest rate of the FNFT
            },
            {
                product: 0,// The type of FNFT Product
                timeCreated: Math.floor(Date.now() / 1000), // The time the FNFT was minted
                fnftLife: 30 * 24 * 60 * 60, // The time the FNFT was locked     
                soulBoundTerm: 365, // Reduction
                amount: ethers.utils.parseEther("100"), // The amount of B&B tokens locked (100)
                interestRate: ethers.utils.parseUnits("0.05", 18) // The interest rate of the FNFT
            },
            {
                product: 0,// The type of FNFT Product
                timeCreated: Math.floor(Date.now() / 1000), // The time the FNFT was minted
                fnftLife: 30 * 24 * 60 * 60, // The time the FNFT was locked     
                soulBoundTerm: 365, // Reduction
                amount: ethers.utils.parseEther("100"), // The amount of B&B tokens locked (100)
                interestRate: ethers.utils.parseUnits("0.05", 18) // The interest rate of the FNFT
            },
            {
                product: 0,// The type of FNFT Product
                timeCreated: Math.floor(Date.now() / 1000), // The time the FNFT was minted
                fnftLife: 30 * 24 * 60 * 60, // The time the FNFT was locked     
                soulBoundTerm: 365, // Reduction
                amount: ethers.utils.parseEther("100"), // The amount of B&B tokens locked (100)
                interestRate: ethers.utils.parseUnits("0.05", 18) // The interest rate of the FNFT
            },
        ]

        // Approve that the smart contract spend our tokens to be able to mint FNFT's
        await myToken.connect(owner).approve(FNFTv2.address, AttributesData[0].amount);
        // Perform the Mint
        await FNFTv2.connect(owner).mintBatch1(AttributesData, AttributesData.length);
        // Check the balances and other outcomes
        expect((await FNFTv2.balanceOf(await owner.getAddress(), 0)));
        expect((await myToken.connect(owner).balanceOf(await owner.getAddress())));
        });
    });

    describe("mintBatch2()", function () {
        it("should mint multiple new type of FNFT token", async function () {
        const [owner] = await ethers.getSigners();
        const AttributesData = [
            {
                product: 0,// The type of FNFT Product
                timeCreated: Math.floor(Date.now() / 1000), // The time the FNFT was minted
                fnftLife: 30 * 24 * 60 * 60, // The time the FNFT was locked     
                soulBoundTerm: 365, // Reduction
                amount: ethers.utils.parseEther("10"), // The amount of B&B tokens locked (100)
                interestRate: ethers.utils.parseUnits("0.05", 18) // The interest rate of the FNFT
            },
            {
                product: 0,// The type of FNFT Product
                timeCreated: Math.floor(Date.now() / 1000), // The time the FNFT was minted
                fnftLife: 30 * 24 * 60 * 60, // The time the FNFT was locked     
                soulBoundTerm: 365, // Reduction
                amount: ethers.utils.parseEther("10"), // The amount of B&B tokens locked (100)
                interestRate: ethers.utils.parseUnits("0.05", 18) // The interest rate of the FNFT
            },
            {
                product: 0,// The type of FNFT Product
                timeCreated: Math.floor(Date.now() / 1000), // The time the FNFT was minted
                fnftLife: 30 * 24 * 60 * 60, // The time the FNFT was locked     
                soulBoundTerm: 365, // Reduction
                amount: ethers.utils.parseEther("10"), // The amount of B&B tokens locked (100)
                interestRate: ethers.utils.parseUnits("0.05", 18) // The interest rate of the FNFT
            }
        ];
        const Amount = [5, 10, 15];
        

        // Approve that the smart contract spend our tokens to be able to mint FNFT's
        await myToken.connect(owner).approve(FNFTv2.address, AttributesData[0].amount);
        // Perform the Mint
        await FNFTv2.connect(owner).mintBatch2(AttributesData, Amount);
        // Check the balances and other outcomes
        expect((await FNFTv2.balanceOf(await owner.getAddress(), 0)));
        expect((await myToken.connect(owner).balanceOf(await owner.getAddress())));
        });

        it("should throw an error if Amounts Length is not equal to Attributes Length", async function () {
            const [owner] = await ethers.getSigners();
            const AttributesData = [
                {
                    product: 0,// The type of FNFT Product
                    timeCreated: Math.floor(Date.now() / 1000), // The time the FNFT was minted
                    fnftLife: 30 * 24 * 60 * 60, // The time the FNFT was locked     
                    soulBoundTerm: 365, // Reduction
                    amount: ethers.utils.parseEther("100"), // The amount of B&B tokens locked (100)
                    interestRate: ethers.utils.parseUnits("0.05", 18) // The interest rate of the FNFT
                },
                {
                    product: 0,// The type of FNFT Product
                    timeCreated: Math.floor(Date.now() / 1000), // The time the FNFT was minted
                    fnftLife: 30 * 24 * 60 * 60, // The time the FNFT was locked     
                    soulBoundTerm: 365, // Reduction
                    amount: ethers.utils.parseEther("100"), // The amount of B&B tokens locked (100)
                    interestRate: ethers.utils.parseUnits("0.05", 18) // The interest rate of the FNFT
                },
                {
                    product: 0,// The type of FNFT Product
                    timeCreated: Math.floor(Date.now() / 1000), // The time the FNFT was minted
                    fnftLife: 30 * 24 * 60 * 60, // The time the FNFT was locked     
                    soulBoundTerm: 365, // Reduction
                    amount: ethers.utils.parseEther("100"), // The amount of B&B tokens locked (100)
                    interestRate: ethers.utils.parseUnits("0.05", 18) // The interest rate of the FNFT
                },
                {
                    product: 0,// The type of FNFT Product
                    timeCreated: Math.floor(Date.now() / 1000), // The time the FNFT was minted
                    fnftLife: 30 * 24 * 60 * 60, // The time the FNFT was locked     
                    soulBoundTerm: 365, // Reduction
                    amount: ethers.utils.parseEther("100"), // The amount of B&B tokens locked (100)
                    interestRate: ethers.utils.parseUnits("0.05", 18) // The interest rate of the FNFT
                }
            ];
            const Amount = [5, 10, 15];
    
            await myToken.connect(owner).approve(FNFTv2.address, 0);
            // Perform the Mint and expect it to revert with the custom error
            await expect(FNFTv2.connect(owner).mintBatch2(AttributesData, Amount)).to.be.revertedWith("FNFT:NotSameLength");
        });
    });

    describe("setMinimumErc20Balance()", function () {

        it("should update the minimum ERC20 balance required to mint", async function () {
        const newMinimumBalance = ethers.utils.parseEther("2");
        await FNFTv2.setMinimumErc20Balance(newMinimumBalance);
        const minimumBalance = await FNFTv2.minimumErc20Balance();
        expect(minimumBalance).to.equal(newMinimumBalance);
        });

    });

});

  
