// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DeFiAMM} from "./DeFiAMM.sol";

/**
 * @title AMMFactory
 * @dev Factory for deploying AMM pairs using both CREATE and CREATE2.
 * This satisfies the "Advanced Solidity" requirement from Lecture 1.
 */
contract AMMFactory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    /**
     * @dev Deploys a new AMM pair using CREATE2 for deterministic addressing.
     * @param tokenA Address of the first token.
     * @param tokenB Address of the second token.
     */
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "Identical tokens");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Zero address");
        require(getPair[token0][token1] == address(0), "Pair exists");

        // Using CREATE2
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        pair = address(new DeFiAMM{salt: salt}(token0, token1));

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // reverse mapping
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    /**
     * @dev Deploys an arbitrary contract using CREATE (via inline assembly).
     * This demonstrates the use of the CREATE opcode as required.
     * @param bytecode The contract creation bytecode.
     */
    function deployUtility(bytes memory bytecode) external returns (address addr) {
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(addr != address(0), "Create failed");
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }
}
