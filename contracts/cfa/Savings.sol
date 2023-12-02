// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// import './interface/ISavings.sol';
// import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
// import '@openzeppelin/contracts/access/Ownable.sol';
// import '@openzeppelin/contracts/utils/Strings.sol';
// import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
// import '@openzeppelin/contracts/utils/Base64.sol';
// import '../utils/Registry.sol';
// import '../utils/GlobalMarker.sol';
// import './Referral.sol';

// contract Savings is ISavings, ERC1155, Ownable, ReentrancyGuard {
//   /**
//    * Use
//    */
//   using Strings for uint256;

//   /**
//    * Local variables
//    */
//   Registry public registry;
//   GlobalMarker public sysInterest;
//   Referral public referral;
//   Life public life;

//   uint256 public idCounter = 1;

//   mapping(uint256 => Attributes) public attributes;

//   /**
//    * Events
//    */
//   event SavingsCreated(Attributes _attribute);
//   event SavingsWithdrawn(Attributes _attribute, uint256 _time);

//   /**
//    * Modifiers
//    */

//   /**
//    * Constructor
//    */
//   constructor() ERC1155('') {
//     life.min = 1;
//     life.max = 30;
//   }

//   /**
//    * Main Function
//    */

//   function _createSavings(Attributes memory _attributes) internal {
//     require(sysInterest.isInterestSet(), 'GlobalSupply: Interest not yet set');
//     require(_attributes.cfaLife >= life.min && life.max >= _attributes.cfaLife, 'Savings: Invalid life duration');
//     require(_attributes.amount > 0, 'Savings: Invalid amount');

//     if ((referral.eligibleForReward(msg.sender))) {
//       referral.rewardForReferrer(msg.sender, _attributes.amount);
//       uint256 discount = referral.getReferredDiscount();
//       uint256 amtPayable = _attributes.amount - ((_attributes.amount * discount) / 10000);
//       IERC20(registry.registry('BbToken')).transferFrom(msg.sender, address(this), amtPayable);
//     } else {
//       IERC20(registry.registry('BbToken')).transferFrom(msg.sender, address(this), _attributes.amount);
//     }

//     _mint(msg.sender, idCounter, 1, '');
//     _attributes.timeCreated = block.timestamp;
//     _attributes.effectiveInterestTime = block.timestamp;
//     _attributes.interestRate = sysInterest.getInterestRate();
//     uint256 originalCfaLife = _attributes.cfaLife;
//     uint256 yearsLeft = (originalCfaLife * 30 days) + block.timestamp;
//     _attributes.cfaLife = yearsLeft;
//     attributes[idCounter] = _attributes;
//     emit SavingsCreated(_attributes);
//     idCounter++;
//   }

//   function createSavings(Attributes[] memory _attributes) external nonReentrant {
//     for (uint256 i = 0; i < _attributes.length; i++) {
//       _createSavings(_attributes[i]);
//     }
//   }

//   // function withdraw

//   /**
//    * Write Function
//    */
//   function setRegistry(address _registry) external onlyOwner {
//     registry = Registry(_registry);
//   }

//   function setGlobalMarker(address _sysInterest) external onlyOwner {
//     sysInterest = GlobalMarker(_sysInterest);
//   }

//   function setReferral(address _referral) external onlyOwner {
//     referral = Referral(_referral);
//   }

//   /**
//    * Read Function
//    */
// }

/**
 * ON CHAIN SMART CONTRACT
 */

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Base64.sol';
import './interface/ISavings.sol';
import './Referral.sol';
import '../utils/Registry.sol';
import '../utils/GlobalMarker.sol';

contract Savings is ISavings, ERC1155, Ownable, ReentrancyGuard {
  using Strings for uint256;

  /**
   * Local variables
   */
  Referral public referral; // Referral contract
  Registry public registry; // The registry contract
  Life public life; // max and minimum life of Savings CFA
  Metadata public metadata; // The metadata of the Savings CFA
  GlobalMarker public globalMarker; // the supply and Interest marker

  mapping(uint256 => Loan) public loan;
  mapping(uint256 => Attributes) public attributes;
  uint256 public idCounter = 1;

  /**
   * Events
   */
  event SavingsCreated(Attributes _attribute);
  event SavingsWithdrawn(Attributes _attribute, uint256 _time);
  event SavingsBurned(Attributes _attribute, uint256 _time);
  event LoanCreated(uint256 _id, uint256 _totalLoan);
  event LoanRepaid(uint256 _id);

  /**
   * Modifier
   */

  /**
   * Constructor
   */
  constructor() ERC1155('') {}

  /**
   * Main Function
   */

  function _saveAttributes(Attributes memory _attributes) internal {
    require(_attributes.cfaLife >= life.min && life.max >= _attributes.cfaLife, 'Savings: Invalid CFA life duration');
    _attributes.timeCreated = block.timestamp;
    _attributes.effectiveInterestTime = block.timestamp;
    _attributes.interestRate = GlobalMarker(registry.registry('GlobalMarker')).getInterestRate();
    uint256 originalCfaLife = _attributes.cfaLife;
    uint256 yearsLeft = (originalCfaLife * (30 days * 12)) + block.timestamp;
    _attributes.cfaLife = yearsLeft;
    attributes[idCounter] = _attributes;
  }

  function _mintSavings(Attributes memory _attributes, address caller) internal {
    if ((Referral(registry.registry('Referral')).eligibleForReward(caller))) {
      Referral(registry.registry('Referral')).discountForReferrer(caller, _attributes. );
      uint256 discount = Referral(registry.registry('Referral')).getReferredDiscount();
      uint256 amtPayable = _attributes.amount - ((_attributes.amount * discount) / 10000);
      IERC20(registry.registry('BbToken')).transferFrom(msg.sender, address(this), amtPayable);
    } else {
      IERC20(registry.registry('BbToken')).transferFrom(msg.sender, address(this), _attributes.amount);
    }
    _mint(msg.sender, idCounter, 1, '');
    _saveAttributes(_attributes);
    emit SavingsCreated(_attributes);
  }

  function mintSavings(Attributes[] memory _attributes, address _referrer) external nonReentrant {
    require(GlobalMarker(registry.registry('GlobalMarker')).isInterestSet(), 'GlobalSupply: Interest not yet set');
    if (_referrer != address(0)) {
      Referral(registry.registry('Referral')).addReferrer(msg.sender, _referrer);
    }
    for (uint256 i = 0; i < _attributes.length; i++) {
      _mintSavings(_attributes[i], msg.sender);
      idCounter++;
    }
  }

  function _burnSavings(uint256 _id) internal {
    emit SavingsBurned(attributes[_id], block.timestamp);
    delete attributes[_id];
    _burn(msg.sender, _id, 1);
  }

  function withdrawSavings(uint256 _id, uint256 _amount) external nonReentrant {
    // require(
    //   attributes[_id].effectiveInterestTime + attributes[_id].cfaLife < block.timestamp,
    //   'Savings: CFA is not matured'
    // );
    require(block.timestamp > attributes[_id].cfaLife, 'Savings: CFA not yet matured');
    require(!loan[_id].onLoan, 'Savings: On Loan');
    // require(block.timestamp < attributes[_id].cfaLife, 'Savings: insurance has expired');

    // (, uint256 interest) = getTotalInterest(_id); // Gets the accrued interest + principal

    BBToken token = BBToken(registry.registry('BbToken'));
    token.transfer(msg.sender, attributes[_id].amount);
    token.mint(msg.sender, _amount);

    _burnSavings(_id);
    emit SavingsWithdrawn(attributes[_id], block.timestamp);
  }

  // TODO: Locking calculation

  /**
   * Write Function
   */

  function setImage(string memory _image) external onlyOwner {
    metadata.image = _image;
  }

  function setMetadata(string memory _name, string memory _description) external onlyOwner {
    metadata.name = _name;
    metadata.description = _description;
  }

  function setRegistry(address _registry) external onlyOwner {
    registry = Registry(_registry);
  }

  function setLife(uint256 _min, uint256 _max) external onlyOwner {
    life.min = _min;
    life.max = _max;
  }

  /**
   * Read Function
   */

  function getTotalInterest(uint256 _id) public view returns (uint256, uint256) {
    uint256 principal = attributes[_id].amount;
    uint256 interest = attributes[_id].interestRate;
    uint256 month = 30 days;
    uint256 months = (attributes[_id].cfaLife - attributes[_id].effectiveInterestTime) / month;
    uint256 basisPoint = 10000;
    uint256 totalInterest = 0;

    for (uint256 index = 0; index < months; index++) {
      uint256 tempInterest = (principal * interest) / basisPoint;
      principal += tempInterest;
      totalInterest += tempInterest;
    }
    // uint256 totalInterest = (principal * compoundedInterest) / basisPoint;

    return (principal, totalInterest);
  }

  function getYieldedInterest(uint256 _id) public view returns (uint256, uint256) {
    uint256 principal = attributes[_id].amount;
    uint256 interest = attributes[_id].interestRate;
    uint256 months = (block.timestamp - attributes[_id].effectiveInterestTime) / 30 days;
    uint256 basisPoint = 10000;
    uint256 totalInterest = 0;

    for (uint256 index = 0; index < months; index++) {
      uint256 tempInterest = (principal * interest) / basisPoint;
      principal += tempInterest;
      totalInterest += tempInterest;
    }
    // uint256 totalInterest = (principal * compoundedInterest) / basisPoint;

    return (principal, totalInterest);
  }

  function getImage() public view returns (string memory) {
    string memory image = metadata.image;
    return image;
  }

  // function batchGetImage(uint256[] memory _tokenId) public view returns (string[] memory) {
  //   string[] memory images = new string[](_tokenId.length);

  //   for (uint256 index = 0; index < _tokenId.length; index++) {
  //     images[index] = getImage(_tokenId[index]);
  //   }

  //   return images;
  // }

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
    require(balanceOf(msg.sender, _id) == 1, 'Savings: invalid id');
    require(!loan[_id].onLoan, 'Savings: Loan already created');
    require(block.timestamp < attributes[_id].cfaLife, 'Savings: insurance has expired');

    (uint256 totalPrincipal, ) = getYieldedInterest(_id);
    uint256 loanedPrincipal = ((totalPrincipal) * 25) / 100;
    BBToken token = BBToken(registry.registry('BbToken'));
    token.mint(msg.sender, loanedPrincipal);

    loan[_id].onLoan = true;
    loan[_id].loanBalance = loanedPrincipal;
    loan[_id].timeWhenLoaned = block.timestamp;

    emit LoanCreated(_id, (loanedPrincipal * 25) / 100);
  }

  function repayLoan(uint256 _id, uint256 _amount) external nonReentrant {
    require(loan[_id].onLoan, 'Savings: Loan invalid');
    require(_amount <= loan[_id].loanBalance, 'Savings: Incorrect loan repayment amount');

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

  function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public override {
    // require(attributes[id].soulBoundTerm == 0, 'CFA: El CFA esta bloqueado y no se puede transferir');
    super.safeTransferFrom(from, to, id, amount, data);
  }

  /**
   * @dev Overrides the `burn` function to prevent burning of locked CFAs.
   */
  function burn(uint256 id) public {
    // require(attributes[id].soulBoundTerm == 0, 'CFA: El CFA esta bloqueado y no se puede quemar');
    _burn(msg.sender, id, 1);
  }

  // Override the `burnBatch` function to prevent burning of locked CFAs
  function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) public {
    // for (uint256 i = 0; i < ids.length; i++) {
    //   require(attributes[ids[i]].soulBoundTerm == 0, 'CFA: No se puede quemar un CFA bloqueado');
    // }
    this.burnBatch(account, ids, amounts);
  }

  function uri(uint256 _tokenId) public view virtual override returns (string memory) {
    bytes memory _metadata = abi.encodePacked(getMetadata(_tokenId));

    return string(abi.encodePacked('data:application/json;base64,', Base64.encode(_metadata)));
  }
}
