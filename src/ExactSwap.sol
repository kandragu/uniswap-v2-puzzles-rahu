// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";
import {console} from "forge-std/Test.sol";

contract ExactSwap {
    uint256 public constant usdcOut = 1337 * 1e6;

    /**
     *  PERFORM AN SIMPLE SWAP WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 WETH.
     *  The challenge is to swap an exact amount of WETH for 1337 USDC token using the `swap` function
     *  from USDC/WETH pool.
     *
     */
    function performExactSwap(address pool, address weth, address usdc) public {
        /**
         *     swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data);
         *
         *     amount0Out: the amount of USDC to receive from swap.
         *     amount1Out: the amount of WETH to receive from swap.
         *     to: recipient address to receive the USDC tokens.
         *     data: leave it empty.
         */

        // your code start here

        // dx = (xdy) / (0.997(y - dy))

        (uint256 reserveOut, uint256 reserveIn, ) = IUniswapV2Pair(pool)
            .getReserves();

        uint ethOutPut = (reserveIn * usdcOut * 1000) /
            ((reserveOut - usdcOut) * 997) +
            1;

        IUniswapV2Pair(weth).transfer(pool, ethOutPut);
        IUniswapV2Pair(pool).swap(1337 * 1e6, 0, address(this), "");
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    /*function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint numerator = reserveIn * amountOut * 1000;
        uint denominator = (reserveOut - amountOut) * (997);
        amountIn = (numerator / denominator) + 1;
    }*/
}
