import { useQuery } from '@tanstack/react-query';
import { useMemo, useState } from 'react';
import { useCartStore } from '../../app/store/cartStore';
import { zimbiteApi } from '../../services/zimbiteApi';

export function VendorPage() {
  const { data: vendors = [] } = useQuery({ queryKey: ['vendors'], queryFn: zimbiteApi.listVendors });
  const [selectedVendor, setSelectedVendor] = useState<string | null>(null);
  const addItem = useCartStore((state) => state.addItem);

  const activeVendorId = selectedVendor ?? vendors[0]?.id ?? null;

  const { data: menuItems = [] } = useQuery({
    queryKey: ['menu-items', activeVendorId],
    queryFn: () => zimbiteApi.listMenuItems(activeVendorId!),
    enabled: Boolean(activeVendorId)
  });

  const grouped = useMemo(() => {
    const map = new Map<string, typeof menuItems>();
    menuItems.forEach((item) => {
      const bucket = map.get(item.category) ?? [];
      bucket.push(item);
      map.set(item.category, bucket);
    });
    return Array.from(map.entries());
  }, [menuItems]);

  return (
    <section className="grid-two">
      <article className="panel">
        <h2>Vendors</h2>
        {vendors.map((vendor) => (
          <button
            key={vendor.id}
            className={`list-item ${activeVendorId === vendor.id ? 'active' : ''}`}
            onClick={() => setSelectedVendor(vendor.id)}
          >
            <span>{vendor.name}</span>
            <small>{vendor.city} · {vendor.open ? 'Open' : 'Closed'}</small>
          </button>
        ))}
      </article>

      <article className="panel">
        <h2>Menu</h2>
        {grouped.map(([category, items]) => (
          <div key={category} className="category-block">
            <h3>{category}</h3>
            {items.map((item) => (
              <div key={item.id} className="menu-row">
                <div>
                  <strong>{item.name}</strong>
                  <p>{item.currency} {item.basePrice.toFixed(2)}</p>
                </div>
                <button
                  className="btn-secondary"
                  onClick={() => addItem(item.vendorId, {
                    menuItemId: item.id,
                    name: item.name,
                    unitPrice: item.basePrice
                  })}
                >
                  Add
                </button>
              </div>
            ))}
          </div>
        ))}
      </article>
    </section>
  );
}
