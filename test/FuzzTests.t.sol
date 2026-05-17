// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeFiAMM} from "../src/DeFiAMM.sol";
import {GovToken} from "../src/GovToken.sol";
import {YieldVault} from "../src/YieldVault.sol";
import {ProtocolNFT} from "../src/ProtocolNFT.sol";
import {MockToken} from "./mocks/MockToken.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract FuzzTests is Test {
    DeFiAMM amm;
    GovToken token;
    YieldVault vault;
    ProtocolNFT nft;

    address user = address(0x123);

    function setUp() public {
        token = new GovToken();
        GovToken token2 = new GovToken();
        amm = new DeFiAMM(address(token), address(token2));
        nft = new ProtocolNFT(address(this));

        YieldVault implementation = new YieldVault();
        bytes memory initData = abi.encodeWithSelector(YieldVault.initialize.selector, address(token), "Vault", "VLT");
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        vault = YieldVault(address(proxy));

        token.transfer(user, 1000000e18);
        vm.startPrank(user);
        token.approve(address(vault), type(uint256).max);
        vm.stopPrank();
    }

    function testFuzzVaultDeposit(uint256 amount) public {
        vm.assume(amount > 1e15 && amount < 1000e18);

        vm.prank(user);
        uint256 shares = vault.deposit(amount, user);
        assertGt(shares, 0);
        assertEq(vault.balanceOf(user), shares);
    }

    function testFuzzAMMFee(uint256 newFee) public {
        vm.assume(newFee <= 10);
        amm.setFee(newFee);
        assertEq(amm.fee(), newFee);
    }

    function testFuzzNFTMint(address to) public {
        vm.assume(to != address(0) && to != address(this));
        nft.safeMint(to);
        assertEq(nft.balanceOf(to), 1);
    }

    function testFuzzGovDelegation(uint256 amount) public {
        vm.assume(amount > 0 && amount <= token.balanceOf(address(this)));
        address randomVoter = address(0xABC);
        token.transfer(randomVoter, amount);

        vm.prank(randomVoter);
        token.delegate(randomVoter);

        assertEq(token.getVotes(randomVoter), amount);
    }

    function testFuzzAMMAddLiquidity(uint256 amount0, uint256 amount1) public {
        amount0 = bound(amount0, 1e18, 1000e18);
        amount1 = bound(amount1, 1e18, 1000e18);

        MockToken t0 = new MockToken("T0", "T0");
        MockToken t1 = new MockToken("T1", "T1");
        DeFiAMM localAmm = new DeFiAMM(address(t0), address(t1));

        t0.approve(address(localAmm), amount0);
        t1.approve(address(localAmm), amount1);

        uint256 shares = localAmm.addLiquidity(amount0, amount1);
        assertGt(shares, 0);
    }
}
