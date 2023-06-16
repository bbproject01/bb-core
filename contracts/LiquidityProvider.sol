// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/**
 * @title UniswapLiquidityProvider
 * @notice Contrato para proveer liquidez en Uniswap
 */
contract UniswapLiquidityProvider {
    address private uniswapRouter;
    address private token;
    bool private liquidityLocked;
    uint256 private liquidityLockTime;
    address private authorizedAddress;

    constructor(address _token, address _uniswapRouter) {
        uniswapRouter = _uniswapRouter;
        token = _token;
        authorizedAddress = msg.sender;
    }

    /**
     * @dev Modificador para restringir el acceso solo a la dirección autorizada.
     */
    modifier onlyAuthorized {
        require(msg.sender == authorizedAddress, "Unauthorized access");
        _;
    }

    /**
     * @notice Agrega liquidez al par de tokens en Uniswap.
     * @param amountTokenDesired La cantidad de tokens deseados a agregar.
     * @param amountETHDesired La cantidad de ETH deseados a agregar.
     */
    function addLiquidity(uint256 amountTokenDesired, uint256 amountETHDesired) public onlyAuthorized {
        IUniswapV2Router02 router = IUniswapV2Router02(uniswapRouter);
        require(router != IUniswapV2Router02(address(0)), "Uniswap router not found");
        IERC20(token).approve(address(router), amountTokenDesired);
        router.addLiquidityETH{value: amountETHDesired}(token, amountTokenDesired, 0, 0, address(this), block.timestamp + 1800);
        lockLiquidity();
    }

    /**
     * @notice Bloquea la liquidez agregada.
     */
    function lockLiquidity() public onlyAuthorized {
        require(!liquidityLocked, "Liquidity already locked");
        liquidityLocked = true;
        liquidityLockTime = block.timestamp + 1800; // 30 minutes lock time
    }

    /**
     * @notice Desbloquea la liquidez previamente bloqueada.
     */
    function unlockLiquidity() public onlyAuthorized {
        require(liquidityLocked, "Liquidity not locked");
        require(block.timestamp > liquidityLockTime, "Liquidity still locked");
        liquidityLocked = false;
    }

    /**
     * @notice Establece la dirección autorizada.
     * @param _address La nueva dirección autorizada.
     */
    function setAuthorizedAddress(address _address) public onlyAuthorized {
        authorizedAddress = _address;
    }

    /**
     * @notice Retira los tokens del contrato.
     * @param tokenAddress La dirección del token a retirar.
     */
    function withdrawTokens(address tokenAddress) public onlyAuthorized {
        IERC20 tokenInstance = IERC20(tokenAddress);
        uint256 balance = tokenInstance.balanceOf(address(this));
        tokenInstance.transfer(msg.sender, balance);
    }

    /**
     * @notice Retira los ETH del contrato.
     */
    function withdrawETH() public onlyAuthorized {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /**
     * @dev Función fallback para recibir ETH.
     */
    receive() external payable {}
}