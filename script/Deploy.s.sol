// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {GovToken} from "../src/GovToken.sol";
import {AMMFactory} from "../src/AMMFactory.sol";
import {YieldVault} from "../src/YieldVault.sol";
import {OracleConsumer} from "../src/OracleConsumer.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @title DeployProtocol
 * @dev Deployment script for Arbitrum Sepolia.
 */
contract DeployProtocol is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Governance Token
        GovToken govToken = new GovToken();
        console2.log("GovToken deployed at:", address(govToken));

        // 2. Deploy AMM Factory
        AMMFactory factory = new AMMFactory();
        console2.log("AMMFactory deployed at:", address(factory));

        // 3. Deploy Oracle Consumer (using mock or real feed address)
        // For Arbitrum Sepolia ETH/USD feed: 0xd3062148e75917A4000d273bC51aA95610eCd2C3
        OracleConsumer oracle = new OracleConsumer();
        console2.log("OracleConsumer deployed at:", address(oracle));

        // 4. Deploy YieldVault (UUPS Proxy)
        YieldVault implementation = new YieldVault();
        console2.log("YieldVault Implementation deployed at:", address(implementation));

        bytes memory initData =
            abi.encodeWithSelector(YieldVault.initialize.selector, address(govToken), "Vault Yield Token", "vYLT");
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        console2.log("YieldVault Proxy deployed at:", address(proxy));

        vm.stopBroadcast();
    }
}
