// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Base64.sol';
import './interface/ILockedSavings.sol';
import '../token/BBTOKENv2.sol';
import '../utils/Registry.sol';
import '../utils/GlobalMarker.sol';
import './Referral.sol';

contract LockedSavings is ILockedSavings, ERC1155, Ownable, ReentrancyGuard {
  // Uses
  using Strings for uint256;

  // Local variables
  Registry public registry;
  System public system;
  Referral public referral;

  mapping(uint256 => Attributes) public attributes;
  mapping(uint256 => mapping(uint256 => uint256)) public multipliers;

  uint256 public idCounter = 1;

  // Modifiers

  // Events
  event LockedSavingsCreated(Attributes _attributes);

  // Constructor
  constructor() ERC1155('') {}

  // Main Function
  function _saveAttributes(Attributes memory _attributes) internal {
    uint256 currMarker = getMarker();
    uint256 interestRate = GlobalMarker(registry.getContractAddress('GlobalMarker')).getInterestRate();
    uint256 lifeBasedOnMult = multipliers[_attributes.multiplier][currMarker];

    require(lifeBasedOnMult != 0, 'LockedSavings: Invalid Multiplier');

    _attributes.marker = currMarker;
    _attributes.timeCreated = block.timestamp;
    _attributes.cfaLife = lifeBasedOnMult * 30 days;
    _attributes.interestRate = interestRate;

    attributes[idCounter] = _attributes;
  }

  function _createLockedSavings(Attributes memory _attributes, address caller) internal {
    if ((Referral(registry.getContractAddress('Referral')).eligibleForReward(caller))) {
      Referral(registry.getContractAddress('Referral')).rewardForReferrer(caller, _attributes.principal);
      uint256 discount = Referral(registry.getContractAddress('Referral')).getReferredDiscount();
      uint256 amtPayable = _attributes.principal - ((_attributes.principal * discount) / 10000);
      IERC20(registry.getContractAddress('BbToken')).transferFrom(msg.sender, address(this), amtPayable);
    } else {
      IERC20(registry.getContractAddress('BbToken')).transferFrom(msg.sender, address(this), _attributes.principal);
    }
    _saveAttributes(_attributes);
    _mint(msg.sender, idCounter, 1, '');
    idCounter++;
  }

  function createLockedSavings(Attributes[] memory _attributes, address _referrer) external nonReentrant {
    uint256 currMarker = GlobalMarker(registry.getContractAddress('GlobalMarker')).getMarker();
    require(currMarker <= 100, 'LockedSavings: Beyond Max Marker');
    if (_referrer != address(0)) {
      Referral(registry.getContractAddress('Referral')).addReferrer(msg.sender, _referrer);
    }
    for (uint256 i = 0; i < _attributes.length; i++) {
      _createLockedSavings(_attributes[i], msg.sender);
    }
  }

  function withdrawLockedSavings(uint256 _id, uint256 _interest) external nonReentrant {
    require(balanceOf(msg.sender, _id) == 1, 'LockedSavings: You do not own this CFA');
    require(
      block.timestamp >= attributes[_id].timeCreated + attributes[_id].cfaLife,
      'LockedSavings: CFA is still locked'
    );

    BBToken(registry.getContractAddress('BbToken')).burn(attributes[_id].principal);
    BBToken(registry.getContractAddress('BbToken')).mint(msg.sender, _interest);
    _burn(msg.sender, _id, 1);
  }

  // Write Function
  function setRegistry(address _registry) external onlyOwner {
    registry = Registry(_registry);
  }

  function _setMultiplier(uint256 _multiplier, uint256 _marker, uint256 _cfaLife) internal onlyOwner {
    multipliers[_multiplier][_marker] = _cfaLife;
  }

  function setMultiplier(uint256 _multiplier, uint256[] memory _marker, uint256[] memory _cfaLife) external onlyOwner {
    for (uint256 i = 0; i < _marker.length; i++) {
      _setMultiplier(_multiplier, _marker[i], _cfaLife[i]);
    }
  }

  function setMinMaxMarker(uint256 _minMarker, uint256 _maxMarker) external onlyOwner {
    system.minMarker = _minMarker;
    system.maxMarker = _maxMarker;
  }

  // Read Function
  function getMarker() public view returns (uint256) {
    uint256 currMarker = GlobalMarker(registry.getContractAddress('GlobalMarker')).getMarker();
    uint256 tempMarker = 5;

    if (currMarker < 5) {
      return 1;
    } else {
      for (uint256 i = 0; i <= 19; i++) {
        if (currMarker >= tempMarker && currMarker < tempMarker) {
          return tempMarker;
        }

        tempMarker += 5;
      }
    }

    return 0;
  }

  // Override
  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) public virtual override {
    require(
      from == _msgSender() || isApprovedForAll(from, _msgSender()),
      'ERC1155: caller is not token owner or approved'
    );
    require(
      attributes[id].timeCreated + attributes[id].cfaLife >= block.timestamp,
      'LockedSavings: CFA is still locked'
    );
    _safeTransferFrom(from, to, id, amount, data);
  }

  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public virtual override {
    require(
      from == _msgSender() || isApprovedForAll(from, _msgSender()),
      'ERC1155: caller is not token owner or approved'
    );
    for (uint256 i = 0; i < ids.length; i++) {
      require(
        attributes[ids[i]].timeCreated + attributes[ids[i]].cfaLife >= block.timestamp,
        'LockedSavings: CFA is still locked'
      );
    }
    _safeBatchTransferFrom(from, to, ids, amounts, data);
  }
}
