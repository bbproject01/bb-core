// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';

contract BBToken is ERC20, ERC20Burnable {
  uint256 maxSupply;

  constructor(uint256 _initSupply, uint256 _maxSupply) ERC20('BBToken', 'BBT') {
    maxSupply = _maxSupply;
    _mint(msg.sender, _initSupply);
  }

  function mint(address _user, uint256 _amount) external {
    _mint(_user, _amount);
  }
}
