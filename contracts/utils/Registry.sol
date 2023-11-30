// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import '@openzeppelin/contracts/access/Ownable.sol';

contract Registry is Ownable {
  mapping(string => address) public registry;
  mapping(address => bool) public registered;

  function setAddress(string memory _name, address _address) external onlyOwner {
    registry[_name] = _address;
    registered[_address] = true;
  }

  function getAddress(string memory _name) external view returns (address) {
    require(registry[_name] != address(0), 'Registry: Does not exist');
    return registry[_name];
  }

  function isRegistered(address _address) external view returns (bool) {
    return registered[_address];
  }
}
