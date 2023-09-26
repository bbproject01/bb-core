// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Base64.sol';
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
  mapping(uint256 => Attributes) public attributes;
  mapping(uint256 => uint256) public interestRate;

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

  function withdraw(uint256 _id, uint256 _amount) external {
    require(balanceOf(msg.sender, _id) == 1, 'Insurance: invalid id');
    require(_amount <= attributes[_id].principal, 'Insurance: invalid amount');

    IERC20(registry.registry('BbToken')).transfer(msg.sender, _amount);
    attributes[_id].principal -= _amount;

    if (attributes[_id].principal < 1 ether) {
      _burn(msg.sender, _id, 1);
      emit InsuranceBurned(attributes[_id], block.timestamp);
    }

    emit InsuranceWithdrawn(_id, _amount, block.timestamp);
  }

  /**
   * Write Functions
   */

  /**
   * Read Functions
   */
  function getInterestRate(uint256 _period) public view returns (uint256) {
    require(interestRate[_period] != 0, 'Insurance: invalid period');
    return interestRate[_period];
  }

  /**
   * Override Functions
   */
}
