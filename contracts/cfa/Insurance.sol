// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Base64.sol';
import '../utils/Registry.sol';
import './interface/IInsurance.sol';
import './Referral.sol';

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
  Referral public referral;

  uint256 public idCounter = 1;

  mapping(uint256 => uint256) public interestRate;
  mapping(uint256 => Attributes) public attributes;
  mapping(uint256 => Loan) public loan;

  /**
   * Modifiers
   */

  /**
   * Events
   */
  event InsuranceCreated(Attributes _attributes);
  event InsuranceWithdrawn(uint256 _id, uint256 _amount, uint256 _time);
  event InsuranceBurned(Attributes _attributes, uint256 _time);
  event LoanCreated(uint256 _id, uint256 _totalLoan);
  event LoanRepaid(uint256 _id);
  event expired(uint256 _id);

  /**
   * Constructor
   */

  constructor() ERC1155('') {}

  /**
   * Main Functions
   */
  function _saveAttributes(Attributes memory _attributes) internal {
    _attributes.timeCreated = block.timestamp;
    _attributes.cfaLife = block.timestamp + (30 days * 12 * 30); // 30 Years of CFA Life
    _attributes.effectiveInterestTime = _attributes.timeCreated;
    attributes[idCounter] = _attributes;
  }

  function _mintInsurance(Attributes memory _attributes, address caller) internal {
    if ((Referral(registry.registry('Referral')).eligibleForReward(caller))) {
      Referral(registry.registry('Referral')).discountForReferrer(caller, _attributes.principal);
      uint256 discount = Referral(registry.registry('Referral')).getReferredDiscount();
      uint256 amtPayable = _attributes.principal - ((_attributes.principal * discount) / 10000);
      IERC20(registry.registry('BbToken')).transferFrom(msg.sender, address(this), amtPayable);
    } else {
      IERC20(registry.registry('BbToken')).transferFrom(msg.sender, address(this), _attributes.principal);
    }
    _mint(msg.sender, idCounter, 1, '');
    _saveAttributes(_attributes);
    emit InsuranceCreated(_attributes);
  }

  function mintInsurance(Attributes[] memory _attributes, address _referrer) external {
    if (_referrer != address(0)) {
      Referral(registry.registry('Referral')).addReferrer(msg.sender, _referrer);
    }
    for (uint256 i = 0; i < _attributes.length; i++) {
      require(interestRate[_attributes[i].timePeriod] != 0, 'Insurance: invalid time period');
      _mintInsurance(_attributes[i], msg.sender);
      idCounter++;
    }
  }

  function withdraw(uint256 _id, uint256 _amount) external nonReentrant {
    (uint256 interest, uint256 totalPrincipal) = getInterest(_id); // interest = total yielded interest, totalPrincipal = principal + interest
    // require(block.timestamp < attributes[_id].cfaLife, 'Insurance: insurance has expired');
    require(balanceOf(msg.sender, _id) == 1, 'Insurance: invalid id');
    require(_amount <= (totalPrincipal), 'Insurance: invalid amount'); // amount should be less than or equal to totalPrincipal
    // require(
    //   ((block.timestamp - attributes[_id].timeCreated) / attributes[_id].timePeriod) > 0,
    //   'Insurance: Still not matured'
    // ); With this, withdraw can only happen when interest has ticked
    require(!loan[_id].onLoan, 'Insurance: On Loan');

    attributes[_id].principal += interest;

    BBToken token = BBToken(registry.registry('BbToken'));
    token.mint(address(this), interest);

    token.transfer(msg.sender, _amount);
    attributes[_id].principal -= _amount;

    if (attributes[_id].principal < 1000000000000000000) {
      emit InsuranceBurned(attributes[_id], block.timestamp);
      delete attributes[_id];
      _burn(msg.sender, _id, 1);
    } else {
      attributes[_id].effectiveInterestTime += getIterations(_id) * attributes[_id].timePeriod;
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
      interestRate[_period[i]] = _interestRate[i];
    }
  }

  /**
   * Read Functions
   */
  function getIterations(uint256 _id) public view returns (uint256) {
    uint256 totalIterations = (block.timestamp - attributes[_id].effectiveInterestTime) / attributes[_id].timePeriod;
    if (block.timestamp > attributes[_id].cfaLife) {
      totalIterations = (attributes[_id].cfaLife - attributes[_id].effectiveInterestTime) / attributes[_id].timePeriod;
    }
    return totalIterations;
  }

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
    uint256 iterations = getIterations(_id);
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

  function getLoanBalance(uint _id) external view returns (uint256) {
    uint _loanBalance = loan[_id].loanBalance;
    return _loanBalance;
  }

  /**
   * Loan functions
   */

  function createLoan(uint256 _id) external nonReentrant {
    require(balanceOf(msg.sender, _id) == 1, 'Insurance: invalid id');
    require(!loan[_id].onLoan, 'Insurance: Loan already created');
    require(block.timestamp < attributes[_id].cfaLife, 'Insurance: insurance has expired');

    (uint256 interest, uint256 totalPrincipal) = getInterest(_id);
    uint256 loanedPrincipal = ((totalPrincipal) * 25) / 100;
    BBToken token = BBToken(registry.registry('BbToken'));
    token.mint(address(this), interest);
    token.mint(msg.sender, loanedPrincipal);

    loan[_id].onLoan = true;
    loan[_id].loanBalance = loanedPrincipal;
    loan[_id].timeWhenLoaned = block.timestamp;

    attributes[_id].effectiveInterestTime = block.timestamp;

    emit LoanCreated(_id, loanedPrincipal);
  }

  function repayLoan(uint256 _id, uint256 _amount) external nonReentrant {
    require(loan[_id].onLoan, 'Insurance: Loan invalid');
    require(_amount <= loan[_id].loanBalance, 'Insurance: Incorrect loan repayment amount');

    IERC20(registry.registry('BbToken')).transferFrom(msg.sender, address(this), _amount);

    if (_amount < loan[_id].loanBalance) {
      loan[_id].loanBalance -= _amount;
    } else {
      attributes[_id].effectiveInterestTime = block.timestamp;
      loan[_id].loanBalance = 0;
      loan[_id].onLoan = false;
      uint256 timePassed = block.timestamp - loan[_id].timeWhenLoaned;
      attributes[_id].cfaLife += timePassed; // Extends CFA life to make up for loaned time
    }

    BBToken(registry.registry('BbToken')).burn(_amount);

    emit LoanRepaid(_id);
  }

  /**
   * Override Functions
   */
}
