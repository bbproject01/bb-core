// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract BLMToken is ERC20Upgradeable, OwnableUpgradeable {
    function initialize() external initializer {
        __Ownable_init(msg.sender);
        __ERC20_init("BLM", "BLM");
    }

    function mint(address _receiver, uint256 _amount) external onlyOwner {
        _mint(_receiver, _amount);
    }

    function burn(address _user, uint256 _amount) external onlyOwner {
        _burn(_user, _amount);
    }
}
