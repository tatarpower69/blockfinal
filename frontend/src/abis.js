export const DEFI_AMM_ABI = [
  "function swap(address tokenInAddress, uint256 amountIn, uint256 minAmountOut) external returns (uint256)",
  "function addLiquidity(uint256 amount0, uint256 amount1) external returns (uint256)",
  "function removeLiquidity(uint256 shares) external returns (uint256, uint256)",
  "function fee() view returns (uint256)",
  "function reserve0() view returns (uint256)",
  "function reserve1() view returns (uint256)"
];

export const YIELD_VAULT_ABI = [
  "function deposit(uint256 assets, address receiver) external returns (uint256)",
  "function withdraw(uint256 assets, address receiver, address owner) external returns (uint256)",
  "function totalAssets() view returns (uint256)",
  "function asset() view returns (address)"
];

export const GOVERNOR_ABI = [
  "function propose(address[] targets, uint256[] values, bytes[] calldatas, string description) external returns (uint256)",
  "function castVote(uint256 proposalId, uint8 support) external returns (uint256)",
  "function queue(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) external",
  "function execute(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) external",
  "function state(uint256 proposalId) view returns (uint8)"
];

export const ERC20_ABI = [
  "function approve(address spender, uint256 amount) external returns (bool)",
  "function balanceOf(address account) view returns (uint256)",
  "function allowance(address owner, address spender) view returns (uint256)"
];
