# BlockFinal DeFi Ecosystem

A comprehensive decentralized finance and governance ecosystem deployed on Arbitrum Sepolia. The project consists of a core Automated Market Maker (AMM), a Yield Vault, an ERC-721 Token (Protocol NFT), and a full-fledged DAO Governance system.

## Project Structure & Responsibilities

The project development was divided between two team members, strictly following the architectural and security requirements.

### 👤 Member 1 (Smart Contracts & Security)
- **Core Contracts**: `DeFiAMM.sol`, `YieldVault.sol` (ERC-4626), `AMMFactory.sol`.
- **Oracles**: Chainlink Price Feed integration (`OracleConsumer.sol`) with staleness checks.
- **Advanced Solidity**: Implementation of UUPS Proxy pattern, `CREATE2` factory deployment, and inline Yul assembly for gas optimizations.
- **Security**: Implementation of CEI patterns, Reentrancy guards, and access control.
- **Auditing**: Produced the security audit report and performed Slither static analysis.

### 👤 Member 2 (Governance, Frontend & DevOps)
- **Governance System**: 
  - Deployed `MyGovernor.sol` and `TimelockController.sol`.
  - Integrated `ERC20Votes` into the governance token.
  - Built the full on-chain voting cycle (Propose → Vote → Queue → Execute).
- **Frontend Dashboard**:
  - Developed a high-fidelity React + Wagmi application with a Vanilla CSS design system.
  - Implemented secure wallet connection and transaction lifecycle handling.
  - Built out the UI for Token Swaps, Vault Staking, and active Governance Voting.
- **The Graph**:
  - Configured `subgraph.yaml` and defined GraphQL schemas for tracking protocol events.
- **Tokens**: Developed and tested the `ProtocolNFT.sol` (ERC-721) contract.
- **DevOps**: 
  - Configured GitHub Actions CI pipeline (Compile, Test, Coverage, Slither).
  - Enforced code formatting via Git pre-commit hooks (`forge fmt`).

## Testing

The project holds a **100% success rate across 29 tests**, exceeding the required threshold.

- **Unit Tests**: 21 tests covering all core primitives.
- **Fuzz Tests**: 5 tests validating boundaries on the AMM and Vault.
- **Fork Tests**: 3 tests simulating interactions on Arbitrum Sepolia.

To run the test suite:
```shell
$ forge test -vvv
```

## Setup & Deployment

### Build
```shell
$ forge build
```

### Format
```shell
$ forge fmt
```

### Slither Analysis
```shell
$ slither .
```
Project run succesful
