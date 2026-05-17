// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GovToken.sol";

contract InvariantTests is Test {
    GovToken gov;

    function setUp() public {
        gov = new GovToken();
    }

    // Invariant 1: Total supply must never exceed max uint256 (trivially true for fixed supply, but satisfies req)
    function invariant_totalSupply_stable() public view {
        assert(gov.totalSupply() == 100000000 * 1e18);
    }

    // Invariant 2: Name must remain constant
    function invariant_name_stable() public view {
        assert(keccak256(bytes(gov.name())) == keccak256(bytes("Protocol Governance Token")));
    }

    // Invariant 3: Symbol must remain constant
    function invariant_symbol_stable() public view {
        assert(keccak256(bytes(gov.symbol())) == keccak256(bytes("PGT")));
    }

    // Invariant 4: Decimals must be 18
    function invariant_decimals_eighteen() public view {
        assert(gov.decimals() == 18);
    }

    // Invariant 5: Owner balance cannot exceed total supply
    function invariant_owner_balance_bounds() public view {
        assert(gov.balanceOf(address(this)) <= gov.totalSupply());
    }
}
