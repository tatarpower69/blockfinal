// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeFiAMM} from "../src/DeFiAMM.sol";
import {MockToken} from "./mocks/MockToken.sol";

contract AMMUnitTests is Test {
    DeFiAMM amm;
    MockToken t0;
    MockToken t1;

    address user = address(0x1);

    function setUp() public {
        t0 = new MockToken("T0", "T0");
        t1 = new MockToken("T1", "T1");
        amm = new DeFiAMM(address(t0), address(t1));

        deal(address(t0), user, 1000e18);
        deal(address(t1), user, 1000e18);

        vm.startPrank(user);
        t0.approve(address(amm), type(uint256).max);
        t1.approve(address(amm), type(uint256).max);
        vm.stopPrank();
    }

    function testAddLiquidity() public {
        vm.prank(user);
        amm.addLiquidity(100e18, 100e18);
        assertEq(amm.reserve0(), 100e18);
        assertEq(amm.reserve1(), 100e18);
    }

    function testSwap() public {
        vm.startPrank(user);
        amm.addLiquidity(100e18, 100e18);
        uint256 out = amm.swap(address(t0), 10e18, 0);
        assertGt(out, 0);
        vm.stopPrank();
    }

    function testSetFeeRestriction() public {
        vm.prank(address(0xdead));
        vm.expectRevert();
        amm.setFee(5);
    }

    function testRemoveLiquidity() public {
        vm.startPrank(user);
        amm.addLiquidity(100e18, 100e18);
        uint256 shares = amm.balanceOf(user);
        amm.removeLiquidity(shares);
        vm.stopPrank();
        assertEq(amm.reserve0(), 0);
    }

    // Additional tests to reach 25+ unit tests
    function testInvalidTokenSwap() public {
        MockToken t2 = new MockToken("T2", "T2");
        vm.prank(user);
        vm.expectRevert("Invalid token");
        amm.swap(address(t2), 10e18, 0);
    }

    function testZeroAmountSwap() public {
        vm.prank(user);
        vm.expectRevert("Amount must be > 0");
        amm.swap(address(t0), 0, 0);
    }

    function testZeroSharesAddLiquidity() public {
        vm.prank(user);
        vm.expectRevert("Shares = 0");
        amm.addLiquidity(0, 0);
    }

    function testFeeTooHigh() public {
        vm.prank(amm.owner());
        vm.expectRevert("Fee too high");
        amm.setFee(11); // Max is 10
    }

    function testInitialReserves() public {
        assertEq(amm.reserve0(), 0);
        assertEq(amm.reserve1(), 0);
    }
}
