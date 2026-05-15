import React, { useState } from 'react';
import { BarChart3, Lock, ShieldCheck, Info, Loader2 } from 'lucide-react';
import { useWriteContract, useAccount } from 'wagmi';
import { parseEther } from 'viem';
import { YIELD_VAULT_ABI, ERC20_ABI } from '../abis';
import { CONTRACT_ADDRESSES } from '../contractAddresses';

const VaultComponent = () => {
  const [amount, setAmount] = useState('');
  const [isPending, setIsPending] = useState(false);
  const { address } = useAccount();
  const { writeContractAsync } = useWriteContract();

  const handleDeposit = async () => {
    if (!amount || isPending) return;
    setIsPending(true);
    try {
      const val = parseEther(amount);
      await writeContractAsync({
        address: CONTRACT_ADDRESSES.GovToken,
        abi: ERC20_ABI,
        functionName: 'approve',
        args: [CONTRACT_ADDRESSES.YieldVault, val],
      });
      await writeContractAsync({
        address: CONTRACT_ADDRESSES.YieldVault,
        abi: YIELD_VAULT_ABI,
        functionName: 'deposit',
        args: [val, address],
      });
      alert('Staking Successful!');
      setAmount('');
    } catch (err) {
      console.error(err);
      alert('Deposit Failed: ' + (err.shortMessage || 'Unknown error'));
    } finally {
      setIsPending(false);
    }
  };

  return (
    <div className="glass-panel" style={{ maxWidth: '560px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '20px', marginBottom: '40px' }}>
        <div style={{ background: 'linear-gradient(135deg, rgba(124, 58, 237, 0.3), rgba(59, 130, 246, 0.3))', padding: '16px', borderRadius: '16px', border: '1px solid rgba(255, 255, 255, 0.1)' }}>
          <BarChart3 size={28} color="#a78bfa" />
        </div>
        <div>
          <h2 style={{ fontSize: '24px', fontWeight: 900, letterSpacing: '-0.02em' }}>Yield Vault</h2>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
             <ShieldCheck size={12} color="#10b981" />
             <p style={{ fontSize: '10px', color: '#10b981', fontWeight: 800, textTransform: 'uppercase', letterSpacing: '0.1em' }}>Audited & Verified</p>
          </div>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '40px' }}>
        <div style={{ background: 'rgba(255, 255, 255, 0.03)', padding: '20px', borderRadius: '20px', border: '1px solid rgba(255, 255, 255, 0.05)' }}>
          <p style={{ fontSize: '10px', color: '#64748b', fontWeight: 800, textTransform: 'uppercase', marginBottom: '8px' }}>Projected APY</p>
          <p style={{ fontSize: '28px', fontWeight: 900, color: '#10b981' }}>12.42%</p>
        </div>
        <div style={{ background: 'rgba(255, 255, 255, 0.03)', padding: '20px', borderRadius: '20px', border: '1px solid rgba(255, 255, 255, 0.05)' }}>
          <p style={{ fontSize: '10px', color: '#64748b', fontWeight: 800, textTransform: 'uppercase', marginBottom: '8px' }}>Total TVL</p>
          <p style={{ fontSize: '28px', fontWeight: 900, color: '#a78bfa' }}>$1.28M</p>
        </div>
      </div>

      <div className="swap-input-group">
        <div className="swap-input-header">
          <span>STAKE AMOUNT</span>
          <span style={{ color: '#a78bfa', fontWeight: 800 }}>BAL: 5,420 PGT</span>
        </div>
        <input 
          type="number" 
          placeholder="0.00" 
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          className="swap-input"
          style={{ width: '100%' }}
          disabled={isPending}
        />
      </div>

      <div style={{ background: 'rgba(59, 130, 246, 0.05)', padding: '16px', borderRadius: '16px', marginTop: '24px', border: '1px solid rgba(59, 130, 246, 0.1)', display: 'flex', gap: '12px' }}>
         <Info size={18} color="#3b82f6" />
         <p style={{ fontSize: '12px', color: '#94a3b8', lineHeight: '1.4' }}>
            Assets are subject to a 24-hour withdrawal lock period for security.
         </p>
      </div>

      <button 
        onClick={handleDeposit} 
        className="btn-action" 
        disabled={!amount || isPending}
        style={{ 
            background: isPending ? 'rgba(255,255,255,0.05)' : '#7c3aed',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '10px',
            marginTop: '32px'
        }}
      >
        {isPending ? <Loader2 className="animate-spin" size={20} /> : <><Lock size={16} /> Stake PGT Assets</>}
      </button>
    </div>
  );
};

export default VaultComponent;
