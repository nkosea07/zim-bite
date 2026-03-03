import { useQuery } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { useAuthStore } from '../../app/store/authStore';
import { zimbiteApi } from '../../services/zimbiteApi';

type OrderStatus = 'PENDING_PAYMENT' | 'CONFIRMED' | 'PREPARING' | 'ASSIGNED' | 'PICKED_UP' | 'OUT_FOR_DELIVERY' | 'DELIVERED' | 'CANCELLED';

const STATUS_CONFIG: Record<string, { label: string; badge: string }> = {
  PENDING_PAYMENT:  { label: 'Pending Payment', badge: 'badge-warning' },
  CONFIRMED:        { label: 'Confirmed',        badge: 'badge-brand'   },
  PREPARING:        { label: 'Preparing',        badge: 'badge-brand'   },
  ASSIGNED:         { label: 'Rider Assigned',   badge: 'badge-brand'   },
  PICKED_UP:        { label: 'Picked Up',        badge: 'badge-success' },
  OUT_FOR_DELIVERY: { label: 'On the Way',       badge: 'badge-success' },
  DELIVERED:        { label: 'Delivered',        badge: 'badge-success' },
  CANCELLED:        { label: 'Cancelled',        badge: 'badge-danger'  }
};

const ORDER_STATUS_RANK: OrderStatus[] = [
  'PENDING_PAYMENT', 'CONFIRMED', 'PREPARING', 'ASSIGNED', 'PICKED_UP', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED'
];

const TIMELINE_STEPS: { status: OrderStatus; label: string; icon: string }[] = [
  { status: 'CONFIRMED',        label: 'Confirmed',  icon: '✅' },
  { status: 'PREPARING',        label: 'Preparing',  icon: '🍳' },
  { status: 'OUT_FOR_DELIVERY', label: 'On the Way', icon: '🛵' },
  { status: 'DELIVERED',        label: 'Delivered',  icon: '🎉' }
];

export function OrdersPage() {
  const { userId } = useAuthStore();

  const { data: orders, isLoading, isError } = useQuery({
    queryKey: ['orders', userId],
    queryFn: zimbiteApi.listOrders,
    enabled: !!userId
  });

  if (!userId) {
    return (
      <div className="empty-state">
        <div className="empty-state-icon">📋</div>
        <p className="empty-state-title">Sign in to view orders</p>
        <p className="empty-state-desc">Your order history will appear here once you're signed in.</p>
        <Link to="/auth/login" className="btn-primary">Sign In</Link>
      </div>
    );
  }

  if (isLoading) {
    return (
      <>
        <div className="section-header">
          <p className="section-eyebrow">Order history</p>
          <h1 className="section-title">Your Orders</h1>
        </div>
        <div style={{ display: 'grid', gap: 'var(--space-5)' }}>
          {[1, 2].map((n) => (
            <div key={n} className="panel skeleton" style={{ height: 140 }} />
          ))}
        </div>
      </>
    );
  }

  if (isError) {
    return (
      <div className="empty-state">
        <div className="empty-state-icon">⚠️</div>
        <p className="empty-state-title">Couldn't load orders</p>
        <p className="empty-state-desc">Please check your connection and try again.</p>
        <Link to="/" className="btn-primary">Go Home</Link>
      </div>
    );
  }

  return (
    <>
      <div className="section-header">
        <p className="section-eyebrow">Order history</p>
        <h1 className="section-title">Your Orders</h1>
        <p className="section-subtitle">Track active orders and view past deliveries.</p>
      </div>

      {!orders || orders.length === 0 ? (
        <div className="empty-state">
          <div className="empty-state-icon">📭</div>
          <p className="empty-state-title">No orders yet</p>
          <p className="empty-state-desc">Place your first breakfast order to see it here.</p>
          <Link to="/vendors" className="btn-primary">Browse Vendors</Link>
        </div>
      ) : (
        <div style={{ display: 'grid', gap: 'var(--space-5)' }}>
          {orders.map((order) => {
            const cfg = STATUS_CONFIG[order.status] ?? { label: order.status, badge: 'badge-warning' };
            const rank = ORDER_STATUS_RANK.indexOf(order.status as OrderStatus);
            const isActive = !['DELIVERED', 'CANCELLED'].includes(order.status);

            return (
              <div key={order.orderId} className="panel">
                <div
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'flex-start',
                    flexWrap: 'wrap',
                    gap: 'var(--space-3)',
                    marginBottom: 'var(--space-5)'
                  }}
                >
                  <div>
                    <p style={{ fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: '1.1rem' }}>
                      Order #{order.orderId.toString().slice(0, 8).toUpperCase()}
                    </p>
                    <p className="text-sm text-muted">
                      {order.scheduledFor
                        ? `Scheduled: ${new Date(order.scheduledFor).toLocaleString()}`
                        : 'Standard delivery'}
                    </p>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)' }}>
                    <span className={`badge ${cfg.badge}`}>{cfg.label}</span>
                    <span style={{ fontWeight: 700, fontSize: '1.05rem', color: 'var(--text)' }}>
                      {order.currency} ${Number(order.totalAmount).toFixed(2)}
                    </span>
                  </div>
                </div>

                {/* Progress timeline for active orders */}
                {isActive && (
                  <div
                    style={{
                      display: 'flex',
                      gap: 0,
                      alignItems: 'center',
                      marginBottom: 'var(--space-5)',
                      overflowX: 'auto',
                      paddingBottom: 'var(--space-2)'
                    }}
                  >
                    {TIMELINE_STEPS.map((ts, i) => {
                      const tsRank = ORDER_STATUS_RANK.indexOf(ts.status);
                      const isDone = tsRank <= rank;
                      const isCurrent = ts.status === order.status;

                      return (
                        <div key={ts.status} style={{ display: 'flex', alignItems: 'center', flex: i < TIMELINE_STEPS.length - 1 ? 1 : 0 }}>
                          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
                            <div
                              style={{
                                width: 36,
                                height: 36,
                                borderRadius: '50%',
                                background: isDone ? 'var(--brand)' : 'var(--surface-3)',
                                border: `2px solid ${isDone ? 'var(--brand)' : 'var(--line)'}`,
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                fontSize: '0.9rem',
                                boxShadow: isCurrent ? '0 0 0 4px rgba(210,77,41,0.2)' : 'none',
                                transition: 'all 0.3s ease'
                              }}
                            >
                              {isDone
                                ? ts.icon
                                : <span style={{ color: 'var(--muted)', fontSize: '0.7rem', fontWeight: 700 }}>{i + 1}</span>}
                            </div>
                            <span style={{ fontSize: '0.7rem', fontWeight: 500, color: isDone ? 'var(--brand-dark)' : 'var(--muted)', whiteSpace: 'nowrap' }}>
                              {ts.label}
                            </span>
                          </div>
                          {i < TIMELINE_STEPS.length - 1 && (
                            <div
                              style={{
                                flex: 1,
                                height: 2,
                                background: tsRank < rank ? 'var(--brand)' : 'var(--line)',
                                margin: '0 var(--space-2)',
                                marginBottom: 20,
                                minWidth: 40
                              }}
                            />
                          )}
                        </div>
                      );
                    })}
                  </div>
                )}

                <div style={{ display: 'flex', gap: 'var(--space-3)', flexWrap: 'wrap' }}>
                  {isActive && (
                    <Link to={`/tracking/${order.orderId}`} className="btn-primary" style={{ fontSize: '0.875rem' }}>
                      🗺️ Track Delivery
                    </Link>
                  )}
                  {order.status === 'DELIVERED' && (
                    <Link to="/vendors" className="btn-ghost" style={{ fontSize: '0.875rem' }}>
                      Reorder
                    </Link>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </>
  );
}
