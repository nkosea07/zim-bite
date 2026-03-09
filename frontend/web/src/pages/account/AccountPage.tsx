import { useState, FormEvent } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Link, useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../app/store/authStore';
import { toast } from '../../app/store/toastStore';
import { zimbiteApi } from '../../services/zimbiteApi';
import { AddressPickerMap, type AddressResult } from '../../components/AddressPickerMap';

type Section = 'overview' | 'orders' | 'subscriptions' | 'favorites' | 'addresses' | 'settings';

const NAV: { id: Section; icon: string; label: string }[] = [
  { id: 'overview',      icon: '📊', label: 'Overview' },
  { id: 'orders',        icon: '📋', label: 'Orders' },
  { id: 'subscriptions', icon: '🔔', label: 'Subscriptions' },
  { id: 'favorites',     icon: '❤️', label: 'Favorites' },
  { id: 'addresses',     icon: '📍', label: 'Addresses' },
  { id: 'settings',      icon: '⚙️', label: 'Settings' }
];

export function AccountPage() {
  const { userId, role, clearSession } = useAuthStore();
  const navigate = useNavigate();
  const qc = useQueryClient();
  const [section, setSection] = useState<Section>('overview');
  const [showMap, setShowMap] = useState(false);

  // ── Queries ────────────────────────────────────────────────
  const { data: profile } = useQuery({
    queryKey: ['profile'],
    queryFn: zimbiteApi.getProfile,
    enabled: !!userId
  });

  const { data: orders } = useQuery({
    queryKey: ['orders'],
    queryFn: zimbiteApi.listOrders,
    enabled: !!userId && (section === 'overview' || section === 'orders')
  });

  const { data: subscriptions } = useQuery({
    queryKey: ['subscriptions'],
    queryFn: zimbiteApi.listSubscriptions,
    enabled: !!userId && (section === 'overview' || section === 'subscriptions')
  });

  const { data: favorites } = useQuery({
    queryKey: ['favorites'],
    queryFn: zimbiteApi.listFavorites,
    enabled: !!userId && section === 'favorites'
  });

  const { data: addresses, isLoading: addressesLoading } = useQuery({
    queryKey: ['addresses'],
    queryFn: zimbiteApi.listAddresses,
    enabled: !!userId && (section === 'overview' || section === 'addresses')
  });

  const addAddressMutation = useMutation({
    mutationFn: zimbiteApi.addAddress,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['addresses'] });
      setShowMap(false);
      toast.success('Address saved!', 'Your delivery address has been added.');
    },
    onError: () => toast.error('Failed to save address', 'Please check your connection and try again.')
  });

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
          onSave={(result: AddressResult) => addAddressMutation.mutate(result)}
          onClose={() => setShowMap(false)}
        />
      )}

      <div className="section-header">
        <p className="section-eyebrow">Your Account</p>
        <h1 className="section-title">Dashboard</h1>
      </div>

      <div className="dashboard-layout">
        {/* ── Sidebar ──────────────────────────────────────── */}
        <nav className="dash-sidebar">
          {NAV.map((n) => (
            <button
              key={n.id}
              className={`dash-nav-item${section === n.id ? ' active' : ''}`}
              onClick={() => setSection(n.id)}
            >
              <span>{n.icon}</span> {n.label}
            </button>
          ))}
          <hr className="divider" />
          <button className="dash-nav-item" onClick={handleSignOut} style={{ color: 'var(--danger)' }}>
            <span>🚪</span> Sign Out
          </button>
        </nav>

        {/* ── Main content ─────────────────────────────────── */}
        <div className="dash-main">

          {/* ── Overview ────────────────────────────────────── */}
          {section === 'overview' && (
            <>
              {/* Profile card */}
              <div className="panel" style={{ marginBottom: 'var(--space-5)' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
                  <div style={{
                    width: 56, height: 56, background: 'var(--brand)', borderRadius: '50%',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontSize: '1.4rem', color: '#fff', fontWeight: 700, flexShrink: 0
                  }}>
                    {(profile?.firstName?.[0] || userId[0]).toUpperCase()}
                  </div>
                  <div>
                    <p style={{ fontWeight: 700, fontSize: '1.05rem' }}>
                      {profile ? `${profile.firstName} ${profile.lastName}` : userId.slice(0, 20)}
                    </p>
                    <span className="badge badge-brand" style={{ marginTop: 4 }}>{role ?? 'CUSTOMER'}</span>
                  </div>
                </div>
              </div>

              {/* Stat cards */}
              <div className="stat-grid" style={{ marginBottom: 'var(--space-6)' }}>
                <div className="stat-card">
                  <div className="stat-card-icon">📋</div>
                  <div className="stat-card-value">{orders?.length ?? '–'}</div>
                  <div className="stat-card-label">Total Orders</div>
                </div>
                <div className="stat-card">
                  <div className="stat-card-icon">🔔</div>
                  <div className="stat-card-value">{subscriptions?.filter((s) => s.status === 'ACTIVE').length ?? '–'}</div>
                  <div className="stat-card-label">Active Subscriptions</div>
                </div>
                <div className="stat-card">
                  <div className="stat-card-icon">📍</div>
                  <div className="stat-card-value">{addresses?.length ?? '–'}</div>
                  <div className="stat-card-label">Saved Addresses</div>
                </div>
              </div>

              {/* Recent orders */}
              <div className="panel">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--space-4)' }}>
                  <p className="panel-title" style={{ marginBottom: 0 }}>Recent Orders</p>
                  <button className="btn-ghost" onClick={() => setSection('orders')}>View all →</button>
                </div>
                {orders && orders.length > 0 ? (
                  orders.slice(0, 3).map((o) => (
                    <div className="data-row" key={o.orderId}>
                      <div style={{ flex: 1 }}>
                        <p style={{ fontWeight: 600, fontSize: '0.9rem' }}>#{o.orderId.slice(0, 8)}</p>
                        <p className="text-xs text-muted">{o.scheduledFor || 'ASAP'}</p>
                      </div>
                      <span className={`badge ${o.status === 'DELIVERED' ? 'badge-success' : o.status === 'CANCELLED' ? 'badge-danger' : 'badge-brand'}`}>
                        {o.status}
                      </span>
                      <span className="fw-bold">${o.totalAmount.toFixed(2)}</span>
                    </div>
                  ))
                ) : (
                  <p className="text-sm text-muted" style={{ padding: 'var(--space-4) 0' }}>No orders yet. Browse vendors to get started.</p>
                )}
              </div>
            </>
          )}

          {/* ── Orders ──────────────────────────────────────── */}
          {section === 'orders' && (
            <div className="panel">
              <p className="panel-title">Order History</p>
              {orders && orders.length > 0 ? (
                orders.map((o) => (
                  <div className="data-row" key={o.orderId}>
                    <div style={{ flex: 1 }}>
                      <p style={{ fontWeight: 600, fontSize: '0.9rem' }}>#{o.orderId.slice(0, 8)}</p>
                      <p className="text-xs text-muted">{o.scheduledFor || 'ASAP'}</p>
                    </div>
                    <span className={`badge ${o.status === 'DELIVERED' ? 'badge-success' : o.status === 'CANCELLED' ? 'badge-danger' : 'badge-brand'}`}>
                      {o.status}
                    </span>
                    <span className="fw-bold">${o.totalAmount.toFixed(2)}</span>
                    {o.status !== 'DELIVERED' && o.status !== 'CANCELLED' && (
                      <Link to={`/tracking/${o.orderId}`} className="btn-ghost" style={{ fontSize: '0.8rem' }}>
                        Track →
                      </Link>
                    )}
                  </div>
                ))
              ) : (
                <div className="empty-state">
                  <div className="empty-state-icon">📋</div>
                  <p className="empty-state-title">No orders yet</p>
                  <p className="empty-state-desc">Your order history will appear here.</p>
                  <Link to="/vendors" className="btn-primary">Browse Vendors</Link>
                </div>
              )}
            </div>
          )}

          {/* ── Subscriptions ───────────────────────────────── */}
          {section === 'subscriptions' && (
            <div className="panel">
              <p className="panel-title">Subscriptions</p>
              {subscriptions && subscriptions.length > 0 ? (
                <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
                  {subscriptions.map((s) => (
                    <div key={s.id} style={{ background: 'var(--surface-3)', borderRadius: 'var(--radius-md)', padding: 'var(--space-4)' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--space-2)' }}>
                        <span className="fw-semibold">{s.vendorName}</span>
                        <span className={`badge ${s.status === 'ACTIVE' ? 'badge-success' : s.status === 'PAUSED' ? 'badge-warning' : 'badge-muted'}`}>
                          {s.status}
                        </span>
                      </div>
                      <p className="text-sm text-muted">
                        <span className="badge badge-brand">{s.planType}</span>
                        {s.nextDeliveryDate && <span style={{ marginLeft: 'var(--space-3)' }}>Next: {new Date(s.nextDeliveryDate).toLocaleDateString()}</span>}
                      </p>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="empty-state">
                  <div className="empty-state-icon">🔔</div>
                  <p className="empty-state-title">No subscriptions</p>
                  <p className="empty-state-desc">Subscribe to a vendor for regular breakfast delivery.</p>
                  <Link to="/vendors" className="btn-primary">Browse Vendors</Link>
                </div>
              )}
            </div>
          )}

          {/* ── Favorites ───────────────────────────────────── */}
          {section === 'favorites' && (
            <div className="panel">
              <p className="panel-title">Favorite Items</p>
              {favorites && favorites.length > 0 ? (
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: 'var(--space-3)' }}>
                  {favorites.map((item) => (
                    <div key={item.id} className="card" style={{ padding: 'var(--space-4)' }}>
                      <p className="fw-semibold text-sm">{item.name}</p>
                      <p className="text-xs text-muted">{item.vendorName}</p>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 'var(--space-3)' }}>
                        <span className="fw-bold">${item.basePrice.toFixed(2)}</span>
                        <Link to="/vendors" className="btn-ghost" style={{ fontSize: '0.78rem' }}>Order Again →</Link>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="empty-state">
                  <div className="empty-state-icon">❤️</div>
                  <p className="empty-state-title">No favorites yet</p>
                  <p className="empty-state-desc">Save items you love for quick reordering.</p>
                </div>
              )}
            </div>
          )}

          {/* ── Addresses ───────────────────────────────────── */}
          {section === 'addresses' && (
            <div className="panel">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--space-5)' }}>
                <p className="panel-title" style={{ marginBottom: 0 }}>Saved Addresses</p>
                <button className="btn-primary" onClick={() => setShowMap(true)} style={{ fontSize: '0.875rem' }}>
                  + Add Address
                </button>
              </div>
              {addressesLoading ? (
                <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
                  {[1, 2].map((n) => <div key={n} className="skeleton" style={{ height: 72 }} />)}
                </div>
              ) : addresses && addresses.length > 0 ? (
                <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
                  {addresses.map((addr) => (
                    <div key={addr.id} style={{ background: 'var(--surface-3)', borderRadius: 'var(--radius-md)', padding: 'var(--space-4)', display: 'grid', gap: 'var(--space-2)' }}>
                      <span className="badge badge-brand" style={{ fontSize: '0.75rem', justifySelf: 'start' }}>{addr.label}</span>
                      <p style={{ fontWeight: 600, fontSize: '0.9rem' }}>
                        {addr.line1}{addr.area ? `, ${addr.area}` : ''}, {addr.city}
                      </p>
                      <p style={{ fontSize: '0.72rem', fontFamily: 'monospace', color: 'var(--muted)' }}>
                        {addr.latitude.toFixed(5)}, {addr.longitude.toFixed(5)}
                      </p>
                    </div>
                  ))}
                </div>
              ) : (
                <div style={{ textAlign: 'center', padding: 'var(--space-8) 0' }}>
                  <div style={{ fontSize: '2.5rem', marginBottom: 'var(--space-3)' }}>🗺️</div>
                  <p style={{ fontWeight: 600, marginBottom: 'var(--space-2)' }}>No saved addresses yet</p>
                  <p className="text-sm text-muted" style={{ marginBottom: 'var(--space-4)' }}>Add a delivery address to start ordering.</p>
                  <button className="btn-primary" onClick={() => setShowMap(true)}>+ Add your first address</button>
                </div>
              )}
            </div>
          )}

          {/* ── Settings ────────────────────────────────────── */}
          {section === 'settings' && (
            <ProfileSettings profile={profile} />
          )}
        </div>
      </div>
    </>
  );
}

/* ── Profile Settings sub-component ────────────────────────── */

function ProfileSettings({ profile }: { profile?: { firstName: string; lastName: string; email: string; phoneNumber: string } }) {
  const qc = useQueryClient();
  const [firstName, setFirstName] = useState(profile?.firstName ?? '');
  const [lastName, setLastName]   = useState(profile?.lastName ?? '');
  const [email, setEmail]         = useState(profile?.email ?? '');
  const [phone, setPhone]         = useState(profile?.phoneNumber ?? '');
  const [dirty, setDirty]         = useState(false);

  const updateMut = useMutation({
    mutationFn: () => zimbiteApi.updateProfile({
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      phoneNumber: phone.trim()
    }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['profile'] });
      toast.success('Saved!', 'Profile updated.');
      setDirty(false);
    },
    onError: () => toast.error('Failed', 'Could not save changes.')
  });

  function onChange(setter: (v: string) => void) {
    return (e: React.ChangeEvent<HTMLInputElement>) => {
      setter(e.target.value);
      setDirty(true);
    };
  }

  return (
    <div className="panel" style={{ maxWidth: 480 }}>
      <p className="panel-title">Profile Settings</p>
      <form onSubmit={(e: FormEvent) => { e.preventDefault(); updateMut.mutate(); }} className="stacked-form">
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--space-3)' }}>
          <div className="form-field">
            <label className="form-label">First name</label>
            <input className="form-input" value={firstName} onChange={onChange(setFirstName)} />
          </div>
          <div className="form-field">
            <label className="form-label">Last name</label>
            <input className="form-input" value={lastName} onChange={onChange(setLastName)} />
          </div>
        </div>
        <div className="form-field">
          <label className="form-label">Email</label>
          <input className="form-input" type="email" value={email} onChange={onChange(setEmail)} />
        </div>
        <div className="form-field">
          <label className="form-label">Phone</label>
          <input className="form-input" type="tel" value={phone} onChange={onChange(setPhone)} />
        </div>
        <button className="btn-primary" type="submit" disabled={updateMut.isPending || !dirty} style={{ justifySelf: 'end' }}>
          {updateMut.isPending ? 'Saving…' : 'Save Changes'}
        </button>
      </form>
    </div>
  );
}
