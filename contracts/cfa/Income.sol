// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import './interface/IIncome.sol';
import '../token/BBTOKENv2.sol';
import '../utils/Registry.sol';
import '../utils/GlobalMarker.sol';
import './Referral.sol';

contract Income is IIncome, ERC1155, Ownable, ReentrancyGuard {
  /**
   * Local variables
   */
  System system;
  Registry public registry;
  GlobalMarker public globalMarker;
  Referral public referral;

  mapping(uint256 => Attributes) public attributes;
  mapping(uint256 => Loan) public loan;
  // mapping(uint256 => uint256) public lastClaimTime;
  uint256 public idCounter = 1;

  /**
   * Events
   */
  event IncomeCreated(Attributes _attributes);
  event IncomeWithdrawn(uint256 _id, uint256 _amount, uint256 _time);
  event IncomeBurned(uint256 _id, Attributes _attributes, uint256 _time);
  event LoanCreated(uint256 _id, uint256 _totalLoan);
  event LoanRepaid(uint256 _id);

  /**
   * Modifiers
   */

  /**
   * Construstor
   */
  constructor() ERC1155('') {
    system.maxPaymentFrequency = 12;
    system.maxPrincipalLockTime = 50;
  }

  /**
   * Write function
   */
  function _setAttributes(Attributes memory _attributes) internal {
    require(_attributes.paymentFrequency <= system.maxPaymentFrequency, 'Income:: Invalid payment frequency');
    require(_attributes.principalLockTime <= system.maxPrincipalLockTime, 'Income:: Invalid principal lock time');

    _attributes.timeCreated = block.timestamp;
    _attributes.interest = GlobalMarker(registry.getAddress('GlobalMarker')).getInterestRate();
    _attributes.paymentFrequency *= 30 days;
    _attributes.principalLockTime *= 365 days;
    attributes[idCounter] = _attributes;
  }

  function mintIncome(Attributes[] memory _attributes, address _referrer) external {
    if (_referrer != address(0)) {
      Referral(registry.getAddress('Referral')).addReferrer(msg.sender, _referrer);
    }
    for (uint i = 0; i < _attributes.length; i++) {
      if ((Referral(registry.getAddress('Referral')).eligibleForReward(msg.sender))) {
        Referral(registry.getAddress('Referral')).discountForReferrer(msg.sender, _attributes[i].principal);
        uint256 discount = Referral(registry.getAddress('Referral')).getReferredDiscount();
        uint256 amtPayable = _attributes[i].principal - ((_attributes[i].principal * discount) / 10000);
        IERC20(registry.getAddress('BbToken')).transferFrom(msg.sender, address(this), amtPayable);
      } else {
        IERC20(registry.getAddress('BbToken')).transferFrom(msg.sender, address(this), _attributes[i].principal);
      }
      _setAttributes(_attributes[i]);
      _mint(msg.sender, idCounter, 1, '');
      idCounter++;
    }
  }

  function withdrawIncome(uint256 _tokenId, uint256 _amount) public {
    require(balanceOf(msg.sender, _tokenId) >= 1, 'Income:: Not product owner');

    BBToken token = BBToken(registry.getAddress('BbToken'));
    // token.mint(msg.sender, _amount);
  }

  function withdrawPrincipal(uint256 _tokenId) external {
    require(balanceOf(msg.sender, _tokenId) >= 1, 'Income:: Not product owner');
    require(
      block.timestamp >= attributes[_tokenId].timeCreated + attributes[_tokenId].principalLockTime,
      'Income:: Principal is locked'
    );

    IERC20 token = IERC20(registry.getAddress('BbToken'));
    token.transfer(msg.sender, attributes[_tokenId].principal);

    _burn(msg.sender, _tokenId, 1);
  }

  function setRegistry(address _registry) external onlyOwner {
    registry = Registry(_registry);
  }

  function setTimeCreated(uint256 _id, uint256 _timeCreated) external {
    attributes[_id].timeCreated = _timeCreated;
  }

  /**
   * Read function
   */
  function getIndexes(uint256 _tokenId) external view returns (uint256, uint256) {
    uint256 timeDiff = (block.timestamp - attributes[_tokenId].timeCreated) / attributes[_tokenId].paymentFrequency;
    uint256 currentIndex = 0;
    uint256 claimedIndex = 0;

    if (timeDiff > 0) {
      currentIndex = timeDiff;
    }

    if (attributes[_tokenId].lastClaimTime > 0) {
      claimedIndex =
        (attributes[_tokenId].lastClaimTime - attributes[_tokenId].timeCreated) /
        attributes[_tokenId].paymentFrequency;
    }

    return (currentIndex, claimedIndex);
  }

  function getInterest(uint256 _tokenId) external view returns (uint256) {
    uint256 cfaInterest = attributes[_tokenId].interest;
    return cfaInterest;

    // remove if not needed
  }

  function getAccumulatedInterest(uint256 _tokenId) internal view returns (uint256) {
    uint256 interest;
    return interest;
    /*
      call offchain computation here. this should return interest accumulated, without the principal added. change loan accordingly
      if return value is to be changed. pls use this when func withdrawIncome is called, as this should be used to compute
      accumulated interest available for withdrawal
    */
  }

  /**
   * Loan functions
   */

  function createLoan(uint256 _id) external nonReentrant {
    require(balanceOf(msg.sender, _id) == 1, 'Income: invalid id');
    require(!loan[_id].onLoan, 'Income: Loan already created');
    require(block.timestamp < attributes[_id].cfaLife, 'Income: Income has expired');

    uint256 interest = getAccumulatedInterest(_id);
    withdrawIncome(_id, interest);
    uint256 loanedPrincipal = ((attributes[_id].principal) * 25) / 100;
    BBToken token = BBToken(registry.getAddress('BbToken'));
    token.mint(address(this), loanedPrincipal);

    loan[_id].onLoan = true;
    loan[_id].loanBalance = loanedPrincipal;
    loan[_id].timeWhenLoaned = block.timestamp;

    emit LoanCreated(_id, loanedPrincipal);
  }

  function repayLoan(uint256 _id, uint256 _amount) external nonReentrant {
    require(loan[_id].onLoan, 'Income: Loan invalid');
    require(_amount <= loan[_id].loanBalance, 'Income: Incorrect loan repayment amount');

    IERC20(registry.getAddress('BbToken')).transferFrom(msg.sender, address(this), _amount);

    if (_amount < loan[_id].loanBalance) {
      loan[_id].loanBalance -= _amount;
    } else {
      attributes[_id].lastClaimTime = block.timestamp;
      loan[_id].loanBalance = 0;
      loan[_id].onLoan = false;
      uint256 timePassed = block.timestamp - loan[_id].timeWhenLoaned;
      attributes[_id].cfaLife += timePassed; // Extends CFA life to make up for loaned time
    }

    BBToken(registry.getAddress('BbToken')).burn(_amount);

    emit LoanRepaid(_id);
  }
  /**
   * Overrides
   */
}
