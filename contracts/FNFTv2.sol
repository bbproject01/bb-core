// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";

error NotEnoughERC20Balance();
error AlreadyLocked();

/**
 * @title FNFT
 * @dev Este contrato implementa la funcionalidad de un NFT Financiero (FNFT)
 */
contract FNFT is ERC1155, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;
    IERC20 public erc20Token; // La dirección del token ERC20 requerido para acuñar FNFT
    uint256 public minimumErc20Balance; // El saldo mínimo de ERC20 necesario para acuñar FNFT
    
    struct FNFTMetadata {
        uint256 originalTerm; // El plazo original en meses para el FNFT
        uint256 timePassed; // El tiempo que ha pasado desde la acuñación del FNFT, en meses
        uint256 maximumReduction; // La reducción máxima permitida en el plazo original, representada como una fracción (ej. 0.25 para 25%)
    }

    // Mapeo de ID de token a metadatos FNFT
    mapping(uint256 => FNFTMetadata) public _fnftMetadata;

    // Mapeo de ID de token a estado de bloqueo
    mapping(uint256 => bool) public _isLocked;

    // Mapeo de direcciones a saldo de ERC20 bloqueado
    mapping(address => uint256) public _lockedBalance;

    event FNFTMinted(address indexed to, uint256 indexed tokenId, uint256 originalTerm, uint256 maximumReduction);
    event FNFTLocked(uint256 indexed tokenId, address indexed owner, uint256 balance);
    event FNFTUnlocked(uint256 indexed tokenId, address indexed owner, uint256 balance);


    constructor(address _erc20Token, uint256 _minimumErc20Balance, string memory _uri) ERC1155(_uri) {
        erc20Token = IERC20(_erc20Token);
        minimumErc20Balance = _minimumErc20Balance;
        _tokenIdTracker.increment();
    }

    /**
     * @dev Permite al propietario del contrato cambiar la dirección del token ERC20.
     * @param _erc20Token La nueva dirección del token ERC20.
     */
    function setERC20Token(address _erc20Token) public onlyOwner {
        erc20Token = IERC20(_erc20Token);
    }

    /**
     * @dev Permite al propietario del contrato cambiar el saldo mínimo de ERC20 necesario para acuñar FNFT.
     * @param _minimumErc20Balance El nuevo saldo mínimo de ERC20.
     */
    function setMinimumErc20Balance(uint256 _minimumErc20Balance) public onlyOwner {
        minimumErc20Balance = _minimumErc20Balance;
    }

    /**
     * @dev Acuña un nuevo FNFT para el remitente.
     * @param originalTerm El plazo original en meses para el FNFT.
     * @param maximumReduction La reducción máxima permitida en el plazo original.
     * @param erc20Amount The amount of ERC20 tokens to exchange for the FNFT
     * @return The ID of the minted FNFT
     */
    function mint(uint256 originalTerm, uint256 maximumReduction, uint256 erc20Amount) public {        
        if (erc20Token.balanceOf(msg.sender) < minimumErc20Balance) {
            revert NotEnoughERC20Balance();
        }

        uint256 newTokenId = _tokenIdTracker.current();
        _mint(msg.sender, newTokenId, 1, "");
        _fnftMetadata[newTokenId] = FNFTMetadata(originalTerm, 0, maximumReduction);
        _tokenIdTracker.increment();

        emit FNFTMinted(msg.sender, newTokenId, originalTerm, maximumReduction);

        //Guarda el $$ erc20 al este contrato 
    }
     /**
     * @dev Acuña nuevos FNFT en lote.
     * @param amounts El número de FNFT a acuñar para cada par (originalTerm, maximumReduction).
     * @param originalTerms Los plazos originales para los FNFT.
     * @param maximumReductions Las reducciones máximas permitidas en los plazos originales.
     */
    function mintBatch(uint256[] memory amounts, uint256[] memory originalTerms, uint256[] memory maximumReductions) public {
        require(amounts.length == originalTerms.length, "FNFT: Los parametros de entrada no tienen la misma longitud");
        require(originalTerms.length == maximumReductions.length, "FNFT: Los parametros de entrada no tienen la misma longitud");

        for (uint256 i = 0; i < amounts.length; i++) {
            for (uint256 j = 0; j < amounts[i]; j++) {
                mint(originalTerms[i], maximumReductions[i]);
            }
        }
    }

    /**
     * @dev Bloquea un FNFT, transfiriendo el saldo mínimo de ERC20 al contrato y marcando el FNFT como bloqueado.
     * @param tokenId El ID del FNFT a bloquear.
     */
    function lock(uint256 tokenId) public {
        require(_exists(tokenId), "FNFT: El FNFT no existe");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC1155: caller is not owner nor approved");
        require(!_isLocked[tokenId], "AlreadyLocked");

        uint256 balanceToLock = minimumErc20Balance;
        require(erc20Token.balanceOf(msg.sender) >= balanceToLock, "FNFT: Saldo insuficiente de ERC20 para bloquear");

        // Transferencia del saldo de ERC20 al contrato
        erc20Token.transferFrom(msg.sender, address(this), balanceToLock);

        // Marca el FNFT como bloqueado y actualiza el saldo bloqueado
        isLocked[tokenId] = true;
        lockedBalance[msg.sender] += balanceToLock;

        emit FNFTLocked(tokenId, msg.sender, balanceToLock);
    }

    /**
     * @dev Bloquea múltiples FNFTs, transfiriendo el saldo mínimo de ERC20 al contrato por cada FNFT y marcándolos como bloqueados.
     * @param tokenIds Los IDs de los FNFTs a bloquear.
     */
    function lockBatch(uint256[] memory tokenIds) public {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            lock(tokenIds[i]);
        }
    }
    function unlock(uint256 tokenId) public {
      require(_isLocked[tokenId], "FNFT: FNFT is not locked");

      _isLocked[tokenId] = false;

      emit FNFTUnlocked(tokenId, msg.sender, minimumErc20Balance);
    }
    function lockBatch(uint256[] memory tokenIds) public {
      //TODO: AL devolverlo regresar el balance a su dueño- 
      for (uint256 i = 0; i < tokenIds.length; ++i) {
          lock(tokenIds[i]);
      }
    }

    /**
     * @dev Sobreescribe la función `safeTransferFrom` para prevenir la transferencia de FNFTs bloqueados.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public override {
        require(!isLocked[id], "FNFT: El FNFT esta bloqueado y no se puede transferir");
        super.safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev Sobreescribe la función `burn` para prevenir la quema de FNFTs bloqueados.
     */
    function burn(uint256 id) public override {
        require(!isLocked[id], "FNFT: El FNFT esta bloqueado y no se puede quemar");
        super.burn(id);
    }
    // Sobrescribir la función `burnBatch` para prevenir la quema de FNFTs bloqueados
    function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) public override {
        for (uint256 i = 0; i < ids.length; i++) {
            require(!isLocked[ids[i]], "FNFT: No se puede quemar un FNFT bloqueado");
        }
        super.burnBatch(account, ids, amounts);
    }
    /// @notice Función para verificar si un FNFT existe.
    /// @dev Esta función devuelve verdadero si el FNFT con el ID dado existe, y falso en caso contrario.
    /// @param _tokenId El ID del FNFT a verificar.
    /// @return `true` si el FNFT existe, `false` en caso contrario.
    function _exists(uint256 _tokenId) internal view returns (bool) {
        return _fnftMetadata[_tokenId].originalTerm != 0;
    }
}
