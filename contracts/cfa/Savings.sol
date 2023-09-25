// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Base64.sol';
import './interface/ICFA.sol';
import './interface/ISavings.sol';
import './Referral.sol';
import '../utils/Registry.sol';

contract Savings is ISavings, ERC1155, Ownable {
  using Strings for uint256;

  /**
   * Local variables
   */
  Registry public registry; // The registry contract
  Life public life; // max and minimum life of Savings CFA
  Metadata public metadata; // The metadata of the Savings CFA

  mapping(uint256 => Attributes) public attributes;
  uint256[] public markers = new uint256[](219);
  uint256[] public interests = new uint256[](219);
  uint256 public idCounter = 1;

  /**
   * Events
   */
  event SavingsCreated(Attributes _attribute);
  event SavingsWithdrawn(Attributes _attribute, uint256 _time);
  event SavingsBinded(Attributes _attribute, uint256 _time);

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

  function _saveMetadata(Attributes memory _attributes) internal {
    _attributes.timeCreated = block.timestamp;
    _attributes.interestRate = 0;
    attributes[idCounter] = _attributes;
  }

  function _mintSavings(Attributes memory _attributes) internal {
    IERC20(registry.registry('BbToken')).transferFrom(msg.sender, address(this), _attributes.amount);

    attributes[idCounter] = _attributes;
    _mint(msg.sender, idCounter, idCounter, '');
    _saveMetadata(_attributes);

    emit SavingsCreated(_attributes);
  }

  function mintSavings(Attributes[] memory _attributes) external {
    for (uint256 i = 0; i < _attributes.length; i++) {
      _mintSavings(_attributes[i]);
      idCounter++;
    }

    // TODO: add referral
  }

  function _burnSavings(uint256 _id) internal {
    IERC20(registry.registry('BbToken')).transfer(msg.sender, attributes[_id].amount);
    delete attributes[_id];
    _burn(msg.sender, _id, idCounter);
  }

  function withdrawSavings(uint256 _id) external {
    require(attributes[_id].timeCreated + attributes[_id].cfaLife < block.timestamp, 'Savings: CFA is not matured');
    _burnSavings(_id);

    emit SavingsWithdrawn(attributes[_id], block.timestamp);
  }

  function bindSavings(uint256 _id) external {
    require(attributes[_id].soulBoundTerm == 0, 'Savings: CFA is already bound');
    require(balanceOf(msg.sender, _id) > 0, 'Savings: CFA is not owned by the caller');

    attributes[_id].soulBoundTerm = block.timestamp;

    emit SavingsBinded(attributes[_id], block.timestamp);
  }

  /**
   * Write Function
   */

  function setImage(string[2] memory _image) external onlyOwner {
    metadata.image[0] = _image[0];
    metadata.image[1] = _image[1];
  }

  function setMetadata(string memory _name, string memory _description) external onlyOwner {
    metadata.name = _name;
    metadata.description = _description;
  }

  function setRegsitry(address _registry) external onlyOwner {
    registry = Registry(_registry);
  }

  function setLife(uint256 _min, uint256 _max) external onlyOwner {
    life.min = _min;
    life.max = _max;
  }

  function setInterest(uint256[] memory _marker, uint256[] memory _interest) external onlyOwner {
    require(_marker.length == _interest.length, 'Savings: Invalid input');
    for (uint256 i = 0; i < _marker.length; i++) {
      markers[i] = _marker[i];
      interests[i] = _interest[i];
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

  // TODO: change public to internal
  function getMarker() public view returns (uint256) {
    uint256 totalSupply = IERC20(registry.registry('BbToken')).totalSupply();
    uint256 marker = 0;
    for (uint256 index = 0; index < markers.length; index++) {
      if (totalSupply > markers[index] && totalSupply <= markers[index + 1]) {
        marker = markers[index];
      }
    }

    return marker;
  }

  // TODO: change public to internal
  function getInterestRate() public view returns (uint256) {
    uint256 marker = getMarker();
    return interests[marker];
  }

  function getTotalInterest(uint256 _id) public view returns (uint256, uint256) {
    uint256 principal = attributes[_id].amount;
    uint256 interest = interests[attributes[_id].cfaLife];
    uint256 months = (block.timestamp - attributes[_id].timeCreated) / 30 days;
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

  function getImage(uint256 tokenId) public view returns (string memory) {
    bool status = attributes[tokenId].soulBoundTerm > 0;
    string memory image = status ? metadata.image[1] : metadata.image[0];
    return image;
  }

  function batchGetImage(uint256[] memory _tokenId) public view returns (string[] memory) {
    string[] memory images = new string[](_tokenId.length);

    for (uint256 index = 0; index < _tokenId.length; index++) {
      images[index] = getImage(_tokenId[index]);
    }

    return images;
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
        getImage(_tokenId),
        '"',
        '}'
      )
    );

    return _metadata;
  }

  /**
   * Override Functions
   */

  function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public override {
    require(attributes[id].soulBoundTerm == 0, 'CFA: El CFA esta bloqueado y no se puede transferir');
    super.safeTransferFrom(from, to, id, amount, data);
  }

  /**
   * @dev Overrides the `burn` function to prevent burning of locked CFAs.
   */
  function burn(uint256 id) public {
    require(attributes[id].soulBoundTerm == 0, 'CFA: El CFA esta bloqueado y no se puede quemar');
    _burn(msg.sender, id, 1);
  }

  // Override the `burnBatch` function to prevent burning of locked CFAs
  function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) public {
    for (uint256 i = 0; i < ids.length; i++) {
      require(attributes[ids[i]].soulBoundTerm == 0, 'CFA: No se puede quemar un CFA bloqueado');
    }
    this.burnBatch(account, ids, amounts);
  }

  function uri(uint256 _tokenId) public view virtual override returns (string memory) {
    bytes memory _metadata = abi.encodePacked(getMetadata(_tokenId));

    return string(abi.encodePacked('data:application/json;base64,', Base64.encode(_metadata)));
  }
}
