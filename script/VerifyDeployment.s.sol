// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {MyGovernor} from "../src/MyGovernor.sol";

contract VerifyDeployment is Script {
    function run() external view {
        // Example addresses - in a real scenario, these would be passed via env vars
        address timelockAddr = vm.envOr("TIMELOCK_ADDRESS", address(0));
        address governorAddr = vm.envOr("GOVERNOR_ADDRESS", address(0));

        if (timelockAddr == address(0) || governorAddr == address(0)) {
            console2.log("Skipping verification: TIMELOCK_ADDRESS or GOVERNOR_ADDRESS not set.");
            return;
        }

        TimelockController timelock = TimelockController(payable(timelockAddr));
        MyGovernor governor = MyGovernor(payable(governorAddr));

        // 1. Check Timelock Delay
        uint256 delay = timelock.getMinDelay();
        console2.log("Timelock Delay:", delay);
        require(delay == 1 days, "Timelock delay is not 1 day");

        // 2. Check Governor Parameters
        console2.log("Voting Delay:", governor.votingDelay());
        require(governor.votingDelay() == 1 days, "Voting delay incorrect");

        console2.log("Voting Period:", governor.votingPeriod());
        require(governor.votingPeriod() == 1 weeks, "Voting period incorrect");

        // 3. Verify Proposer Role
        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bool isProposer = timelock.hasRole(proposerRole, governorAddr);
        console2.log("Governor has PROPOSER_ROLE:", isProposer);
        require(isProposer, "Governor cannot propose");

        console2.log("Verification Passed! System is secure.");
    }
}
