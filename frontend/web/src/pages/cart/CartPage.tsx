import { useCartStore } from '../../app/store/cartStore';

export function CartPage() {
  const items = useCartStore((state) => state.items);
  const total = useCartStore((state) => state.total());
  const updateQuantity = useCartStore((state) => state.updateQuantity);

  return (
    <section className="panel">
      <h2>Cart</h2>
      {items.length === 0 ? <p>Your cart is empty.</p> : null}
      {items.map((item) => (
        <div key={item.menuItemId} className="menu-row">
          <div>
            <strong>{item.name}</strong>
            <p>USD {item.unitPrice.toFixed(2)} each</p>
          </div>
          <div className="quantity-wrap">
            <button className="btn-secondary" onClick={() => updateQuantity(item.menuItemId, item.quantity - 1)}>-</button>
            <span>{item.quantity}</span>
            <button className="btn-secondary" onClick={() => updateQuantity(item.menuItemId, item.quantity + 1)}>+</button>
          </div>
        </div>
      ))}
      <hr />
      <p><strong>Total:</strong> USD {total.toFixed(2)}</p>
    </section>
  );
}
