// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import '../utils/Registry.sol';

contract BBToken is ERC20, ERC20Burnable {
  Registry public registry;
  uint256 maxSupply;

  constructor(uint256 _initSupply, uint256 _maxSupply) ERC20('BBToken', 'BBT') {
    maxSupply = _maxSupply;
    _mint(msg.sender, _initSupply);
  }

  function mint(address _user, uint256 _amount) public {
    require(_isAuthorizedAddress(msg.sender), 'BBToken:: Not authorized');
    _mint(_user, _amount);
  }

  function _isAuthorizedAddress(address _address) internal view returns (bool) {
    if (registry.getAddress('Insurace') == _address) return true;
    if (registry.getAddress('Savings') == _address) return true;
    if (registry.getAddress('Income') == _address) return true;

    return false;
  }

  function setRegistry(address _registry) external {
    registry = Registry(_registry);
  }
}
