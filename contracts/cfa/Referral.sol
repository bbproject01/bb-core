// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/access/Ownable.sol';
import './interface/IReferral.sol';
import '../token/BBTOKENv2.sol';
import '../utils/Registry.sol';

contract Referral is Ownable, IReferral {
  // Local Variables
  Registry public registry;
  IReferral public referral;

  uint256 public minBuys = 5; // minimum number of buys required to be eligible for referral
  uint256 public supplyMarkerSize;

  uint256[] public amtReferredBracket; // number of referrals required to reach each bracket
  uint256[] public returnRates;
  uint256[][] public interestSet; // interest values
  uint256[] public supplyMarkers; // supply values

  bool interestsSet;

  address public defaultReferrer; // default referrer for users who have not been referred
  mapping(address => Referrer) public referrer;
  mapping(address => bool) public operators; // address => bool mapping to check if an address is an operator // user => number of referrals

  // Events
  event ReferralRecorded(address indexed user, address indexed referrer);
  event ReferralRemoved(address indexed user);

  // Modifiers
  modifier onlyOperator() {
    require(operators[msg.sender], '000');
    _;
  }

  // Constructor
  constructor() Ownable() {}

  // Write Functions
  /**
   * @dev Used to set referrer to a new user
   */
  function addReferrer(address _referrer) external onlyOperator {
    require(referrer[msg.sender].referrer == address(0), '001');

    referrer[msg.sender].referrer = _referrer;
    referrer[msg.sender].referralCount++;

    emit ReferralRecorded(msg.sender, _referrer);
  }

  /**
   * @dev Used to remove referrer from a user
   */
  function removeReferrer(address _user) external onlyOwner {
    require(referrer[_user].referrer != address(0), '002');

    delete referrer[_user].referrer;
    referrer[_user].referralCount--;

    emit ReferralRemoved(_user);
  }

  /**
   * @dev Used to set default referrer
   */
  function setDefaultReferrer(address _referrer) external onlyOwner {
    defaultReferrer = _referrer;
  }

  function addBuyCount(address _user, uint256 _qty) external onlyOperator {
    referrer[_user].buyCount += _qty;
  }

  function setInterestRate(uint256[] memory _marker, uint256[][] memory _newInterestSet) external {
    require(_marker.length == _newInterestSet.length, 'Referral: Arrays length mismatch');

    // Update marker
    marker = _marker;

    // Update interestSet based on marker values
    for (uint256 i = 0; i < _marker.length; i++) {
      require(_marker[i] > 0 && _marker[i] <= interestSet.length, 'Referral: Invalid marker value');
      interestSet[_marker[i] - 1] = _newInterestSet[i];
    }
  }

  function setSupplyMarkers(uint256[] memory _markers) external onlyOwner {
    require(_markers.length > 0, 'Referral: Empty markers array');

    // Iterate through the supplied markers to set supplyMarkers and update supplyMarkerSize
    for (uint256 i = 0; i < _markers.length; i++) {
      supplyMarkers.push(_markers[i]);
      supplyMarkerSize++;
    }
  }

  function setAmtReferredBracket(uint256[] memory _amtReferredBracket) external onlyOwner {
    require(_amtReferredBracket.length > 0, 'Referral: Empty amtReferredBracket array');

    amtReferredBracket = _amtReferredBracket;
  }

  // /**
  //  * @dev Used to change required number of referrals to reach each bracket
  //  * @param _bracket Array of number of referrals required to reach each bracket
  //  */
  // function changeUserBracket(address _user) external onlyOwner {
  //   bracket = _bracket;
  // }

  // updates what bracket user is in


  //to be called externally, gets the users bracket and returns amount
  function returnReward(address _sender, uint256 amount) external onlyOwner {
    address _referrer = referrer[_sender].referrer;
    uint256 returnRate = returnRates[_userBracket];

    uint256 reward = ((amount) * returnRate) / 100;

    BBToken token = BBToken(registry.registry('BbToken'));
    token.mint(_referrer, reward);
  }

  // updates rate of return for each bracket
  function changeRates(uint256[] memory _rates) external onlyOwner {
    returnRates = _rates;
  }

  // View Functions
  /**
   * @dev Used to get bracket of a user
   * @param _user address of user that you wanted to check
   */
  // function getBracket(address _user) external returns (uint256 _bracket) {
  //   uint256 _referralCount = referrer[_user].referralCount;

  //   if (_referralCount == 0) {
  //     return 0;
  //   } else {
  //     for (uint256 i = 0; i < bracket.length; i++) {
  //       if (_referralCount < bracket[i]) {
  //         if (userBracket[_user] != i) {
  //           updateBracket(i, _user);
  //         }
  //         return i;
  //       }
  //     }
  //   }
  }

  function getMarker() internal view returns (uint256) {
    uint256 totalSupply = IERC20(registry.registry('BbToken')).totalSupply();
    uint256 supplyMarker = 0;

    if (totalSupply > supplyMarkers[supplyMarkerSize - 1]) {
      return supplyMarkerSize - 1;
    }

    for (uint256 index = 0; index < supplyMarkers.length - 1; index++) {
      if (totalSupply > supplyMarkers[index] && totalSupply <= supplyMarkers[index + 1]) {
        supplyMarker = index;
        break;
      }
    }

    return supplyMarker;
  }

function getUsersInterestMarker(address _referrer) internal view returns (uint256) {
    uint256 referredCount = referrer[_referrer].referralCount;

    uint256 bracketIndex = 0;
    while (bracketIndex < amtReferredBracket.length && referredCount >= amtReferredBracket[bracketIndex]) {
      bracketIndex++;
    }

    require(bracketIndex < interestSet.length, 'Referral: Invalid bracket index');

    return bracketIndex;
}

function getUserInterest(address _referrer) internal view returns (uint256) {
  address user = _referrer;

  uint256 globalMarker = getMarker();
  uint256[] interestBracket = interestSet[globalMarker];

  uint256 userMarker = getUsersInterestMarker(user);
  uint256 userInterest = interestBracket[userMarker];

  return userInterest;

}
}
