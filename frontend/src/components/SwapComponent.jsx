import React, { useState } from 'react';
import { RefreshCw, Settings, ChevronDown, ArrowDownUp, Check, Loader2 } from 'lucide-react';
import { useWriteContract, useAccount } from 'wagmi';
import { parseEther } from 'viem';
import { DEFI_AMM_ABI, ERC20_ABI } from '../abis';
import { CONTRACT_ADDRESSES } from '../contractAddresses';

const SwapComponent = () => {
  const [amount, setAmount] = useState('');
  const [isPending, setIsPending] = useState(false);
  const [isFlipped, setIsFlipped] = useState(false);
  const { address } = useAccount();
  const { writeContractAsync } = useWriteContract();

  const tokenIn = isFlipped ? 'USDC' : 'PGT';
  const tokenOut = isFlipped ? 'PGT' : 'USDC';
  const balanceIn = isFlipped ? '12,450.20' : '2,481.00';
  const balanceOut = isFlipped ? '2,481.00' : '12,450.20';

  const handleFlip = () => {
    setIsFlipped(!isFlipped);
    setAmount('');
  };

  const handleSwap = async () => {
    if (!amount || isPending) return;
    setIsPending(true);
    try {
      const val = parseEther(amount);
      const tokenAddress = isFlipped ? CONTRACT_ADDRESSES.USDC : CONTRACT_ADDRESSES.GovToken; 
      
      await writeContractAsync({
        address: tokenAddress,
        abi: ERC20_ABI,
        functionName: 'approve',
        args: [CONTRACT_ADDRESSES.AMMFactory, val],
      });
      
      await writeContractAsync({
        address: CONTRACT_ADDRESSES.AMMFactory,
        abi: DEFI_AMM_ABI,
        functionName: 'swap',
        args: [tokenAddress, val, 0],
      });
      
      alert('Swap Successful!');
      setAmount('');
    } catch (err) {
      console.error(err);
      alert('Transaction Failed');
    } finally {
      setIsPending(false);
    }
  };

  return (
    <div className="glass-panel float-anim">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
        <h2 style={{ fontSize: '18px', fontWeight: 900, letterSpacing: '0.05em' }}>SWAP</h2>
        <div style={{ display: 'flex', gap: '12px' }}>
          <RefreshCw size={18} color="#64748b" className={isPending ? 'animate-spin' : ''} style={{ cursor: 'pointer' }} />
          <Settings size={18} color="#64748b" style={{ cursor: 'pointer' }} />
        </div>
      </div>

      <div className="swap-input-group">
        <div className="swap-input-header">
          <span>YOU PAY</span>
          <span style={{ color: '#a78bfa', cursor: 'pointer' }}>MAX</span>
        </div>
        <div className="input-row">
          <input
            type="number"
            placeholder="0.0"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className="swap-input"
            disabled={isPending}
          />
          <div className="token-select" onClick={handleFlip} style={{ cursor: 'pointer' }}>
            <div className="token-icon" style={{ background: isFlipped ? '#3b82f6' : 'linear-gradient(45deg, #7c3aed, #3b82f6)' }}></div>
            <span>{tokenIn}</span>
            <ChevronDown size={14} color="#64748b" />
          </div>
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '16px', fontSize: '11px', color: '#64748b', fontWeight: 600 }}>
          <span>≈ ${amount ? (Number(amount) * (isFlipped ? 1 : 3842)).toLocaleString() : '0.00'}</span>
          <span>Balance: {balanceIn}</span>
        </div>
      </div>

      <div className="swap-divider">
        <button className="btn-swap-arrow" onClick={handleFlip} style={{ transform: isPending ? 'rotate(180deg)' : 'none', transition: 'all 0.5s' }}>
          <ArrowDownUp size={18} color="#a78bfa" />
        </button>
      </div>

      <div className="swap-input-group">
        <div className="swap-input-header">
          <span>YOU RECEIVE</span>
        </div>
        <div className="input-row">
          <input
            type="number"
            placeholder="0.0"
            readOnly
            value={amount ? (Number(amount) * (isFlipped ? 1/3842 : 3842) * 0.995).toFixed(6) : ''}
            className="swap-input"
            style={{ color: '#94a3b8' }}
          />
          <div className="token-select" onClick={handleFlip} style={{ cursor: 'pointer' }}>
            <div className="token-icon" style={{ background: isFlipped ? 'linear-gradient(45deg, #7c3aed, #3b82f6)' : '#3b82f6' }}></div>
            <span>{tokenOut}</span>
            <ChevronDown size={14} color="#64748b" />
          </div>
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '16px', fontSize: '11px', color: '#64748b', fontWeight: 600 }}>
          <span>≈ ${amount ? (Number(amount) * (isFlipped ? 1 : 3842) * 0.995).toLocaleString() : '0.00'}</span>
          <span>Balance: {balanceOut}</span>
        </div>
      </div>

      <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '24px', fontSize: '11px', fontWeight: 700, padding: '0 4px' }}>
        <span style={{ color: '#64748b' }}>Slippage Tolerance: <span style={{ color: '#a78bfa' }}>0.5%</span></span>
        <div style={{ color: '#10b981', textTransform: 'uppercase', display: 'flex', alignItems: 'center', gap: '4px' }}>
          Best route <Check size={12} />
        </div>
      </div>

      <button 
        onClick={handleSwap} 
        className="btn-action" 
        disabled={!amount || isPending}
        style={{ 
            background: isPending ? 'rgba(255,255,255,0.05)' : 'var(--primary)',
            color: isPending ? '#64748b' : 'white',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px'
        }}
      >
        {isPending ? <Loader2 className="animate-spin" size={20} /> : 'Swap Tokens'}
      </button>
    </div>
  );
};

export default SwapComponent;
