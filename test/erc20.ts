import { ethers } from "hardhat";
import chai from "chai";
import chaiAsPromised from "chai-as-promised";

chai.use(chaiAsPromised);
const expect = chai.expect;

import type { BBTOKEN } from "./typechain-types";
import { BigNumber } from "ethers";

describe("BBTOKEN", function () {
  let myToken: BBTOKEN;
  const NAME = 'B&B';
  const SYMBOL = 'B&B';
  const DECIMALS = 18  
  const MILLON = Math.pow(10, 6);
  const BILLON = Math.pow(10, 12);
  const oneMillonWei = ethers.utils.parseUnits(MILLON.toString(), 18);

  beforeEach(async function () {

    const MyToken = await ethers.getContractFactory("BBTOKEN");
    myToken = await MyToken.deploy(NAME, SYMBOL, DECIMALS, MILLON, BILLON);
    await myToken.deployed();
    
  });

  describe("name", function () {
    it("should return the correct name", async function () {            
      expect(await myToken.name()).to.equal(NAME);
    });
  });

  describe("symbol", function () {
    it("should return the correct symbol", async function () {
      expect(await myToken.symbol()).to.equal(SYMBOL);
    });
  });

  describe("decimals", function () {
    it("should return the correct decimals", async function () {
      expect(await myToken.decimals()).to.equal(DECIMALS);
    });
  });

  describe("totalSupply", function () {
    it("debería devolver el suministro total correcto", async function () {
      const expectedTotalSupply = oneMillonWei;
      const totalSupply = await myToken.totalSupply();
  
      expect(totalSupply.eq(expectedTotalSupply)).to.be.true;
    });
  });

  describe("balanceOf", function () {
    it("debería devolver el saldo correcto para una cuenta", async function () {
      const [cuenta] = await ethers.getSigners();
      const balance = await myToken.balanceOf(cuenta.address);
      expect(balance.eq(oneMillonWei)).to.be.true;
    });
  });

  describe("transfer", function () {
    it("debería transferir tokens del remitente al destinatario", async function () {
      const [remitente, destinatario] = await ethers.getSigners();
      const transferAmount = ethers.utils.parseUnits("1000", 18);
  
      const initialBalanceSender = await myToken.balanceOf(remitente.address);
      const initialBalanceRecipient = await myToken.balanceOf(destinatario.address);
  
      await myToken.connect(remitente).transfer(destinatario.address, transferAmount);
  
      const finalBalanceSender = await myToken.balanceOf(remitente.address);
      const finalBalanceRecipient = await myToken.balanceOf(destinatario.address);
  
      expect(finalBalanceSender.eq(initialBalanceSender.sub(transferAmount))).to.be.true;
      expect(finalBalanceRecipient.eq(initialBalanceRecipient.add(transferAmount))).to.be.true;
    });
  
    it("debería revertir si el remitente tiene saldo insuficiente", async function () {
      // cuenta 5 de la lista de firmantes. 
      const [,,,remitente, destinatario] = await ethers.getSigners();
      const transferAmount = ethers.utils.parseUnits("2000", 18);
      await expect(myToken.connect(remitente).transfer(destinatario.address, transferAmount)).to.be.rejectedWith("ERC20: insufficient balance");
    });
  });
  
  describe("approve", function () {
    it("debería aprobar a un gastador para gastar tokens en nombre del propietario", async function () {
      const [owner, spender] = await ethers.getSigners();
      const initialAllowance = await myToken.allowance(owner.address, spender.address);
      const approveAmount = ethers.utils.parseUnits("1000", 18);
  
      await myToken.approve(spender.address, approveAmount);
  
      const newAllowance = await myToken.allowance(owner.address, spender.address);
      const expectedAllowance = initialAllowance.add(approveAmount);
  
      expect(newAllowance.toString()).to.equal(expectedAllowance.toString());
    });
  });
  
  describe("transferFrom", function () {
    it("debería transferir tokens del remitente al destinatario en nombre del propietario", async function () {
      const [owner, sender, recipient] = await ethers.getSigners();
      const approveAmount = ethers.utils.parseUnits("1000", 18);
      const transferAmount = ethers.utils.parseUnits("500", 18);
      await myToken.approve(sender.address, approveAmount);
  
      const initialBalanceOwner = await myToken.balanceOf(owner.address);
      const initialBalanceSender = await myToken.balanceOf(sender.address);
      const initialBalanceRecipient = await myToken.balanceOf(recipient.address);
      await myToken.connect(sender).transferFrom(owner.address, recipient.address, transferAmount);
  
      const newAllowance = await myToken.allowance(owner.address, sender.address);
      const expectedAllowance = approveAmount.sub(transferAmount);
      const newBalanceOwner = await myToken.balanceOf(owner.address);
      const expectedBalanceOwner = initialBalanceOwner.sub(transferAmount);
      const newBalanceSender = await myToken.balanceOf(sender.address);
      const newBalanceRecipient = await myToken.balanceOf(recipient.address);
      const expectedBalanceRecipient = initialBalanceRecipient.add(transferAmount);
  
      expect(newAllowance.toString()).to.equal(expectedAllowance.toString());
      expect(newBalanceOwner.toString()).to.equal(expectedBalanceOwner.toString());
      expect(newBalanceSender.toString()).to.equal(initialBalanceSender.toString());
      expect(newBalanceRecipient.toString()).to.equal(expectedBalanceRecipient.toString());
    });
  
    it("debería revertir si el propietario tiene un saldo insuficiente", async function () {
      const [,,,,owner, spender, recipient] = await ethers.getSigners();
      const approveAmount = ethers.utils.parseUnits("500", 18);
      const transferAmount = ethers.utils.parseUnits("1000", 18);
      await myToken.approve(spender.address, approveAmount);
  
      await expect(myToken.connect(spender).transferFrom(owner.address, recipient.address, transferAmount)).to.be.rejectedWith("ERC20: insufficient balance");
    });
  
    it("debería revertir si el gastador tiene una asignación insuficiente", async function () {
      const [owner, spender, recipient] = await ethers.getSigners();
      const approveAmount = ethers.utils.parseUnits("500", 18);
      const transferAmount = ethers.utils.parseUnits("1000", 18);
      await myToken.approve(spender.address, approveAmount);
  
      await expect(myToken.connect(spender).transferFrom(owner.address, recipient.address, transferAmount)).to.be.rejectedWith("ERC20: transfer amount exceeds allowance");
    });
  });
  

  describe("increaseAllowance", function () {
    it("debería aumentar la asignación del gastador por la cantidad especificada", async function () {
      const [owner, spender] = await ethers.getSigners();
      const initialAllowance = await myToken.allowance(owner.address, spender.address);
      const increaseAmount = ethers.utils.parseUnits("1000", 18);
      await myToken.increaseAllowance(spender.address, increaseAmount);
  
      const newAllowance = await myToken.allowance(owner.address, spender.address);
      const expectedAllowance = initialAllowance.add(increaseAmount);
  
      expect(newAllowance.toString()).to.equal(expectedAllowance.toString());
    });
  });

  describe("decreaseAllowance", function () {
    it("debería disminuir la asignación del gastador en la cantidad especificada", async function () {
      const [propietario, gastador] = await ethers.getSigners();
      const asignacionInicial = await myToken.allowance(propietario.address, gastador.address);
      const cantidadDisminuir = ethers.utils.parseUnits("500", 18);
  
      const nuevaAsignacion = asignacionInicial.sub(cantidadDisminuir);
      const asignacionFinal = nuevaAsignacion.lt(0) ? ethers.BigNumber.from(0) : nuevaAsignacion;
  
      if (asignacionInicial.gt(cantidadDisminuir)) {
        const transaction = await myToken.decreaseAllowance(gastador.address, cantidadDisminuir, { gasLimit: 500000 });
        await transaction.wait();
      }  
      expect((await myToken.allowance(propietario.address, gastador.address)).eq(asignacionFinal)).to.be.true;
  });
    

    it("debería revertir si la asignación del gastador disminuye por debajo de cero", async function () {
      const [propietario, gastador] = await ethers.getSigners();
      const asignacionInicial = await myToken.allowance(propietario.address, gastador.address);
      const cantidadDisminuir = asignacionInicial.add(1);
    
      await expect(myToken.decreaseAllowance(gastador.address, cantidadDisminuir)).to.be.rejectedWith("ERC20: decreased allowance below zero");
    });    
  });

  describe("mint", function () {
    it("debería crear nuevos tokens y asignarlos a la cuenta especificada", async function () {
      const [owner, account] = await ethers.getSigners();
      const initialTotalSupply = await myToken.totalSupply();
      const mintAmount = ethers.utils.parseUnits("1000", 18);
      await myToken.connect(owner).mint(account.address, mintAmount);
  
      expect((await myToken.totalSupply()).eq(initialTotalSupply.add(mintAmount))).to.be.true;
      expect((await myToken.balanceOf(account.address)).eq(mintAmount)).to.be.true;
      
    });
  });
  

  describe("burn", function () {
    it("debería quemar tokens de la cuenta especificada", async function () {
      const totalSupplyInicial = await myToken.totalSupply();
      const [owner] = await ethers.getSigners();
      const balanceInicialCuenta = await myToken.balanceOf(owner.address);
      const cantidadQuemar = ethers.utils.parseUnits("1", 18);
      
      const transaction = await myToken.connect(owner).burn(cantidadQuemar, { gasLimit: 500000 });
      await transaction.wait();
      
      expect((await myToken.totalSupply()).eq(totalSupplyInicial.sub(cantidadQuemar))).to.be.true;
      expect((await myToken.balanceOf(owner.address)).eq(balanceInicialCuenta.sub(cantidadQuemar))).to.be.true;
    });
    
 
    it("debería revertir si la cuenta tiene un saldo insuficiente", async function () {
      const [, account] = await ethers.getSigners();
      const balanceInicialCuenta = await myToken.balanceOf(account.address);
      const cantidadQuemar = balanceInicialCuenta.add(1);
  
      await expect(myToken.connect(account).burn(cantidadQuemar)).to.be.rejectedWith("ERC20: insufficient balance for burning");
    });


    describe("burnFrom", function () {
      it("debería quemar tokens de la cuenta especificada en nombre del propietario", async function () {
        const [account, spender] = await ethers.getSigners();
        const totalSupplyInicial = await myToken.totalSupply();
        const balanceInicialCuenta = await myToken.balanceOf(account.address);
        const cantidadQuemar = ethers.utils.parseUnits("1", 18);

        await myToken.connect(account).approve(spender.address, balanceInicialCuenta);
        await myToken.connect(spender).burnFrom(account.address, cantidadQuemar);
    
        expect((await myToken.totalSupply()).eq(totalSupplyInicial.sub(cantidadQuemar))).to.be.true;
        expect((await myToken.balanceOf(account.address)).eq(balanceInicialCuenta.sub(cantidadQuemar))).to.be.true;
        
        // se realizar la resta del balance - la cantidad de tokens eliminados
        const allowance = BigNumber.from(balanceInicialCuenta).sub(cantidadQuemar);
        expect((await myToken.connect(account).allowance(account.address, spender.address)).eq(allowance)).to.be.true;
      });

      it("debería revertir si la cuenta tiene un saldo insuficiente", async function () {
        const [,,, account, spender] = await ethers.getSigners();
        const balanceInicialCuenta = await myToken.balanceOf(account.address);
        const cantidadQuemar = balanceInicialCuenta.add(1);
        await myToken.connect(account).approve(spender.address, cantidadQuemar); // aprobamos la cantidad a eliminar para no obtener el revert de
    
        await expect(myToken.connect(spender).burnFrom(account.address, cantidadQuemar)).to.be.rejectedWith("ERC20: insufficient balance for burning");
      });

      it("debería revertir si el gastador tiene una asignación insuficiente", async function () {
        const [owner, account, spender] = await ethers.getSigners();

        await myToken.connect(owner).mint(account.address, ethers.utils.parseUnits("10", 18));
        // const balanceInicialCuenta = await myToken.balanceOf(account.address);
        const cantidadQuemar = ethers.utils.parseUnits("10", 18);
        const cantidadAprobada = ethers.utils.parseUnits("5", 18);
        await myToken.connect(account).approve(spender.address, cantidadAprobada);
    
        await expect(myToken.connect(spender).burnFrom(account.address, cantidadQuemar)).to.be.rejectedWith("ERC20: burn amount exceeds allowance");
      });
    });
  });
});
