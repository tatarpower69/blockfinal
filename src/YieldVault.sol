// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC4626Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title YieldVault
 * @dev An upgradeable ERC-4626 vault that generates yield.
 * Uses UUPS proxy pattern for upgradeability.
 */
contract YieldVault is ERC4626Upgradeable, UUPSUpgradeable, OwnableUpgradeable {
    using SafeERC20 for IERC20;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializer for the upgradeable vault.
     * @param asset_ The underlying asset of the vault.
     * @param name_ Token name.
     * @param symbol_ Token symbol.
     */
    function initialize(IERC20 asset_, string memory name_, string memory symbol_) public initializer {
        __ERC4626_init(asset_);
        __ERC20_init(name_, symbol_);
        __Ownable_init(msg.sender);
    }

    /**
     * @dev Authorization function for UUPS upgrades.
     * Only the owner can upgrade the implementation.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Harvest yield or reinvest funds. (Placeholder for strategy logic).
     */
    function harvest() external onlyOwner {
        // Logic to reinvest or collect yield from external protocols
        // In a real scenario, this would interact with other DeFi protocols.
    }

    /**
     * @dev Override to ensure ERC-4626 rounding invariants.
     */
    function deposit(uint256 assets, address receiver) public override returns (uint256) {
        return super.deposit(assets, receiver);
    }
}
