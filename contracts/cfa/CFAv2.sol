// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/utils/Base64.sol';
import './interface/ICFA.sol';

error NotEnoughERC20Balance();
error AlreadyLocked();

/**
 * @title CFAv2
 * @dev This contract implements the functionality of a Crypto Financial Assets (CFA)
 */
contract CFAv2 is ICFA, ERC1155, Ownable {
  using Strings for uint256;
  using Strings for Product;
  using Counters for Counters.Counter;

  /**
   * Local variables
   */

  Counters.Counter private _tokenIdTracker;
  IERC20 public erc20Token; // The address of the ERC20 token required to mint CFA
  uint256 public minimumErc20Balance; // The minimum balance of ERC20 needed to mint CFA

  mapping(uint256 => Metadata) public metadata;
  mapping(uint256 => Attributes) public attributes; // Token ID to CFA metadata mapping
  mapping(uint256 => bool) public _isLocked; // Token ID to lock state mapping
  mapping(address => uint256) public _lockedBalance; // Address mapping to blocked ERC20 balance

  /**
   * Events
   */

  event CFAMinted(address indexed to, uint256 indexed tokenId, uint256 originalTerm, uint256 maximumReduction);
  event MetadataSaved(
    uint256 tokenId,
    Product productType,
    uint256 cfaLife,
    uint256 soulBoundTerm,
    uint256 erc20Amount,
    uint256 interestRate
  );
  event CFALocked(uint256 indexed tokenId, address indexed owner, uint256 balance);
  event CFAUnlocked(uint256 indexed tokenId, address indexed owner, uint256 balance);

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
   * @dev Allows the contract owner to change the minimum balance of ERC20 needed to mint CFA.
   * @param _minimumErc20Balance The new ERC20 minimum balance.
   */
  function setMinimumErc20Balance(uint256 _minimumErc20Balance) public onlyOwner {
    minimumErc20Balance = _minimumErc20Balance;
  }

  /**
   * @dev Coins a new CFA for the sender.
   * @param cfaAttributes Array of CFA attributes for each CFA to mint.
   * @param tokenId The CFA Token ID that the metadata will be saved on.
   */
  function saveMetaData(Attributes memory cfaAttributes, uint256 tokenId) public {
    // TODO: Update this Formula | Waiting for latest formula
    // uint256 interestRate = compounding_frequency * [(final_amount / erc20Amount) ** (1 / (compounding_frequency * yearsLocked)) - 1];
    uint256 interestRate = 0;
    attributes[tokenId] = Attributes(
      cfaAttributes.product,
      block.timestamp,
      cfaAttributes.cfaLife,
      cfaAttributes.soulBoundTerm,
      cfaAttributes.amount,
      interestRate
    ); // WIP: Change last value to interestRate
    emit MetadataSaved(
      tokenId,
      cfaAttributes.product,
      cfaAttributes.cfaLife,
      cfaAttributes.soulBoundTerm,
      cfaAttributes.amount,
      interestRate
    );
  }

  /**
   * @dev Coins a new CFA for the sender.
   * @param cfaAttributes Array of CFA attributes for each CFA to mint.
   */
  function mint(Attributes memory cfaAttributes) public {
    // if (erc20Token.balanceOf(msg.sender) < minimumErc20Balance) {
    //   revert NotEnoughERC20Balance();
    // }
    if (erc20Token.balanceOf(msg.sender) < cfaAttributes.amount) {
      revert('NotEnoughERC20Balance');
    }

    uint256 newTokenId = _tokenIdTracker.current();
    _mint(msg.sender, newTokenId, 1, '');
    _tokenIdTracker.increment();
    saveMetaData(cfaAttributes, newTokenId);

    emit CFAMinted(msg.sender, newTokenId, cfaAttributes.cfaLife, cfaAttributes.amount);
  }

  /**
   * @dev Mint new CFAs in batch.
   * @param cfaAttributes Array of CFA attributes for each CFA to mint.
   * @param amounts The number of CFAs to mint.
   */
  function mintBatch1(Attributes[] memory cfaAttributes, uint256 amounts) public {
    for (uint256 i = 0; i < amounts; i++) {
      mint(cfaAttributes[i]);
    }
  }

  /**
   * @dev Mint new CFAs in batch. [Like A Cart]
   * @param cfaAttributes Array of CFA attributes for each CFA to mint.
   * @param amounts The number of CFAs to mint for each pair (originalTerm, maximumReduction).
   */
  function mintBatch2(Attributes[] memory cfaAttributes, uint256[] memory amounts) public {
    if (amounts.length != cfaAttributes.length) {
      revert('CFA:NotSameLength');
    }

    for (uint256 i = 0; i < amounts.length; i++) {
      for (uint256 j = 0; j < amounts[i]; j++) {
        Attributes memory attributes = Attributes( // Create a local memory variable
          cfaAttributes[i].product,
          cfaAttributes[i].timeCreated,
          cfaAttributes[i].cfaLife,
          cfaAttributes[i].soulBoundTerm,
          cfaAttributes[i].amount,
          cfaAttributes[i].interestRate
        );
        mint(attributes); // Pass the memory reference to the mint function
      }
    }
  }

  /**
   * @dev Blocks a CFA, transferring the minimum balance of ERC20 to the contract and marking the CFA as blocked.
   * @param tokenId The ID of the CFA to block.
   */
  function lock(uint256 tokenId) public {
    require(_exists(tokenId), 'CFA: CFA does not exist');
    require(balanceOf(msg.sender, tokenId) > 0, 'ERC1155: caller is not owner');
    require(!_isLocked[tokenId], 'AlreadyLocked');

    uint256 balanceToLock = minimumErc20Balance;
    require(erc20Token.balanceOf(msg.sender) >= balanceToLock, 'CFA: Insufficient balance of ERC20 to lock');

    // Transfer of the ERC20 balance to the contract
    erc20Token.transferFrom(msg.sender, address(this), balanceToLock);

    // Mark the CFA as blocked and update the blocked balance
    // isLocked[tokenId] = true;
    // lockedBalance[msg.sender] += balanceToLock;

    emit CFALocked(tokenId, msg.sender, balanceToLock);
  }

  function unlock(uint256 tokenId) public {
    require(_isLocked[tokenId], 'CFA: CFA is not locked');

    _isLocked[tokenId] = false;

    emit CFAUnlocked(tokenId, msg.sender, minimumErc20Balance);
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
    bool status = attributes[tokenId].soulBoundTerm > 0;
    string memory image = status ? metadata[tokenId].image[1] : metadata[tokenId].image[0];
    return image;
  }

  function getAttributes(uint256 tokenId) public view returns (string memory) {
    string memory attributes = string(
      abi.encodePacked(
        '{',
        '"Product Type":',
        "'",
        (attributes[tokenId].product),
        "'",
        ',',
        '"Time Created":',
        "'",
        (attributes[tokenId].timeCreated),
        "'",
        ',',
        '"CFA Life":',
        "'",
        (attributes[tokenId].cfaLife),
        "'",
        ',',
        '"Soul Bound Term":',
        "'",
        (attributes[tokenId].soulBoundTerm),
        "'",
        ',',
        '"B&B Locked":',
        "'",
        (attributes[tokenId].amount),
        "'",
        ',',
        '"Interest Rate":',
        "'",
        (attributes[tokenId].interestRate),
        "'",
        ',',
        ')'
      )
    );

    return attributes;
  }

  function getMetadata(uint256 _tokenId) public view returns (string memory) {
    string memory _metadata = string(
      abi.encodePacked(
        '{',
        "'name':",
        metadata[_tokenId].name,
        ' #',
        _tokenId.toString(),
        "',",
        "'",
        "'description':",
        "'",
        metadata[_tokenId].description,
        "',",
        "'image':",
        "'",
        getImage(_tokenId),
        "',",
        "'attributes':",
        getAttributes(_tokenId),
        ',',
        '}'
      )
    );

    return _metadata;
  }

  /**
   * Overrides
   */

  /**
   * @dev Overrides the `safeTransferFrom` function to prevent the transfer of blocked CFAs.
   */
  function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public override {
    require(attributes[id].soulBoundTerm == 0, 'CFA: El CFA esta bloqueado y no se puede transferir');
    super.safeTransferFrom(from, to, id, amount, data);
  }

  /**
   * @dev Overrides the `burn` function to prevent burning of locked CFAs.
   */
  function burn(uint256 id) public {
    require(attributes[id].soulBoundTerm == 0, 'CFA: El CFA esta bloqueado y no se puede quemar');
    this.burn(id);
  }

  // Override the `burnBatch` function to prevent burning of locked CFAs
  function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) public {
    for (uint256 i = 0; i < ids.length; i++) {
      require(attributes[ids[i]].soulBoundTerm == 0, 'CFA: No se puede quemar un CFA bloqueado');
    }
    this.burnBatch(account, ids, amounts);
  }

  function uri(uint256 _tokenId) public view virtual override returns (string memory) {
    bytes memory _metadata = abi.encodePacked(getMetadata(_tokenId));

    return string(abi.encodePacked('data:application/json;base64,', Base64.encode(_metadata)));
  }

  /// @notice Function to check if a CFA exists.
  /// @dev This function returns true if the CFA with the given ID exists, and false otherwise.
  /// @param _tokenId The CFA ID to verify.
  /// @return `true` if the CFA exists, `false` otherwise.
  function _exists(uint256 _tokenId) internal view returns (bool) {
    return attributes[_tokenId].cfaLife != 0;
  }
}
