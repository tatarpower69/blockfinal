# Project Architecture & Technical Specification

## 1. System Overview
The DeFi Super-App is a modular ecosystem on Arbitrum Sepolia consisting of a Constant Product AMM, a Yield-Optimized Vault, and a Governance DAO.

## 2. Component Breakdown

### 2.1 Core Contracts (Member A)
- **`DeFiAMM.sol`**: Custom AMM implementation. Uses `CREATE2` for deterministic pair deployment. Math is optimized with inline **Yul** for computing square roots to save gas during `mint` and `burn` operations.
- **`YieldVault.sol`**: An **ERC-4626** compliant vault. Uses **UUPS (Universal Upgradeable Proxy Standard)** to allow future strategy migrations. Managed via `AccessControl`.
- **`AMMFactory.sol`**: Registry and deployer for AMM pairs.
- **`OracleConsumer.sol`**: Integration with **Chainlink Data Feeds** on Arbitrum for real-time asset pricing.
- **`GovToken.sol`**: ERC20 token with `ERC20Votes` extension for snapshot-based governance.

### 2.2 Governance Flow (Member B - To be implemented)
- **`Governor.sol`**: OpenZeppelin-based governance contract.
- **`Timelock.sol`**: 2-day delay for all governance-approved actions.

## 3. Deployment Topology
- **Network**: Arbitrum Sepolia (L2)
- **Execution Environment**: EVM (Shanghai/Cancun ready)
- **Upgradeability**: Proxy-first approach for the Vault. Core AMM logic is immutable.

## 4. Key Security Patterns
1. **Checks-Effects-Interactions (CEI)**: Applied across all state-changing functions to prevent reentrancy.
2. **AccessControl**: Granular roles (ADMIN, STRATEGIST, UPGRADER) instead of a single `Ownable`.
3. **Dead-shares protection**: Initial liquidity burn in AMM to prevent inflation attacks.

## 5. Integration Guide for Member B
- **Subgraph**: Focus on `Swap`, `Mint`, and `Burn` events from Factory-deployed pairs.
- **Frontend**: Connect using `wagmi` / `rainbowkit`. Use `vYLT` (Vault) share price for ROI charts.
