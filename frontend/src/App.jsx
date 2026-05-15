import React, { useState } from 'react';
import { createConfig, http, WagmiProvider, useConnect, useAccount, useDisconnect, useSwitchChain } from 'wagmi';
import { arbitrumSepolia } from 'wagmi/chains';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Wallet, ShieldCheck, Zap, Globe, Activity, TrendingUp, LogOut } from 'lucide-react';
import SwapComponent from './components/SwapComponent';
import VaultComponent from './components/VaultComponent';
import GovernanceComponent from './components/GovernanceComponent';

const queryClient = new QueryClient();

const config = createConfig({
  chains: [arbitrumSepolia],
  transports: {
    [arbitrumSepolia.id]: http('https://arb-sepolia.g.alchemy.com/v2/FxE3GJ6xAKSF2lprZ9kE3'),
  },
});

function Dashboard() {
  const [activeTab, setActiveTab] = useState('swap');
  const { address, isConnected } = useAccount();
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();

  const handleConnect = () => {
    if (connectors[0]) {
      connect({ connector: connectors[0] });
    } else {
      alert("No wallet found. Please install MetaMask.");
    }
  };

  return (
    <div className="app-root">
      <div className="mesh-bg"></div>

      <nav className="navbar">
        <div className="nav-logo">
          <div className="logo-icon">
            <ShieldCheck size={24} color="white" />
          </div>
          <span className="logo-text" style={{ fontSize: '20px', fontWeight: 900, letterSpacing: '-0.02em' }}>BLOCKFINAL</span>
        </div>

        <div className="nav-links">
          {['swap', 'vault', 'governance'].map((tab) => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`btn-nav ${activeTab === tab ? 'active' : ''}`}
            >
              {tab.toUpperCase()}
            </button>
          ))}
        </div>

        <div className="nav-actions">
          {isConnected ? (
            <div style={{ display: 'flex', gap: '8px' }}>
              <button className="btn-nav active" style={{ borderColor: 'rgba(16, 185, 129, 0.3)', color: '#10b981' }}>
                {address?.slice(0, 6)}...{address?.slice(-4)}
              </button>
              <button onClick={() => disconnect()} className="btn-nav" style={{ padding: '8px' }}>
                <LogOut size={16} />
              </button>
            </div>
          ) : (
            <button
              onClick={handleConnect}
              className="btn-connect"
            >
              <Wallet size={16} />
              CONNECT
            </button>
          )}
        </div>
      </nav>

      <div className="ticker-bar">
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <div className="status-dot"></div>
          <span style={{ letterSpacing: '0.05em' }}>ARBITRUM SEPOLIA ACTIVE</span>
        </div>
        <div style={{ display: 'flex', gap: '40px' }}>
          <span>ETH/USD: $3,842.10</span>
          <span>GAS: 12 GWEI</span>
          <span style={{ color: '#10b981', display: 'flex', alignItems: 'center', gap: '4px' }}>
            <TrendingUp size={12} /> +2.45%
          </span>
        </div>
      </div>

      <main className="main-container">
        <div className="content-left">
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#a78bfa', fontSize: '12px', fontWeight: 800, marginBottom: '16px', textTransform: 'uppercase', letterSpacing: '0.2em' }}>
             <Zap size={14} fill="#a78bfa" /> Protocol Statistics
          </div>
          <h1 className="hero-title">
            The Future of <br />
            <span>DAO & DeFi</span>
          </h1>
          <p className="hero-desc">
            Experience hyper-efficient swaps and automated yield strategies on the most advanced L2 governance framework.
          </p>

          <div className="stats-grid">
            <div className="stat-item">
              <p className="stat-value">$2.4B</p>
              <p className="stat-label">TVL Locked</p>
            </div>
            <div className="stat-item">
              <p className="stat-value">48.2K</p>
              <p className="stat-label">Total Users</p>
            </div>
            <div className="stat-item">
              <p className="stat-value">0.05%</p>
              <p className="stat-label">L2 Fees</p>
            </div>
          </div>
        </div>

        <div className="widget-container">
          {!isConnected && activeTab !== 'governance' && (
             <div className="glass-panel" style={{ textAlign: 'center', padding: '60px 40px' }}>
                <Wallet size={48} color="#64748b" style={{ marginBottom: '24px' }} />
                <h3 style={{ fontSize: '20px', fontWeight: 800, marginBottom: '12px' }}>Wallet Disconnected</h3>
                <p style={{ color: '#64748b', fontSize: '14px', marginBottom: '32px' }}>Please connect your wallet to interact with the protocol.</p>
                <button onClick={handleConnect} className="btn-action" style={{ background: '#7c3aed' }}>Connect Now</button>
             </div>
          )}
          
          {isConnected && (
            <>
              {activeTab === 'swap' && <SwapComponent />}
              {activeTab === 'vault' && <VaultComponent />}
              {activeTab === 'governance' && <GovernanceComponent />}
            </>
          )}

          {!isConnected && activeTab === 'governance' && (
             <div className="glass-panel" style={{ opacity: 0.8 }}>
                <p style={{ color: '#64748b', fontSize: '12px', textAlign: 'center' }}>Connect wallet to see proposals</p>
             </div>
          )}
        </div>
      </main>

      <footer className="footer">
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <div className="status-dot"></div>
          <span style={{ textTransform: 'uppercase', letterSpacing: '0.1em' }}>All Systems Operational</span>
        </div>
        <div>© 2026 BLOCKFINAL LABS</div>
        <div style={{ color: '#a78bfa' }}>Arbitrum L2 • 421614</div>
      </footer>
    </div>
  );
}

function App() {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <Dashboard />
      </QueryClientProvider>
    </WagmiProvider>
  );
}

export default App;
