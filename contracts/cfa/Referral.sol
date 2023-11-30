// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '../token/BBTOKENv2.sol';
import './interface/IReferral.sol';
import '../utils/Registry.sol';

contract Referral is Ownable, IReferral {
  // Local Variables
  Registry public registry;

  uint256[] public amtReferredBracket;
  uint256[][] public interestSet;
  uint256[] public supplyMarkers;
  uint256[] public referredRewardRates;
  address public defaultReferrer;
  bool _interestSet;

  mapping(address => Referrer) public referrer;
  mapping(address => bool) public operators;

  // Events
  event ReferralRecorded(address indexed user, address indexed referrer);
  event ReferralRemoved(address indexed user);

  // Modifiers
  modifier onlyRegistered() {
    require(registry.isRegistered(msg.sender) == true, 'Referral: Caller not a registered contract');
    _;
  }

  // Constructor
  constructor() Ownable() {}

  // Write Functions
  /**
   * @dev Used to set referrer to a new user
   */
  function addReferrer(address _referred, address _referrer) external onlyRegistered {
    require(referrer[_referred].referrer == address(0), 'Referral: Referrer already set');
    require(_referrer != _referred, 'Referral: Cannot set referrer to yourself');
    require(!isReferral(_referrer, _referred), 'Referral: Circular referral not allowed');
    // QQ: Does this method allow for a user to set a referrer to a user who has already been referred?

    referrer[_referrer].referrals.push(_referred);
    referrer[_referrer].referralCount++;
    referrer[_referred].wasReferred = true;
    referrer[_referred].referrer = _referrer;
    emit ReferralRecorded(_referred, _referrer);
  }

  /**
   * @dev Used to remove referrer from a user
   */
  function removeReferrer(address _user) external onlyOwner {
    require(referrer[_user].referrer != address(0), '002');
    // QQ: Is there a need to remove a referrer from a user?

    delete referrer[_user].referrer;
    referrer[_user].referralCount--;

    emit ReferralRemoved(_user);
  }

  /**
   * @dev Used to set interest rates
   */
  function setInterestRate(uint256[][] memory _newInterestSet) external onlyOwner {
    require(_newInterestSet.length > 0, 'Referral: Empty array');

    interestSet = new uint256[][](_newInterestSet.length);
    _interestSet = true;
    for (uint256 i = 0; i < _newInterestSet.length; i++) {
      require(_newInterestSet[i].length > 0, 'Referral: Empty sub-array');
      interestSet[i] = _newInterestSet[i];
    }
  }

  function setSupplyMarkers(uint256[] memory _markers) external onlyOwner {
    require(_markers.length > 0, 'Referral: Empty markers array');

    // Iterate through the supplied markers to set supplyMarkers and update supplyMarkerSize
    for (uint256 i = 0; i < _markers.length; i++) {
      supplyMarkers[i] = _markers[i];
    }
  }

  function setReferredRewards(uint256[] memory _rewards) external onlyOwner {
    require(_rewards.length > 0, 'Referral: Empty markers array');

    for (uint256 i = 0; i < _rewards.length; i++) {
      referredRewardRates[i] = _rewards[i];
    }
  }

  function setAmtReferredBracket(uint256[] memory _amtReferredBracket) external onlyOwner {
    require(_amtReferredBracket.length > 0, 'Referral: Empty array');

    amtReferredBracket = _amtReferredBracket;
  }

  /**
   * @dev Used to return rewards to the referrer
   */
  function discountForReferrer(address _sender, uint256 amount) external onlyRegistered {
    require(referredRewardRates.length != 0, 'referredRewardRates not set');
    require(supplyMarkers.length != 0, 'supplyMarkers not set');
    require(amtReferredBracket.length != 0, 'supplyMarkers not set');
    require(_interestSet, 'interest not set');

    referrer[_sender].buyCount++;
    address _referrer = referrer[_sender].referrer;
    uint256 returnRate = getUserInterest(_sender);
    uint256 reward = (amount * returnRate) / 10000;
    BBToken token = BBToken(registry.registry('BbToken'));
    token.mint(_referrer, reward);
  }

  // View Functions
  /**
   * @dev Used to get the marker for the current supply
   */
  function getMarker() public view returns (uint256) {
    uint256 totalSupply = IERC20(registry.registry('BbToken')).totalSupply();
    uint256 supplyMarker = 0;

    if (totalSupply > supplyMarkers[supplyMarkers.length - 1]) {
      return supplyMarkers.length - 1;
    }

    for (uint256 index = 0; index < supplyMarkers.length - 1; index++) {
      if (totalSupply > supplyMarkers[index] && totalSupply <= supplyMarkers[index + 1]) {
        supplyMarker = index;
        break;
      }
    }

    return supplyMarker;
  }

  /**
   * @dev Used to get the interest marker for a user
   */
  function getUsersInterestMarker(address _referrer) public view returns (uint256) {
    uint256 referredCount = referrer[_referrer].referralCount;

    uint256 bracketIndex = 0;
    while (bracketIndex < amtReferredBracket.length && referredCount >= amtReferredBracket[bracketIndex]) {
      bracketIndex++;
    }
    require(bracketIndex < interestSet.length, 'Referral: Invalid bracket index');
    return bracketIndex;
  }

  function eligibleForReward(address _referrer) external view returns (bool) {
    if (referrer[_referrer].buyCount <= 10 && referrer[_referrer].referrer != address(0)) {
      return true;
    } else {
      return false;
    }
  }

  function isReferral(address _referral, address _referrer) public view returns (bool) {
    uint256 referralCount = referrer[_referrer].referralCount;
    for (uint256 i = 0; i < referralCount; i++) {
      address referredAddress = referrer[_referrer].referrals[i];
      if (referredAddress == _referral) {
        return true;
      }
    }
    return false;
  }

  // QQ: Is this function necessary? Function is not used anywhere
  function getAttributes(address _address) public view returns (Referrer memory) {
    Referrer memory _attributes = referrer[_address];
    return _attributes;
  }

  /**
   * @dev Used to get the interest rate for a user
   */
  function getUserInterest(address _referrer) internal view returns (uint256) {
    uint256 globalMarker = getMarker();
    uint256[] memory interestBracket = interestSet[globalMarker];

    uint256 userMarker = getUsersInterestMarker(_referrer);
    uint256 userInterest = interestBracket[userMarker];

    return userInterest;
  }

  // QQ: Function not used anywhere, what's the purpose of this function?
  function getReferredDiscount() public view returns (uint256) {
    uint256 _getMarker = getMarker();
    uint256 reward = referredRewardRates[_getMarker];
    return reward;
  }

  // Debug functions
  // function getInterestSet() external view returns (uint256[] memory) {
  //   uint256 globalMarker = getMarker();
  //   uint256[] memory interestBracket = interestSet[globalMarker];
  //   return interestBracket;
  // }

  // function increaseeferralCount(uint256 impostor) public {
  //   referrer[msg.sender].referralCount += impostor;
  // }

  // function checkCurrentBracket() public view returns (uint256[] memory) {
  //   uint256 globalMarker = getMarker();
  //   uint256[] memory interestBracket = interestSet[globalMarker];

  //   return interestBracket;
  // }

  // function checkSupply() public view returns (uint256) {
  //   uint256 supply = IERC20(registry.registry('BbToken')).totalSupply();
  //   return supply;
  // }

  // function checkReferrals(address refferrrr) public view returns (address[] memory) {
  //   address[] memory amongus = referrer[refferrrr].referrals;
  //   return amongus;
  // }
}
