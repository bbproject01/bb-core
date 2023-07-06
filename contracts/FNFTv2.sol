// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/utils/Context.sol';

error NotEnoughERC20Balance();
error AlreadyLocked();

/**
 * @title FNFT
 * @dev This contract implements the functionality of a Financial NFT (FNFT)
 */
contract FNFT is ERC1155, Ownable {
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdTracker;
  IERC20 public erc20Token; // The address of the ERC20 token required to mint FNFT
  uint256 public minimumErc20Balance; // The minimum balance of ERC20 needed to mint FNFT

  struct FNFTMetadata {
    uint256 originalTerm; // The original term in months for the FNFT
    uint256 timePassed; // The time that has passed since the minting of the FNFT, in months
    uint256 maximumReduction; // The maximum reduction allowed in the original term, represented as a fraction (eg 0.25 for 25%)
  }

  mapping(uint256 => FNFTMetadata) public _fnftMetadata; // Token ID to FNFT metadata mapping
  mapping(uint256 => bool) public _isLocked; // Token ID to lock state mapping
  mapping(address => uint256) public _lockedBalance; // Address mapping to blocked ERC20 balance

  event FNFTMinted(address indexed to, uint256 indexed tokenId, uint256 originalTerm, uint256 maximumReduction);
  event FNFTLocked(uint256 indexed tokenId, address indexed owner, uint256 balance);
  event FNFTUnlocked(uint256 indexed tokenId, address indexed owner, uint256 balance);

  constructor(address _erc20Token, uint256 _minimumErc20Balance, string memory _uri) ERC1155(_uri) {
    erc20Token = IERC20(_erc20Token);
    minimumErc20Balance = _minimumErc20Balance;
    _tokenIdTracker.increment();
  }

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
   * @param originalTerm The original term in months for the FNFT.
   * @param maximumReduction The maximum reduction allowed in the original term.
   * @param erc20Amount The amount of ERC20 tokens to exchange for the FNFT
   * @return The ID of the minted FNFT
   */
  function mint(uint256 originalTerm, uint256 maximumReduction, uint256 erc20Amount) public {
    if (erc20Token.balanceOf(msg.sender) < minimumErc20Balance) {
      revert NotEnoughERC20Balance();
    }

    uint256 newTokenId = _tokenIdTracker.current();
    _mint(msg.sender, newTokenId, 1, '');
    _fnftMetadata[newTokenId] = FNFTMetadata(originalTerm, 0, maximumReduction);
    _tokenIdTracker.increment();

    emit FNFTMinted(msg.sender, newTokenId, originalTerm, maximumReduction);

    //Save the $$ erc20 to this contract
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
    require(_isApprovedOrOwner(_msgSender(), tokenId), 'ERC1155: caller is not owner nor approved');
    require(!_isLocked[tokenId], 'AlreadyLocked');

    uint256 balanceToLock = minimumErc20Balance;
    require(erc20Token.balanceOf(msg.sender) >= balanceToLock, 'FNFT: Insufficient balance of ERC20 to lock');

    // Transfer of the ERC20 balance to the contract
    erc20Token.transferFrom(msg.sender, address(this), balanceToLock);

    // Mark the FNFT as blocked and update the blocked balance
    isLocked[tokenId] = true;
    lockedBalance[msg.sender] += balanceToLock;

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
   * @dev Overrides the `safeTransferFrom` function to prevent the transfer of blocked FNFTs.
   */
  function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public override {
    require(!isLocked[id], 'FNFT: El FNFT esta bloqueado y no se puede transferir');
    super.safeTransferFrom(from, to, id, amount, data);
  }

  /**
   * @dev Overrides the `burn` function to prevent burning of locked FNFTs.
   */
  function burn(uint256 id) public override {
    require(!isLocked[id], 'FNFT: El FNFT esta bloqueado y no se puede quemar');
    super.burn(id);
  }

  // Override the `burnBatch` function to prevent burning of locked FNFTs
  function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) public override {
    for (uint256 i = 0; i < ids.length; i++) {
      require(!isLocked[ids[i]], 'FNFT: No se puede quemar un FNFT bloqueado');
    }
    super.burnBatch(account, ids, amounts);
  }

  /// @notice Function to check if a FNFT exists.
  /// @dev This function returns true if the FNFT with the given ID exists, and false otherwise.
  /// @param _tokenId The FNFT ID to verify.
  /// @return `true` if the FNFT exists, `false` otherwise.
  function _exists(uint256 _tokenId) internal view returns (bool) {
    return _fnftMetadata[_tokenId].originalTerm != 0;
  }
}
