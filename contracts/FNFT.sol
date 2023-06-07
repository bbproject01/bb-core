// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// @title Contrato FNFT
/// @notice Contrato inteligente de FNFT basado en ERC1155
contract FNFT is ERC1155 {
  IERC20 public erc20Token;
  uint256 public nextTokenId;
  uint256 public minimumErc20Balance = 1 * 10 ** 18; // costo minimo del FNFT
  address private _owner;

  mapping(uint256 => FNFTMetadata) public idToFNFTMetadata;

  struct FNFTMetadata {
    uint256 originalTerm; // El plazo original en meses para el FNFT
    uint256 timePassed; // El tiempo que ha pasado desde la acuñación del FNFT, en meses
    uint256 maximumReduction; // La reducción máxima permitida en el plazo original, representada como una fracción (ej. 25 para 25%)
  }

  constructor(string memory _uri, IERC20 _erc20Token) ERC1155(_uri) {
    erc20Token = _erc20Token;
    _owner = msg.sender;
  }

  event FNFTMinted(address indexed to, uint256 id, uint256 originalTerm, uint256 maximumReduction);

  /// @notice Función para acuñar un nuevo FNFT.
  /// @dev Esta función crea un nuevo FNFT con un ID único y lo asigna al remitente.
  /// @param _originalTerm El plazo original del FNFT.
  /// @param _maximumReduction La reducción máxima permitida del plazo del FNFT.
  /// @param _price The price in ERC20 tokens
  function mint(uint256 _originalTerm, uint256 _maximumReduction, uint256 _price) public {
    // require(erc20Token.balanceOf(msg.sender) >= minimumErc20Balance, 'FNFT: Saldo insuficiente de ERC20 para el minteo');
    // require(erc20Token.balanceOf(msg.sender) > _price, 'FNFT: Saldo insuficiente de ERC20 para el minteo');
    // require(erc20Token.transferFrom(msg.sender, address(this), _price), 'ERC20 transfer failed');

    nextTokenId++;
    uint256 newTokenId = nextTokenId;

    idToFNFTMetadata[newTokenId] = FNFTMetadata(_originalTerm, 0, _maximumReduction);
    _mint(msg.sender, newTokenId, _price, '');
  }

  /// @notice Cambia el token ERC20 asociado a este contrato.
  /// @param _erc20Token La dirección del nuevo token ERC20.
  function setERC20Token(IERC20 _erc20Token) public {
    require(msg.sender == _owner, 'FNFT: No eres el owner');
    erc20Token = _erc20Token;
  }

  /// @notice Cambia el saldo mínimo de ERC20 necesario para acuñar.
  /// @param _minimumErc20Balance El nuevo saldo mínimo.
  function setMinimumErc20Balance(uint256 _minimumErc20Balance) public {
    require(msg.sender == _owner, 'FNFT: No eres el owner');
    minimumErc20Balance = _minimumErc20Balance;
  }

  /// @notice Cambia la URI base para los tokens ERC1155.
  /// @param _newURI La nueva URI base.
  function setURI(string memory _newURI) public {
    require(msg.sender == _owner, 'FNFT: No eres el owner');
    _setURI(_newURI);
  }
}
