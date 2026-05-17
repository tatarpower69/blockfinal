// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {
    AggregatorV3Interface
} from "chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title MockV3Aggregator
 * @dev Mock contract for Chainlink Price Feeds to be used in tests.
 */
contract MockV3Aggregator is AggregatorV3Interface {
    string public override description = "Mock V3 Aggregator";
    uint8 public override decimals;
    uint256 public override version = 1;

    int256 private _latestAnswer;
    uint256 private _updatedAt;

    constructor(uint8 _decimals, int256 _initialAnswer) {
        decimals = _decimals;
        _latestAnswer = _initialAnswer;
        _updatedAt = block.timestamp;
    }

    function updateAnswer(int256 _answer) public {
        _latestAnswer = _answer;
        _updatedAt = block.timestamp;
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (1, _latestAnswer, _updatedAt, _updatedAt, 1);
    }

    function getRoundData(uint80)
        external
        pure
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (0, 0, 0, 0, 0);
    }
}
