import chai from 'chai';
import chaiAsPromised from 'chai-as-promised';
import { ethers, waffle } from 'hardhat';
import { BigNumber, Contract, Signer } from 'ethers';
import { time } from '@nomicfoundation/hardhat-network-helpers';

chai.use(chaiAsPromised);
const expect = chai.expect;

describe('FNFT Contract', function () {
  let FNFT: Contract;
  let myToken: Contract;

  const NAME = 'B&B';
  const SYMBOL = 'B&B';
  const DECIMALS = 18;
  const MILLON = Math.pow(10, 6);
  const BILLON = Math.pow(10, 12);
  const URI = '';

  beforeEach(async function () {
    const [owner] = await ethers.getSigners();

    // ERC20
    const MyToken = await ethers.getContractFactory('BBTOKEN');
    myToken = await MyToken.deploy(NAME, SYMBOL, DECIMALS, MILLON, BILLON);
    await myToken.deployed();
    await myToken.mint(await owner.getContractAddress(), ethers.utils.parseEther('1000'));

    // ERC1155
    const FNFTFactory = await ethers.getContractFactory('FNFT');
    FNFT = await FNFTFactory.deploy(URI, myToken.address);
    await FNFT.deployed();
  });

  describe('mint()', function () {
    it('should mint a new FNFT token', async function () {
      const TIEMPO_MESES = 4; // el plazo
      const REDUCION_MAXIMA = 25; // el pct de reduccion
      const PRICE = ethers.utils.parseUnits('100', 18); // 100 tokens BBToken

      const [owner] = await ethers.getSigners();
      // aprobar que gaste el smart contract nuestros tokens para poder mint FNFT's
      await myToken.connect(owner).approve(FNFT.address, PRICE);
      await FNFT.connect(owner).mint(TIEMPO_MESES, REDUCION_MAXIMA, PRICE);

      expect((await FNFT.balanceOf(await owner.getContractAddress(), 1)).eq(PRICE)).to.be.true;
    });
  });

  describe('setMinimumErc20Balance()', function () {
    it('should update the minimum ERC20 balance required to mint', async function () {
      const newMinimumBalance = ethers.utils.parseEther('2');
      await FNFT.setMinimumErc20Balance(newMinimumBalance);
      const minimumBalance = await FNFT.minimumErc20Balance();
      expect(minimumBalance).to.equal(newMinimumBalance);
    });
  });

  describe('safeTransferFrom()', function () {
    it('should transfer FNFT tokens from one account to another', async function () {
      4;

      const [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
      const id = 1;

      // Aprobamos que el smartcontract FNFT pueda gastar tokens de owner
      await myToken.connect(owner).approve(FNFT.address, ethers.utils.parseEther('10'));

      // Asegúrate de que el propietario tiene tokens FNFT para transferir
      await FNFT.mint(12, 25, ethers.utils.parseEther('1'));

      const initialBalanceOwner = await FNFT.balanceOf(await owner.getContractAddress(), id);
      const initialBalanceAddr1 = await FNFT.balanceOf(await addr1.getContractAddress(), id);

      expect(initialBalanceOwner).to.equal(ethers.utils.parseEther('1'));
      expect(initialBalanceAddr1).to.equal(BigNumber.from(0));

      // Transfiere tokens del propietario a addr1
      await FNFT.connect(owner).safeTransferFrom(
        await owner.getContractAddress(),
        await addr1.getContractAddress(),
        id,
        ethers.utils.parseEther('1'),
        '0x0123456789abcdef'
      );

      const finalBalanceOwner = await FNFT.balanceOf(await owner.getContractAddress(), id);
      const finalBalanceAddr1 = await FNFT.balanceOf(await addr1.getContractAddress(), id);

      expect(finalBalanceOwner).to.equal(BigNumber.from(0));
      expect(finalBalanceAddr1).to.equal(ethers.utils.parseEther('1'));
    });
  });

  describe('getTokensOwner()', function () {
    it('deberia obtener un array con N cantidad de FNFT´s', async function () {
      4;

      const [owner, account] = await ethers.getSigners();

      // Creamos los FNFT's desde owner
      await myToken.connect(owner).approve(FNFT.address, ethers.utils.parseEther('3'));
      await FNFT.connect(owner).mint(12, 25, ethers.utils.parseEther('1'));
      await FNFT.connect(owner).mint(10, 25, ethers.utils.parseEther('1'));
      await FNFT.connect(owner).mint(20, 25, ethers.utils.parseEther('1'));

      // agregamos tokens BNB a account
      await myToken.mint(await account.getContractAddress(), ethers.utils.parseEther('1000'));
      await myToken.connect(account).approve(FNFT.address, ethers.utils.parseEther('3'));

      // Creamos los FNFT's de account
      await FNFT.connect(account).mint(10, 25, ethers.utils.parseEther('1'));
      await FNFT.connect(account).mint(10, 25, ethers.utils.parseEther('1'));

      const listTokensOwner = await FNFT.getTokensOwner();
      const listTokensAccount = await FNFT.connect(account).getTokensOwner();

      // validamos que sea la longitud esperada
      expect(listTokensOwner.length).to.equal(3);
      expect(listTokensAccount.length).to.equal(2);
    });

    it("deberia obtener un arreglo vacion si la cuenta no tiene FNFT's", async function () {
      4;

      const [owner, account] = await ethers.getSigners();

      // Aprobamos que el smartcontract FNFT pueda gastar tokens de owner
      await myToken.connect(owner).approve(FNFT.address, ethers.utils.parseEther('10'));

      // Creamos los FNFT's desde owner
      await FNFT.connect(owner).mint(12, 25, ethers.utils.parseEther('1'));
      await FNFT.connect(owner).mint(10, 25, ethers.utils.parseEther('1'));
      await FNFT.connect(owner).mint(20, 25, ethers.utils.parseEther('1'));

      // agregamos tokens BNB a account
      await myToken.mint(await account.getContractAddress(), ethers.utils.parseEther('1000'));

      const listTokensAccount = await FNFT.connect(account).getTokensOwner();

      // validamos que sea la longitud esperada
      expect(listTokensAccount.length).to.equal(0);
    });
  });

  describe('getInfoFNFTMetadata()', function () {
    it('deberia obtener la información del FNFT consultado', async function () {
      4;
      const [owner] = await ethers.getSigners();
      const originalTerm = 12;
      const maximumReduction = 25;
      const id = 1;

      // Aprobamos que el smartcontract FNFT pueda gastar tokens de owner
      await myToken.connect(owner).approve(FNFT.address, ethers.utils.parseEther('10'));

      // Creamos los FNFT's desde owner
      await FNFT.connect(owner).mint(originalTerm, maximumReduction, ethers.utils.parseEther('1'));

      const infoFNFTMetadata = await FNFT.getInfoFNFTMetadata(id);

      // validamos que sea la longitud esperada
      expect(infoFNFTMetadata.originalTerm).to.equal(originalTerm);
      expect(infoFNFTMetadata.maximumReduction).to.equal(maximumReduction);
    });

    it('deberia obtener ceros si el id del FNFT enviado no existe', async function () {
      4;
      const [owner] = await ethers.getSigners();
      const originalTerm = 12;
      const timePassed = 0;
      const maximumReduction = 25;
      const id = 10;

      // Aprobamos que el smartcontract FNFT pueda gastar tokens de owner
      await myToken.connect(owner).approve(FNFT.address, ethers.utils.parseEther('10'));

      // Creamos los FNFT's desde owner
      await FNFT.connect(owner).mint(originalTerm, maximumReduction, ethers.utils.parseEther('1'));

      const infoFNFTMetadata = await FNFT.getInfoFNFTMetadata(id);

      // validamos que sea la longitud esperada
      expect(infoFNFTMetadata.originalTerm).to.equal(0);
      expect(infoFNFTMetadata.timePassed).to.equal(0);
      expect(infoFNFTMetadata.maximumReduction).to.equal(0);
    });

    it('deberia ver la informacion account de un FNFT de owner', async function () {
      4;
      const [owner, account] = await ethers.getSigners();
      const originalTerm = 12;
      const maximumReduction = 25;
      const id = 1;

      // Aprobamos que el smartcontract FNFT pueda gastar tokens de owner
      await myToken.connect(owner).approve(FNFT.address, ethers.utils.parseEther('10'));

      // Creamos los FNFT's desde owner
      await FNFT.connect(owner).mint(originalTerm, maximumReduction, ethers.utils.parseEther('1'));

      const infoFNFTMetadata = await FNFT.connect(account).getInfoFNFTMetadata(id);

      // validamos que sea la longitud esperada
      expect(infoFNFTMetadata.originalTerm).to.equal(originalTerm);
      expect(infoFNFTMetadata.maximumReduction).to.equal(maximumReduction);
    });
  });

  describe('Pruebas de Bloqueo', function () {
    it('deberia bloquear un FNFT', async function () {
      const TIEMPO_MESES = 4; // el plazo
      const REDUCION_MAXIMA = 25; // el pct de reduccion
      const PRICE = ethers.utils.parseUnits('100', 18); // 100 tokens BBToken
      const id = 1;
      const [owner] = await ethers.getSigners();

      // aprobar que gaste el smart contract nuestros tokens para poder mint FNFT's
      await myToken.connect(owner).approve(FNFT.address, PRICE);
      await FNFT.connect(owner).mint(TIEMPO_MESES, REDUCION_MAXIMA, PRICE);
      await FNFT.connect(owner).createLock(id);
      expect(await FNFT.connect(owner).isLockable(id)).to.be.true;
    });

    it('deberia obtener un error si no es el propietario', async function () {
      const TIEMPO_MESES = 4; // el plazo
      const REDUCION_MAXIMA = 25; // el pct de reduccion
      const PRICE = ethers.utils.parseUnits('100', 18); // 100 tokens BBToken
      const id = 1;
      const [owner, account] = await ethers.getSigners();

      // aprobar que gaste el smart contract nuestros tokens para poder mint FNFT's
      await myToken.connect(owner).approve(FNFT.address, PRICE);
      await FNFT.connect(owner).mint(TIEMPO_MESES, REDUCION_MAXIMA, PRICE);
      await FNFT.connect(owner).createLock(id);
      await expect(FNFT.connect(account).createLock(id)).to.be.rejectedWith('Only the owner can lock the token');
    });

    it('deberia obtener un error si ya fue bloqueado anteriormente', async function () {
      const TIEMPO_MESES = 4; // el plazo
      const REDUCION_MAXIMA = 25; // el pct de reduccion
      const PRICE = ethers.utils.parseUnits('100', 18); // 100 tokens BBToken
      const id = 1;
      const [owner] = await ethers.getSigners();

      // aprobar que gaste el smart contract nuestros tokens para poder mint FNFT's
      await myToken.connect(owner).approve(FNFT.address, PRICE);
      await FNFT.connect(owner).mint(TIEMPO_MESES, REDUCION_MAXIMA, PRICE);
      await FNFT.connect(owner).createLock(id);
      await expect(FNFT.connect(owner).createLock(id)).to.be.rejectedWith('Lock already exists for this token');
    });
    it('deberia obtener false si el FNFT no esta bloqueado', async function () {
      const TIEMPO_MESES = 4; // el plazo
      const REDUCION_MAXIMA = 25; // el pct de reduccion
      const PRICE = ethers.utils.parseUnits('100', 18); // 100 tokens BBToken
      const id = 1;
      const [owner] = await ethers.getSigners();

      // aprobar que gaste el smart contract nuestros tokens para poder mint FNFT's
      await myToken.connect(owner).approve(FNFT.address, PRICE);
      await FNFT.connect(owner).mint(TIEMPO_MESES, REDUCION_MAXIMA, PRICE);
      expect(await FNFT.connect(owner).isLockable(id)).to.be.false;
    });

    it('deberia obtener true si el FNFT esta bloqueado', async function () {
      const TIEMPO_MESES = 4; // el plazo
      const REDUCION_MAXIMA = 25; // el pct de reduccion
      const PRICE = ethers.utils.parseUnits('100', 18); // 100 tokens BBToken
      const id = 1;
      const [owner] = await ethers.getSigners();

      // aprobar que gaste el smart contract nuestros tokens para poder mint FNFT's
      await myToken.connect(owner).approve(FNFT.address, PRICE);
      await FNFT.connect(owner).mint(TIEMPO_MESES, REDUCION_MAXIMA, PRICE);
      await FNFT.connect(owner).createLock(id);
      expect(await FNFT.connect(owner).isLockable(id)).to.be.true;
    });
    it('deberia desbloquear un FNFT', async function () {
      const TIEMPO_MESES = 4; // el plazo
      const REDUCION_MAXIMA = 25; // el pct de reduccion
      const PRICE = ethers.utils.parseUnits('100', 18); // 100 tokens BBToken
      const id = 1;
      const [owner] = await ethers.getSigners();

      // aprobar que gaste el smart contract nuestros tokens para poder mint FNFT's
      await myToken.connect(owner).approve(FNFT.address, PRICE);
      await FNFT.connect(owner).mint(TIEMPO_MESES, REDUCION_MAXIMA, PRICE);
      await FNFT.connect(owner).createLock(id);
      await FNFT.connect(owner).unlock(id);
      expect(await FNFT.connect(owner).isLockable(id)).to.be.false;
    });
  });

  describe('Pruebas de Transferencia para FNFT', function () {
    it('Debería fallar si el remitente no es el propietario', async function () {
      const [owner, addr1, addr2] = await ethers.getSigners();

      const PRICE = ethers.utils.parseUnits('7', 18);
      await myToken.connect(owner).approve(FNFT.address, PRICE);

      await FNFT.connect(owner).mint(12, 25, PRICE);
      await expect(FNFT.connect(addr1).transfer(addr2.address, 1)).to.be.revertedWith('Only Owner');
    });

    it('Debería fallar si el token está bloqueado', async function () {
      const PRICE = ethers.utils.parseUnits('15', 18);
      const [owner, addr2] = await ethers.getSigners();

      await myToken.connect(owner).approve(FNFT.address, PRICE);

      await FNFT.connect(owner).mint(12, 25, PRICE);
      const finalTokenId = await FNFT.nextTokenId();
      await FNFT.createLock(finalTokenId);
      await expect(FNFT.transfer(addr2.address, finalTokenId)).to.be.revertedWith('Token is locked');
    });

    it('Debería transferir el token si no está bloqueado y el remitente es el propietario', async function () {
      const PRICE = ethers.utils.parseUnits('10', 18);
      const [owner, addr2] = await ethers.getSigners();
      await myToken.connect(owner).approve(FNFT.address, PRICE);
      await FNFT.connect(owner).mint(12, 25, PRICE);

      const finalTokenId = await FNFT.nextTokenId();

      console.log('user mint --> ', owner.address);
      console.log('last ID --> ', finalTokenId.toString());
      console.log('owner last ID --> ', await FNFT.tokensOwners(finalTokenId));

      // Asume que el token con id 1 existe y es propiedad del address del desplegador
      await FNFT.transfer(addr2.address, finalTokenId);
      console.log('owner after tranfer --> ', await FNFT.tokensOwners(finalTokenId));

      expect(await FNFT.tokensOwners(finalTokenId)).to.equal(addr2.address);
    });
  });

  describe('withDrawFNFT()', function () {
    it('deberia obtener un error si el FNFT esta bloqueado', async function () {
      const TIEMPO_MESES = 4; // el plazo
      const REDUCION_MAXIMA = 25; // el pct de reduccion
      const PRICE = ethers.utils.parseUnits('100', 18); // 100 tokens BBToken
      const id = 1;
      const [owner] = await ethers.getSigners();

      // aprobar que gaste el smart contract nuestros tokens para poder mint FNFT's
      await myToken.connect(owner).approve(FNFT.address, PRICE);
      await FNFT.connect(owner).mint(TIEMPO_MESES, REDUCION_MAXIMA, PRICE);
      await FNFT.connect(owner).createLock(id);

      await expect(FNFT.connect(owner).withDrawFNFT(id)).to.be.rejectedWith('Token is locked');
    });

    it('deberia obtener un error si no es el propietario del FNFT', async function () {
      const TIEMPO_MESES = 4; // el plazo
      const REDUCION_MAXIMA = 25; // el pct de reduccion
      const PRICE = ethers.utils.parseUnits('100', 18); // 100 tokens BBToken
      const id = 1;
      const [owner, account] = await ethers.getSigners();

      // aprobar que gaste el smart contract nuestros tokens para poder mint FNFT's
      await myToken.connect(owner).approve(FNFT.address, PRICE);
      await FNFT.connect(owner).mint(TIEMPO_MESES, REDUCION_MAXIMA, PRICE);

      await expect(FNFT.connect(account).withDrawFNFT(id)).to.be.rejectedWith(
        'FNFT: Solo el propietario del FNFT puede reclamar los tokens'
      );
    });

    it('deberia obtener un error si el tiempo no se ha cumplido', async function () {
      const TIEMPO_MESES = 4; // el plazo
      const REDUCION_MAXIMA = 25; // el pct de reduccion
      const PRICE = ethers.utils.parseUnits('100', 18); // 100 tokens BBToken
      const id = 1;
      const [owner] = await ethers.getSigners();

      // aprobar que gaste el smart contract nuestros tokens para poder mint FNFT's
      await myToken.connect(owner).approve(FNFT.address, PRICE);
      await FNFT.connect(owner).mint(TIEMPO_MESES, REDUCION_MAXIMA, PRICE);

      await expect(FNFT.connect(owner).withDrawFNFT(id)).to.be.rejectedWith(
        'FNFT: Aun no se ha cumplido el tiempo para reclamar sus tokens'
      );
    });

    it('deberia retirar los tokens si el plazo ha finalizado', async function () {
      const TIEMPO_MESES = 4; // el plazo
      const REDUCION_MAXIMA = 25; // el pct de reduccion
      const PRICE = ethers.utils.parseUnits('100', 18); // 100 tokens BBToken
      const id = 1;
      const [owner] = await ethers.getSigners();

      // aprobar que gaste el smart contract nuestros tokens para poder mint FNFT's
      await myToken.connect(owner).approve(FNFT.address, PRICE);

      // Obtenemos el balance inicial
      const balanceInicial: BigNumber = await myToken.connect(owner).balanceOf(await owner.getContractAddress());

      // Minteamos el FNFT con el precio acordado
      await FNFT.connect(owner).mint(TIEMPO_MESES, REDUCION_MAXIMA, PRICE);

      // Obtenemos el balance intermedio con la reduccion del precio del FNFT
      const balanceIntermedio: BigNumber = await myToken.connect(owner).balanceOf(await owner.getContractAddress());

      // Incrementa el tiempo en el tiempo del FNFT día (en segundos)
      await ethers.provider.send('evm_increaseTime', [TIEMPO_MESES * 30 * 24 * 60 * 60]);

      // Retiramos los tokens del FNFT
      await FNFT.connect(owner).withDrawFNFT(id);

      // Obtenemos el balance final despues del retiro
      const balanceFinal: BigNumber = await myToken.connect(owner).balanceOf(await owner.getContractAddress());

      expect(balanceFinal.eq(balanceInicial)).to.be.true;
      expect(balanceIntermedio.eq(balanceInicial.sub(PRICE))).to.be.true;
    });

    it('deberia retirar los tokens actualizando la fecha de creación', async function () {
      const TIEMPO_MESES = 4; // el plazo
      const REDUCION_MAXIMA = 25; // el pct de reduccion
      const PRICE = ethers.utils.parseUnits('100', 18); // 100 tokens BBToken
      const id = 1;
      const [owner] = await ethers.getSigners();

      // aprobar que gaste el smart contract nuestros tokens para poder mint FNFT's
      await myToken.connect(owner).approve(FNFT.address, PRICE);

      // Obtenemos el balance inicial
      const balanceInicial: BigNumber = await myToken.connect(owner).balanceOf(await owner.getContractAddress());

      // Minteamos el FNFT con el precio acordado
      await FNFT.connect(owner).mint(TIEMPO_MESES, REDUCION_MAXIMA, PRICE);

      // Obtenemos el balance intermedio con la reduccion del precio del FNFT
      const balanceIntermedio: BigNumber = await myToken.connect(owner).balanceOf(await owner.getContractAddress());

      // Actualizar la fecha de creacion
      await FNFT.connect(owner).updateDate(id);

      // Retiramos los tokens del FNFT
      await FNFT.connect(owner).withDrawFNFT(id);

      // Obtenemos el balance final despues del retiro
      const balanceFinal: BigNumber = await myToken.connect(owner).balanceOf(await owner.getContractAddress());

      expect(balanceFinal.eq(balanceInicial)).to.be.true;
      expect(balanceIntermedio.eq(balanceInicial.sub(PRICE))).to.be.true;
    });
  });
});
