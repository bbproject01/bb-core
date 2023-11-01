// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Base64.sol';
import '../token/BBTOKENv2.sol';
import '../utils/Registry.sol';
import './interface/IInsurance.sol';

contract Insurance is IInsurance, ERC1155, Ownable, ReentrancyGuard {
  /**
   * Use
   */
  using Strings for uint256;

  /**
   * Local variables
   */
  Metadata public metadata;
  Registry public registry;

  uint256 public idCounter;
  mapping(uint256 => uint256) public interestRate;
  mapping(uint256 => Attributes) public attributes;

  /**
   * Modifiers
   */

  /**
   * Events
   */
  event InsuranceCreated(Attributes _attributes);
  event InsuranceWithdrawn(uint256 _id, uint256 _amount, uint256 _time);
  event InsuranceBurned(Attributes _attributes, uint256 _time);

  /**
   * Constructor
   */

  constructor() ERC1155('') {}

  /**
   * Main Functions
   */
  function _saveMetadata(Attributes memory _attributes) internal {
    _attributes.timeCreated = block.timestamp;
    attributes[idCounter] = _attributes;
  }

  function _mintInsurance(Attributes memory _attributes) internal {
    IERC20(registry.registry('BbToken')).transferFrom(msg.sender, address(this), _attributes.principal);

    _mint(msg.sender, idCounter, 1, '');
    _saveMetadata(_attributes);

    emit InsuranceCreated(_attributes);
  }

  function mintInsurance(Attributes[] memory _attributes) external {
    for (uint256 i = 0; i < _attributes.length; i++) {
      _mintInsurance(_attributes[i]);
      idCounter++;
    }

    // TODO: add referral
  }

  function withdraw(uint256 _id, uint256 _amount) external nonReentrant {
    (uint256 interest, uint256 totalPrincipal) = getInterest(_id);

    require(balanceOf(msg.sender, _id) == 1, 'Insurance: invalid id');
    require(_amount <= (totalPrincipal), 'Insurance: invalid amount');
    require(
      ((block.timestamp - attributes[_id].timeCreated) / attributes[_id].timePeriod) > 0,
      'Insurance: Still not matured'
    );

    // TODO: implement interest
    BBToken token = BBToken(registry.registry('BbToken'));
    token.mint(interest);

    token.transfer(msg.sender, _amount + interest);
    attributes[_id].principal -= _amount;

    if (attributes[_id].principal < 1 ether) {
      _burn(msg.sender, _id, 1);
      emit InsuranceBurned(attributes[_id], block.timestamp);
    } else {
      attributes[_id].timeCreated = block.timestamp;
    }

    emit InsuranceWithdrawn(_id, _amount, block.timestamp);
  }

  /**
   * Write Functions
   */
  function setMetadata(Metadata memory _metadata) external onlyOwner {
    metadata = _metadata;
  }

  function setRegistry(address _registry) external onlyOwner {
    registry = Registry(_registry);
  }

  function setInterestRate(uint256[] memory _period, uint256[] memory _interestRate) external onlyOwner {
    require(_period.length == _interestRate.length, 'Insurance: invalid length');
    for (uint256 i = 0; i < _period.length; i++) {
      interestRate[_period[i]] = interestRate[i];
    }
  }

  /**
   * Read Functions
   */
  function getInterestRate(uint256 _period) public view returns (uint256) {
    require(interestRate[_period] != 0, 'Insurance: invalid period');
    return interestRate[_period];
  }

  function getInsuranceInterest(uint256 _id) external view returns (uint256) {
    uint256 period = attributes[_id].timePeriod;
    return getInterestRate(period);
  }

  function getInterest(uint256 _id) public view returns (uint256, uint256) {
    uint256 principal = attributes[_id].principal;
    uint256 interest = getInterestRate(attributes[_id].timePeriod);
    uint256 iterations = (block.timestamp - attributes[_id].timeCreated) / attributes[_id].timePeriod;
    uint256 totalInterest = 0;

    if (iterations == 0) {
      return (0, principal);
    }

    for (uint256 i = 0; i < iterations; i++) {
      uint256 tempInterest = (principal * interest) / 10000;
      principal += tempInterest;
      totalInterest += tempInterest;
    }

    return (totalInterest, principal);
  }

  function getImage() public view returns (string memory) {
    string memory image = metadata.image;
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
        getImage(),
        '"',
        '}'
      )
    );

    return _metadata;
  }

  /**
   * Override Functions
   */
}
