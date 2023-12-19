// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.20;

// import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
// import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

// /**
//  * @title FNFT
//  * @notice FNFT smart contract based on ERC1155
//  */
// contract FNFT is ERC1155 {
//   IERC20 public erc20Token;
//   uint256 public nextTokenId;
//   uint256 public minimumErc20Balance = 1 * 10 ** 18; // minimum cost of the FNFT
//   address private _owner;

//   mapping(uint256 => FNFTMetadata) public idToFNFTMetadata;
//   mapping(address => uint256[]) private _ownedTokens;
//   mapping(uint256 => address) private _tokenOwners;

//   struct FNFTMetadata {
//     bool blocked; //
//     uint256 blockDate; // Date of first block
//     uint256 originalTerm; // The original term in months for the FNFT
//     uint256 createDate; // Date of creation of the FNFT
//     uint256 timePassed; // The time that has passed since the minting of the FNFT, in months
//     uint256 maximumReduction; // The maximum reduction allowed in the original term, represented as a fraction (eg 25 to 25%)
//   }

//   constructor(string memory _uri, IERC20 _erc20Token) ERC1155(_uri) {
//     erc20Token = _erc20Token;
//     _owner = msg.sender;
//   }

//   event FNFTMinted(address indexed to, uint256 id, uint256 originalTerm, uint256 maximumReduction);

//   /**
//    * @notice Function to coin a new FNFT.
//    * @dev This function creates a new FNFT with a unique ID and assigns it to the sender.
//    * @param _originalTerm  The original term of the FNFT.
//    * @param _maximumReduction The maximum reduction allowed in the term of the FNFT.
//    * @param _amount The price in ERC20 tokens
//    */
//   function mint(uint256 _originalTerm, uint256 _maximumReduction, uint256 _amount) public {
//     require(
//       erc20Token.balanceOf(msg.sender) >= minimumErc20Balance,
//       'FNFT: Saldo insuficiente de ERC20 para el minteo'
//     );
//     require(erc20Token.balanceOf(msg.sender) > _amount, 'FNFT: Saldo insuficiente de ERC20 para el minteo');
//     require(erc20Token.transferFrom(msg.sender, address(this), _amount), 'ERC20 transfer failed');

//     nextTokenId++;
//     uint256 id = nextTokenId;

//     _mint(msg.sender, id, _amount, '');
//     // idToFNFTMetadata[id] = FNFTMetadata(_originalTerm, 0, _maximumReduction);
//     idToFNFTMetadata[id] = FNFTMetadata(false, 0, _originalTerm, block.timestamp, 0, _maximumReduction);
//     _ownedTokens[msg.sender].push(id);
//     _tokenOwners[id] = msg.sender;
//   }

//   /**
//    * @notice Change the ERC20 token associated with this contract.
//    * @param _erc20Token The address of the new ERC20 token.
//    */
//   function setERC20Token(IERC20 _erc20Token) public {
//     require(msg.sender == _owner, 'FNFT: No eres el owner');
//     erc20Token = _erc20Token;
//   }

//   /**
//    * @notice Change the minimum ERC20 balance needed to mint.
//    * @param _minimumErc20Balance The new minimum balance.
//    */
//   function setMinimumErc20Balance(uint256 _minimumErc20Balance) public {
//     require(msg.sender == _owner, 'FNFT: No eres el owner');
//     minimumErc20Balance = _minimumErc20Balance;
//   }

//   /**
//    * @notice Change the base URI for ERC1155 tokens.
//    * @param _newURI The new base URI.
//    */
//   function setURI(string memory _newURI) public {
//     require(msg.sender == _owner, 'FNFT: No eres el owner');
//     _setURI(_newURI);
//   }

//   /**
//    * @notice Gets all FNFT's created by the owner.
//    * @return An arrangement with the owner's FNFT's IDs.
//    */
//   function getTokensOwner() public view returns (uint256[] memory) {
//     return _ownedTokens[msg.sender];
//   }

//   /**
//    * @notice Obtains the owner of a FNFT through its ID.
//    * @param _id The ID of the FNFT.
//    * @return The address of the owner of the FNFT.
//    */
//   function tokensOwners(uint256 _id) public view returns (address) {
//     return _tokenOwners[_id];
//   }

//   /**
//    * @notice Obtains the metadata information of a FNFT through its ID.
//    * @param _id The ID of the FNFT.
//    * @return The FNFTMetadata structure containing the FNFT data.
//    */
//   function getInfoFNFTMetadata(uint256 _id) public view returns (FNFTMetadata memory) {
//     return idToFNFTMetadata[_id];
//   }

//   /**
//    * @notice Function to withdraw the balance of the FNFT's.
//    * @param _id The ID of the FNFT.
//    */
//   function withDrawFNFT(uint256 _id) public {
//     require(!isLockable(_id), 'Token is locked');
//     require(_tokenOwners[_id] == msg.sender, 'FNFT: Solo el propietario del FNFT puede reclamar los tokens');
//     uint256 timePass = idToFNFTMetadata[_id].createDate + idToFNFTMetadata[_id].originalTerm * 30 * 24 * 60 * 60; // 30 days, 24 hours, 60 minutes, 60 seconds
//     require(block.timestamp >= timePass, 'FNFT: Aun no se ha cumplido el tiempo para reclamar sus tokens');
//     uint256 balance = balanceOf(_tokenOwners[_id], _id); // Get the initial balance
//     uint256 acumulate = 0; // Function that obtains the accumulated tokens of the FNFT
//     uint256 totalTokens = balance + acumulate; // The sum of the initial balance is made plus the accumulated
//     erc20Token.transfer(msg.sender, totalTokens);
//     _burn(msg.sender, _id, balance);
//   }

//   /**
//    * @notice Blocks a FNFT by its ID.
//    * @param _id The ID of the FNFT.
//    */
//   function createLock(uint _id) public {
//     require(_tokenOwners[_id] == msg.sender, 'Only the owner can lock the token');
//     require(idToFNFTMetadata[_id].blockDate == 0, 'Lock already exists for this token');

//     idToFNFTMetadata[_id].blockDate = block.timestamp;
//     idToFNFTMetadata[_id].blocked = true;
//   }

//   /**
//    * @notice Check if a FNFT is blocked by its ID.
//    * @param _id The ID of the FNFT.
//    * @return True if FNFT is blocked, False otherwise.
//    */
//   function isLockable(uint _id) public view returns (bool) {
//     return idToFNFTMetadata[_id].blocked;
//   }

//   /**
//    * @notice Unlocks a FNFT using its ID.
//    * @param _id The ID of the FNFT.
//    */
//   function unlock(uint _id) public {
//     idToFNFTMetadata[_id].blocked = false;
//   }

//   /**
//    * @notice Transfer a FNFT to another address.
//    * @param _to The address to which the FNFT is to be transferred.
//    * @param _id The ID of the FNFT.
//    */
//   function transfer(address _to, uint256 _id) public {
//     require(!isLockable(_id), 'Token is locked');
//     require(_tokenOwners[_id] == msg.sender, 'Only Owner');
//     super.safeTransferFrom(msg.sender, _to, _id, balanceOf(msg.sender, _id), '');
//     // Update the owner of the FNFT.
//     _tokenOwners[_id] = _to;

//     // Remove the FNFT from the array of the old owner
//     uint256[] storage ownerTokens = _ownedTokens[msg.sender];
//     for (uint i = 0; i < ownerTokens.length; i++) {
//       if (ownerTokens[i] == _id) {
//         // Moves the last FNFT to the place of the FNFT being removed
//         ownerTokens[i] = ownerTokens[ownerTokens.length - 1];
//         // Reduce the size of the array by one
//         ownerTokens.pop();
//         break;
//       }
//     }

//     // Add the FNFT to the new owner's array
//     _ownedTokens[_to].push(_id);
//   }

//   /**
//    * @notice Updates the creation date of a FNFT.
//    * @param _id The ID of the FNFT.
//    */
//   function updateDate(uint _id) public {
//     idToFNFTMetadata[_id].createDate = 0;
//   }
// }
