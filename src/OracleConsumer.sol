// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {
    AggregatorV3Interface
} from "chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title OracleConsumer
 * @dev Integration with Chainlink Price Feeds with staleness checks.
 * Satisfies the Oracles requirement (Lecture 8).
 */
contract OracleConsumer {
    error PriceStale();
    error PriceNegative();

    uint256 public constant STALENESS_THRESHOLD = 3600; // 1 hour

    /**
     * @dev Get the latest price from a Chainlink feed with safety checks.
     * @param priceFeed The address of the Chainlink price feed.
     */
    function getLatestPrice(address priceFeed) public view returns (int256) {
        (uint80 roundId, int256 price,/* uint256 startedAt */, uint256 updatedAt, uint80 answeredInRound) =
            AggregatorV3Interface(priceFeed).latestRoundData();

        // Staleness check: revert if price is older than 1 hour
        if (updatedAt < block.timestamp - STALENESS_THRESHOLD) revert PriceStale();

        // Ensure price is positive
        if (price <= 0) revert PriceNegative();

        // Check for round completeness
        if (answeredInRound < roundId) revert PriceStale();

        return price;
    }
}
