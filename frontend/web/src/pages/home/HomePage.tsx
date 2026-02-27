import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { zimbiteApi } from '../../services/zimbiteApi';
import { useAuthStore } from '../../app/store/authStore';
import { VendorCardSkeleton } from '../../components/ui/Skeleton';

const FEATURES = [
  { icon: '⏰', title: '5AM – 10AM Window',   desc: 'Fresh breakfast ordered ahead, delivered at peak morning hours across Zimbabwe.' },
  { icon: '🗺️', title: 'Nearby Vendors',      desc: 'Discover local breakfast spots sorted by distance from your location.' },
  { icon: '🍳', title: 'Meal Builder',        desc: 'Compose a custom breakfast from fresh components with real-time pricing.' },
  { icon: '📱', title: 'Low-Bandwidth Ready', desc: 'Optimised for Zimbabwe mobile networks — fast even on 2G connections.' }
];

export function HomePage() {
  const { userId } = useAuthStore();

  const { data: vendors = [], isLoading } = useQuery({
    queryKey: ['vendors'],
    queryFn: zimbiteApi.listVendors
  });

  const now = new Date();
  const hr = now.getHours();
  const isOpen = hr >= 5 && hr < 10;

  return (
    <>
      {/* ── Hero ─────────────────────────────────────────────── */}
      <section className="hero">
        <div className="hero-eyebrow">
          <span className="hero-window-dot" style={{ background: isOpen ? 'var(--success)' : 'var(--muted)' }} />
          {isOpen ? 'Orders open now · closes 10AM' : 'Opens daily at 5AM · order ahead'}
        </div>

        <h1 className="hero-title">
          Breakfast <em>delivered</em>&nbsp;to your door in Zimbabwe
        </h1>

        <p className="hero-description">
          Browse nearby vendors, build your perfect morning meal, and track delivery
          in real time — all optimised for Zimbabwe's mobile networks.
        </p>

        <div className="hero-cta-row">
          <Link to="/vendors" className="btn-primary btn-lg">
            Browse Vendors →
          </Link>
          <Link to="/meal-builder" className="btn-secondary btn-lg">
            🍳 Meal Builder
          </Link>
        </div>

        {!userId && (
          <div className="hero-window">
            <span>New here?</span>
            <Link to="/auth/login" className="btn-ghost" style={{ padding: '2px 10px' }}>
              Sign in to order
            </Link>
          </div>
        )}
      </section>

      {/* ── Nearby Vendors ───────────────────────────────────── */}
      <section style={{ marginTop: 'var(--space-12)' }}>
        <div className="section-header" style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', flexWrap: 'wrap', gap: 'var(--space-4)' }}>
          <div>
            <p className="section-eyebrow">Now open near you</p>
            <h2 className="section-title">Popular Vendors</h2>
            <p className="section-subtitle">Fresh breakfast from trusted kitchens around your area.</p>
          </div>
          <Link to="/vendors" className="btn-ghost">See all →</Link>
        </div>

        <div className="vendor-grid">
          {isLoading
            ? Array.from({ length: 4 }).map((_, i) => <VendorCardSkeleton key={i} />)
            : vendors.slice(0, 4).map((vendor, i) => (
                <Link
                  key={vendor.id}
                  to={`/vendors?id=${vendor.id}`}
                  className="card"
                  style={{
                    textDecoration: 'none',
                    animation: `rise-in 400ms ease ${i * 60}ms both`
                  }}
                >
                  <div
                    className="vendor-card-thumb"
                    style={{
                      background: `linear-gradient(135deg,
                        hsl(${(i * 53 + 15) % 360},55%,38%) 0%,
                        hsl(${(i * 53 + 55) % 360},60%,50%) 100%)`
                    }}
                  >
                    <span className={vendor.open ? 'vendor-open-badge' : 'vendor-closed-badge'}>
                      {vendor.open ? '● Open' : 'Closed'}
                    </span>
                  </div>
                  <div className="card-body">
                    <p className="vendor-card-name">{vendor.name}</p>
                    <div className="vendor-card-meta">
                      <span className="star-rating">★★★★☆</span>
                      <span>·</span>
                      <span>{vendor.city}</span>
                    </div>
                    <div style={{ marginTop: 'var(--space-3)' }}>
                      <span
                        className="btn-secondary"
                        style={{ fontSize: '0.8rem', padding: '6px 14px' }}
                      >
                        View Menu →
                      </span>
                    </div>
                  </div>
                </Link>
              ))}
        </div>
      </section>

      {/* ── Feature highlights ───────────────────────────────── */}
      <section style={{ marginTop: 'var(--space-16)' }}>
        <div className="section-header">
          <p className="section-eyebrow">Why ZimBite</p>
          <h2 className="section-title">Built for Zimbabwe</h2>
        </div>
        <div className="features-grid">
          {FEATURES.map((f, i) => (
            <div
              key={f.title}
              className="feature-card"
              style={{ animation: `rise-in 400ms ease ${i * 80}ms both` }}
            >
              <div className="feature-icon">{f.icon}</div>
              <p className="feature-title">{f.title}</p>
              <p className="feature-desc">{f.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ── CTA banner ───────────────────────────────────────── */}
      <section
        style={{
          marginTop: 'var(--space-16)',
          background: 'var(--brand)',
          borderRadius: 'var(--radius-xl)',
          padding: 'var(--space-12) var(--page-gutter)',
          textAlign: 'center',
          color: '#fff'
        }}
      >
        <h2
          style={{
            fontFamily: 'var(--font-display)',
            fontSize: 'clamp(1.5rem, 3vw, 2.25rem)',
            fontWeight: 900,
            marginBottom: 'var(--space-3)'
          }}
        >
          Ready for breakfast?
        </h2>
        <p style={{ opacity: 0.85, marginBottom: 'var(--space-6)', fontSize: '1rem' }}>
          Place your order before 10AM and get it delivered fresh to your door.
        </p>
        <Link
          to="/vendors"
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: 'var(--space-2)',
            background: '#fff',
            color: 'var(--brand-dark)',
            borderRadius: 'var(--radius-md)',
            padding: 'var(--space-3) var(--space-8)',
            fontWeight: 700,
            fontSize: '0.95rem',
            textDecoration: 'none'
          }}
        >
          Start Ordering →
        </Link>
      </section>
    </>
  );
}
