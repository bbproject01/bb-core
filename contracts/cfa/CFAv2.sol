// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
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
  using Counters for Counters.Counter;

  /**
   * Local variables
   */

  Counters.Counter private _tokenIdTracker;
  IERC20 public erc20Token; // The address of the ERC20 token required to mint CFA
  uint256 public minimumErc20Balance; // The minimum balance of ERC20 needed to mint CFA

  Metadata public metadata;
  mapping(uint256 => Attributes) public attributes; // Token ID to CFA metadata mapping

  /**
   * Events
   */

  event CFAMinted(address indexed to, uint256 indexed tokenId, uint256 originalTerm, uint256 maximumReduction);
  event MetadataSaved(
    uint256 tokenId,
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

  constructor(address _erc20Token, uint256 _minimumErc20Balance) ERC1155('') {
    erc20Token = IERC20(_erc20Token);
    minimumErc20Balance = _minimumErc20Balance;
    _tokenIdTracker.increment();

    metadata.name = 'CFA';
    metadata.description = 'Sample Description for CFA';
    metadata.image[
        0
      ] = 'https://magenta-protestant-falcon-171.mypinata.cloud/ipfs/QmdL8nW1NrnmKkvSx7wHC8EBtNyYgHnR24ARaQLXYysnKa';
    metadata.image[
        1
      ] = 'https://magenta-protestant-falcon-171.mypinata.cloud/ipfs/QmeAaJgrpVVxc9Z4EKbJTz5hBipKZhgNB33UEsFv2bLxFc';
  }

  /**
   * Main Functions
   */

  /**
   * @dev Coins a new CFA for the sender.
   * @param cfaAttributes Array of CFA attributes for each CFA to mint.
   */
  function saveMetadata(Attributes memory cfaAttributes) public {
    // TODO: Update this Formula | Waiting for latest formula
    // uint256 interestRate = compounding_frequency * [(final_amount / erc20Amount) ** (1 / (compounding_frequency * yearsLocked)) - 1];
    uint256 interestRate = 0;
    attributes[_tokenIdTracker.current()] = cfaAttributes;
    emit MetadataSaved(
      _tokenIdTracker.current(),
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
    if (erc20Token.balanceOf(msg.sender) < cfaAttributes.amount) {
      revert('NotEnoughERC20Balance');
    }

    _mint(msg.sender, _tokenIdTracker.current(), 1, '');
    saveMetadata(cfaAttributes);

    emit CFAMinted(msg.sender, _tokenIdTracker.current(), cfaAttributes.cfaLife, cfaAttributes.amount);
    _tokenIdTracker.increment();
  }

  /**
   * @dev Mint new CFAs in batch.
   * @param cfaAttributes Array of CFA attributes for each CFA to mint.
   * @param amounts Array of number of CFAs to mint.
   */
  function mintBatch(Attributes[] memory cfaAttributes, uint256[] memory amounts) public {
    require(amounts.length == cfaAttributes.length, 'CFA: Not same length');
    for (uint256 i = 0; i < amounts.length; i++) {
      for (uint256 attrIndex = 0; attrIndex < amounts[i]; attrIndex++) {
        mint(cfaAttributes[i]);
      }
    }
  }

  /**
   * @dev Blocks a CFA, transferring the minimum balance of ERC20 to the contract and marking the CFA as blocked.
   * @param _tokenId The ID of the CFA to block.
   */
  function lock(uint256 _tokenId, uint256 _term) public {
    require(_exists(_tokenId), 'CFA: CFA does not exist');
    require(balanceOf(msg.sender, _tokenId) > 0, 'CFA: Not owner of CFA');
    require(attributes[_tokenId].soulBoundTerm == 0, 'AlreadyLocked');

    uint256 balanceToLock = minimumErc20Balance;
    require(erc20Token.balanceOf(msg.sender) >= balanceToLock, 'CFA: Insufficient balance of ERC20 to lock');

    attributes[_tokenId].soulBoundTerm = _term;

    emit CFALocked(_tokenId, msg.sender, balanceToLock);
  }

  function unlock(uint256 tokenId) public {
    Attributes memory attribute = attributes[tokenId];
    require(attribute.soulBoundTerm != 0, 'CFA: CFA is not locked');
    require(block.timestamp > (attribute.soulBoundTerm + attribute.timeCreated), 'CFA: CFA is locked');

    attributes[tokenId].soulBoundTerm = 0;

    emit CFAUnlocked(tokenId, msg.sender, attribute.amount);
  }

  function lockBatch(uint256[] memory tokenIds, uint256[] memory _terms) public {
    //TODO: When returning it, return the balance to its owner-
    for (uint256 i = 0; i < tokenIds.length; ++i) {
      lock(tokenIds[i], _terms[i]);
    }
  }

  /**
   * Setter Functions
   */

  function setImage(string[2] memory _images) external onlyOwner {
    metadata.image[0] = _images[0];
    metadata.image[1] = _images[1];
  }

  function setMetadata(string memory _name, string memory _desc) external onlyOwner {
    metadata.name = _name;
    metadata.description = _desc;
  }

  function setERC20Token(address _erc20Token) public onlyOwner {
    erc20Token = IERC20(_erc20Token);
  }

  function setMinimumErc20Balance(uint256 _minimumErc20Balance) public onlyOwner {
    minimumErc20Balance = _minimumErc20Balance;
  }

  /**
   * View Functions
   */

  function getImage(uint256 tokenId) public view returns (string memory) {
    bool status = attributes[tokenId].soulBoundTerm > 0;
    string memory image = status ? metadata.image[1] : metadata.image[0];
    return image;
  }

  function getMetadata(uint256 _tokenId) public view returns (string memory) {
    string memory _metadata = string(
      abi.encodePacked(
        '{',
        '"name":"',
        metadata.name,
        ' #',
        _tokenId.toString(),
        '",',
        '"description":',
        '"',
        metadata.description,
        '",',
        '"image":',
        '"',
        getImage(_tokenId),
        '"',
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
