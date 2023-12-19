// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
// import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
// import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

// /**
//  * @title UniswapLiquidityProvider
//  * @notice Contract to provide liquidity on Uniswap
//  */
// contract UniswapLiquidityProvider {
//   address private uniswapRouter;
//   address private token;
//   bool private liquidityLocked;
//   uint256 private liquidityLockTime;
//   address private authorizedAddress;

//   constructor(address _token, address _uniswapRouter) {
//     uniswapRouter = _uniswapRouter;
//     token = _token;
//     authorizedAddress = msg.sender;
//   }

//   /**
//    * @dev Switch to restrict access to authorized address only.
//    */
//   modifier onlyAuthorized() {
//     require(msg.sender == authorizedAddress, 'Unauthorized access');
//     _;
//   }

//   /**
//    * @notice Adds liquidity to the token pair on Uniswap.
//    * @param amountTokenDesired The amount of tokens desired to add.
//    * @param amountETHDesired The amount of ETH desired to add.
//    */
//   function addLiquidity(uint256 amountTokenDesired, uint256 amountETHDesired) public onlyAuthorized {
//     IUniswapV2Router02 router = IUniswapV2Router02(uniswapRouter);
//     require(router != IUniswapV2Router02(address(0)), 'Uniswap router not found');
//     IERC20(token).approve(address(router), amountTokenDesired);
//     router.addLiquidityETH{value: amountETHDesired}(
//       token,
//       amountTokenDesired,
//       0,
//       0,
//       address(this),
//       block.timestamp + 1800
//     );
//     lockLiquidity();
//   }

//   /**
//    * @notice Locks aggregate liquidity.
//    */
//   function lockLiquidity() public onlyAuthorized {
//     require(!liquidityLocked, 'Liquidity already locked');
//     liquidityLocked = true;
//     liquidityLockTime = block.timestamp + 1800; // 30 minutes lock time
//   }

//   /**
//    * @notice Unlock previously locked liquidity.
//    */
//   function unlockLiquidity() public onlyAuthorized {
//     require(liquidityLocked, 'Liquidity not locked');
//     require(block.timestamp > liquidityLockTime, 'Liquidity still locked');
//     liquidityLocked = false;
//   }

//   /**
//    * @notice Sets the authorized address.
//    * @param _address The new authorized address.
//    */
//   function setAuthorizedAddress(address _address) public onlyAuthorized {
//     authorizedAddress = _address;
//   }

//   /**
//    * @notice Remove the tokens from the contract.
//    * @param tokenAddress The address of the token to withdraw.
//    */
//   function withdrawTokens(address tokenAddress) public onlyAuthorized {
//     IERC20 tokenInstance = IERC20(tokenAddress);
//     uint256 balance = tokenInstance.balanceOf(address(this));
//     tokenInstance.transfer(msg.sender, balance);
//   }

//   /**
//    * @notice Withdraw the ETH from the contract.
//    */
//   function withdrawETH() public onlyAuthorized {
//     uint256 balance = address(this).balance;
//     payable(msg.sender).transfer(balance);
//   }

//   /**
//    * @dev Fallback function to receive ETH.
//    */
//   receive() external payable {}
// }
