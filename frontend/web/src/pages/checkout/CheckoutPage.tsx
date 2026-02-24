import { useMutation } from '@tanstack/react-query';
import { useMemo, useState } from 'react';
import { useAuthStore } from '../../app/store/authStore';
import { useCartStore } from '../../app/store/cartStore';
import { zimbiteApi } from '../../services/zimbiteApi';

export function CheckoutPage() {
  const auth = useAuthStore();
  const cart = useCartStore();
  const [result, setResult] = useState<string>('');

  const amount = useMemo(() => cart.total(), [cart]);

  const checkoutMutation = useMutation({
    mutationFn: async () => {
      if (!auth.userId) {
        throw new Error('Session missing. Use demo session on home page.');
      }
      if (!cart.vendorId || cart.items.length === 0) {
        throw new Error('Cart is empty.');
      }

      const order = await zimbiteApi.placeOrder({
        userId: auth.userId,
        vendorId: cart.vendorId,
        currency: cart.currency,
        items: cart.items.map((item) => ({ menuItemId: item.menuItemId, quantity: item.quantity }))
      });

      const payment = await zimbiteApi.initiatePayment({
        orderId: order.orderId,
        provider: 'ECOCASH',
        amount: order.totalAmount,
        currency: order.currency
      });

      return { order, payment };
    },
    onSuccess: ({ order, payment }) => {
      setResult(`Order ${order.orderId} accepted (${order.status}). Payment ${payment.paymentId} is ${payment.status}.`);
      cart.clearCart();
    },
    onError: (error) => {
      setResult(error instanceof Error ? error.message : 'Checkout failed');
    }
  });

  return (
    <section className="panel">
      <h2>Checkout</h2>
      <p>Provider: EcoCash</p>
      <p>Amount: USD {amount.toFixed(2)}</p>
      <button className="btn-primary" onClick={() => checkoutMutation.mutate()} disabled={checkoutMutation.isPending}>
        {checkoutMutation.isPending ? 'Processing...' : 'Place Order and Initiate Payment'}
      </button>
      {result ? <p className="status">{result}</p> : null}
    </section>
  );
}
