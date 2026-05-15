// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {GovToken} from "../src/GovToken.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

contract DeployGovernance is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address tokenAddress = 0x2d16DA4Df8CFB3A6962Aa28Dce9d0c6F089d6ac7; // Existing GovToken

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Timelock
        address[] memory proposers = new address[](1);
        proposers[0] = deployer; // In production, this would be the Governor
        address[] memory executors = new address[](1);
        executors[0] = address(0); // Anyone can execute

        TimelockController timelock = new TimelockController(
            1 days,
            proposers,
            executors,
            deployer
        );
        console2.log("Timelock deployed at:", address(timelock));

        // 2. Deploy Governor
        MyGovernor governor = new MyGovernor(IVotes(tokenAddress), timelock);
        console2.log("MyGovernor deployed at:", address(governor));

        // 3. Set Governor as proposer in Timelock
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));

        vm.stopBroadcast();
    }
}
