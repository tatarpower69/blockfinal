import React, { useState } from 'react';
import { Plus, Check, X, Clock, Users, Loader2 } from 'lucide-react';
import { useWriteContract, useAccount } from 'wagmi';
import { GOVERNOR_ABI } from '../abis';
import { CONTRACT_ADDRESSES } from '../contractAddresses';

const GovernanceComponent = () => {
  const { address } = useAccount();
  const { writeContractAsync } = useWriteContract();
  const [isPending, setIsPending] = useState(false);
  const [proposals] = useState([
    {
      id: "40699880860727658646212568515640768266380464520545636710223862719742623427710",
      title: "BIP-14: Increase Staking Yield for Governance Participants",
      status: "Active",
      votesFor: "12,450,000",
      votesAgainst: "1,204,500",
      deadline: "48h 12m left",
      proposer: "0x84d...e2f3"
    }
  ]);

  const handleVote = async (proposalId, support) => {
    if (isPending) return;
    setIsPending(true);
    try {
      await writeContractAsync({
        address: CONTRACT_ADDRESSES.Governor,
        abi: GOVERNOR_ABI,
        functionName: 'castVote',
        args: [BigInt(proposalId), support],
      });
      alert('Vote Cast Successfully!');
    } catch (err) {
      console.error(err);
      alert('Voting Failed: ' + (err.shortMessage || 'Unknown error'));
    } finally {
      setIsPending(false);
    }
  };

  return (
    <div style={{ width: '100%', maxWidth: '800px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '40px', padding: '0 8px' }}>
        <div>
          <h2 style={{ fontSize: '36px', fontWeight: 900, letterSpacing: '-0.04em' }}>Governance</h2>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginTop: '4px' }}>
             <Users size={14} color="#64748b" />
             <p style={{ fontSize: '12px', color: '#64748b', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.1em' }}>4,821 Voters Active</p>
          </div>
        </div>
        <button className="btn-connect" style={{ background: 'rgba(124, 58, 237, 0.1)', border: '1px solid rgba(124, 58, 237, 0.2)', color: '#a78bfa', padding: '12px 28px' }}>
          <Plus size={16} /> NEW PROPOSAL
        </button>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
        {proposals.map((proposal) => (
          <div key={proposal.id} className="glass-panel" style={{ padding: '40px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '24px', alignItems: 'center' }}>
              <div style={{ display: 'flex', gap: '12px' }}>
                <span style={{ background: 'rgba(16, 185, 129, 0.1)', color: '#10b981', border: '1px solid rgba(16, 185, 129, 0.2)', padding: '6px 16px', borderRadius: '10px', fontSize: '11px', fontWeight: 900, textTransform: 'uppercase' }}>
                    {proposal.status}
                </span>
                <span style={{ background: 'rgba(255, 255, 255, 0.05)', color: '#94a3b8', border: '1px solid rgba(255, 255, 255, 0.05)', padding: '6px 16px', borderRadius: '10px', fontSize: '11px', fontWeight: 600 }}>
                    Core
                </span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#64748b', fontSize: '13px', fontWeight: 500 }}>
                <Clock size={16} /> {proposal.deadline}
              </div>
            </div>

            <h3 style={{ fontSize: '26px', fontWeight: 800, marginBottom: '12px', lineHeight: '1.3' }}>{proposal.title}</h3>
            <p style={{ color: '#64748b', fontSize: '14px', marginBottom: '40px' }}>Proposed by {proposal.proposer}</p>

            <div style={{ marginBottom: '48px' }}>
              <div style={{ marginBottom: '32px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', fontWeight: 800, marginBottom: '10px' }}>
                  <span style={{ color: '#94a3b8', textTransform: 'uppercase' }}>Support (For)</span>
                  <span style={{ color: '#10b981' }}>{proposal.votesFor} PGT (91%)</span>
                </div>
                <div style={{ height: '10px', background: 'rgba(255, 255, 255, 0.05)', borderRadius: '5px', overflow: 'hidden' }}>
                  <div style={{ height: '100%', background: 'linear-gradient(90deg, #10b981, #34d399)', width: '91%', boxShadow: '0 0 15px rgba(16, 185, 129, 0.3)' }}></div>
                </div>
              </div>
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', fontWeight: 800, marginBottom: '10px' }}>
                  <span style={{ color: '#94a3b8', textTransform: 'uppercase' }}>Against</span>
                  <span style={{ color: '#ef4444' }}>{proposal.votesAgainst} PGT (9%)</span>
                </div>
                <div style={{ height: '100%', background: 'rgba(255, 255, 255, 0.05)', borderRadius: '5px', overflow: 'hidden', height: '10px' }}>
                  <div style={{ height: '100%', background: '#ef4444', width: '9%', boxShadow: '0 0 15px rgba(239, 68, 68, 0.3)' }}></div>
                </div>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '20px' }}>
              <button 
                onClick={() => handleVote(proposal.id, 1)}
                disabled={isPending}
                style={{ flex: 1, padding: '20px', background: 'rgba(16, 185, 129, 0.1)', border: '1px solid rgba(16, 185, 129, 0.2)', borderRadius: '16px', color: '#10b981', fontWeight: 800, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px', transition: 'all 0.2s' }}
              >
                {isPending ? <Loader2 className="animate-spin" size={20} /> : <><Check size={20} /> VOTE FOR</>}
              </button>
              <button 
                onClick={() => handleVote(proposal.id, 0)}
                disabled={isPending}
                style={{ flex: 1, padding: '20px', background: 'rgba(239, 68, 68, 0.1)', border: '1px solid rgba(239, 68, 68, 0.2)', borderRadius: '16px', color: '#ef4444', fontWeight: 800, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px', transition: 'all 0.2s' }}
              >
                {isPending ? <Loader2 className="animate-spin" size={20} /> : <><X size={20} /> VOTE AGAINST</>}
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default GovernanceComponent;
