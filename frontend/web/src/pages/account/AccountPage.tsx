import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Link, useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../app/store/authStore';
import { toast } from '../../app/store/toastStore';
import { zimbiteApi } from '../../services/zimbiteApi';
import { AddressPickerMap, type AddressResult } from '../../components/AddressPickerMap';

const QUICK_LINKS = [
  { icon: '📋', label: 'My Orders',        to: '/orders',      desc: 'Track and view past orders' },
  { icon: '🍳', label: 'Meal Builder',     to: '/meal-builder', desc: 'Build a custom breakfast' },
  { icon: '🔔', label: 'Subscriptions',   to: '/vendors',      desc: 'Manage meal plans' },
  { icon: '🏪', label: 'Browse Vendors',  to: '/vendors',      desc: 'Discover breakfast spots' }
];

export function AccountPage() {
  const { userId, role, token, clearSession } = useAuthStore();
  const navigate  = useNavigate();
  const qc        = useQueryClient();
  const [showMap, setShowMap] = useState(false);

  const { data: addresses, isLoading: addressesLoading } = useQuery({
    queryKey: ['addresses'],
    queryFn:  zimbiteApi.listAddresses,
    enabled:  !!userId
  });

  const addAddressMutation = useMutation({
    mutationFn: zimbiteApi.addAddress,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['addresses'] });
      setShowMap(false);
      toast.success('Address saved!', 'Your delivery address has been added.');
    },
    onError: () => {
      toast.error('Failed to save address', 'Please check your connection and try again.');
    }
  });

  function handleAddressResult(result: AddressResult) {
    addAddressMutation.mutate(result);
  }

  function handleSignOut() {
    clearSession();
    toast.show('Signed out', 'Come back tomorrow at 5AM!');
    navigate('/auth/login');
  }

  if (!userId) {
    return (
      <div className="empty-state">
        <div className="empty-state-icon">🔑</div>
        <p className="empty-state-title">Not signed in</p>
        <p className="empty-state-desc">Sign in to manage your account, view orders, and more.</p>
        <Link to="/auth/login" className="btn-primary">Sign In</Link>
      </div>
    );
  }

  return (
    <>
      {showMap && (
        <AddressPickerMap
          onSave={handleAddressResult}
          onClose={() => setShowMap(false)}
        />
      )}

      <div className="section-header">
        <p className="section-eyebrow">Your profile</p>
        <h1 className="section-title">Account</h1>
      </div>

      <div style={{ display: 'grid', gap: 'var(--space-5)', gridTemplateColumns: 'repeat(auto-fit, minmax(340px, 1fr))', alignItems: 'start' }}>
        {/* ── Profile card ────────────────────────────────────── */}
        <div className="panel">
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 'var(--space-4)',
              marginBottom: 'var(--space-6)'
            }}
          >
            <div
              style={{
                width: 56,
                height: 56,
                background: 'var(--brand)',
                borderRadius: '50%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '1.4rem',
                color: '#fff',
                fontWeight: 700,
                flexShrink: 0
              }}
            >
              {userId.slice(0, 1).toUpperCase()}
            </div>
            <div>
              <p style={{ fontWeight: 700, fontSize: '1.05rem' }}>
                {userId.length > 20 ? userId.slice(0, 20) + '…' : userId}
              </p>
              <span className="badge badge-brand" style={{ marginTop: 4 }}>
                {role ?? 'CUSTOMER'}
              </span>
            </div>
          </div>

          <div style={{ display: 'grid', gap: 'var(--space-3)', marginBottom: 'var(--space-6)' }}>
            <div
              style={{
                background: 'var(--surface-3)',
                borderRadius: 'var(--radius-md)',
                padding: 'var(--space-3) var(--space-4)',
                fontSize: '0.85rem'
              }}
            >
              <p className="text-muted text-xs" style={{ marginBottom: 2 }}>User ID</p>
              <p style={{ fontFamily: 'monospace', fontSize: '0.8rem', wordBreak: 'break-all' }}>{userId}</p>
            </div>
            <div
              style={{
                background: 'var(--surface-3)',
                borderRadius: 'var(--radius-md)',
                padding: 'var(--space-3) var(--space-4)',
                fontSize: '0.85rem'
              }}
            >
              <p className="text-muted text-xs" style={{ marginBottom: 2 }}>Session token</p>
              <p style={{ fontFamily: 'monospace', fontSize: '0.8rem' }}>
                {token ? `${token.slice(0, 20)}…` : '—'}
              </p>
            </div>
          </div>

          <button
            className="btn-secondary"
            onClick={handleSignOut}
            style={{ width: '100%', justifyContent: 'center', color: 'var(--danger)', borderColor: 'var(--danger)' }}
          >
            🚪 Sign Out
          </button>
        </div>

        {/* ── Quick links ──────────────────────────────────────── */}
        <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
          {QUICK_LINKS.map((link) => (
            <Link
              key={link.label}
              to={link.to}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 'var(--space-4)',
                background: 'var(--surface)',
                border: '1px solid var(--line)',
                borderRadius: 'var(--radius-md)',
                padding: 'var(--space-4) var(--space-5)',
                textDecoration: 'none',
                transition: 'border-color var(--dur-fast), background var(--dur-fast), transform var(--dur-fast) var(--ease-out)'
              }}
              onMouseEnter={(e) => {
                (e.currentTarget as HTMLElement).style.borderColor = 'var(--brand)';
                (e.currentTarget as HTMLElement).style.transform = 'translateX(4px)';
              }}
              onMouseLeave={(e) => {
                (e.currentTarget as HTMLElement).style.borderColor = 'var(--line)';
                (e.currentTarget as HTMLElement).style.transform = 'none';
              }}
            >
              <div
                style={{
                  width: 44,
                  height: 44,
                  background: 'var(--brand-tint)',
                  borderRadius: 'var(--radius-md)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '1.3rem',
                  flexShrink: 0
                }}
              >
                {link.icon}
              </div>
              <div>
                <p style={{ fontWeight: 600, fontSize: '0.925rem', color: 'var(--text)' }}>{link.label}</p>
                <p style={{ fontSize: '0.8rem', color: 'var(--muted)' }}>{link.desc}</p>
              </div>
              <span style={{ marginLeft: 'auto', color: 'var(--muted)', fontSize: '1rem' }}>→</span>
            </Link>
          ))}
        </div>
      </div>

      {/* ── Saved Addresses ─────────────────────────────────── */}
      <div className="panel" style={{ marginTop: 'var(--space-5)' }}>
        <div
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: 'var(--space-5)'
          }}
        >
          <p className="panel-title" style={{ marginBottom: 0 }}>📍 Saved Addresses</p>
          <button
            className="btn-primary"
            onClick={() => setShowMap(true)}
            style={{ fontSize: '0.875rem' }}
          >
            + Add Address
          </button>
        </div>

        {addressesLoading ? (
          <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
            {[1, 2].map((n) => (
              <div key={n} className="skeleton" style={{ height: 72, borderRadius: 'var(--radius-md)' }} />
            ))}
          </div>
        ) : addresses && addresses.length > 0 ? (
          <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
            {addresses.map((addr) => (
              <div
                key={addr.id}
                style={{
                  background: 'var(--surface-3)',
                  borderRadius: 'var(--radius-md)',
                  padding: 'var(--space-4)',
                  display: 'grid',
                  gap: 'var(--space-2)'
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-2)' }}>
                  <span className="badge badge-brand" style={{ fontSize: '0.75rem' }}>{addr.label}</span>
                </div>
                <p style={{ fontWeight: 600, fontSize: '0.9rem' }}>
                  {addr.line1}{addr.area ? `, ${addr.area}` : ''}, {addr.city}
                </p>
                <p style={{
                  fontSize: '0.72rem', fontFamily: 'monospace', color: 'var(--muted)',
                  background: 'var(--surface)', borderRadius: 'var(--radius-sm)',
                  padding: '2px 6px', display: 'inline-block'
                }}>
                  📌 {addr.latitude.toFixed(5)}, {addr.longitude.toFixed(5)}
                </p>
              </div>
            ))}
          </div>
        ) : (
          <div style={{ textAlign: 'center', padding: 'var(--space-8) 0' }}>
            <div style={{ fontSize: '2.5rem', marginBottom: 'var(--space-3)' }}>🗺️</div>
            <p style={{ fontWeight: 600, marginBottom: 'var(--space-2)' }}>No saved addresses yet</p>
            <p className="text-sm text-muted" style={{ marginBottom: 'var(--space-4)' }}>
              Add a delivery address to start ordering.
            </p>
            <button className="btn-primary" onClick={() => setShowMap(true)}>
              + Add your first address
            </button>
          </div>
        )}
      </div>
    </>
  );
}
