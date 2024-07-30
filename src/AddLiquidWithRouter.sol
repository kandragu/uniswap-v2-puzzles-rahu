// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import {IWETH} from "./interfaces/IWETH.sol";
import {console} from "forge-std/Test.sol";

contract AddLiquidWithRouter {
    /**
     *  ADD LIQUIDITY WITH ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1000 USDC and 1 ETH.
     *  Mint a position (deposit liquidity) in the pool USDC/ETH to `msg.sender`.
     *  The challenge is to use Uniswapv2 router to add liquidity to the pool.
     *
     */
    address private weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public pool = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;
    address public immutable router;

    constructor(address _router) {
        router = _router;
    }

    function addLiquidityWithRouter(
        address usdcAddress,
        uint256 deadline
    ) public {
        // your code start here
        IWETH(payable(weth)).deposit{value: 1 ether}();
        require(
            IUniswapV2Pair(weth).balanceOf(address(this)) == 1 ether,
            "WETH balance is not 1 ether"
        );

        console.log(
            "WETH balance: %s",
            IUniswapV2Pair(weth).balanceOf(address(this))
        );
        console.log("ETH balance: %s", address(this).balance);
        console.log(
            "USDC balance: %s",
            IUniswapV2Pair(usdcAddress).balanceOf(address(this))
        );

        IUniswapV2Pair(usdcAddress).approve(router, 1000 * 10 ** 6);
        IUniswapV2Pair(weth).approve(router, 1 ether);

        console.log(
            "token0 %s token1 %s",
            IUniswapV2Pair(pool).token0(),
            IUniswapV2Pair(pool).token1()
        );

        uint256 amountA = 1000 * 10 ** 6;

        (uint256 reserveA, uint256 reserveB, ) = IUniswapV2Pair(pool)
            .getReserves();
        uint256 amountB = (amountA * (reserveB)) / reserveA;
        console.log("amountB", amountB);

        console.log("reserveA, reserveB", reserveA, reserveB);

        IUniswapV2Router(router).addLiquidityETH{value: 1 ether}(
            usdcAddress,
            1000 * 10 ** 6,
            1000 * 10 ** 6,
            amountB,
            msg.sender,
            deadline
        );
    }

    receive() external payable {}
}

interface IUniswapV2Router {
    /**
     *     token: the usdc address
     *     amountTokenDesired: the amount of USDC to add as liquidity.
     *     amountTokenMin: bounds the extent to which the ETH/USDC price can go up before the transaction reverts. Must be <= amountUSDCDesired.
     *     amountETHMin: bounds the extent to which the USDC/ETH price can go up before the transaction reverts. Must be <= amountETHDesired.
     *     to: recipient address to receive the liquidity tokens.
     *     deadline: timestamp after which the transaction will revert.
     */
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}
