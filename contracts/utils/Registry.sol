// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import '@openzeppelin/contracts/access/Ownable.sol';

contract Registry is Ownable {
  mapping(string => address) public registry;

  function addToRegistry(string memory _name, address _address) external onlyOwner {
    if (registry[_name] != address(0)) {
      revert('SteadRegistry: Name already exists');
    }
    registry[_name] = _address;
  }

  function updateRegistry(string memory _name, address _address) external onlyOwner {
    registry[_name] = _address;
  }

  function removeFromRegistry(string memory _name) external onlyOwner {
    delete registry[_name];
  }
}
