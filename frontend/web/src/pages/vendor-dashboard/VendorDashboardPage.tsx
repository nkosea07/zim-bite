import { useState, FormEvent } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useAuthStore } from '../../app/store/authStore';
import { zimbiteApi, type MenuItem, type CreateVendorPayload } from '../../services/zimbiteApi';
import { toast } from '../../app/store/toastStore';

type Section = 'overview' | 'orders' | 'menu' | 'analytics' | 'reviews' | 'settings';

const NAV: { id: Section; icon: string; label: string }[] = [
  { id: 'overview',  icon: '📊', label: 'Overview' },
  { id: 'orders',    icon: '📋', label: 'Orders' },
  { id: 'menu',      icon: '🍽️', label: 'Menu' },
  { id: 'analytics', icon: '📈', label: 'Analytics' },
  { id: 'reviews',   icon: '⭐', label: 'Reviews' },
  { id: 'settings',  icon: '⚙️', label: 'Settings' }
];

export function VendorDashboardPage() {
  const { vendorId, userId, setVendorId } = useAuthStore();
  const [section, setSection] = useState<Section>('overview');
  const qc = useQueryClient();

  // ── Vendor setup (if no vendorId yet) ──────────────────────
  const [setupName, setSetupName]   = useState('');
  const [setupDesc, setSetupDesc]   = useState('');
  const [setupPhone, setSetupPhone] = useState('');
  const [setupCity, setSetupCity]   = useState('');
  const [setupLat, setSetupLat]     = useState('-17.8252');
  const [setupLng, setSetupLng]     = useState('31.0335');

  const createVendorMut = useMutation({
    mutationFn: (p: CreateVendorPayload) => zimbiteApi.createVendor({ ...p, email: '' }),
    onSuccess: (v) => {
      setVendorId(v.id);
      toast.success('Vendor created!', 'Your vendor profile is live.');
    },
    onError: () => toast.error('Failed', 'Could not create vendor profile.')
  });

  function onSetupSubmit(e: FormEvent) {
    e.preventDefault();
    if (!setupName.trim() || !setupCity.trim()) return;
    createVendorMut.mutate({
      name: setupName.trim(),
      description: setupDesc.trim() || undefined,
      phoneNumber: setupPhone.trim(),
      email: '',
      city: setupCity.trim(),
      latitude: parseFloat(setupLat) || -17.8252,
      longitude: parseFloat(setupLng) || 31.0335
    });
  }

  // If no vendor yet, show setup
  if (!vendorId) {
    return (
      <>
        <div className="section-header">
          <p className="section-eyebrow">Vendor Setup</p>
          <h1 className="section-title">Complete Your Profile</h1>
          <p className="section-subtitle">Set up your vendor before you can start selling.</p>
        </div>
        <div className="panel" style={{ maxWidth: 520 }}>
          <form onSubmit={onSetupSubmit} className="stacked-form">
            <div className="form-field">
              <label className="form-label">Business Name</label>
              <input className="form-input" value={setupName} onChange={(e) => setSetupName(e.target.value)} placeholder="e.g. Tino's Kitchen" />
            </div>
            <div className="form-field">
              <label className="form-label">Description</label>
              <textarea className="form-textarea" value={setupDesc} onChange={(e) => setSetupDesc(e.target.value)} placeholder="What makes your breakfast special?" />
            </div>
            <div className="form-field">
              <label className="form-label">Phone</label>
              <input className="form-input" value={setupPhone} onChange={(e) => setSetupPhone(e.target.value)} placeholder="+263771234567" />
            </div>
            <div className="form-field">
              <label className="form-label">City</label>
              <input className="form-input" value={setupCity} onChange={(e) => setSetupCity(e.target.value)} placeholder="Harare" />
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--space-3)' }}>
              <div className="form-field">
                <label className="form-label">Latitude</label>
                <input className="form-input" value={setupLat} onChange={(e) => setSetupLat(e.target.value)} />
              </div>
              <div className="form-field">
                <label className="form-label">Longitude</label>
                <input className="form-input" value={setupLng} onChange={(e) => setSetupLng(e.target.value)} />
              </div>
            </div>
            <button className="btn-primary" type="submit" disabled={createVendorMut.isPending || !setupName.trim() || !setupCity.trim()} style={{ width: '100%', justifyContent: 'center' }}>
              {createVendorMut.isPending ? <><span className="btn-spinner" /> Creating…</> : 'Create Vendor Profile →'}
            </button>
          </form>
        </div>
      </>
    );
  }

  // ── Queries ────────────────────────────────────────────────
  const { data: stats } = useQuery({
    queryKey: ['vendor-stats', vendorId],
    queryFn: () => zimbiteApi.getVendorStats(vendorId),
    enabled: !!vendorId
  });

  const { data: orders } = useQuery({
    queryKey: ['vendor-orders'],
    queryFn: zimbiteApi.listOrders,
    enabled: section === 'overview' || section === 'orders'
  });

  const { data: menuItems, isLoading: menuLoading } = useQuery({
    queryKey: ['vendor-menu', vendorId],
    queryFn: () => zimbiteApi.listMenuItems(vendorId),
    enabled: !!vendorId && (section === 'menu' || section === 'overview')
  });

  const { data: analytics } = useQuery({
    queryKey: ['vendor-analytics', vendorId],
    queryFn: () => zimbiteApi.getVendorDashboard(vendorId),
    enabled: !!vendorId && section === 'analytics'
  });

  const { data: reviews } = useQuery({
    queryKey: ['vendor-reviews', vendorId],
    queryFn: () => zimbiteApi.getVendorReviews(vendorId),
    enabled: !!vendorId && section === 'reviews'
  });

  const { data: vendor } = useQuery({
    queryKey: ['vendor-detail', vendorId],
    queryFn: () => zimbiteApi.getVendor(vendorId),
    enabled: !!vendorId && section === 'settings'
  });

  // Toggle item availability
  const toggleMut = useMutation({
    mutationFn: ({ itemId, available }: { itemId: string; available: boolean }) =>
      zimbiteApi.toggleMenuItemAvailability(vendorId, itemId, available),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['vendor-menu', vendorId] })
  });

  // Add menu item
  const [showAddItem, setShowAddItem] = useState(false);
  const [newItemName, setNewItemName]     = useState('');
  const [newItemCat, setNewItemCat]       = useState('');
  const [newItemPrice, setNewItemPrice]   = useState('');

  const addItemMut = useMutation({
    mutationFn: () => zimbiteApi.createMenuItem(vendorId, {
      name: newItemName.trim(),
      category: newItemCat.trim() || 'Breakfast',
      basePrice: parseFloat(newItemPrice) || 0,
      currency: 'USD',
      available: true
    }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['vendor-menu', vendorId] });
      setNewItemName(''); setNewItemCat(''); setNewItemPrice('');
      setShowAddItem(false);
      toast.success('Item added!', 'Menu item is now live.');
    }
  });

  // Group menu items by category
  const categories = menuItems
    ? [...new Set(menuItems.map((i) => i.category))]
    : [];
  const [activeCategory, setActiveCategory] = useState<string | null>(null);
  const filteredMenu = menuItems?.filter((i) =>
    !activeCategory || i.category === activeCategory
  );

  return (
    <>
      <div className="section-header">
        <p className="section-eyebrow">Vendor Dashboard</p>
        <h1 className="section-title">Your Restaurant</h1>
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
        </nav>

        {/* ── Main content ─────────────────────────────────── */}
        <div className="dash-main">

          {/* ── Overview ────────────────────────────────────── */}
          {section === 'overview' && (
            <>
              <div className="stat-grid" style={{ marginBottom: 'var(--space-6)' }}>
                <div className="stat-card">
                  <div className="stat-card-icon">📦</div>
                  <div className="stat-card-value">{stats?.ordersToday ?? '–'}</div>
                  <div className="stat-card-label">Orders Today</div>
                </div>
                <div className="stat-card">
                  <div className="stat-card-icon">💰</div>
                  <div className="stat-card-value">${stats?.revenueToday?.toFixed(2) ?? '–'}</div>
                  <div className="stat-card-label">Revenue Today</div>
                </div>
                <div className="stat-card">
                  <div className="stat-card-icon">⭐</div>
                  <div className="stat-card-value">{stats?.rating?.toFixed(1) ?? '–'}</div>
                  <div className="stat-card-label">Rating</div>
                </div>
                <div className="stat-card">
                  <div className="stat-card-icon">📋</div>
                  <div className="stat-card-value">{stats?.totalOrders ?? '–'}</div>
                  <div className="stat-card-label">Total Orders</div>
                </div>
              </div>

              <div className="panel">
                <p className="panel-title">Recent Orders</p>
                {orders && orders.length > 0 ? (
                  orders.slice(0, 5).map((o) => (
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
                  <p className="text-sm text-muted" style={{ padding: 'var(--space-4) 0' }}>No orders yet.</p>
                )}
              </div>
            </>
          )}

          {/* ── Orders ──────────────────────────────────────── */}
          {section === 'orders' && (
            <div className="panel">
              <p className="panel-title">All Orders</p>
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
                  </div>
                ))
              ) : (
                <div className="empty-state">
                  <div className="empty-state-icon">📋</div>
                  <p className="empty-state-title">No orders yet</p>
                  <p className="empty-state-desc">Orders from customers will appear here.</p>
                </div>
              )}
            </div>
          )}

          {/* ── Menu ────────────────────────────────────────── */}
          {section === 'menu' && (
            <>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--space-4)' }}>
                <p className="panel-title" style={{ marginBottom: 0 }}>Menu Items</p>
                <button className="btn-primary" onClick={() => setShowAddItem(!showAddItem)} style={{ fontSize: '0.85rem' }}>
                  {showAddItem ? 'Cancel' : '+ Add Item'}
                </button>
              </div>

              {showAddItem && (
                <div className="panel" style={{ marginBottom: 'var(--space-4)' }}>
                  <form onSubmit={(e) => { e.preventDefault(); addItemMut.mutate(); }} style={{ display: 'grid', gap: 'var(--space-3)' }}>
                    <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr 1fr', gap: 'var(--space-3)' }}>
                      <input className="form-input" placeholder="Item name" value={newItemName} onChange={(e) => setNewItemName(e.target.value)} />
                      <input className="form-input" placeholder="Category" value={newItemCat} onChange={(e) => setNewItemCat(e.target.value)} />
                      <input className="form-input" placeholder="Price (USD)" type="number" step="0.01" value={newItemPrice} onChange={(e) => setNewItemPrice(e.target.value)} />
                    </div>
                    <button className="btn-primary" type="submit" disabled={addItemMut.isPending || !newItemName.trim()} style={{ justifySelf: 'end', fontSize: '0.85rem' }}>
                      {addItemMut.isPending ? 'Adding…' : 'Add Item'}
                    </button>
                  </form>
                </div>
              )}

              {categories.length > 0 && (
                <div className="menu-category-tabs" style={{ marginBottom: 'var(--space-4)' }}>
                  <button className={`category-tab${!activeCategory ? ' active' : ''}`} onClick={() => setActiveCategory(null)}>All</button>
                  {categories.map((c) => (
                    <button key={c} className={`category-tab${activeCategory === c ? ' active' : ''}`} onClick={() => setActiveCategory(c)}>{c}</button>
                  ))}
                </div>
              )}

              <div className="panel">
                {menuLoading ? (
                  <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
                    {[1, 2, 3].map((n) => <div key={n} className="skeleton" style={{ height: 56 }} />)}
                  </div>
                ) : filteredMenu && filteredMenu.length > 0 ? (
                  filteredMenu.map((item) => (
                    <div className="data-row" key={item.id}>
                      <div style={{ flex: 1 }}>
                        <p style={{ fontWeight: 600, fontSize: '0.9rem' }}>{item.name}</p>
                        <p className="text-xs text-muted">{item.category} · ${item.basePrice.toFixed(2)}</p>
                      </div>
                      <button
                        className={`toggle${item.available ? ' on' : ''}`}
                        onClick={() => toggleMut.mutate({ itemId: item.id, available: !item.available })}
                        disabled={toggleMut.isPending}
                        aria-label={item.available ? 'Disable item' : 'Enable item'}
                      />
                    </div>
                  ))
                ) : (
                  <div className="empty-state">
                    <div className="empty-state-icon">🍽️</div>
                    <p className="empty-state-title">No menu items</p>
                    <p className="empty-state-desc">Add your first breakfast item to get started.</p>
                  </div>
                )}
              </div>
            </>
          )}

          {/* ── Analytics ───────────────────────────────────── */}
          {section === 'analytics' && (
            <>
              {analytics ? (
                <div style={{ display: 'grid', gap: 'var(--space-6)' }}>
                  <div className="panel">
                    <p className="panel-title">Weekly Orders</p>
                    {analytics.weeklyOrders.length > 0 ? (
                      <div className="bar-chart">
                        {analytics.weeklyOrders.map((d) => {
                          const max = Math.max(...analytics.weeklyOrders.map((x) => x.count), 1);
                          return (
                            <div className="bar-col" key={d.day}>
                              <span className="bar-value">{d.count}</span>
                              <div className="bar" style={{ height: `${(d.count / max) * 100}%` }} />
                              <span className="bar-label">{d.day}</span>
                            </div>
                          );
                        })}
                      </div>
                    ) : <p className="text-sm text-muted">No data yet.</p>}
                  </div>

                  <div className="panel">
                    <p className="panel-title">Weekly Revenue</p>
                    {analytics.weeklyRevenue.length > 0 ? (
                      <div className="bar-chart">
                        {analytics.weeklyRevenue.map((d) => {
                          const max = Math.max(...analytics.weeklyRevenue.map((x) => x.amount), 1);
                          return (
                            <div className="bar-col" key={d.day}>
                              <span className="bar-value">${d.amount}</span>
                              <div className="bar" style={{ height: `${(d.amount / max) * 100}%` }} />
                              <span className="bar-label">{d.day}</span>
                            </div>
                          );
                        })}
                      </div>
                    ) : <p className="text-sm text-muted">No data yet.</p>}
                  </div>

                  {analytics.topItems.length > 0 && (
                    <div className="panel">
                      <p className="panel-title">Top Selling Items</p>
                      {analytics.topItems.map((item, i) => (
                        <div className="data-row" key={item.name}>
                          <span className="badge badge-brand" style={{ width: 28, justifyContent: 'center' }}>#{i + 1}</span>
                          <span style={{ flex: 1, fontWeight: 500 }}>{item.name}</span>
                          <span className="fw-bold">{item.count} sold</span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              ) : (
                <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
                  {[1, 2].map((n) => <div key={n} className="skeleton" style={{ height: 200 }} />)}
                </div>
              )}
            </>
          )}

          {/* ── Reviews ─────────────────────────────────────── */}
          {section === 'reviews' && (
            <div className="panel">
              <p className="panel-title">Customer Reviews</p>
              {reviews && reviews.length > 0 ? (
                <div style={{ display: 'grid', gap: 'var(--space-4)' }}>
                  {reviews.map((r) => (
                    <div key={r.id} style={{ padding: 'var(--space-4)', background: 'var(--surface-3)', borderRadius: 'var(--radius-md)' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--space-2)' }}>
                        <span className="fw-semibold">{r.customerName}</span>
                        <span className="stars">{'★'.repeat(r.rating)}{'☆'.repeat(5 - r.rating)}</span>
                      </div>
                      <p style={{ fontSize: '0.9rem', color: 'var(--text-2)' }}>{r.comment}</p>
                      <p className="text-xs text-muted" style={{ marginTop: 'var(--space-2)' }}>
                        {new Date(r.createdAt).toLocaleDateString()}
                      </p>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="empty-state">
                  <div className="empty-state-icon">⭐</div>
                  <p className="empty-state-title">No reviews yet</p>
                  <p className="empty-state-desc">Customer reviews will appear here once orders are fulfilled.</p>
                </div>
              )}
            </div>
          )}

          {/* ── Settings ────────────────────────────────────── */}
          {section === 'settings' && (
            <VendorSettings vendorId={vendorId} vendor={vendor} />
          )}
        </div>
      </div>
    </>
  );
}

/* ── Vendor Settings sub-component ─────────────────────────── */

function VendorSettings({ vendorId, vendor }: { vendorId: string; vendor?: ReturnType<typeof zimbiteApi.getVendor> extends Promise<infer T> ? T : never }) {
  const qc = useQueryClient();
  const [name, setName]   = useState(vendor?.name ?? '');
  const [desc, setDesc]   = useState(vendor?.description ?? '');
  const [phone, setPhone] = useState(vendor?.phoneNumber ?? '');
  const [city, setCity]   = useState(vendor?.city ?? '');
  const [dirty, setDirty] = useState(false);

  const updateMut = useMutation({
    mutationFn: () => zimbiteApi.updateVendor(vendorId, {
      name: name.trim(),
      description: desc.trim() || undefined,
      phoneNumber: phone.trim(),
      city: city.trim()
    }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['vendor-detail', vendorId] });
      toast.success('Saved!', 'Vendor profile updated.');
      setDirty(false);
    },
    onError: () => toast.error('Failed', 'Could not save changes.')
  });

  function onChange(setter: (v: string) => void) {
    return (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
      setter(e.target.value);
      setDirty(true);
    };
  }

  return (
    <div className="panel" style={{ maxWidth: 520 }}>
      <p className="panel-title">Vendor Profile</p>
      <form onSubmit={(e) => { e.preventDefault(); updateMut.mutate(); }} className="stacked-form">
        <div className="form-field">
          <label className="form-label">Business Name</label>
          <input className="form-input" value={name} onChange={onChange(setName)} />
        </div>
        <div className="form-field">
          <label className="form-label">Description</label>
          <textarea className="form-textarea" value={desc} onChange={onChange(setDesc)} />
        </div>
        <div className="form-field">
          <label className="form-label">Phone</label>
          <input className="form-input" value={phone} onChange={onChange(setPhone)} />
        </div>
        <div className="form-field">
          <label className="form-label">City</label>
          <input className="form-input" value={city} onChange={onChange(setCity)} />
        </div>
        <button className="btn-primary" type="submit" disabled={updateMut.isPending || !dirty} style={{ justifySelf: 'end' }}>
          {updateMut.isPending ? 'Saving…' : 'Save Changes'}
        </button>
      </form>
    </div>
  );
}
