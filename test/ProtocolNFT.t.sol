// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ProtocolNFT} from "../src/ProtocolNFT.sol";

contract ProtocolNFTTest is Test {
    ProtocolNFT nft;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);

    function setUp() public {
        vm.prank(owner);
        nft = new ProtocolNFT(owner);
    }

    function testInitialState() public {
        assertEq(nft.name(), "Protocol Membership");
        assertEq(nft.symbol(), "PMB");
        assertEq(nft.owner(), owner);
    }

    function testMinting() public {
        vm.prank(owner);
        nft.safeMint(user1);
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.ownerOf(0), user1);
    }

    function testMultipleMinting() public {
        vm.startPrank(owner);
        nft.safeMint(user1);
        nft.safeMint(user2);
        vm.stopPrank();
        
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.balanceOf(user2), 1);
        assertEq(nft.ownerOf(0), user1);
        assertEq(nft.ownerOf(1), user2);
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(user1);
        vm.expectRevert(); // OwnableUnauthorizedAccount
        nft.safeMint(user1);
    }

    function testTransfer() public {
        vm.prank(owner);
        nft.safeMint(user1);
        
        vm.prank(user1);
        nft.safeTransferFrom(user1, user2, 0);
        
        assertEq(nft.ownerOf(0), user2);
        assertEq(nft.balanceOf(user1), 0);
        assertEq(nft.balanceOf(user2), 1);
    }

    function testApproval() public {
        vm.prank(owner);
        nft.safeMint(user1);
        
        vm.prank(user1);
        nft.approve(user2, 0);
        
        assertEq(nft.getApproved(0), user2);
        
        vm.prank(user2);
        nft.safeTransferFrom(user1, user2, 0);
        assertEq(nft.ownerOf(0), user2);
    }
}
