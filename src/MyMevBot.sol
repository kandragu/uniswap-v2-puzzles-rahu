// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";
import "../src/interfaces/IUniswapV2Pair.sol";
import {Test, console2} from "forge-std/Test.sol";

/**
 *
 *  ARBITRAGE A POOL
 *
 * Given two pools where the token pair represents the same underlying; WETH/USDC and WETH/USDT (the formal has the corect price, while the latter doesnt).
 * The challenge is to flash borrowing some USDC (>1000) from `flashLenderPool` to arbitrage the pool(s), then make profit by ensuring MyMevBot contract's USDC balance
 * is more than 0.
 *
 */
contract MyMevBot {
    address public immutable flashLenderPool;
    address public immutable weth;
    address public immutable usdc;
    address public immutable usdt;
    address public immutable router;
    bool public flashLoaned;

    address public USDC_WETH_pool = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;
    address public ETH_USDT_pool = 0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852;

    constructor(
        address _flashLenderPool,
        address _weth,
        address _usdc,
        address _usdt,
        address _router
    ) {
        flashLenderPool = _flashLenderPool;
        weth = _weth;
        usdc = _usdc;
        usdt = _usdt;
        router = _router;
    }

    function performArbitrage() public {
        // your code here
        // get the price in both pools
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(USDC_WETH_pool)
            .getReserves();

        console2.log(
            "reserve0(USDC_WETH_pool): %d, reserve1: %d",
            reserve0 / 1e6,
            reserve1 / 1e18
        );
        // address token0 = IUniswapV2Pair(USDC_WETH_pool).token0();
        // console2.log("token0(USDC_WETH_pool): %s", token0);

        uint256 price0 = (reserve0 / 1e6) / (reserve1 / 1e18);
        (reserve0, reserve1, ) = IUniswapV2Pair(ETH_USDT_pool).getReserves();
        // address tokenZero = IUniswapV2Pair(ETH_USDT_pool).token0();
        // console2.log("token0(ETH_USDT_pool): %s", tokenZero);

        uint256 price1 = (reserve1 / 1e6) / (reserve0 / 1e18);

        console2.log(
            "price0(USDC_WETH_pool): %d, price1(ETH_USDT_pool): %d",
            price0,
            price1
        );

        //start of code
        // flash loan
        IUniswapV3Pool(flashLenderPool).flash(
            address(this),
            1000 * 1e6,
            0,
            abi.encodeWithSignature(
                "uniswapV3FlashCallback(uint256,uint256,bytes)",
                0,
                0,
                ""
            )
        );
    }

    function uniswapV3FlashCallback(
        uint256 _fee0,
        uint256,
        bytes calldata data
    ) external {
        callMeCallMe();

        uint256 usdcBal = IERC20(usdc).balanceOf(address(this));
        console2.log("fee0: %d", _fee0);

        // your code start here
        // transfer the USDC to the USDC_WETH_pool
        IERC20(usdc).transfer(msg.sender, 1000 * 1e6 + _fee0);
    }

    function callMeCallMe() private {
        uint256 usdcBal = IERC20(usdc).balanceOf(address(this));
        console2.log("usdcBal: %d", usdcBal / 1e6);
        require(msg.sender == address(flashLenderPool), "not callback");
        require(
            flashLoaned = usdcBal >= 1000 * 1e6,
            "FlashLoan less than 1,000 USDC."
        );
    }
}

interface IUniswapV3Pool {
    /**
     * recipient: the address which will receive the token0 and/or token1 amounts.
     * amount0: the amount of token0 to send.
     * amount1: the amount of token1 to send.
     * data: any data to be passed through to the callback.
     */
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
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
