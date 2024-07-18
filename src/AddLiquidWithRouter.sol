// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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
        IUniswapV2Pair(usdcAddress).approve(router, 1000 * 10 ** 6);
        IUniswapV2Pair(weth).approve(router, 1 ether);

        uint256 amountA = 1000 * 10 ** 6;

        (uint256 reserveA, uint256 reserveB, ) = IUniswapV2Pair(pool)
            .getReserves();
        uint256 amountB = (amountA * (reserveB)) / reserveA;

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
