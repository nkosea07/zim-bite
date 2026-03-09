import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../app/store/authStore';
import { useCartStore } from '../../app/store/cartStore';
import { zimbiteApi, type Address } from '../../services/zimbiteApi';
import { toast } from '../../app/store/toastStore';
import { AddressPickerMap, type AddressResult } from '../../components/AddressPickerMap';

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

/** Build ISO 8601 datetime for the next valid breakfast window from an HH:mm string */
function buildScheduledFor(timeHHmm: string): string {
  const [h, m] = timeHHmm.split(':').map(Number);
  const d = new Date();
  d.setHours(h, m, 0, 0);
  if (d <= new Date()) d.setDate(d.getDate() + 1);
  return d.toISOString();
}

function formatAddressLine(addr: Address): string {
  const parts = [addr.line1, addr.area, addr.city].filter(Boolean);
  return parts.join(', ');
}

export function CheckoutPage() {
  const navigate = useNavigate();
  const auth     = useAuthStore();
  const cart     = useCartStore();
  const qc       = useQueryClient();

  const [step, setStep]                       = useState<Step>('delivery');
  const [selectedAddress, setSelectedAddress] = useState<Address | null>(null);
  const [showAddressMap, setShowAddressMap]   = useState(false);
  const [scheduledTime, setScheduled]         = useState('07:00');
  const [provider, setProvider]               = useState<Provider>('ECOCASH');

  const subtotal   = useMemo(() => cart.total(), [cart]);
  const grandTotal = subtotal + DELIVERY_FEE;
  const stepIndex  = STEPS.findIndex((s) => s.id === step);

  const { data: addresses = [], isLoading: addressesLoading } = useQuery({
    queryKey: ['addresses'],
    queryFn:  zimbiteApi.listAddresses,
    enabled:  !!auth.userId
  });

  const addAddressMutation = useMutation({
    mutationFn: zimbiteApi.addAddress,
    onSuccess: (saved) => {
      qc.invalidateQueries({ queryKey: ['addresses'] });
      setSelectedAddress(saved);
      setShowAddressMap(false);
      toast.success('Address saved!', 'Delivery address added to your account.');
    },
    onError: () => {
      toast.error('Failed to save address', 'Please try again.');
    }
  });

  // Track order ID so we can retry payment without duplicating the order
  const [pendingOrderId, setPendingOrderId] = useState<string | null>(null);

  const checkoutMutation = useMutation({
    mutationFn: async () => {
      if (!auth.userId)                        throw new Error('Sign in to place an order.');
      if (!cart.vendorId || !cart.items.length) throw new Error('Your cart is empty.');
      if (!selectedAddress)                    throw new Error('Please select a delivery address.');

      // Reuse existing order on retry to avoid duplicates
      let orderId = pendingOrderId;
      let order;

      if (!orderId) {
        order = await zimbiteApi.placeOrder({
          vendorId:          cart.vendorId,
          deliveryAddressId: selectedAddress.id,
          currency:          cart.currency,
          items:             cart.items.map((i) => ({ menuItemId: i.menuItemId, quantity: i.quantity })),
          scheduledFor:      buildScheduledFor(scheduledTime)
        });
        orderId = order.orderId;
        setPendingOrderId(orderId);
      }

      const payment = await zimbiteApi.initiatePayment({
        orderId,
        provider,
        amount:   order?.totalAmount ?? cart.total() + DELIVERY_FEE,
        currency: order?.currency ?? cart.currency
      });

      return { orderId, payment };
    },
    onSuccess: ({ orderId }) => {
      cart.clearCart();
      setPendingOrderId(null);
      toast.success('Order placed!', `Order #${orderId.slice(0, 8).toUpperCase()} is confirmed.`);
      navigate('/orders');
    },
    onError: (err) => {
      // Order was created but payment failed — user can retry without re-creating order
      toast.error('Checkout failed', err instanceof Error ? err.message : 'Please try again.');
    }
  });

  function handleAddressResult(result: AddressResult) {
    addAddressMutation.mutate(result);
  }

  const canProceedDelivery = selectedAddress !== null;
  const canSubmit          = canProceedDelivery && cart.items.length > 0;

  return (
    <>
      {showAddressMap && (
        <AddressPickerMap
          onSave={handleAddressResult}
          onClose={() => setShowAddressMap(false)}
        />
      )}

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

              {/* Address format hint */}
              <div
                style={{
                  background: 'var(--surface-3)',
                  borderRadius: 'var(--radius-md)',
                  padding: 'var(--space-3) var(--space-4)',
                  marginBottom: 'var(--space-4)',
                  fontSize: '0.8rem',
                  color: 'var(--muted)',
                  borderLeft: '3px solid var(--brand)'
                }}
              >
                <strong style={{ color: 'var(--text)' }}>Address format:</strong>{' '}
                House/Stand No. Street, Suburb, City
                <br />
                <em>e.g. 12 Samora Machel Ave, Avondale, Harare</em>
              </div>

              {/* Address selector */}
              <div className="stacked-form">
                <div className="form-field">
                  <label className="form-label">Select delivery address</label>

                  {addressesLoading ? (
                    <div style={{ display: 'grid', gap: 'var(--space-2)' }}>
                      {[1, 2].map((n) => (
                        <div key={n} className="skeleton" style={{ height: 64, borderRadius: 'var(--radius-md)' }} />
                      ))}
                    </div>
                  ) : (
                    <div style={{ display: 'grid', gap: 'var(--space-2)' }}>
                      {addresses.map((addr) => {
                        const isSelected = selectedAddress?.id === addr.id;
                        return (
                          <button
                            key={addr.id}
                            onClick={() => setSelectedAddress(addr)}
                            style={{
                              textAlign: 'left',
                              background: isSelected ? 'var(--brand-tint)' : 'var(--surface-3)',
                              border: `2px solid ${isSelected ? 'var(--brand)' : 'var(--line)'}`,
                              borderRadius: 'var(--radius-md)',
                              padding: 'var(--space-3) var(--space-4)',
                              cursor: 'pointer',
                              display: 'flex',
                              alignItems: 'flex-start',
                              gap: 'var(--space-3)',
                              transition: 'border-color var(--dur-fast), background var(--dur-fast)'
                            }}
                          >
                            <span style={{
                              width: 22, height: 22, borderRadius: '50%', flexShrink: 0, marginTop: 2,
                              border: `2px solid ${isSelected ? 'var(--brand)' : 'var(--line)'}`,
                              background: isSelected ? 'var(--brand)' : 'transparent',
                              display: 'flex', alignItems: 'center', justifyContent: 'center',
                              color: '#fff', fontSize: '0.7rem'
                            }}>
                              {isSelected ? '✓' : ''}
                            </span>
                            <div>
                              <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-2)', marginBottom: 2 }}>
                                <span className="badge badge-brand" style={{ fontSize: '0.7rem' }}>{addr.label}</span>
                              </div>
                              <p style={{ fontSize: '0.875rem', fontWeight: 500, color: 'var(--text)' }}>
                                {formatAddressLine(addr)}
                              </p>
                              <p style={{ fontSize: '0.7rem', fontFamily: 'monospace', color: 'var(--muted)', marginTop: 2 }}>
                                📌 {addr.latitude.toFixed(5)}, {addr.longitude.toFixed(5)}
                              </p>
                            </div>
                          </button>
                        );
                      })}

                      {/* Add new address card */}
                      <button
                        onClick={() => setShowAddressMap(true)}
                        style={{
                          textAlign: 'left',
                          background: 'var(--surface-3)',
                          border: '2px dashed var(--line)',
                          borderRadius: 'var(--radius-md)',
                          padding: 'var(--space-3) var(--space-4)',
                          cursor: 'pointer',
                          display: 'flex',
                          alignItems: 'center',
                          gap: 'var(--space-3)',
                          color: 'var(--muted)',
                          fontSize: '0.875rem',
                          transition: 'border-color var(--dur-fast)'
                        }}
                        onMouseEnter={(e) => (e.currentTarget.style.borderColor = 'var(--brand)')}
                        onMouseLeave={(e) => (e.currentTarget.style.borderColor = 'var(--line)')}
                      >
                        <span style={{ fontSize: '1.2rem' }}>＋</span>
                        {addresses.length === 0 ? 'Add a delivery address' : 'Add a new address'}
                      </button>
                    </div>
                  )}
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
                <div style={{ display: 'flex', justifyContent: 'space-between', gap: 'var(--space-3)' }}>
                  <span className="text-muted">Address</span>
                  <span className="fw-semibold" style={{ textAlign: 'right' }}>
                    {selectedAddress ? formatAddressLine(selectedAddress) : '—'}
                  </span>
                </div>
                {selectedAddress && (
                  <div style={{ display: 'flex', justifyContent: 'space-between', gap: 'var(--space-3)' }}>
                    <span className="text-muted">Coordinates</span>
                    <span style={{ fontFamily: 'monospace', fontSize: '0.78rem', color: 'var(--muted)' }}>
                      {selectedAddress.latitude.toFixed(5)}, {selectedAddress.longitude.toFixed(5)}
                    </span>
                  </div>
                )}
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
