// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/access/Ownable.sol';
import './interface/IReferral.sol';
import '../token/BBTOKENv2.sol';
import '../utils/Registry.sol';

contract Referral is Ownable {
  // Local Variables
  Registry public registry;
  uint256 public minBuys = 5; // minimum number of buys required to be eligible for referral
  uint256[] public bracket = [0, 100, 1_000, 10_000, 100_000, 1_000_000]; // number of referrals required to reach each bracket
  uint256[] public returnRates = [7, 10, 15, 20, 25];
  address public defaultReferrer; // default referrer for users who have not been referred
  
  mapping(address => bool) public operators; // address => bool mapping to check if an address is an operator
  mapping(address => address) public referrer; // user => referrer
  mapping(address => uint256) public referralCount; // user => number of referrals
  mapping(address => uint256) public buyCount; // user => total buys of CFA
  mapping(address => uint256) public userBracket;

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

  function addBuyCount(address _user, uint256 _qty) external onlyOperator {
    buyCount[_user] += _qty;
  }

  /**
   * @dev Used to change required number of referrals to reach each bracket
   * @param _bracket Array of number of referrals required to reach each bracket
   */
  function changeBracket(uint256[] memory _bracket) external onlyOwner {
    bracket = _bracket;
  }

  // updates what bracket user is in
  function updateBracket(uint256 bracketIndex, address _user) internal {
    userBracket[_user] = bracketIndex;
  }

  //to be called externally, gets the users bracket and returns amount
  function returnReward(address _sender, uint256 amount) external onlyOwner {
    address _referrer = referrer[_sender];
    uint256 _userBracket = userBracket[_referrer];
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
function getBracket(address _user) external returns (uint256 _bracket) {
    uint256 _referralCount = referralCount[_user];

    if (_referralCount == 0) {
        return 0;
    } else {
        for (uint256 i = 0; i < bracket.length; i++) {
            if (_referralCount < bracket[i]) {
                if (userBracket[_user] != i) {
                    updateBracket(i, _user);
                }
                return i;
            }
        }
    }
}
}
