import { useState, useEffect, FormEvent } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useAuthStore } from '../../app/store/authStore';
import { zimbiteApi } from '../../services/zimbiteApi';
import { toast } from '../../app/store/toastStore';

type Section = 'overview' | 'available' | 'active' | 'earnings' | 'settings';

const NAV: { id: Section; icon: string; label: string }[] = [
  { id: 'overview',  icon: '📊', label: 'Overview' },
  { id: 'available', icon: '📦', label: 'Available' },
  { id: 'active',    icon: '🚴', label: 'Active' },
  { id: 'earnings',  icon: '💰', label: 'Earnings' },
  { id: 'settings',  icon: '⚙️', label: 'Settings' }
];

// Default Harare coords
const DEFAULT_LAT = -17.8252;
const DEFAULT_LNG = 31.0335;

export function RiderDashboardPage() {
  const [section, setSection] = useState<Section>('overview');
  const qc = useQueryClient();

  // Use browser geolocation if available
  const [coords, setCoords] = useState({ lat: DEFAULT_LAT, lng: DEFAULT_LNG });

  useEffect(() => {
    navigator.geolocation?.getCurrentPosition(
      (pos) => setCoords({ lat: pos.coords.latitude, lng: pos.coords.longitude }),
      () => { /* use defaults */ }
    );
  }, []);

  const { data: available, isLoading: availableLoading } = useQuery({
    queryKey: ['rider-available', coords.lat, coords.lng],
    queryFn: () => zimbiteApi.getAvailableDeliveries(coords.lat, coords.lng),
    enabled: section === 'overview' || section === 'available',
    refetchInterval: 30_000
  });

  const { data: active, isLoading: activeLoading } = useQuery({
    queryKey: ['rider-active'],
    queryFn: zimbiteApi.getActiveDeliveries,
    enabled: section === 'overview' || section === 'active' || section === 'earnings',
    refetchInterval: 10_000
  });

  const { data: profile } = useQuery({
    queryKey: ['profile'],
    queryFn: zimbiteApi.getProfile,
    enabled: section === 'settings'
  });

  const acceptMut = useMutation({
    mutationFn: (deliveryId: string) => zimbiteApi.acceptDelivery(deliveryId),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['rider-available'] });
      qc.invalidateQueries({ queryKey: ['rider-active'] });
      toast.success('Accepted!', 'Delivery assigned to you.');
      setSection('active');
    },
    onError: () => toast.error('Failed', 'Could not accept delivery.')
  });

  const statusMut = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      zimbiteApi.updateDeliveryStatus(id, status),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['rider-active'] });
      qc.invalidateQueries({ queryKey: ['rider-available'] });
      toast.success('Updated!', 'Delivery status changed.');
    },
    onError: () => toast.error('Failed', 'Could not update status.')
  });

  const activeDelivery = active?.[0];
  const todayDeliveries = active?.length ?? 0;
  const todayEarnings = active?.reduce((sum, d) => sum + d.estimatedEarning, 0) ?? 0;

  // Chat state for active delivery
  const [showChat, setShowChat] = useState(false);
  const activeDeliveryId = activeDelivery?.id;
  const { data: chatMessages } = useQuery({
    queryKey: ['delivery-chat', activeDeliveryId],
    queryFn: () => zimbiteApi.getDeliveryChat(activeDeliveryId!),
    enabled: !!activeDeliveryId && showChat,
    refetchInterval: showChat ? 5_000 : false
  });

  return (
    <>
      <div className="section-header">
        <p className="section-eyebrow">Rider Dashboard</p>
        <h1 className="section-title">Deliveries</h1>
      </div>

      <div className="dashboard-layout">
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
        </nav>

        <div className="dash-main">

          {/* ── Overview ────────────────────────────────────── */}
          {section === 'overview' && (
            <>
              <div className="stat-grid" style={{ marginBottom: 'var(--space-6)' }}>
                <div className="stat-card">
                  <div className="stat-card-icon">📦</div>
                  <div className="stat-card-value">{todayDeliveries}</div>
                  <div className="stat-card-label">Active Deliveries</div>
                </div>
                <div className="stat-card">
                  <div className="stat-card-icon">🚴</div>
                  <div className="stat-card-value">{activeDelivery ? activeDelivery.status : 'Idle'}</div>
                  <div className="stat-card-label">Current Status</div>
                </div>
                <div className="stat-card">
                  <div className="stat-card-icon">💰</div>
                  <div className="stat-card-value">${todayEarnings.toFixed(2)}</div>
                  <div className="stat-card-label">Est. Earnings</div>
                </div>
              </div>

              {activeDelivery && (
                <div className="panel" style={{ marginBottom: 'var(--space-5)' }}>
                  <p className="panel-title">Current Delivery</p>
                  <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <span className="fw-semibold">#{activeDelivery.orderId.slice(0, 8)}</span>
                      <span className="badge badge-brand">{activeDelivery.status}</span>
                    </div>
                    <div className="data-row" style={{ border: 'none', padding: 'var(--space-2) 0' }}>
                      <span>🏪</span>
                      <div style={{ flex: 1 }}>
                        <p className="fw-semibold text-sm">{activeDelivery.vendorName}</p>
                        <p className="text-xs text-muted">{activeDelivery.vendorAddress}</p>
                      </div>
                    </div>
                    <div className="data-row" style={{ border: 'none', padding: 'var(--space-2) 0' }}>
                      <span>📍</span>
                      <div style={{ flex: 1 }}>
                        <p className="fw-semibold text-sm">{activeDelivery.customerName}</p>
                        <p className="text-xs text-muted">{activeDelivery.customerAddress}</p>
                      </div>
                    </div>
                    <div style={{ display: 'flex', gap: 'var(--space-3)' }}>
                      {activeDelivery.status === 'ASSIGNED' && (
                        <button
                          className="btn-primary"
                          onClick={() => statusMut.mutate({ id: activeDelivery.id, status: 'PICKED_UP' })}
                          disabled={statusMut.isPending}
                          style={{ flex: 1, justifyContent: 'center' }}
                        >
                          Mark Picked Up
                        </button>
                      )}
                      {activeDelivery.status === 'PICKED_UP' && (
                        <button
                          className="btn-primary"
                          onClick={() => statusMut.mutate({ id: activeDelivery.id, status: 'DELIVERED' })}
                          disabled={statusMut.isPending}
                          style={{ flex: 1, justifyContent: 'center' }}
                        >
                          Mark Delivered
                        </button>
                      )}
                      <button
                        className="btn-secondary"
                        onClick={() => { setSection('active'); setShowChat(true); }}
                        style={{ fontSize: '0.85rem' }}
                      >
                        💬 Chat
                      </button>
                    </div>
                  </div>
                </div>
              )}

              {available && available.length > 0 && (
                <div className="panel">
                  <p className="panel-title">Nearby Deliveries ({available.length})</p>
                  {available.slice(0, 3).map((d) => (
                    <div className="data-row" key={d.id}>
                      <div style={{ flex: 1 }}>
                        <p className="fw-semibold text-sm">{d.vendorName} → {d.customerName}</p>
                        <p className="text-xs text-muted">{d.vendorAddress}</p>
                      </div>
                      <span className="fw-bold text-sm">${d.estimatedEarning.toFixed(2)}</span>
                      <button
                        className="btn-primary"
                        style={{ fontSize: '0.8rem', padding: 'var(--space-2) var(--space-3)' }}
                        onClick={() => acceptMut.mutate(d.id)}
                        disabled={acceptMut.isPending}
                      >
                        Accept
                      </button>
                    </div>
                  ))}
                  {available.length > 3 && (
                    <button className="btn-ghost" onClick={() => setSection('available')} style={{ marginTop: 'var(--space-2)' }}>
                      View all {available.length} →
                    </button>
                  )}
                </div>
              )}
            </>
          )}

          {/* ── Available Deliveries ────────────────────────── */}
          {section === 'available' && (
            <div className="panel">
              <p className="panel-title">Available Deliveries</p>
              {availableLoading ? (
                <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
                  {[1, 2, 3].map((n) => <div key={n} className="skeleton" style={{ height: 64 }} />)}
                </div>
              ) : available && available.length > 0 ? (
                available.map((d) => (
                  <div className="data-row" key={d.id}>
                    <div style={{ flex: 1 }}>
                      <p className="fw-semibold text-sm">{d.vendorName} → {d.customerName}</p>
                      <p className="text-xs text-muted">{d.vendorAddress} → {d.customerAddress}</p>
                    </div>
                    <span className="fw-bold">${d.estimatedEarning.toFixed(2)}</span>
                    <button
                      className="btn-primary"
                      style={{ fontSize: '0.8rem', padding: 'var(--space-2) var(--space-3)' }}
                      onClick={() => acceptMut.mutate(d.id)}
                      disabled={acceptMut.isPending}
                    >
                      Accept
                    </button>
                  </div>
                ))
              ) : (
                <div className="empty-state">
                  <div className="empty-state-icon">📦</div>
                  <p className="empty-state-title">No deliveries nearby</p>
                  <p className="empty-state-desc">New delivery requests will appear here automatically.</p>
                </div>
              )}
            </div>
          )}

          {/* ── Active Delivery ──────────────────────────────── */}
          {section === 'active' && (
            <>
              <div className="panel">
                <p className="panel-title">Active Deliveries</p>
                {activeLoading ? (
                  <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
                    {[1, 2].map((n) => <div key={n} className="skeleton" style={{ height: 100 }} />)}
                  </div>
                ) : active && active.length > 0 ? (
                  <div style={{ display: 'grid', gap: 'var(--space-4)' }}>
                    {active.map((d) => (
                      <div key={d.id} style={{ background: 'var(--surface-3)', borderRadius: 'var(--radius-md)', padding: 'var(--space-4)' }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--space-3)' }}>
                          <span className="fw-semibold">#{d.orderId.slice(0, 8)}</span>
                          <span className="badge badge-brand">{d.status}</span>
                        </div>
                        <p className="text-sm"><strong>From:</strong> {d.vendorName} — {d.vendorAddress}</p>
                        <p className="text-sm"><strong>To:</strong> {d.customerName} — {d.customerAddress}</p>
                        <p className="text-sm fw-bold" style={{ marginTop: 'var(--space-2)' }}>Earning: ${d.estimatedEarning.toFixed(2)}</p>
                        <div style={{ display: 'flex', gap: 'var(--space-3)', marginTop: 'var(--space-3)' }}>
                          {d.status === 'ASSIGNED' && (
                            <button className="btn-primary" onClick={() => statusMut.mutate({ id: d.id, status: 'PICKED_UP' })} disabled={statusMut.isPending} style={{ flex: 1, justifyContent: 'center', fontSize: '0.85rem' }}>
                              Mark Picked Up
                            </button>
                          )}
                          {d.status === 'PICKED_UP' && (
                            <button className="btn-primary" onClick={() => statusMut.mutate({ id: d.id, status: 'DELIVERED' })} disabled={statusMut.isPending} style={{ flex: 1, justifyContent: 'center', fontSize: '0.85rem' }}>
                              Mark Delivered
                            </button>
                          )}
                          <button
                            className="btn-secondary"
                            onClick={() => setShowChat(showChat && activeDelivery?.id === d.id ? false : true)}
                            style={{ fontSize: '0.85rem' }}
                          >
                            💬 Chat
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="empty-state">
                    <div className="empty-state-icon">🚴</div>
                    <p className="empty-state-title">No active deliveries</p>
                    <p className="empty-state-desc">Accept a delivery to get started.</p>
                  </div>
                )}
              </div>

              {/* ── Chat panel ─────────────────────────────────── */}
              {showChat && activeDelivery && (
                <div className="panel" style={{ marginTop: 'var(--space-4)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--space-4)' }}>
                    <p className="panel-title" style={{ marginBottom: 0 }}>💬 Delivery Chat</p>
                    <button className="btn-ghost" onClick={() => setShowChat(false)}>Close</button>
                  </div>
                  <div style={{ maxHeight: 300, overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: 'var(--space-3)', marginBottom: 'var(--space-4)' }}>
                    {chatMessages && chatMessages.length > 0 ? (
                      chatMessages.map((msg) => (
                        <div
                          key={msg.id}
                          style={{
                            alignSelf: msg.senderRole === 'RIDER' ? 'flex-end' : 'flex-start',
                            background: msg.senderRole === 'RIDER' ? 'var(--brand-tint)' : 'var(--surface-3)',
                            borderRadius: 'var(--radius-md)',
                            padding: 'var(--space-3) var(--space-4)',
                            maxWidth: '75%'
                          }}
                        >
                          <p className="text-xs fw-semibold text-muted" style={{ marginBottom: 2 }}>{msg.senderRole}</p>
                          <p className="text-sm">{msg.content}</p>
                          <p className="text-xs text-muted" style={{ marginTop: 2 }}>
                            {new Date(msg.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                          </p>
                        </div>
                      ))
                    ) : (
                      <p className="text-sm text-muted" style={{ textAlign: 'center', padding: 'var(--space-4) 0' }}>
                        No messages yet.
                      </p>
                    )}
                  </div>
                </div>
              )}
            </>
          )}

          {/* ── Earnings ────────────────────────────────────── */}
          {section === 'earnings' && (
            <div style={{ display: 'grid', gap: 'var(--space-5)' }}>
              <div className="stat-grid">
                <div className="stat-card">
                  <div className="stat-card-icon">💰</div>
                  <div className="stat-card-value">${todayEarnings.toFixed(2)}</div>
                  <div className="stat-card-label">Today's Earnings</div>
                </div>
                <div className="stat-card">
                  <div className="stat-card-icon">📦</div>
                  <div className="stat-card-value">{todayDeliveries}</div>
                  <div className="stat-card-label">Today's Deliveries</div>
                </div>
                <div className="stat-card">
                  <div className="stat-card-icon">📊</div>
                  <div className="stat-card-value">
                    ${todayDeliveries > 0 ? (todayEarnings / todayDeliveries).toFixed(2) : '0.00'}
                  </div>
                  <div className="stat-card-label">Avg per Delivery</div>
                </div>
              </div>

              <div className="panel">
                <p className="panel-title">Delivery History</p>
                {active && active.length > 0 ? (
                  active.map((d) => (
                    <div className="data-row" key={d.id}>
                      <div style={{ flex: 1 }}>
                        <p className="fw-semibold text-sm">#{d.orderId.slice(0, 8)}</p>
                        <p className="text-xs text-muted">{d.vendorName} → {d.customerName}</p>
                      </div>
                      <span className={`badge ${d.status === 'DELIVERED' ? 'badge-success' : 'badge-brand'}`}>
                        {d.status}
                      </span>
                      <span className="fw-bold">${d.estimatedEarning.toFixed(2)}</span>
                      <span className="text-xs text-muted">
                        {new Date(d.createdAt).toLocaleDateString()}
                      </span>
                    </div>
                  ))
                ) : (
                  <p className="text-sm text-muted" style={{ padding: 'var(--space-4) 0' }}>
                    No delivery history yet. Accept deliveries to start earning.
                  </p>
                )}
              </div>
            </div>
          )}

          {/* ── Settings ────────────────────────────────────── */}
          {section === 'settings' && (
            <RiderSettings profile={profile} />
          )}
        </div>
      </div>
    </>
  );
}

/* ── Rider Settings sub-component ──────────────────────────── */

function RiderSettings({ profile }: { profile?: { firstName: string; lastName: string; email: string; phoneNumber: string } }) {
  const qc = useQueryClient();
  const [firstName, setFirstName] = useState(profile?.firstName ?? '');
  const [lastName, setLastName]   = useState(profile?.lastName ?? '');
  const [phone, setPhone]         = useState(profile?.phoneNumber ?? '');
  const [vehicle, setVehicle]     = useState('');
  const [dirty, setDirty]         = useState(false);

  const updateMut = useMutation({
    mutationFn: () => zimbiteApi.updateProfile({
      firstName: firstName.trim(),
      lastName: lastName.trim(),
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
      <p className="panel-title">Rider Profile</p>
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
          <label className="form-label">Phone</label>
          <input className="form-input" type="tel" value={phone} onChange={onChange(setPhone)} />
        </div>
        <div className="form-field">
          <label className="form-label">Vehicle type</label>
          <input className="form-input" value={vehicle} onChange={onChange(setVehicle)} placeholder="e.g. Motorcycle, Bicycle" />
          <span className="form-hint">Vehicle info is stored locally for now.</span>
        </div>
        <button className="btn-primary" type="submit" disabled={updateMut.isPending || !dirty} style={{ justifySelf: 'end' }}>
          {updateMut.isPending ? 'Saving…' : 'Save Changes'}
        </button>
      </form>
    </div>
  );
}
