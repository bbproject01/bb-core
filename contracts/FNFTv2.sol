// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/utils/Base64.sol';
import './IFNFT.sol';

error NotEnoughERC20Balance();
error AlreadyLocked();

/**
 * @title FNFT
 * @dev This contract implements the functionality of a Financial NFT (FNFT)
 */
contract FNFT is IFNFT, ERC1155, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;

  /**
   * Local variables
   */

  Counters.Counter private _tokenIdTracker;
  IERC20 public erc20Token; // The address of the ERC20 token required to mint FNFT
  uint256 public minimumErc20Balance; // The minimum balance of ERC20 needed to mint FNFT

  Metadata public metadata; // The metadata of the FNFT

  mapping(uint256 => FNFTattributes) public _fnftMetadata; // Token ID to FNFT metadata mapping
  mapping(uint256 => bool) public _isLocked; // Token ID to lock state mapping
  mapping(address => uint256) public _lockedBalance; // Address mapping to blocked ERC20 balance

  /**
   * Events
   */

  event FNFTMinted(address indexed to, uint256 indexed tokenId, uint256 originalTerm, uint256 maximumReduction);
  event FNFTLocked(uint256 indexed tokenId, address indexed owner, uint256 balance);
  event FNFTUnlocked(uint256 indexed tokenId, address indexed owner, uint256 balance);

  /**
   * Constructor
   */

  constructor(address _erc20Token, uint256 _minimumErc20Balance, string memory _uri) ERC1155(_uri) {
    erc20Token = IERC20(_erc20Token);
    minimumErc20Balance = _minimumErc20Balance;
    _tokenIdTracker.increment();
  }

  /**
   * Main Functions
   */

  /**
   * @dev Allows the contract owner to change the address of the ERC20 token.
   * @param _erc20Token The new address of the ERC20 token.
   */
  function setERC20Token(address _erc20Token) public onlyOwner {
    erc20Token = IERC20(_erc20Token);
  }

  /**
   * @dev Allows the contract owner to change the minimum balance of ERC20 needed to mint FNFT.
   * @param _minimumErc20Balance The new ERC20 minimum balance.
   */
  function setMinimumErc20Balance(uint256 _minimumErc20Balance) public onlyOwner {
    minimumErc20Balance = _minimumErc20Balance;
  }

  /**
   * @dev Coins a new FNFT for the sender.
   * @param productType The type of FNFT product.
   * @param fNftLife The period of time before the FNFT expires.
   * @param soulBoundTerm The period of time before the FNFT can be unlocked/transferrable.
   * @param erc20Amount The principal amount of B&B Tokens
   */
  function mint(
    Product productType,
    uint256 fNftLife,
    uint256 soulBoundTerm,
    uint256 erc20Amount,
    uint256 yearsLocked
  ) public {
    if (erc20Token.balanceOf(msg.sender) < minimumErc20Balance) {
      revert NotEnoughERC20Balance();
    }

    // TODO: Update this Formula
    // uint256 interestRate = compounding_frequency * [(final_amount / erc20Amount) ** (1 / (compounding_frequency * yearsLocked)) - 1];

    uint256 newTokenId = _tokenIdTracker.current();
    _mint(msg.sender, newTokenId, 1, '');
    // _fnftMetadata[newTokenId] = FNFTMetadata(originalTerm, 0, maximumReduction);
    _fnftMetadata[newTokenId] = FNFTattributes(productType, block.timestamp, fNftLife, soulBoundTerm, erc20Amount, 0); // WIP: Change last value to interestRate
    _tokenIdTracker.increment();

    // emit FNFTMinted(msg.sender, newTokenId, originalTerm, maximumReduction);
  }

  /**
   * @dev Mint new FNFTs in batch.
   * @param amounts The number of FNFTs to mint for each pair (originalTerm, maximumReduction).
   * @param originalTerms The original deadlines for the FNFT.
   * @param maximumReductions The maximum reductions allowed in the original terms.
   */
  function mintBatch(
    uint256[] memory amounts,
    uint256[] memory originalTerms,
    uint256[] memory maximumReductions
  ) public {
    require(amounts.length == originalTerms.length, 'FNFT: The input parameters do not have the same length');
    require(originalTerms.length == maximumReductions.length, 'FNFT: The input parameters do not have the same length');

    for (uint256 i = 0; i < amounts.length; i++) {
      for (uint256 j = 0; j < amounts[i]; j++) {
        mint(originalTerms[i], maximumReductions[i]);
      }
    }
  }

  /**
   * @dev Blocks a FNFT, transferring the minimum balance of ERC20 to the contract and marking the FNFT as blocked.
   * @param tokenId The ID of the FNFT to block.
   */
  function lock(uint256 tokenId) public {
    require(_exists(tokenId), 'FNFT: FNFT does not exist');
    require(balanceOf(msg.sender, tokenId), 'ERC1155: caller is not owner');
    require(!_isLocked[tokenId], 'AlreadyLocked');

    uint256 balanceToLock = minimumErc20Balance;
    require(erc20Token.balanceOf(msg.sender) >= balanceToLock, 'FNFT: Insufficient balance of ERC20 to lock');

    // Transfer of the ERC20 balance to the contract
    erc20Token.transferFrom(msg.sender, address(this), balanceToLock);

    // Mark the FNFT as blocked and update the blocked balance
    // isLocked[tokenId] = true;
    // lockedBalance[msg.sender] += balanceToLock;

    emit FNFTLocked(tokenId, msg.sender, balanceToLock);
  }

  /**
   * @dev Block multiple FNFTs, transferring the minimum balance of ERC20 to the contract for each FNFT and marking them as blocked.
   * @param tokenIds The IDs of the FNFTs to block.
   */
  function lockBatch(uint256[] memory tokenIds) public {
    for (uint256 i = 0; i < tokenIds.length; i++) {
      lock(tokenIds[i]);
    }
  }

  function unlock(uint256 tokenId) public {
    require(_isLocked[tokenId], 'FNFT: FNFT is not locked');

    _isLocked[tokenId] = false;

    emit FNFTUnlocked(tokenId, msg.sender, minimumErc20Balance);
  }

  function lockBatch(uint256[] memory tokenIds) public {
    //TODO: When returning it, return the balance to its owner-
    for (uint256 i = 0; i < tokenIds.length; ++i) {
      lock(tokenIds[i]);
    }
  }

  /**
   * View Functions
   */

  function getImage(uint256 tokenId) public view returns (string memory) {
    return _fnftMetadata[tokenId].image;
  }

  function getAttributes(uint256 tokenId) public view returns (string memory) {
    string memory attributes = string(
      abi.encodePacked(
        '{',
        '"Product Type":',
        "'",
        string(_fnftMetadata[tokenId].product),
        "'",
        ',',
        '"Time Created":',
        "'",
        string(_fnftMetadata[tokenId].timeCreated),
        "'",
        ',',
        '"FNFT Life":',
        "'",
        string(_fnftMetadata[tokenId].fNftLife),
        "'",
        ',',
        '"Soul Bound Term":',
        "'",
        string(_fnftMetadata[tokenId].soulBoundTerm),
        "'",
        ',',
        '"B&B Locked":',
        "'",
        string(_fnftMetadata[tokenId].amount),
        "'",
        ',',
        '"Interest Rate":',
        "'",
        string(_fnftMetadata[tokenId].interestRate),
        "'",
        ',',
        ')'
      )
    );

    return attributes;
  }

  /**
   * Overrides
   */

  /**
   * @dev Overrides the `safeTransferFrom` function to prevent the transfer of blocked FNFTs.
   */
  function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public override {
    require(_fnftMetadata[id].soulBoundTerm == 0, 'FNFT: El FNFT esta bloqueado y no se puede transferir');
    super.safeTransferFrom(from, to, id, amount, data);
  }

  /**
   * @dev Overrides the `burn` function to prevent burning of locked FNFTs.
   */
  function burn(uint256 id) public {
    require(_fnftMetadata[id].soulBoundTerm == 0, 'FNFT: El FNFT esta bloqueado y no se puede quemar');
    super.burn(id);
  }

  // Override the `burnBatch` function to prevent burning of locked FNFTs
  function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) public {
    for (uint256 i = 0; i < ids.length; i++) {
      require(_fnftMetadata[ids[i]].soulBoundTerm == 0, 'FNFT: No se puede quemar un FNFT bloqueado');
    }
    super.burnBatch(account, ids, amounts);
  }

  function uri(uint256 _tokenId) public view virtual override returns (string memory) {
    string memory _uri = abi
      .encodePacked(
        '{',
        "'name':",
        metadata.name,
        ' #',
        _tokenId.toString(),
        "',",
        "'",
        "'description':",
        "'",
        metadata.description,
        "',",
        "'image':",
        "'",
        metadata.image,
        "',",
        "'attributes':",
        getAttributes(_tokenId),
        ',',
        '}'
      )
      .toString();

    return string(abi.encodePacked('data:application/json;base64,', Base64.encode(_uri)));
  }

  /// @notice Function to check if a FNFT exists.
  /// @dev This function returns true if the FNFT with the given ID exists, and false otherwise.
  /// @param _tokenId The FNFT ID to verify.
  /// @return `true` if the FNFT exists, `false` otherwise.
  function _exists(uint256 _tokenId) internal view returns (bool) {
    return _fnftMetadata[_tokenId].originalTerm != 0;
  }
}