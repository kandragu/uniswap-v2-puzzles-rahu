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

    uint256 constant loanAmount = 10_000 * 1e6;

    address public USDC_WETH_pool = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;
    address public ETH_USDT_pool = 0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852;
    address public USDC_USDT_pool = 0x3041CbD36888bECc7bbCBc0045E3B1f144466f5f;

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
        // flash loan
        IUniswapV3Pool(flashLenderPool).flash(
            address(this),
            loanAmount, // usdc to borrow
            0,
            abi.encode(usdc, weth, loanAmount, 0)
        );
    }

    function uniswapV3FlashCallback(
        uint256 _fee0,
        uint256,
        bytes calldata data
    ) external {
        callMeCallMe();

        // your code start here
        // 1. swap the USDC to WETH from the USDC_WETH_pool as the price is lesser
        // 2. calculate the exact amount of output token weth to receive

        (uint256 reserveIn, uint256 reserveOut, ) = IUniswapV2Pair(
            USDC_WETH_pool
        ).getReserves();

        uint256 amountOutMin = (loanAmount * 997 * reserveOut) /
            ((reserveIn * 1000) + (997 * loanAmount));

        address[] memory path = new address[](2);
        path[0] = usdc;
        path[1] = weth;

        // Approve usdc to the router
        IERC20(usdc).approve(router, loanAmount);

        IUniswapV2Router(router).swapExactTokensForTokens(
            loanAmount,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 100 // what is the better way to set the deadline?
        );

        // get the weth balance
        uint256 wethBal = IERC20(weth).balanceOf(address(this));

        // 3. swap the WETH to USDT from the ETH_USDT_pool
        // 4. calculate the exact amount of output token usdt to receive ( may be some slippage in the real world)
        (reserveIn, reserveOut, ) = IUniswapV2Pair(ETH_USDT_pool).getReserves();

        amountOutMin =
            (wethBal * 997 * reserveOut) /
            ((reserveIn * 1000) + (997 * wethBal));

        path[0] = weth;
        path[1] = usdt;

        // Approve weth to the router
        IERC20(weth).approve(router, wethBal);

        IUniswapV2Router(router).swapExactTokensForTokens(
            wethBal,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 100
        );

        // get the USDT balance
        uint256 usdtBal = IERC20(usdt).balanceOf(address(this));

        // swap from usdt to usdc
        path[0] = usdt;
        path[1] = usdc;

        // Transfer usdt to the router
        IERC20(usdt).approve(router, usdtBal);

        // calculate the amount of usdc to receive
        (reserveIn, reserveOut, ) = IUniswapV2Pair(USDC_USDT_pool)
            .getReserves();

        amountOutMin =
            (usdtBal * 997 * reserveOut) /
            ((reserveIn * 1000) + (997 * usdtBal));

        // slippage of 1%
        amountOutMin = (amountOutMin * 99) / 100;

        IUniswapV2Router(router).swapExactTokensForTokens(
            usdtBal,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 100
        );

        // transfer the USDC to the USDC_WETH_pool
        IERC20(usdc).transfer(msg.sender, loanAmount + _fee0);
    }

    function callMeCallMe() private {
        uint256 usdcBal = IERC20(usdc).balanceOf(address(this));
        require(msg.sender == address(flashLenderPool), "not callback");
        require(
            flashLoaned = usdcBal >= loanAmount,
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
