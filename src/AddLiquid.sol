// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/IUniswapV2Pair.sol";

contract AddLiquid {
    /**
     *  ADD LIQUIDITY WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1000 USDC and 1 WETH.
     *  Mint a position (deposit liquidity) in the pool USDC/WETH to msg.sender.
     *  The challenge is to provide the same ratio as the pool then call the mint function in the pool contract.
     *
     */
    function addLiquidity(
        address usdc,
        address weth,
        address pool,
        uint256 usdcReserve,
        uint256 wethReserve
    ) public {
        IUniswapV2Pair pair = IUniswapV2Pair(pool);

        // your code start here

        // see available functions here: https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol

        (uint256 optimalFoo, uint256 optimalBar) = calculateOptimalLiquidity(
            usdcReserve,
            wethReserve,
            1000 * 10 ** 6,
            1 ether
        );

        IUniswapV2Pair(usdc).transfer(pool, optimalFoo);
        IUniswapV2Pair(weth).transfer(pool, optimalBar);

        pair.mint(msg.sender);
    }

    // @dev Calculate the optimal amount of token0 and token1 to provide to a Uniswap V2 pair
    // to maximize the amount of liquidity minted
    // @param reserve0 The current reserve of token0 in the pair
    // @param reserve1 The current reserve of token1 in the pair
    // @param amount0Desired The desired amount of token0 to provide
    // @param amount1Desired The desired amount of token1 to provide
    // @return amount0 The optimal amount of token0 to provide
    // @return amount1 The optimal amount of token1 to provide
    function calculateOptimalLiquidity(
        uint256 reserve0,
        uint256 reserve1,
        uint256 amount0Desired,
        uint256 amount1Desired
    ) public pure returns (uint256 amount0, uint256 amount1) {
        if (reserve0 == 0 && reserve1 == 0) {
            // For the first liquidity provision, use all amounts
            return (amount0Desired, amount1Desired);
        }

        uint256 amount1Optimal = (amount0Desired * reserve1) / reserve0;
        if (amount1Optimal <= amount1Desired) {
            // amount0Desired is the limiting factor
            return (amount0Desired, amount1Optimal);
        } else {
            // amount1Desired is the limiting factor
            uint256 amount0Optimal = (amount1Desired * reserve0) / reserve1;
            assert(amount0Optimal <= amount0Desired);
            return (amount0Optimal, amount1Desired);
        }
    }
}
