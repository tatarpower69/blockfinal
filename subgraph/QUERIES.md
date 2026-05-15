# Protocol Subgraph Queries

To use these queries, navigate to your subgraph playground (e.g., hosted service or local graph-node) and paste the following:

## 1. Get Latest 10 Swaps
Fetches the most recent swap events with user and amount details.
```graphql
{
  swaps(first: 10, orderBy: timestamp, orderDirection: desc) {
    id
    user
    tokenIn
    amountIn
    amountOut
    timestamp
  }
}
```

## 2. Get Liquidity Positions by User
Retrieve all LP positions for a specific wallet address.
```graphql
{
  liquidityPositions(where: {user: "0xYOUR_ADDRESS_HERE"}) {
    id
    pair
    shares
    token0Amount
    token1Amount
  }
}
```

## 3. Vault Yield Statistics
Get the historical yield data from the Yield Vault.
```graphql
{
  vaultYields(first: 5, orderBy: timestamp, orderDirection: desc) {
    id
    vault
    totalAssets
    sharePrice
    timestamp
  }
}
```

## 4. Search for High Value Swaps
Find swaps where the amountIn is greater than a certain threshold.
```graphql
{
  swaps(where: {amountIn_gt: "1000000000000000000"}) {
    id
    user
    amountIn
    transactionHash
  }
}
```

## 5. Protocol Overview
Get the total number of pairs and overall liquidity metadata.
```graphql
{
  liquidityPositions(first: 100) {
    pair
    shares
    timestamp
  }
}
```
