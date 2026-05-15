// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DeFiAMM
 * @dev A constant-product AMM (x * y = k) implementation built from scratch.
 * Optimized with CEI pattern and dynamic fee management by DAO.
 */
contract DeFiAMM is ERC20, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable TOKEN0;
    IERC20 public immutable TOKEN1;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public constant FEE_DENOMINATOR = 1000;
    uint256 public fee = 3; // Default 0.3%, adjustable by owner (DAO)

    event Swap(address indexed user, address indexed tokenIn, uint256 amountIn, uint256 amountOut);
    event AddLiquidity(address indexed user, uint256 amount0, uint256 amount1, uint256 shares);
    event RemoveLiquidity(address indexed user, uint256 amount0, uint256 amount1, uint256 shares);
    event FeeUpdated(uint256 newFee);

    constructor(address _token0, address _token1) ERC20("AMM LP Token", "ALP") Ownable(msg.sender) {
        TOKEN0 = IERC20(_token0);
        TOKEN1 = IERC20(_token1);
    }

    function _update(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    /**
     * @dev Allows the DAO (owner) to update the swap fee.
     */
    function setFee(uint256 newFee) external onlyOwner {
        require(newFee <= 10, "Fee too high"); // Max 1%
        fee = newFee;
        emit FeeUpdated(newFee);
    }

    function swap(address tokenInAddress, uint256 amountIn, uint256 minAmountOut) external nonReentrant returns (uint256 amountOut) {
        require(tokenInAddress == address(TOKEN0) || tokenInAddress == address(TOKEN1), "Invalid token");
        require(amountIn > 0, "Amount must be > 0");

        bool isToken0 = tokenInAddress == address(TOKEN0);
        (IERC20 tokenIn, IERC20 tokenOut, uint256 resIn, uint256 resOut) = isToken0
            ? (TOKEN0, TOKEN1, reserve0, reserve1)
            : (TOKEN1, TOKEN0, reserve1, reserve0);

        tokenIn.safeTransferFrom(msg.sender, address(this), amountIn);

        uint256 amountInWithFee = (amountIn * (FEE_DENOMINATOR - fee)) / FEE_DENOMINATOR;
        amountOut = (resOut * amountInWithFee) / (resIn + amountInWithFee);
        require(amountOut >= minAmountOut, "Slippage too high");

        _update(TOKEN0.balanceOf(address(this)), TOKEN1.balanceOf(address(this)));
        tokenOut.safeTransfer(msg.sender, amountOut);

        emit Swap(msg.sender, tokenInAddress, amountIn, amountOut);
    }

    function addLiquidity(uint256 amount0, uint256 amount1) external nonReentrant returns (uint256 shares) {
        TOKEN0.safeTransferFrom(msg.sender, address(this), amount0);
        TOKEN1.safeTransferFrom(msg.sender, address(this), amount1);

        if (totalSupply() == 0) {
            shares = _sqrtYul(amount0 * amount1);
        } else {
            shares = _min((amount0 * totalSupply()) / reserve0, (amount1 * totalSupply()) / reserve1);
        }

        require(shares > 0, "Shares = 0");
        _mint(msg.sender, shares);

        _update(TOKEN0.balanceOf(address(this)), TOKEN1.balanceOf(address(this)));
        emit AddLiquidity(msg.sender, amount0, amount1, shares);
    }

    function removeLiquidity(uint256 shares) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        uint256 bal0 = TOKEN0.balanceOf(address(this));
        uint256 bal1 = TOKEN1.balanceOf(address(this));

        amount0 = (shares * bal0) / totalSupply();
        amount1 = (shares * bal1) / totalSupply();
        require(amount0 > 0 && amount1 > 0, "Amount = 0");

        _burn(msg.sender, shares);
        _update(TOKEN0.balanceOf(address(this)) - amount0, TOKEN1.balanceOf(address(this)) - amount1);
        
        TOKEN0.safeTransfer(msg.sender, amount0);
        TOKEN1.safeTransfer(msg.sender, amount1);

        emit RemoveLiquidity(msg.sender, amount0, amount1, shares);
    }

    function _sqrtYul(uint256 y) internal pure returns (uint256 z) {
        assembly {
            switch y
            case 0 { z := 0 }
            case 1 { z := 1 }
            case 2 { z := 1 }
            case 3 { z := 1 }
            default {
                z := y
                let x := add(div(y, 2), 1)
                for { } lt(x, z) { } {
                    z := x
                    x := div(add(div(y, x), x), 2)
                }
            }
        }
    }

    function _min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x <= y ? x : y;
    }
}
