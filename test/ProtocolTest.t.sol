// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {GovToken} from "../src/GovToken.sol";
import {DeFiAMM} from "../src/DeFiAMM.sol";
import {YieldVault} from "../src/YieldVault.sol";
import {AMMFactory} from "../src/AMMFactory.sol";
import {OracleConsumer} from "../src/OracleConsumer.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @title ProtocolTest
 * @dev Integration tests for the core protocol components.
 */
contract ProtocolTest is Test {
    GovToken public token;
    AMMFactory public factory;
    OracleConsumer public oracle;
    MockV3Aggregator public aggregator;

    address public user = address(0x1);

    function setUp() public {
        vm.warp(1000000); // Avoid underflow in staleness checks
        // Deploy GovToken
        token = new GovToken();

        // Deploy Factory
        factory = new AMMFactory();

        // Deploy Oracle
        oracle = new OracleConsumer();

        // Deploy Mock Aggregator
        aggregator = new MockV3Aggregator(8, 2000e8); // Initial price $2000
    }

    /**
     * @dev Test GovToken deployment and voting power.
     */
    function testToken() public {
        uint256 supply = token.totalSupply();
        assertEq(supply, 100_000_000 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), supply);
    }

    /**
     * @dev Test AMM creation via Factory using CREATE2.
     */
    function testAMMDeployment() public {
        address tokenB = address(0x2);
        address pair = factory.createPair(address(token), tokenB);
        assertTrue(pair != address(0));

        // Check if deterministic address is stored
        assertEq(factory.getPair(address(token), tokenB), pair);
    }

    /**
     * @dev Test Oracle price retrieval and staleness check.
     */
    function testOraclePrice() public {
        int256 price = oracle.getLatestPrice(address(aggregator));
        assertEq(price, 2000e8);

        // Advance time to trigger staleness
        vm.warp(block.timestamp + 3601);
        vm.expectRevert(OracleConsumer.PriceStale.selector);
        oracle.getLatestPrice(address(aggregator));
    }

    /**
     * @dev Test Vault deployment and upgradeability (UUPS).
     */
    function testVaultUpgrade() public {
        YieldVault implementation = new YieldVault();
        bytes memory initData =
            abi.encodeWithSelector(YieldVault.initialize.selector, address(token), "Vault Shares", "vSHARES");

        // Deploy Proxy
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        YieldVault vault = YieldVault(address(proxy));

        assertEq(vault.name(), "Vault Shares");
        assertEq(vault.asset(), address(token));
    }
}
