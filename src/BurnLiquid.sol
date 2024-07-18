// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract BurnLiquid {
    /**
     *  BURN LIQUIDITY WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 0.01 UNI-V2-LP tokens.
     *  Burn a position (remove liquidity) from USDC/ETH pool to this contract.
     *  The challenge is to use the `burn` function in the pool contract to remove all the liquidity from the pool.
     *
     */
    function burnLiquidity(address pool) public {
        /**
         *     burn(address to);
         *
         *     to: recipient address to receive tokenA and tokenB.
         */
        // your code here

        IUniswapV2Pair _pool = IUniswapV2Pair(pool);

        uint256 lpBalance = _pool.balanceOf(address(this));

        IUniswapV2Pair(pool).transfer(pool, lpBalance);

        _pool.burn(address(this));
    }
}
