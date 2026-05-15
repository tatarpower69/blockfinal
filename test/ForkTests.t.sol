// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {OracleConsumer} from "../src/OracleConsumer.sol";
import {YieldVault} from "../src/YieldVault.sol";

contract ForkTests is Test {
    OracleConsumer oracle;
    YieldVault vault;
    
    // Deployed addresses on Arbitrum Sepolia
    address constant ORACLE_CONSUMER = 0xAcE38F2587fFD46b44b132dCfb608D446A561589;
    address constant YIELD_VAULT_PROXY = 0x64178a180DA30EcA3F0b03674911cD33EB5933Ac;
    address constant AMM_FACTORY = 0x84DE709F2f2119aE18BA04c8096472e4a9366F6A;

    function setUp() public {
        vm.createSelectFork("https://arb-sepolia.g.alchemy.com/v2/FxE3GJ6xAKSF2lprZ9kE3");
        oracle = OracleConsumer(ORACLE_CONSUMER);
        vault = YieldVault(YIELD_VAULT_PROXY);
    }

    function testForkVaultState() public {
        string memory name = vault.name();
        assertEq(name, "Vault Yield Token");
    }

    function testForkGovTokenSupply() public {
        (bool success, bytes memory data) = 0x2d16DA4Df8CFB3A6962Aa28Dce9d0c6F089d6ac7.staticcall(abi.encodeWithSignature("totalSupply()"));
        assertTrue(success);
        uint256 supply = abi.decode(data, (uint256));
        assertGt(supply, 0);
    }

    function testForkAMMFactory() public {
        (bool success, bytes memory data) = AMM_FACTORY.staticcall(abi.encodeWithSignature("allPairsLength()"));
        assertTrue(success);
        uint256 length = abi.decode(data, (uint256));
        console.log("Total AMM Pairs on Fork:", length);
    }
}
