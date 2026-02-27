import { useMutation } from '@tanstack/react-query';
import { useMemo, useState } from 'react';
import { useCartStore } from '../../app/store/cartStore';
import { zimbiteApi, type MealCalcResponse } from '../../services/zimbiteApi';
import { toast } from '../../app/store/toastStore';

type Component = {
  componentId: string;
  label: string;
  emoji: string;
  priceEach: number;
  calsEach: number;
  quantity: number;
};

const ALL_COMPONENTS: Component[] = [
  { componentId: '11111111-1111-1111-1111-111111111111', label: 'Egg',        emoji: '🥚', priceEach: 0.8,  calsEach: 78,  quantity: 0 },
  { componentId: '22222222-2222-2222-2222-222222222222', label: 'Avocado',    emoji: '🥑', priceEach: 1.2,  calsEach: 160, quantity: 0 },
  { componentId: '33333333-3333-3333-3333-333333333333', label: 'Bacon',      emoji: '🥓', priceEach: 1.5,  calsEach: 120, quantity: 0 },
  { componentId: '44444444-4444-4444-4444-444444444444', label: 'Spinach',    emoji: '🥬', priceEach: 0.5,  calsEach: 20,  quantity: 0 },
  { componentId: '55555555-5555-5555-5555-555555555555', label: 'Toast',      emoji: '🍞', priceEach: 0.6,  calsEach: 80,  quantity: 0 },
  { componentId: '66666666-6666-6666-6666-666666666666', label: 'Tomato',     emoji: '🍅', priceEach: 0.4,  calsEach: 35,  quantity: 0 },
  { componentId: '77777777-7777-7777-7777-777777777777', label: 'Sausage',    emoji: '🌭', priceEach: 1.8,  calsEach: 180, quantity: 0 },
  { componentId: '88888888-8888-8888-8888-888888888888', label: 'Cheese',     emoji: '🧀', priceEach: 0.9,  calsEach: 110, quantity: 0 },
  { componentId: '99999999-9999-9999-9999-999999999999', label: 'Mushrooms',  emoji: '🍄', priceEach: 0.7,  calsEach: 25,  quantity: 0 },
  { componentId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', label: 'Ginger Tea', emoji: '🍵', priceEach: 1.2,  calsEach: 5,   quantity: 0 }
];

const BASE_PRICE = 3.0;
const BASE_CALS  = 250;

export function MealBuilderPage() {
  const [components, setComponents] = useState<Component[]>(ALL_COMPONENTS);
  const [result, setResult] = useState<MealCalcResponse>({
    totalPrice: BASE_PRICE,
    estimatedCalories: BASE_CALS,
    available: true
  });

  const addItem = useCartStore((s) => s.addItem);

  const selected = components.filter((c) => c.quantity > 0);
  const totalQty = selected.reduce((n, c) => n + c.quantity, 0);

  const payload = useMemo(() => ({
    vendorId:  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001',
    baseItemId: 'dddddddd-dddd-dddd-dddd-ddddddddddd1',
    components: components
      .filter((c) => c.quantity > 0)
      .map((c) => ({ componentId: c.componentId, quantity: c.quantity }))
  }), [components]);

  const calcMutation = useMutation({
    mutationFn: zimbiteApi.calculateMeal,
    onMutate: (next) => {
      const prev = result;
      const totalComponents = next.components.reduce((s, c) => s + c.quantity, 0);
      const optimistic: MealCalcResponse = {
        totalPrice: Number((BASE_PRICE + next.components.reduce((s, c) => {
          const comp = ALL_COMPONENTS.find((a) => a.componentId === c.componentId);
          return s + (comp?.priceEach ?? 1.2) * c.quantity;
        }, 0)).toFixed(2)),
        estimatedCalories: BASE_CALS + next.components.reduce((s, c) => {
          const comp = ALL_COMPONENTS.find((a) => a.componentId === c.componentId);
          return s + (comp?.calsEach ?? 85) * c.quantity;
        }, 0),
        available: totalComponents <= 15
      };
      setResult(optimistic);
      return { prev };
    },
    onError: (_e, _v, ctx) => { if (ctx?.prev) setResult(ctx.prev); },
    onSuccess: (data) => setResult(data)
  });

  function adjust(componentId: string, delta: number) {
    setComponents((prev) =>
      prev.map((c) => {
        if (c.componentId !== componentId) return c;
        const qty = Math.max(0, Math.min(10, c.quantity + delta));
        return { ...c, quantity: qty };
      })
    );
    const next = {
      ...payload,
      components: payload.components
        .map((c) => c.componentId === componentId
          ? { ...c, quantity: Math.max(0, Math.min(10, c.quantity + delta)) }
          : c
        )
        .filter((c) => c.quantity > 0)
    };
    // add if not already there
    const exists = next.components.find((c) => c.componentId === componentId);
    if (!exists && delta > 0) {
      next.components.push({ componentId, quantity: 1 });
    }
    calcMutation.mutate(next);
  }

  function addToCart() {
    if (selected.length === 0) {
      toast.warning('Nothing selected', 'Add at least one component to your meal.');
      return;
    }
    addItem('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', {
      menuItemId: 'custom-' + Date.now(),
      name: `Custom Meal (${selected.map((c) => c.label).join(', ')})`,
      unitPrice: result.totalPrice
    });
    toast.success('Custom meal added! 🍳', `$${result.totalPrice.toFixed(2)} · ${result.estimatedCalories} kcal`);
  }

  return (
    <>
      <div className="section-header">
        <p className="section-eyebrow">Compose your plate</p>
        <h1 className="section-title">Meal Builder</h1>
        <p className="section-subtitle">
          Pick your ingredients. Price and calories update in real time.
        </p>
      </div>

      <div className="grid-two" style={{ gap: 'var(--space-6)', alignItems: 'start' }}>
        {/* ── Component selector ─────────────────────────────── */}
        <div>
          <div className="component-grid">
            {components.map((comp) => (
              <div
                key={comp.componentId}
                className={`component-card${comp.quantity > 0 ? ' selected' : ''}`}
              >
                {comp.quantity > 0 && (
                  <span className="component-qty-badge">{comp.quantity}</span>
                )}
                <div className="component-icon">{comp.emoji}</div>
                <p className="component-name">{comp.label}</p>
                <p className="component-price">${comp.priceEach.toFixed(2)} · {comp.calsEach} kcal</p>
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: 'var(--space-2)',
                    marginTop: 'var(--space-3)'
                  }}
                >
                  <button
                    className="qty-btn"
                    onClick={() => adjust(comp.componentId, -1)}
                    disabled={comp.quantity === 0}
                    style={{ width: 26, height: 26, fontSize: '0.9rem' }}
                  >
                    −
                  </button>
                  <span className="qty-value" style={{ minWidth: 16 }}>{comp.quantity}</span>
                  <button
                    className="qty-btn"
                    onClick={() => adjust(comp.componentId, 1)}
                    style={{ width: 26, height: 26, fontSize: '0.9rem' }}
                  >
                    +
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* ── Summary sidebar ────────────────────────────────── */}
        <div style={{ position: 'sticky', top: 'calc(var(--topbar-h) + 16px)' }}>
          <div className="panel">
            <p className="panel-title">Your Meal</p>

            {/* Meters */}
            <div className="meal-meter" style={{ marginBottom: 'var(--space-5)' }}>
              <div className="meal-meter-item">
                <p className="meal-meter-value">${result.totalPrice.toFixed(2)}</p>
                <p className="meal-meter-label">Total price</p>
              </div>
              <div className="meal-meter-item">
                <p className="meal-meter-value">{result.estimatedCalories}</p>
                <p className="meal-meter-label">Calories</p>
              </div>
              <div className="meal-meter-item">
                <p className="meal-meter-value">{totalQty}</p>
                <p className="meal-meter-label">Items</p>
              </div>
            </div>

            {/* Selected ingredients */}
            {selected.length > 0 ? (
              <div style={{ marginBottom: 'var(--space-5)' }}>
                {selected.map((c) => (
                  <div key={c.componentId} className="summary-row">
                    <span className="label">{c.emoji} {c.label} × {c.quantity}</span>
                    <span className="value">${(c.priceEach * c.quantity).toFixed(2)}</span>
                  </div>
                ))}
                <div className="summary-row total">
                  <span className="label">Total</span>
                  <span className="value text-brand">${result.totalPrice.toFixed(2)}</span>
                </div>
              </div>
            ) : (
              <p className="text-muted text-sm" style={{ marginBottom: 'var(--space-5)', textAlign: 'center' }}>
                Select components above to build your meal
              </p>
            )}

            {calcMutation.isPending && (
              <p className="text-sm text-muted" style={{ marginBottom: 'var(--space-3)', textAlign: 'center' }}>
                <span style={{ display: 'inline-block', animation: 'spin 0.7s linear infinite' }}>↻</span>
                {' '}Recalculating…
              </p>
            )}

            {!result.available && (
              <div className="badge badge-warning" style={{ marginBottom: 'var(--space-3)', justifyContent: 'center', width: '100%' }}>
                ⚠ Some components may not be available
              </div>
            )}

            <button
              className="btn-primary"
              onClick={addToCart}
              disabled={selected.length === 0 || !result.available}
              style={{ width: '100%', justifyContent: 'center' }}
            >
              🛒 Add to Cart — ${result.totalPrice.toFixed(2)}
            </button>
          </div>
        </div>
      </div>
    </>
  );
}
