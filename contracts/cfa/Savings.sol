// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Base64.sol';
import './interface/ISavings.sol';
import './Referral.sol';
import '../utils/Registry.sol';

contract Savings is ISavings, ERC1155, Ownable, ReentrancyGuard {
  using Strings for uint256;

  /**
   * Local variables
   */
  Referral public referral; // Referral contract
  Registry public registry; // The registry contract
  Life public life; // max and minimum life of Savings CFA
  Metadata public metadata; // The metadata of the Savings CFA

  mapping(uint256 => Loan) public loan;
  mapping(uint256 => Attributes) public attributes;
  uint256[] public markers = new uint256[](219);
  uint256[] public interests = new uint256[](219);
  uint256 public idCounter = 1;
  uint256 public markerSize;
  bool interestsSet;
  /**
   * Events
   */
  event SavingsCreated(Attributes _attribute);
  event SavingsWithdrawn(Attributes _attribute, uint256 _time);
  event SavingsBurned(Attributes _attribute, uint256 _time)
  event LoanCreated(uint256 _id, uint256 _totalLoan);
  event LoanRepayed(uint256 _id);

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
    _attributes.interestRate = getInterestRate();
    uint256 originalCfaLife = _attributes.cfaLife;
    uint256 yearsLeft = (originalCfaLife * 30 days * 12) + block.timestamp;
    _attributes.cfaLife = yearsLeft;
    attributes[idCounter] = _attributes;
  }

  function _mintSavings(Attributes memory _attributes) internal {
    IERC20(registry.registry('BbToken')).transferFrom(msg.sender, address(this), _attributes.amount);

    _mint(msg.sender, idCounter, 1, '');
    _saveAttributes(_attributes);

    emit SavingsCreated(_attributes);
  }

  function mintSavings(Attributes[] memory _attributes) external nonReentrant {
    require(interestsSet, 'Savings: Interest not yet set');

    for (uint256 i = 0; i < _attributes.length; i++) {
      _mintSavings(_attributes[i]);
      idCounter++;
      // Referral(registry.registry('Referral')).returnReward(msg.sender, _attributes[i].amount);
      // Returns referral reward for every CFA minted
    }
  }

  function _burnSavings(uint256 _id) internal {
    emit SavingsBurned(attributes[_id], block.timestamp);
    delete attributes[_id];
    _burn(msg.sender, _id, 1);
  }

  function withdrawSavings(uint256 _id) external nonReentrant {
    // require(
    //   attributes[_id].effectiveInterestTime + attributes[_id].cfaLife < block.timestamp,
    //   'Savings: CFA is not matured'
    // );
    require(block.timestamp > attributes[_id].cfaLife, 'Savings: CFA not yet matured');
    require(!loan[_id].onLoan, 'Savings: On Loan');
    // require(block.timestamp < attributes[_id].cfaLife, 'Savings: insurance has expired');

    (, uint256 interest) = getTotalInterest(_id); // Gets the accrued interest + principal

    BBToken token = BBToken(registry.registry('BbToken'));
    token.transfer(msg.sender, attributes[_id].amount);
    token.mint(msg.sender, interest);

    _burnSavings(_id);
    emit SavingsWithdrawn(attributes[_id], block.timestamp);
  }

  // function bindSavings(uint256 _id, uint256 _period) external {
  //   require(attributes[_id].soulBoundTerm == 0, 'Savings: CFA is already bound');
  //   require(balanceOf(msg.sender, _id) > 0, 'Savings: CFA is not owned by the caller');

  //   attributes[_id].soulBoundTerm = _period;

  //   emit SavingsBinded(attributes[_id], _period);
  // }

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

  function setInterest(uint256[] memory _marker, uint256[] memory _interest) external onlyOwner {
    require(_marker.length == _interest.length, 'Savings: Invalid input');
    interestsSet = true;

    for (uint256 i = 0; i < _marker.length; i++) {
      markers[i] = _marker[i];
      interests[i] = _interest[i];
      markerSize++;
    }
  }

  /**
   * Read Function
   */
  // TODO: change public to internal
  // function getDiff() public view returns (uint256, uint256, uint256) {
  //   uint256 totalSupply = IERC20(registry.registry('BbToken')).totalSupply();

  //   if (totalSupply > 20_000_000 ether && totalSupply <= 24_000_000) {
  //     return (20_000_000 ether, 24_000_000 ether, 1_000_000 ether);
  //   } else if (totalSupply > 24_000_000 ether && totalSupply <= 82_000_000 ether) {
  //     return (24_000_000 ether, 82_000_000 ether, 2_000_000 ether);
  //   } else if (totalSupply > 82_000_000 ether && totalSupply <= 100_000_000 ether) {
  //     return (82_000_000 ether, 100_000_000 ether, 3_000_000 ether);
  //   } else if (totalSupply > 100_000_000 ether && totalSupply <= 120_000_000 ether) {
  //     return (100_000_000 ether, 120_000_000 ether, 4_000_000 ether);
  //   } else if (totalSupply > 120_000_000 ether && totalSupply <= 140_000_000 ether) {
  //     return (120_000_000 ether, 140_000_000 ether, 5_000_000 ether);
  //   } else if (totalSupply > 140_000_000 ether && totalSupply <= 280_000_000 ether) {
  //     return (140_000_000 ether, 280_000_000 ether, 10_000_000 ether);
  //   } else if (totalSupply > 280_000_000 ether && totalSupply <= 420_000_000 ether) {
  //     return (280_000_000 ether, 420_000_000 ether, 20_000_000 ether);
  //   } else if (totalSupply > 420_000_000 ether && totalSupply <= 720_000_000 ether) {
  //     return (420_000_000 ether, 720_000_000 ether, 30_000_000 ether);
  //   } else if (totalSupply > 720_000_000 ether && totalSupply <= 840_000_000 ether) {
  //     return (720_000_000 ether, 840_000_000 ether, 40_000_000 ether);
  //   } else if (totalSupply > 840_000_000 ether && totalSupply <= 2_100_000_000 ether) {
  //     return (840_000_000 ether, 2_100_000_000 ether, 60_000_000 ether);
  //   } else if (totalSupply > 2_100_000_000 ether && totalSupply <= 2_500_000_000 ether) {
  //     return (2_100_000_000 ether, 2_500_000_000 ether, 80_000_000 ether);
  //   } else if (totalSupply > 2_500_000_000 ether && totalSupply <= 4_500_000_000 ether) {
  //     return (2_500_000_000 ether, 4_500_000_000 ether, 100_000_000 ether);
  //   } else if (totalSupply > 4_500_000_000 ether && totalSupply <= 7_500_000_000 ether) {
  //     return (4_500_000_000 ether, 7_500_000_000 ether, 200_000_000 ether);
  //   } else if (totalSupply > 7_500_000_000 ether && totalSupply <= 19_000_000_000 ether) {
  //     return (7_500_000_000 ether, 19_000_000_000 ether, 250_000_000 ether);
  //   } else if (totalSupply > 19_000_000_000 ether && totalSupply <= 20_000_000_000 ether) {
  //     return (19_000_000_000 ether, 20_000_000_000 ether, 200_000_000 ether);
  //   } else if (totalSupply > 20_000_000_000 ether && totalSupply <= 20_200_000_000 ether) {
  //     return (20_000_000_000 ether, 20_200_000_000 ether, 100_000_000 ether);
  //   } else if (totalSupply > 20_200_000_000 ether && totalSupply <= 20_800_000_000 ether) {
  //     return (20_200_000_000 ether, 20_800_000_000 ether, 50_000_000 ether);
  //   } else if (totalSupply > 20_800_000_000 ether && totalSupply <= 20_900_000_000 ether) {
  //     return (20_800_000_000 ether, 20_900_000_000 ether, 20_000_000 ether);
  //   } else {
  //     return (0, 1_000_000 ether, 20_000_000 ether);
  //   }
  // }

  // TODO: change public to internal
  // function getMarker() public view returns (uint256) {
  //   uint256 totalSupply = IERC20(registry.registry('BbToken')).totalSupply();
  //   (uint256 min, uint256 max, uint256 diff) = getDiff();
  //   uint256 iterations = (max - min) / diff;

  //   for (uint256 index = 0; index < iterations; index++) {
  //     if (totalSupply > min + (index * diff) && totalSupply <= min + ((index + 1) * diff)) {
  //       return min + ((index + 1) * diff);
  //     }
  //   }
  // }

  function getMarker() internal view returns (uint256) {
    uint256 totalSupply = IERC20(registry.registry('BbToken')).totalSupply();
    uint256 marker = 0;

    if (totalSupply > markers[markerSize - 1]) {
      return markerSize - 1;
    }

    for (uint256 index = 0; index < markers.length - 1; index++) {
      if (totalSupply > markers[index] && totalSupply <= markers[index + 1]) {
        marker = index;
        break;
      }
    }

    return marker;
  }

  function getInterestRate() internal view returns (uint256) {
    uint256 marker = getMarker();
    return interests[marker];
  }

  function getTotalInterest(uint256 _id) public view returns (uint256, uint256) {
    uint256 principal = attributes[_id].amount;
    uint256 interest = attributes[_id].interestRate;
    uint256 month = 30 days;
    uint256 months = (attributes[_id].cfaLife - attributes[_id].effectiveInterestTime) / month;
    uint256 basisPoint = 100000;
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

  /**
   * Loan functions
   */

  function createLoan(uint256 _id) external nonReentrant {
    require(balanceOf(msg.sender, _id) == 1, 'Savings: invalid id');
    require(!loan[_id].onLoan, 'Savings: Loan already created');
    require(block.timestamp < attributes[_id].cfaLife, 'Savings: insurance has expired');

    (uint256 totalPrincipal, ) = getYieldedInterest(_id);
    uint256 loanedPrincipal = ((totalPrincipal) * 25) / 100;

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

    emit LoanRepayed(_id);
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
