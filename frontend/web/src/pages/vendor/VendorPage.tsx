import { useQuery } from '@tanstack/react-query';
import { useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useCartStore } from '../../app/store/cartStore';
import { zimbiteApi } from '../../services/zimbiteApi';
import { toast } from '../../app/store/toastStore';
import { MenuItemSkeleton } from '../../components/ui/Skeleton';

export function VendorPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const [search, setSearch]             = useState('');
  const [activeCategory, setActiveCategory] = useState<string | null>(null);

  const { data: vendors = [], isLoading: vendorsLoading } = useQuery({
    queryKey: ['vendors'],
    queryFn: zimbiteApi.listVendors
  });

  const paramId         = searchParams.get('id');
  const activeVendorId  = paramId ?? vendors[0]?.id ?? null;
  const activeVendor    = vendors.find((v) => v.id === activeVendorId);

  const { data: menuItems = [], isLoading: menuLoading } = useQuery({
    queryKey: ['menu-items', activeVendorId],
    queryFn:  () => zimbiteApi.listMenuItems(activeVendorId!),
    enabled:  Boolean(activeVendorId)
  });

  const categories = useMemo(() => [...new Set(menuItems.map((i) => i.category))], [menuItems]);

  const filtered = useMemo(() => {
    return menuItems.filter((item) => {
      const matchSearch = !search || item.name.toLowerCase().includes(search.toLowerCase());
      const matchCat    = !activeCategory || item.category === activeCategory;
      return matchSearch && matchCat;
    });
  }, [menuItems, search, activeCategory]);

  const grouped = useMemo(() => {
    const map = new Map<string, typeof filtered>();
    filtered.forEach((item) => {
      const bucket = map.get(item.category) ?? [];
      bucket.push(item);
      map.set(item.category, bucket);
    });
    return Array.from(map.entries());
  }, [filtered]);

  const addItem = useCartStore((s) => s.addItem);

  function handleAdd(item: (typeof menuItems)[number]) {
    addItem(item.vendorId, { menuItemId: item.id, name: item.name, unitPrice: item.basePrice });
    toast.success('Added to cart', item.name);
  }

  return (
    <div className="grid-sidebar">
      {/* ── Vendor list ─────────────────────────────────────── */}
      <aside>
        <div className="panel" style={{ position: 'sticky', top: 'calc(var(--topbar-h) + 16px)' }}>
          <p className="panel-title">Vendors</p>

          <div className="search-bar" style={{ marginBottom: 'var(--space-4)' }}>
            <span style={{ fontSize: '1rem' }}>🔍</span>
            <input
              type="search"
              placeholder="Search vendors…"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          <div className="vendor-list">
            {vendorsLoading
              ? Array.from({ length: 3 }).map((_, i) => (
                  <div key={i} className="vendor-list-item">
                    <div style={{ flex: 1, display: 'grid', gap: 4 }}>
                      <span className="skeleton" style={{ height: 14, width: '70%', borderRadius: 4 }} />
                      <span className="skeleton" style={{ height: 12, width: '40%', borderRadius: 4 }} />
                    </div>
                  </div>
                ))
              : vendors.map((vendor) => (
                  <button
                    key={vendor.id}
                    className={`vendor-list-item${activeVendorId === vendor.id ? ' active' : ''}`}
                    onClick={() => {
                      setSearchParams({ id: vendor.id });
                      setActiveCategory(null);
                    }}
                  >
                    <div className={`vendor-list-item-dot${vendor.open ? '' : ' closed'}`} />
                    <div style={{ flex: 1, textAlign: 'left' }}>
                      <div style={{ fontWeight: 600, fontSize: '0.9rem' }}>{vendor.name}</div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--muted)' }}>
                        {vendor.city} · {vendor.open ? 'Open' : 'Closed'}
                      </div>
                    </div>
                  </button>
                ))}
          </div>
        </div>
      </aside>

      {/* ── Menu ────────────────────────────────────────────── */}
      <main>
        {activeVendor && (
          <div
            style={{
              background: `linear-gradient(135deg, var(--brand) 0%, var(--accent-gold) 100%)`,
              borderRadius: 'var(--radius-lg)',
              padding: 'var(--space-8) var(--space-6)',
              color: '#fff',
              marginBottom: 'var(--space-5)',
              position: 'relative',
              overflow: 'hidden'
            }}
          >
            <div
              style={{
                position: 'absolute', inset: 0, opacity: 0.08,
                backgroundImage: 'radial-gradient(circle at 80% 50%, #fff 0%, transparent 60%)'
              }}
            />
            <span className="badge" style={{ background: 'rgba(255,255,255,0.2)', color: '#fff', marginBottom: 'var(--space-3)' }}>
              {activeVendor.open ? '● Open now' : 'Closed'}
            </span>
            <h2 style={{ fontFamily: 'var(--font-display)', fontSize: '1.6rem', fontWeight: 700, marginBottom: 4 }}>
              {activeVendor.name}
            </h2>
            <p style={{ opacity: 0.85, fontSize: '0.875rem' }}>
              📍 {activeVendor.city} · ★★★★☆ 4.2 (120+ ratings)
            </p>
          </div>
        )}

        {/* Category filter tabs */}
        {categories.length > 0 && (
          <div className="menu-category-tabs" style={{ marginBottom: 'var(--space-5)' }}>
            <button
              className={`category-tab${!activeCategory ? ' active' : ''}`}
              onClick={() => setActiveCategory(null)}
            >
              All
            </button>
            {categories.map((cat) => (
              <button
                key={cat}
                className={`category-tab${activeCategory === cat ? ' active' : ''}`}
                onClick={() => setActiveCategory(cat)}
              >
                {cat}
              </button>
            ))}
          </div>
        )}

        <div className="panel" style={{ padding: 'var(--space-5)' }}>
          {menuLoading ? (
            <div>
              {Array.from({ length: 4 }).map((_, i) => <MenuItemSkeleton key={i} />)}
            </div>
          ) : grouped.length === 0 ? (
            <div className="empty-state" style={{ padding: 'var(--space-10) var(--space-4)' }}>
              <div className="empty-state-icon">🍽️</div>
              <p className="empty-state-title">No items found</p>
              <p className="empty-state-desc">Try clearing your search or selecting a different vendor.</p>
            </div>
          ) : (
            grouped.map(([category, items]) => (
              <div key={category} style={{ marginBottom: 'var(--space-6)' }}>
                <h3
                  style={{
                    fontSize: '0.78rem',
                    fontWeight: 700,
                    letterSpacing: '0.08em',
                    textTransform: 'uppercase',
                    color: 'var(--muted)',
                    marginBottom: 'var(--space-3)',
                    paddingBottom: 'var(--space-2)',
                    borderBottom: '1px solid var(--line)'
                  }}
                >
                  {category}
                </h3>
                {items.map((item) => (
                  <div key={item.id} className="menu-item-card">
                    <div className="menu-item-thumb" />
                    <div className="menu-item-info">
                      <p className="menu-item-name">{item.name}</p>
                      <p className="menu-item-meta">
                        {item.available ? (
                          <span style={{ color: 'var(--success)' }}>● Available</span>
                        ) : (
                          <span style={{ color: 'var(--danger)' }}>Unavailable</span>
                        )}
                      </p>
                    </div>
                    <p className="menu-item-price">${item.basePrice.toFixed(2)}</p>
                    <button
                      className="menu-add-btn"
                      onClick={() => handleAdd(item)}
                      disabled={!item.available}
                      aria-label={`Add ${item.name} to cart`}
                    >
                      +
                    </button>
                  </div>
                ))}
              </div>
            ))
          )}
        </div>
      </main>
    </div>
  );
}
