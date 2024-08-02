// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import {console2} from "forge-std/Test.sol";

contract SimpleSwapWithRouter {
    /**
     *  PERFORM A SIMPLE SWAP USING ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 ETH.
     *  The challenge is to swap any amount of ETH for USDC token using Uniswapv2 router.
     *
     */
    address public immutable router;

    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // address public usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    constructor(address _router) {
        router = _router;
    }

    function performSwapWithRouter(
        address[] calldata path,
        uint256 deadline
    ) public {
        // your code start here

        IUniswapV2Pair(weth).balanceOf(address(this));
        console2.log(
            "weth balance: %d",
            IUniswapV2Pair(weth).balanceOf(address(this))
        );
        IUniswapV2Router(router).swapExactETHForTokens{value: 1 ether}(
            0,
            path,
            address(this),
            deadline
        );
    }

    receive() external payable {}
}

interface IUniswapV2Router {
    /**
     *     amountOutMin: the minimum amount of output tokens that must be received for the transaction not to revert.
     *     path: an array of token addresses. In our case, WETH and USDC.
     *     to: recipient address to receive the liquidity tokens.
     *     deadline: timestamp after which the transaction will revert.
     */
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}
