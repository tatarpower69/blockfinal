// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {GovToken} from "../src/GovToken.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

contract DeployGovernance is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = 0x2d16DA4Df8CFB3A6962Aa28Dce9d0c6F089d6ac7; // Existing GovToken

        vm.startBroadcast(deployerPrivateKey);

        MyGovernor governor = new MyGovernor(IVotes(tokenAddress));
        console2.log("MyGovernor deployed at:", address(governor));

        vm.stopBroadcast();
    }
}
