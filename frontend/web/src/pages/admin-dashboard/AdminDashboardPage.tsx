import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { zimbiteApi } from '../../services/zimbiteApi';

type Section = 'overview' | 'vendors' | 'users' | 'analytics' | 'settings';

const NAV: { id: Section; icon: string; label: string }[] = [
  { id: 'overview',  icon: '📊', label: 'Overview' },
  { id: 'vendors',   icon: '🏪', label: 'Vendors' },
  { id: 'users',     icon: '👥', label: 'Users' },
  { id: 'analytics', icon: '📈', label: 'Analytics' },
  { id: 'settings',  icon: '⚙️', label: 'Settings' }
];

export function AdminDashboardPage() {
  const [section, setSection] = useState<Section>('overview');

  const { data: overview, isLoading: overviewLoading } = useQuery({
    queryKey: ['admin-overview'],
    queryFn: zimbiteApi.getAdminOverview,
    enabled: section === 'overview' || section === 'analytics'
  });

  const { data: vendors, isLoading: vendorsLoading } = useQuery({
    queryKey: ['admin-vendors'],
    queryFn: zimbiteApi.listAllVendors,
    enabled: section === 'vendors' || section === 'overview'
  });

  const { data: revenue } = useQuery({
    queryKey: ['admin-revenue'],
    queryFn: () => zimbiteApi.getRevenueTrends(),
    enabled: section === 'analytics'
  });

  return (
    <>
      <div className="section-header">
        <p className="section-eyebrow">System Admin</p>
        <h1 className="section-title">Admin Dashboard</h1>
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
              {overviewLoading ? (
                <div className="stat-grid" style={{ marginBottom: 'var(--space-6)' }}>
                  {[1, 2, 3, 4, 5].map((n) => <div key={n} className="skeleton" style={{ height: 110 }} />)}
                </div>
              ) : (
                <div className="stat-grid" style={{ marginBottom: 'var(--space-6)' }}>
                  <div className="stat-card">
                    <div className="stat-card-icon">🏪</div>
                    <div className="stat-card-value">{overview?.activeVendors ?? '–'}</div>
                    <div className="stat-card-label">Active Vendors</div>
                  </div>
                  <div className="stat-card">
                    <div className="stat-card-icon">🚴</div>
                    <div className="stat-card-value">{overview?.activeRiders ?? '–'}</div>
                    <div className="stat-card-label">Active Riders</div>
                  </div>
                  <div className="stat-card">
                    <div className="stat-card-icon">📦</div>
                    <div className="stat-card-value">{overview?.ordersToday ?? '–'}</div>
                    <div className="stat-card-label">Orders Today</div>
                  </div>
                  <div className="stat-card">
                    <div className="stat-card-icon">💰</div>
                    <div className="stat-card-value">${overview?.revenueToday?.toFixed(2) ?? '–'}</div>
                    <div className="stat-card-label">Revenue Today</div>
                  </div>
                  <div className="stat-card">
                    <div className="stat-card-icon">👥</div>
                    <div className="stat-card-value">{overview?.totalUsers ?? '–'}</div>
                    <div className="stat-card-label">Total Users</div>
                  </div>
                </div>
              )}

              <div className="panel">
                <p className="panel-title">Quick Actions</p>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(180px, 1fr))', gap: 'var(--space-3)' }}>
                  {[
                    { icon: '🏪', label: 'View Vendors', section: 'vendors' as Section },
                    { icon: '👥', label: 'View Users', section: 'users' as Section },
                    { icon: '📈', label: 'Analytics', section: 'analytics' as Section }
                  ].map((a) => (
                    <button
                      key={a.label}
                      className="payment-card"
                      onClick={() => setSection(a.section)}
                    >
                      <div className="payment-card-icon">{a.icon}</div>
                      <div className="payment-card-label">{a.label}</div>
                    </button>
                  ))}
                </div>
              </div>
            </>
          )}

          {/* ── Vendors ─────────────────────────────────────── */}
          {section === 'vendors' && (
            <div className="panel">
              <p className="panel-title">All Vendors</p>
              {vendorsLoading ? (
                <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
                  {[1, 2, 3].map((n) => <div key={n} className="skeleton" style={{ height: 72 }} />)}
                </div>
              ) : vendors && vendors.length > 0 ? (
                <div style={{ display: 'grid', gap: 'var(--space-3)' }}>
                  {vendors.map((v) => (
                    <div key={v.id} style={{ background: 'var(--surface-3)', borderRadius: 'var(--radius-md)', padding: 'var(--space-4)' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <div>
                          <p style={{ fontWeight: 700, fontSize: '0.95rem' }}>{v.name}</p>
                          <p className="text-xs text-muted">{v.city} · {v.description || 'No description'}</p>
                        </div>
                        <span className={`badge ${v.open ? 'badge-success' : 'badge-muted'}`}>
                          {v.open ? 'Open' : 'Closed'}
                        </span>
                      </div>
                      {(v.rating !== undefined || v.totalOrders !== undefined) && (
                        <div style={{ display: 'flex', gap: 'var(--space-4)', marginTop: 'var(--space-2)' }}>
                          {v.rating !== undefined && <span className="text-xs">⭐ {v.rating.toFixed(1)}</span>}
                          {v.totalOrders !== undefined && <span className="text-xs text-muted">{v.totalOrders} orders</span>}
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              ) : (
                <div className="empty-state">
                  <div className="empty-state-icon">🏪</div>
                  <p className="empty-state-title">No vendors</p>
                  <p className="empty-state-desc">Vendors will appear here once they register.</p>
                </div>
              )}
            </div>
          )}

          {/* ── Users ───────────────────────────────────────── */}
          {section === 'users' && (
            <div className="panel">
              <div className="empty-state">
                <div className="empty-state-icon">👥</div>
                <p className="empty-state-title">User Management</p>
                <p className="empty-state-desc">User management coming soon. Use the database directly for now.</p>
              </div>
            </div>
          )}

          {/* ── Analytics ───────────────────────────────────── */}
          {section === 'analytics' && (
            <>
              {overview && (
                <div className="stat-grid" style={{ marginBottom: 'var(--space-6)' }}>
                  <div className="stat-card">
                    <div className="stat-card-icon">📦</div>
                    <div className="stat-card-value">{overview.ordersToday}</div>
                    <div className="stat-card-label">Orders Today</div>
                  </div>
                  <div className="stat-card">
                    <div className="stat-card-icon">💰</div>
                    <div className="stat-card-value">${overview.revenueToday.toFixed(2)}</div>
                    <div className="stat-card-label">Revenue Today</div>
                  </div>
                </div>
              )}

              <div className="panel">
                <p className="panel-title">Revenue Trends</p>
                {revenue && revenue.length > 0 ? (
                  <div className="bar-chart">
                    {revenue.map((d) => {
                      const max = Math.max(...revenue.map((x) => x.amount), 1);
                      return (
                        <div className="bar-col" key={d.period}>
                          <span className="bar-value">${d.amount}</span>
                          <div className="bar" style={{ height: `${(d.amount / max) * 100}%` }} />
                          <span className="bar-label">{d.period}</span>
                        </div>
                      );
                    })}
                  </div>
                ) : (
                  <p className="text-sm text-muted" style={{ padding: 'var(--space-4) 0' }}>No revenue data yet.</p>
                )}
              </div>
            </>
          )}

          {/* ── Settings ────────────────────────────────────── */}
          {section === 'settings' && (
            <div className="panel">
              <div className="empty-state">
                <div className="empty-state-icon">⚙️</div>
                <p className="empty-state-title">Platform Settings</p>
                <p className="empty-state-desc">Platform configuration coming soon.</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  );
}
