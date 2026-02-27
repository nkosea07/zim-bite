import { useMutation } from '@tanstack/react-query';
import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../app/store/authStore';
import { useCartStore } from '../../app/store/cartStore';
import { zimbiteApi } from '../../services/zimbiteApi';
import { toast } from '../../app/store/toastStore';

type Provider = 'ECOCASH' | 'ONEMONEY' | 'CARD' | 'CASH';
type Step = 'delivery' | 'payment' | 'confirm';

const STEPS: { id: Step; label: string }[] = [
  { id: 'delivery', label: 'Delivery' },
  { id: 'payment',  label: 'Payment' },
  { id: 'confirm',  label: 'Confirm' }
];

const PAYMENT_OPTIONS: { id: Provider; icon: string; label: string; desc: string }[] = [
  { id: 'ECOCASH',  icon: '📱', label: 'EcoCash',         desc: 'Econet mobile money' },
  { id: 'ONEMONEY', icon: '💳', label: 'OneMoney',        desc: 'NetOne mobile money' },
  { id: 'CARD',     icon: '🏦', label: 'Visa / Mastercard', desc: 'Debit or credit card' },
  { id: 'CASH',     icon: '💵', label: 'Cash on Delivery', desc: 'Pay when delivered' }
];

const DELIVERY_FEE = 1.5;

export function CheckoutPage() {
  const navigate = useNavigate();
  const auth = useAuthStore();
  const cart = useCartStore();

  const [step, setStep]               = useState<Step>('delivery');
  const [address, setAddress]         = useState('');
  const [scheduledTime, setScheduled] = useState('07:00');
  const [provider, setProvider]       = useState<Provider>('ECOCASH');

  const subtotal   = useMemo(() => cart.total(), [cart]);
  const grandTotal = subtotal + DELIVERY_FEE;

  const stepIndex = STEPS.findIndex((s) => s.id === step);

  const checkoutMutation = useMutation({
    mutationFn: async () => {
      if (!auth.userId)                        throw new Error('Sign in to place an order.');
      if (!cart.vendorId || !cart.items.length) throw new Error('Your cart is empty.');

      const order = await zimbiteApi.placeOrder({
        userId:   auth.userId,
        vendorId: cart.vendorId,
        currency: cart.currency,
        items:    cart.items.map((i) => ({ menuItemId: i.menuItemId, quantity: i.quantity }))
      });

      const payment = await zimbiteApi.initiatePayment({
        orderId:  order.orderId,
        provider,
        amount:   order.totalAmount,
        currency: order.currency
      });

      return { order, payment };
    },
    onSuccess: ({ order }) => {
      cart.clearCart();
      toast.success('Order placed! 🎉', `Order #${order.orderId.slice(0, 8).toUpperCase()} is confirmed.`);
      navigate('/orders');
    },
    onError: (err) => {
      toast.error('Checkout failed', err instanceof Error ? err.message : 'Please try again.');
    }
  });

  const canProceedDelivery = address.trim().length >= 5;
  const canSubmit          = canProceedDelivery && cart.items.length > 0;

  return (
    <>
      <div className="section-header">
        <p className="section-eyebrow">Almost there</p>
        <h1 className="section-title">Checkout</h1>
      </div>

      {/* ── Stepper ──────────────────────────────────────────── */}
      <div className="stepper" style={{ marginBottom: 'var(--space-8)' }}>
        {STEPS.map((s, i) => (
          <div key={s.id} className="stepper-step">
            <div className={`stepper-circle${i < stepIndex ? ' done' : i === stepIndex ? ' active' : ''}`}>
              {i < stepIndex ? '✓' : i + 1}
            </div>
            <span className={`stepper-label${i === stepIndex ? ' active' : i < stepIndex ? ' done' : ''}`}>
              {s.label}
            </span>
            {i < STEPS.length - 1 && (
              <div className={`stepper-line${i < stepIndex ? ' done' : ''}`} />
            )}
          </div>
        ))}
      </div>

      <div style={{ display: 'grid', gap: 'var(--space-5)', gridTemplateColumns: 'repeat(auto-fit, minmax(340px, 1fr))', alignItems: 'start' }}>
        {/* ── Step panels ──────────────────────────────────── */}
        <div className="panel">
          {/* Step 1: Delivery */}
          {step === 'delivery' && (
            <>
              <p className="panel-title">📍 Delivery Details</p>

              <div className="stacked-form">
                <div className="form-field">
                  <label className="form-label" htmlFor="address">Delivery address</label>
                  <input
                    id="address"
                    className="form-input"
                    type="text"
                    value={address}
                    onChange={(e) => setAddress(e.target.value)}
                    placeholder="e.g. 12 Samora Machel Ave, Harare"
                  />
                </div>
                <div className="form-field">
                  <label className="form-label" htmlFor="time">Delivery time</label>
                  <select
                    id="time"
                    className="form-input"
                    value={scheduledTime}
                    onChange={(e) => setScheduled(e.target.value)}
                  >
                    {['05:30','06:00','06:30','07:00','07:30','08:00','08:30','09:00','09:30'].map((t) => (
                      <option key={t} value={t}>{t} AM</option>
                    ))}
                  </select>
                  <span className="form-hint">Delivery window: 5AM – 10AM</span>
                </div>
              </div>

              <button
                className="btn-primary"
                onClick={() => setStep('payment')}
                disabled={!canProceedDelivery}
                style={{ marginTop: 'var(--space-5)', width: '100%', justifyContent: 'center' }}
              >
                Continue to Payment →
              </button>
            </>
          )}

          {/* Step 2: Payment */}
          {step === 'payment' && (
            <>
              <p className="panel-title">💳 Payment Method</p>

              <div className="payment-options">
                {PAYMENT_OPTIONS.map((opt) => (
                  <button
                    key={opt.id}
                    className={`payment-card${provider === opt.id ? ' selected' : ''}`}
                    onClick={() => setProvider(opt.id)}
                  >
                    <div className="payment-card-icon">{opt.icon}</div>
                    <p className="payment-card-label">{opt.label}</p>
                    <p className="text-xs text-muted" style={{ marginTop: 2 }}>{opt.desc}</p>
                  </button>
                ))}
              </div>

              <div style={{ display: 'flex', gap: 'var(--space-3)', marginTop: 'var(--space-5)' }}>
                <button className="btn-secondary" onClick={() => setStep('delivery')} style={{ flex: 1 }}>
                  ← Back
                </button>
                <button
                  className="btn-primary"
                  onClick={() => setStep('confirm')}
                  style={{ flex: 2, justifyContent: 'center' }}
                >
                  Review Order →
                </button>
              </div>
            </>
          )}

          {/* Step 3: Confirm */}
          {step === 'confirm' && (
            <>
              <p className="panel-title">✅ Confirm Order</p>

              <div
                style={{
                  background: 'var(--surface-3)',
                  borderRadius: 'var(--radius-md)',
                  padding: 'var(--space-4)',
                  marginBottom: 'var(--space-5)',
                  display: 'grid',
                  gap: 'var(--space-3)',
                  fontSize: '0.875rem'
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span className="text-muted">Address</span>
                  <span className="fw-semibold">{address}</span>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span className="text-muted">Delivery time</span>
                  <span className="fw-semibold">{scheduledTime} AM</span>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span className="text-muted">Payment</span>
                  <span className="fw-semibold">
                    {PAYMENT_OPTIONS.find((p) => p.id === provider)?.icon}{' '}
                    {PAYMENT_OPTIONS.find((p) => p.id === provider)?.label}
                  </span>
                </div>
              </div>

              <div style={{ display: 'flex', gap: 'var(--space-3)' }}>
                <button className="btn-secondary" onClick={() => setStep('payment')} style={{ flex: 1 }}>
                  ← Back
                </button>
                <button
                  className="btn-primary"
                  onClick={() => checkoutMutation.mutate()}
                  disabled={checkoutMutation.isPending || !canSubmit}
                  style={{ flex: 2, justifyContent: 'center' }}
                >
                  {checkoutMutation.isPending ? (
                    <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-2)' }}>
                      <span style={{ width: 16, height: 16, border: '2px solid rgba(255,255,255,0.3)', borderTopColor: '#fff', borderRadius: '50%', animation: 'spin 0.7s linear infinite', display: 'inline-block' }} />
                      Placing order…
                    </span>
                  ) : `Place Order — $${grandTotal.toFixed(2)}`}
                </button>
              </div>
            </>
          )}
        </div>

        {/* ── Order summary ──────────────────────────────────── */}
        <div className="panel" style={{ position: 'sticky', top: 'calc(var(--topbar-h) + 16px)' }}>
          <p className="panel-title">Order Summary</p>

          {cart.items.map((item) => (
            <div key={item.menuItemId} className="summary-row">
              <span className="label">{item.name} × {item.quantity}</span>
              <span className="value">${(item.unitPrice * item.quantity).toFixed(2)}</span>
            </div>
          ))}

          <div className="summary-row">
            <span className="label">Subtotal</span>
            <span className="value">${subtotal.toFixed(2)}</span>
          </div>
          <div className="summary-row">
            <span className="label">Delivery fee</span>
            <span className="value">$1.50</span>
          </div>
          <div className="summary-row total">
            <span className="label">Total</span>
            <span className="value text-brand">${grandTotal.toFixed(2)}</span>
          </div>
        </div>
      </div>
    </>
  );
}
