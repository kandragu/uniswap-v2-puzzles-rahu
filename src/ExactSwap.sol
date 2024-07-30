// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";
import {console} from "forge-std/Test.sol";

contract ExactSwap {
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

        // dy = (xdx) / (0.997(x - dx))
        // dy = (997 * x * dx) / (1000 * x - 997 * dx)

        // (uint256 r0, uint256 r1, ) = IUniswapV2Pair(pool).getReserves();
        // (uint256 reserveIn, uint256 reserveOut) = IUniswapV2Pair(pool)
        //     .getReserves();

        (uint256 reserveA, uint256 reserveB, ) = IUniswapV2Pair(pool)
            .getReserves();

        console.log("reserveA, reserveB", reserveA, reserveB);

        address toeken0 = IUniswapV2Pair(pool).token0();
        address toekn1 = IUniswapV2Pair(pool).token1();
        // console.log("reserveIn, reserveOut", reserveIn, reserveOut);
        console.log("token0, token1", toeken0, toekn1);

        // uint256 x = IERC20(weth).balanceOf(address(this));
        // uint256 dx = (x * 997 * r0) / (1000 * x + 997 * r1);
        // console.log("dx", dx);
        // console.log("r0, r1", r0, r1, x);
        // uint amountOut = 1337 * 1e6;

        // uint numerator = reserveIn * amountOut * 1000;
        // // console.log("numerator", numerator);
        // uint denominator = (reserveOut - amountOut) * 997;
        // // console.log("denominator", denominator);
        // uint amountIn = (numerator / denominator) + 1;
        // console.log("amountIn", amountIn);

        /*uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);*/

        uint output = getAmountIn(1337 * 1e6, reserveB, reserveA);
        console.log("output", output);

        uint256 d = (output * 997 * reserveA) /
            ((reserveB * 1000) + (997 * output));
        console.log("d", d);

        IUniswapV2Pair(weth).transfer(pool, output);
        // IUniswapV2Pair(usdc).transfer(pool, 1337);
        IUniswapV2Pair(pool).swap(1337 * 1e6, 0, address(this), "");

        // uint input = getInputAmount(3500 * 1e6, reserveIn, reserveOut);
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
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
    }
}
