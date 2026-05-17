# Project Architecture & Technical Specification

## 1. System Overview (C4 Level 1)
The DeFi Super-App is a modular ecosystem on Arbitrum Sepolia consisting of a Constant Product AMM, a Yield-Optimized Vault, and a Governance DAO.

```mermaid
graph TD
    User([User/Voter]) -->|Swaps, LPs| AMM[DeFi AMM]
    User -->|Stakes| Vault[Yield Vault]
    User -->|Proposes/Votes| Gov[Governor DAO]
    Gov -->|Executes via Timelock| AMM
    Gov -->|Executes via Timelock| Vault
    Oracle[Chainlink Oracle] -->|Price Feeds| AMM
    Oracle -->|Price Feeds| Vault
```

## 2. Component Breakdown (C4 Level 2)

```mermaid
graph TD
    UI[Frontend React App] -->|Ethers.js / Wagmi| Proxy[UUPS Proxy]
    Proxy -->|Delegates| Impl[YieldVault V1]
    UI -->|Queries| Subgraph[The Graph Node]
    Impl -->|Reads| Token[GovToken ERC20Votes]
    UI -->|Calls| Factory[AMM Factory]
    Factory -->|Deploys CREATE2| Pair[AMM Pair]
```

## 3. Sequence Diagrams

### 3.1 Swap Execution
```mermaid
sequenceDiagram
    participant User
    participant Router
    participant Pair
    User->>Router: swapExactTokensForTokens()
    Router->>Pair: transfer tokenIn
    Router->>Pair: swap()
    Pair->>Pair: check K invariant (Yul optimized)
    Pair->>User: transfer tokenOut
```

### 3.2 Governance Lifecycle
```mermaid
sequenceDiagram
    participant Proposer
    participant Governor
    participant Timelock
    Proposer->>Governor: propose(targets, values, calldatas)
    Governor->>Governor: state = Pending
    loop Voting Period (1 week)
        Voters->>Governor: castVote()
    end
    Proposer->>Governor: queue()
    Governor->>Timelock: queueTransaction()
    loop Timelock Delay (2 days)
        Timelock->>Timelock: wait
    end
    Proposer->>Governor: execute()
    Timelock->>TargetContract: call()
```

## 4. Data Model & Storage Layout

### YieldVault (UUPS) Storage
To prevent storage collisions during upgrades, `YieldVault` utilizes the standard ERC-4626 storage variables appended to OpenZeppelin's upgradeable storage gaps.
- `slot 0`: `_initialized` and `_initializing` (Initializable)
- `slot 1-50`: `__gap` for base contracts.
- `slot 51`: `asset` address.

**Rule**: New variables in V2 MUST be added after the existing variables.

## 5. Trust Assumptions
- **TimelockController**: Holds the ultimate authority. Compromise of the Timelock means complete protocol takeover. Delay is set to 2 days to allow users to exit if a malicious proposal passes.
- **Admin Roles**: Factory owner can pause new pair creation but cannot freeze existing pairs.
- **Oracle Risk**: Relies on Chainlink. If Chainlink nodes go offline, the staleness check will revert transactions, halting protocol functions that rely on price discovery, rather than allowing trades at bad prices.

## 6. Architectural Decision Records (ADR)

### ADR 1: UUPS vs Transparent Proxy
- **Context**: Need upgradeability for YieldVault.
- **Decision**: UUPS.
- **Consequences**: Cheaper deployments, upgrade logic is inside the implementation, reducing proxy overhead.

### ADR 2: Yul for AMM Math
- **Context**: AMM square root calculations for LP shares are gas-heavy.
- **Decision**: Inline Yul assembly for `sqrt`.
- **Consequences**: Harder to read, but saves ~2000 gas per mint/burn.

### ADR 3: Foundry vs Hardhat
- **Context**: Testing framework selection.
- **Decision**: Foundry.
- **Consequences**: Fuzzing and Invariant testing built-in, native Solidity tests, 10x faster execution.
