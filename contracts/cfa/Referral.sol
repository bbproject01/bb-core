// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/access/Ownable.sol';

contract Referral is Ownable {
  // Local Variables
  uint256[] public bracket = [0, 100, 1_000, 10_000, 100_000, 1_000_000]; // number of referrals required to reach each bracket
  address public defaultReferrer; // default referrer for users who have not been referred

  mapping(address => address) public referrer; // user => referrer
  mapping(address => uint256) public referralCount; // user => number of referrals

  // Events
  event ReferralRecorded(address indexed user, address indexed referrer);
  event ReferralRemoved(address indexed user);

  // Constructor
  constructor() Ownable() {}

  // Write Functions
  /**
   * @dev Used to set referrer to a new user
   */
  function addReferrer(address _referrer) external {
    require(referrer[msg.sender] == address(0), '001');

    referrer[msg.sender] = _referrer;
    referralCount[_referrer]++;

    emit ReferralRecorded(msg.sender, _referrer);
  }

  /**
   * @dev Used to remove referrer from a user
   */
  function removeReferrer(address _user) external onlyOwner {
    require(referrer[_user] != address(0), '002');

    delete referrer[_user];
    referralCount[referrer[_user]]--;

    emit ReferralRemoved(_user);
  }

  /**
   * @dev Used to set default referrer
   */
  function setDefaultReferrer(address _referrer) external onlyOwner {
    defaultReferrer = _referrer;
  }

  /**
   * @dev Used to change required number of referrals to reach each bracket
   * @param _bracket Array of number of referrals required to reach each bracket
   */
  function changeBracket(uint256[] memory _bracket) external onlyOwner {
    bracket = _bracket;
  }

  // View Functions
  /**
   * @dev Used to get bracket of a user
   * @param _user address of user that you wanted to check
   */
  function getBracket(address _user) external view returns (uint256) {
    uint256 _referralCount = referralCount[_user];

    if (_referralCount == 0) {
      return 0;
    } else {
      for (uint256 i = 0; i < bracket.length; i++) {
        if (_referralCount < bracket[i]) {
          return i;
        }
      }
    }
  }
}
