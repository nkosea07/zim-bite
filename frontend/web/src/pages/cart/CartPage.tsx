import { Link } from 'react-router-dom';
import { useCartStore } from '../../app/store/cartStore';
import { toast } from '../../app/store/toastStore';

const DELIVERY_FEE = 1.5;

export function CartPage() {
  const items          = useCartStore((s) => s.items);
  const total          = useCartStore((s) => s.total());
  const updateQuantity = useCartStore((s) => s.updateQuantity);
  const clearCart      = useCartStore((s) => s.clearCart);

  function handleRemove(id: string, name: string) {
    updateQuantity(id, 0);
    toast.show('Removed', `${name} removed from cart.`);
  }

  const subtotal   = total;
  const grandTotal = subtotal + (items.length > 0 ? DELIVERY_FEE : 0);

  return (
    <>
      <div className="section-header">
        <p className="section-eyebrow">Your selections</p>
        <h1 className="section-title">Cart</h1>
        {items.length > 0 && (
          <p className="section-subtitle">{items.length} item{items.length !== 1 ? 's' : ''} from your selected vendor</p>
        )}
      </div>

      {items.length === 0 ? (
        <div className="empty-state">
          <div className="empty-state-icon">🛒</div>
          <p className="empty-state-title">Your cart is empty</p>
          <p className="empty-state-desc">Browse vendors and add breakfast items to get started.</p>
          <Link to="/vendors" className="btn-primary">Browse Vendors</Link>
        </div>
      ) : (
        <div
          style={{
            display: 'grid',
            gap: 'var(--space-5)',
            gridTemplateColumns: '1fr',
            alignItems: 'start'
          }}
        >
          <div style={{ display: 'grid', gap: 'var(--space-5)', gridTemplateColumns: 'repeat(auto-fit, minmax(340px, 1fr))', alignItems: 'start' }}>
            {/* ── Items ───────────────────────────────────────── */}
            <div className="panel">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--space-5)' }}>
                <p className="panel-title" style={{ margin: 0 }}>Items</p>
                <button
                  className="btn-ghost"
                  onClick={() => { clearCart(); toast.show('Cart cleared'); }}
                  style={{ fontSize: '0.8rem', color: 'var(--danger)' }}
                >
                  Clear all
                </button>
              </div>

              {items.map((item) => (
                <div key={item.menuItemId} className="cart-item">
                  <div
                    style={{
                      width: 52,
                      height: 52,
                      borderRadius: 'var(--radius-md)',
                      background: 'var(--surface-3)',
                      flexShrink: 0,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: '1.4rem'
                    }}
                  >
                    🍳
                  </div>

                  <div className="cart-item-info">
                    <p className="cart-item-name">{item.name}</p>
                    <p className="cart-item-unit">${item.unitPrice.toFixed(2)} each</p>
                  </div>

                  <div className="qty-stepper">
                    <button
                      className="qty-btn"
                      onClick={() => updateQuantity(item.menuItemId, item.quantity - 1)}
                    >
                      −
                    </button>
                    <span className="qty-value">{item.quantity}</span>
                    <button
                      className="qty-btn"
                      onClick={() => updateQuantity(item.menuItemId, item.quantity + 1)}
                    >
                      +
                    </button>
                  </div>

                  <p className="cart-item-subtotal">
                    ${(item.unitPrice * item.quantity).toFixed(2)}
                  </p>

                  <button
                    className="btn-icon"
                    onClick={() => handleRemove(item.menuItemId, item.name)}
                    aria-label="Remove item"
                    style={{ color: 'var(--danger)', background: 'var(--danger-tint)', border: 'none' }}
                  >
                    ✕
                  </button>
                </div>
              ))}
            </div>

            {/* ── Order summary ──────────────────────────────── */}
            <div className="panel" style={{ position: 'sticky', top: 'calc(var(--topbar-h) + 16px)' }}>
              <p className="panel-title">Order Summary</p>

              <div className="summary-row">
                <span className="label">Subtotal</span>
                <span className="value">${subtotal.toFixed(2)}</span>
              </div>
              <div className="summary-row">
                <span className="label">Delivery fee</span>
                <span className="value">${DELIVERY_FEE.toFixed(2)}</span>
              </div>
              <div className="summary-row total">
                <span className="label">Total</span>
                <span className="value text-brand">${grandTotal.toFixed(2)}</span>
              </div>

              <div
                style={{
                  background: 'var(--success-tint)',
                  border: '1px solid var(--success)',
                  borderRadius: 'var(--radius-md)',
                  padding: 'var(--space-3) var(--space-4)',
                  fontSize: '0.82rem',
                  color: 'var(--success)',
                  margin: 'var(--space-5) 0'
                }}
              >
                ✅ Delivery window: <strong>5AM – 10AM</strong> today
              </div>

              <Link
                to="/checkout"
                className="btn-primary"
                style={{ width: '100%', justifyContent: 'center' }}
              >
                Proceed to Checkout →
              </Link>

              <Link
                to="/vendors"
                className="btn-ghost"
                style={{ width: '100%', justifyContent: 'center', marginTop: 'var(--space-3)' }}
              >
                + Add more items
              </Link>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
