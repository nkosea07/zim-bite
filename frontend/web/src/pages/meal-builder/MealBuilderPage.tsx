import { useMutation } from '@tanstack/react-query';
import { useCallback, useMemo, useState } from 'react';
import {
  DndContext,
  DragOverlay,
  PointerSensor,
  KeyboardSensor,
  useSensor,
  useSensors,
  type DragStartEvent,
  type DragEndEvent,
} from '@dnd-kit/core';
import { useCartStore } from '../../app/store/cartStore';
import { zimbiteApi, type MealCalcResponse } from '../../services/zimbiteApi';
import { toast } from '../../app/store/toastStore';
import { MealTabs } from './MealTabs';
import { MealPlate } from './MealPlate';
import { DraggableIngredient } from './DraggableIngredient';
import './MealBuilderPage.css';

/* ── Types ─────────────────────────────────────────── */

type CatalogComponent = {
  componentId: string;
  label: string;
  emoji: string;
  category: 'Proteins' | 'Carbs' | 'Greens' | 'Extras' | 'Drinks';
  priceEach: number;
  calsEach: number;
};

type PlateIngredient = {
  componentId: string;
  label: string;
  emoji: string;
  priceEach: number;
  calsEach: number;
  quantity: number;
  plateX: number;
  plateY: number;
};

type Meal = {
  id: string;
  label: string;
  ingredients: PlateIngredient[];
  totalPrice: number;
  totalCalories: number;
  available: boolean;
};

type BuilderMode = 'classic' | 'drag';

/* ── Constants ─────────────────────────────────────── */

const CATEGORIES = ['Proteins', 'Carbs', 'Greens', 'Extras', 'Drinks'] as const;

const CATEGORY_ICONS: Record<string, string> = {
  Proteins: '🥩',
  Carbs: '🍞',
  Greens: '🥬',
  Extras: '🧀',
  Drinks: '🍵',
};

const ALL_COMPONENTS: CatalogComponent[] = [
  { componentId: '11111111-1111-1111-1111-111111111111', label: 'Egg',        emoji: '🥚', category: 'Proteins', priceEach: 0.8,  calsEach: 78  },
  { componentId: '33333333-3333-3333-3333-333333333333', label: 'Bacon',      emoji: '🥓', category: 'Proteins', priceEach: 1.5,  calsEach: 120 },
  { componentId: '77777777-7777-7777-7777-777777777777', label: 'Sausage',    emoji: '🌭', category: 'Proteins', priceEach: 1.8,  calsEach: 180 },
  { componentId: '55555555-5555-5555-5555-555555555555', label: 'Toast',      emoji: '🍞', category: 'Carbs',    priceEach: 0.6,  calsEach: 80  },
  { componentId: '22222222-2222-2222-2222-222222222222', label: 'Avocado',    emoji: '🥑', category: 'Greens',   priceEach: 1.2,  calsEach: 160 },
  { componentId: '44444444-4444-4444-4444-444444444444', label: 'Spinach',    emoji: '🥬', category: 'Greens',   priceEach: 0.5,  calsEach: 20  },
  { componentId: '66666666-6666-6666-6666-666666666666', label: 'Tomato',     emoji: '🍅', category: 'Greens',   priceEach: 0.4,  calsEach: 35  },
  { componentId: '99999999-9999-9999-9999-999999999999', label: 'Mushrooms',  emoji: '🍄', category: 'Extras',   priceEach: 0.7,  calsEach: 25  },
  { componentId: '88888888-8888-8888-8888-888888888888', label: 'Cheese',     emoji: '🧀', category: 'Extras',   priceEach: 0.9,  calsEach: 110 },
  { componentId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', label: 'Ginger Tea', emoji: '🍵', category: 'Drinks',   priceEach: 1.2,  calsEach: 5   },
];

const BASE_PRICE = 3.0;
const BASE_CALS  = 250;
const MAX_MEALS  = 5;
const MAX_PER_COMPONENT = 10;
const MAX_ITEMS_PER_MEAL = 15;
const VENDOR_ID = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001';
const BASE_ITEM_ID = 'dddddddd-dddd-dddd-dddd-ddddddddddd1';

/* ── Helpers ───────────────────────────────────────── */

let mealCounter = 0;
function createEmptyMeal(n?: number): Meal {
  mealCounter++;
  return {
    id: `meal-${Date.now()}-${mealCounter}`,
    label: `Meal ${n ?? mealCounter}`,
    ingredients: [],
    totalPrice: BASE_PRICE,
    totalCalories: BASE_CALS,
    available: true,
  };
}

function recalcMeal(meal: Meal): Meal {
  const addedPrice = meal.ingredients.reduce((s, i) => s + i.priceEach * i.quantity, 0);
  const addedCals = meal.ingredients.reduce((s, i) => s + i.calsEach * i.quantity, 0);
  const totalQty = meal.ingredients.reduce((s, i) => s + i.quantity, 0);
  return {
    ...meal,
    totalPrice: Number((BASE_PRICE + addedPrice).toFixed(2)),
    totalCalories: BASE_CALS + addedCals,
    available: totalQty <= MAX_ITEMS_PER_MEAL,
  };
}

/** Golden-angle placement for plate ingredients */
function platePosition(index: number, total: number): { plateX: number; plateY: number } {
  if (total === 1) return { plateX: 0.5, plateY: 0.5 };
  const goldenAngle = 137.508 * (Math.PI / 180);
  const angle = index * goldenAngle;
  const r = Math.sqrt((index + 1) / (total + 1)) * 0.32;
  return {
    plateX: 0.5 + r * Math.cos(angle),
    plateY: 0.5 + r * Math.sin(angle),
  };
}

/* ── Component ─────────────────────────────────────── */

export function MealBuilderPage() {
  const [meals, setMeals] = useState<Meal[]>([createEmptyMeal(1)]);
  const [activeMealIndex, setActiveMealIndex] = useState(0);
  const [mode, setMode] = useState<BuilderMode>('classic');
  const [dragId, setDragId] = useState<string | null>(null);
  const [activeCategory, setActiveCategory] = useState<string>('Proteins');

  const addItem = useCartStore((s) => s.addItem);
  const activeMeal = meals[activeMealIndex];

  // DnD sensors
  const pointerSensor = useSensor(PointerSensor, {
    activationConstraint: { distance: 8 },
  });
  const keyboardSensor = useSensor(KeyboardSensor);
  const sensors = useSensors(pointerSensor, keyboardSensor);

  // Ingredient quantities for the active meal (lookup by componentId)
  const qtyMap = useMemo(() => {
    const m = new Map<string, number>();
    for (const ing of activeMeal.ingredients) {
      m.set(ing.componentId, ing.quantity);
    }
    return m;
  }, [activeMeal.ingredients]);

  const totalQty = activeMeal.ingredients.reduce((s, i) => s + i.quantity, 0);

  // Build the API payload for the active meal
  const payload = useMemo(() => ({
    vendorId: VENDOR_ID,
    baseItemId: BASE_ITEM_ID,
    components: activeMeal.ingredients
      .filter((i) => i.quantity > 0)
      .map((i) => ({ componentId: i.componentId, quantity: i.quantity })),
  }), [activeMeal.ingredients]);

  const calcMutation = useMutation({
    mutationFn: zimbiteApi.calculateMeal,
    onSuccess: (data) => {
      setMeals((prev) =>
        prev.map((m, i) =>
          i === activeMealIndex
            ? { ...m, totalPrice: data.totalPrice, totalCalories: data.estimatedCalories, available: data.available }
            : m
        )
      );
    },
  });

  /* ── Adjust ingredient (scoped to active meal) ─── */
  const adjust = useCallback(
    (componentId: string, delta: number) => {
      setMeals((prev) => {
        const updated = [...prev];
        const meal = { ...updated[activeMealIndex] };
        const ingredients = [...meal.ingredients];
        const idx = ingredients.findIndex((i) => i.componentId === componentId);

        if (idx >= 0) {
          const newQty = Math.max(0, Math.min(MAX_PER_COMPONENT, ingredients[idx].quantity + delta));
          if (newQty === 0) {
            ingredients.splice(idx, 1);
          } else {
            ingredients[idx] = { ...ingredients[idx], quantity: newQty };
          }
        } else if (delta > 0) {
          const catalog = ALL_COMPONENTS.find((c) => c.componentId === componentId);
          if (!catalog) return prev;
          const total = ingredients.length;
          const pos = platePosition(total, total + 1);
          ingredients.push({
            componentId: catalog.componentId,
            label: catalog.label,
            emoji: catalog.emoji,
            priceEach: catalog.priceEach,
            calsEach: catalog.calsEach,
            quantity: 1,
            ...pos,
          });
        }

        meal.ingredients = ingredients;
        updated[activeMealIndex] = recalcMeal(meal);
        return updated;
      });

      // Fire API calc
      const nextComponents = (() => {
        const meal = meals[activeMealIndex];
        const ings = [...meal.ingredients];
        const idx = ings.findIndex((i) => i.componentId === componentId);
        const result: Array<{ componentId: string; quantity: number }> = [];

        for (const ing of ings) {
          if (ing.componentId === componentId) {
            const q = Math.max(0, Math.min(MAX_PER_COMPONENT, ing.quantity + delta));
            if (q > 0) result.push({ componentId: ing.componentId, quantity: q });
          } else {
            result.push({ componentId: ing.componentId, quantity: ing.quantity });
          }
        }
        if (idx < 0 && delta > 0) {
          result.push({ componentId, quantity: 1 });
        }
        return result;
      })();

      calcMutation.mutate({
        vendorId: VENDOR_ID,
        baseItemId: BASE_ITEM_ID,
        components: nextComponents,
      });
    },
    [activeMealIndex, meals, calcMutation],
  );

  /* ── DnD handlers ────────────────────────────────── */
  function handleDragStart(event: DragStartEvent) {
    setDragId(event.active.id as string);
  }

  function handleDragEnd(event: DragEndEvent) {
    setDragId(null);
    if (event.over?.id !== 'meal-plate') return;
    const componentId = event.active.id as string;
    adjust(componentId, 1);
  }

  /* ── Remove from plate ───────────────────────────── */
  function removeFromPlate(componentId: string) {
    setMeals((prev) => {
      const updated = [...prev];
      const meal = { ...updated[activeMealIndex] };
      meal.ingredients = meal.ingredients.filter((i) => i.componentId !== componentId);
      updated[activeMealIndex] = recalcMeal(meal);
      return updated;
    });
    calcMutation.mutate({
      ...payload,
      components: payload.components.filter((c) => c.componentId !== componentId),
    });
  }

  /* ── Multi-meal management ───────────────────────── */
  function addMeal() {
    if (meals.length >= MAX_MEALS) return;
    const n = meals.length + 1;
    setMeals((prev) => [...prev, createEmptyMeal(n)]);
    setActiveMealIndex(meals.length);
  }

  function removeMeal(index: number) {
    if (meals.length <= 1) return;
    setMeals((prev) => prev.filter((_, i) => i !== index));
    setActiveMealIndex((prev) => (prev >= index && prev > 0 ? prev - 1 : prev));
  }

  function renameMeal(index: number, label: string) {
    setMeals((prev) => prev.map((m, i) => (i === index ? { ...m, label } : m)));
  }

  /* ── Add all meals to cart ───────────────────────── */
  function addAllToCart() {
    const nonEmpty = meals.filter((m) => m.ingredients.length > 0);
    if (nonEmpty.length === 0) {
      toast.warning('Nothing selected', 'Add at least one ingredient to a meal.');
      return;
    }
    for (const meal of nonEmpty) {
      const names = meal.ingredients.map((i) => i.label).join(', ');
      addItem(VENDOR_ID, {
        menuItemId: 'custom-' + meal.id,
        name: `${meal.label} (${names})`,
        unitPrice: meal.totalPrice,
      });
    }
    const total = nonEmpty.reduce((s, m) => s + m.totalPrice, 0);
    toast.success(
      `${nonEmpty.length} meal${nonEmpty.length > 1 ? 's' : ''} added!`,
      `$${total.toFixed(2)} total`,
    );
  }

  /* ── Derived state ───────────────────────────────── */
  const selected = activeMeal.ingredients;
  const draggedComponent = dragId ? ALL_COMPONENTS.find((c) => c.componentId === dragId) : null;
  const nonEmptyCount = meals.filter((m) => m.ingredients.length > 0).length;

  return (
    <DndContext sensors={sensors} onDragStart={handleDragStart} onDragEnd={handleDragEnd}>
      <div className="section-header">
        <p className="section-eyebrow">Compose your plate</p>
        <h1 className="section-title">Meal Builder</h1>
        <p className="section-subtitle">
          Pick your ingredients. Price and calories update in real time.
        </p>
      </div>

      {/* Mode toggle + Meal tabs row */}
      <div className="builder-toolbar">
        <div className="mode-toggle">
          <button
            className={`mode-toggle-btn${mode === 'classic' ? ' active' : ''}`}
            onClick={() => setMode('classic')}
          >
            Classic
          </button>
          <button
            className={`mode-toggle-btn${mode === 'drag' ? ' active' : ''}`}
            onClick={() => setMode('drag')}
          >
            Drag to Plate
          </button>
        </div>
        <MealTabs
          meals={meals}
          activeIndex={activeMealIndex}
          onSelect={setActiveMealIndex}
          onAdd={addMeal}
          onRemove={removeMeal}
          onRename={renameMeal}
          maxMeals={MAX_MEALS}
        />
      </div>

      {/* ── DRAG MODE ────────────────────────────────── */}
      {mode === 'drag' ? (
        <div className="drag-layout">
          {/* Left: ingredient tray */}
          <div className="ingredient-tray">
            {/* Category filter tabs */}
            <div className="cat-tabs">
              {CATEGORIES.map((cat) => (
                <button
                  key={cat}
                  className={`cat-tab${activeCategory === cat ? ' cat-tab--active' : ''}`}
                  onClick={() => setActiveCategory(cat)}
                >
                  <span className="cat-tab-icon">{CATEGORY_ICONS[cat]}</span>
                  <span className="cat-tab-label">{cat}</span>
                </button>
              ))}
            </div>

            {/* Compact chip grid for active category */}
            <div className="chip-grid">
              {ALL_COMPONENTS
                .filter((c) => c.category === activeCategory)
                .map((comp) => {
                  const qty = qtyMap.get(comp.componentId) ?? 0;
                  return (
                    <DraggableIngredient
                      key={comp.componentId}
                      componentId={comp.componentId}
                      disabled={false}
                    >
                      <div className={`ingredient-chip${qty > 0 ? ' ingredient-chip--active' : ''}`}>
                        <span className="ingredient-chip-emoji">{comp.emoji}</span>
                        <div className="ingredient-chip-info">
                          <span className="ingredient-chip-name">{comp.label}</span>
                          <span className="ingredient-chip-meta">${comp.priceEach.toFixed(2)}</span>
                        </div>
                        {qty > 0 && <span className="ingredient-chip-qty">{qty}</span>}
                        <div className="ingredient-chip-btns">
                          <button
                            className="chip-btn"
                            onClick={(e) => { e.stopPropagation(); adjust(comp.componentId, -1); }}
                            disabled={qty === 0}
                            aria-label={`Remove ${comp.label}`}
                          >
                            -
                          </button>
                          <button
                            className="chip-btn chip-btn--add"
                            onClick={(e) => { e.stopPropagation(); adjust(comp.componentId, 1); }}
                            aria-label={`Add ${comp.label}`}
                          >
                            +
                          </button>
                        </div>
                      </div>
                    </DraggableIngredient>
                  );
                })}
            </div>
          </div>

          {/* Center: the plate */}
          <div className="plate-area">
            <MealPlate
              ingredients={activeMeal.ingredients}
              onRemove={removeFromPlate}
            />
            {/* Quick stats below plate */}
            <div className="plate-stats">
              <span className="plate-stat">
                <strong>${activeMeal.totalPrice.toFixed(2)}</strong> total
              </span>
              <span className="plate-stat-divider" />
              <span className="plate-stat">
                <strong>{activeMeal.totalCalories}</strong> kcal
              </span>
              <span className="plate-stat-divider" />
              <span className="plate-stat">
                <strong>{totalQty}</strong>/{MAX_ITEMS_PER_MEAL} items
              </span>
            </div>
          </div>

          {/* Right: summary + cart */}
          <div className="drag-summary">
            <div className="panel">
              <p className="panel-title">{activeMeal.label}</p>

              {selected.length > 0 ? (
                <div className="drag-summary-list">
                  {selected.map((c) => (
                    <div key={c.componentId} className="drag-summary-item">
                      <span>{c.emoji} {c.label} x{c.quantity}</span>
                      <span className="text-brand">${(c.priceEach * c.quantity).toFixed(2)}</span>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-muted text-sm" style={{ textAlign: 'center', padding: '16px 0' }}>
                  Drag ingredients onto the plate or use +/- buttons
                </p>
              )}

              {!activeMeal.available && (
                <div className="badge badge-warning" style={{ marginBottom: 'var(--space-3)', justifyContent: 'center', width: '100%' }}>
                  Max {MAX_ITEMS_PER_MEAL} items per meal
                </div>
              )}

              <button
                className="btn-primary"
                onClick={addAllToCart}
                disabled={nonEmptyCount === 0}
                style={{ width: '100%', justifyContent: 'center', marginTop: 'var(--space-3)' }}
              >
                Add {nonEmptyCount || ''} Meal{nonEmptyCount !== 1 ? 's' : ''} to Cart — $
                {meals.reduce((s, m) => s + (m.ingredients.length > 0 ? m.totalPrice : 0), 0).toFixed(2)}
              </button>
            </div>
          </div>
        </div>
      ) : (
        /* ── CLASSIC MODE ──────────────────────────────── */
        <div className="meal-builder-layout classic">
          {/* Component selector */}
          <div>
            <div className="component-grid">
              {ALL_COMPONENTS.map((comp) => {
                const qty = qtyMap.get(comp.componentId) ?? 0;
                return (
                  <div
                    key={comp.componentId}
                    className={`component-card${qty > 0 ? ' selected' : ''}`}
                  >
                    {qty > 0 && <span className="component-qty-badge">{qty}</span>}
                    <div className="component-icon">{comp.emoji}</div>
                    <p className="component-name">{comp.label}</p>
                    <p className="component-price">
                      ${comp.priceEach.toFixed(2)} · {comp.calsEach} kcal
                    </p>
                    <div
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        gap: 'var(--space-2)',
                        marginTop: 'var(--space-3)',
                      }}
                    >
                      <button
                        className="qty-btn"
                        onClick={() => adjust(comp.componentId, -1)}
                        disabled={qty === 0}
                        style={{ width: 26, height: 26, fontSize: '0.9rem' }}
                      >
                        -
                      </button>
                      <span className="qty-value" style={{ minWidth: 16 }}>{qty}</span>
                      <button
                        className="qty-btn"
                        onClick={() => adjust(comp.componentId, 1)}
                        style={{ width: 26, height: 26, fontSize: '0.9rem' }}
                      >
                        +
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Summary sidebar */}
          <div style={{ position: 'sticky', top: 'calc(var(--topbar-h) + 16px)' }}>
            <div className="panel">
              <p className="panel-title">{activeMeal.label}</p>

              <div className="meal-meter" style={{ marginBottom: 'var(--space-5)' }}>
                <div className="meal-meter-item">
                  <p className="meal-meter-value">${activeMeal.totalPrice.toFixed(2)}</p>
                  <p className="meal-meter-label">Total price</p>
                </div>
                <div className="meal-meter-item">
                  <p className="meal-meter-value">{activeMeal.totalCalories}</p>
                  <p className="meal-meter-label">Calories</p>
                </div>
                <div className="meal-meter-item">
                  <p className="meal-meter-value">{totalQty}</p>
                  <p className="meal-meter-label">Items</p>
                </div>
              </div>

              {selected.length > 0 ? (
                <div style={{ marginBottom: 'var(--space-5)' }}>
                  {selected.map((c) => (
                    <div key={c.componentId} className="summary-row">
                      <span className="label">{c.emoji} {c.label} x {c.quantity}</span>
                      <span className="value">${(c.priceEach * c.quantity).toFixed(2)}</span>
                    </div>
                  ))}
                  <div className="summary-row total">
                    <span className="label">Total</span>
                    <span className="value text-brand">${activeMeal.totalPrice.toFixed(2)}</span>
                  </div>
                </div>
              ) : (
                <p className="text-muted text-sm" style={{ marginBottom: 'var(--space-5)', textAlign: 'center' }}>
                  Select components above to build your meal
                </p>
              )}

              {calcMutation.isPending && (
                <p className="text-sm text-muted" style={{ marginBottom: 'var(--space-3)', textAlign: 'center' }}>
                  <span style={{ display: 'inline-block', animation: 'spin 0.7s linear infinite' }}>↻</span>{' '}
                  Recalculating...
                </p>
              )}

              {!activeMeal.available && (
                <div className="badge badge-warning" style={{ marginBottom: 'var(--space-3)', justifyContent: 'center', width: '100%' }}>
                  Max {MAX_ITEMS_PER_MEAL} items per meal
                </div>
              )}

              <button
                className="btn-primary"
                onClick={addAllToCart}
                disabled={nonEmptyCount === 0}
                style={{ width: '100%', justifyContent: 'center' }}
              >
                Add {nonEmptyCount || ''} Meal{nonEmptyCount !== 1 ? 's' : ''} to Cart — $
                {meals.reduce((s, m) => s + (m.ingredients.length > 0 ? m.totalPrice : 0), 0).toFixed(2)}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Drag overlay (ghost) */}
      <DragOverlay>
        {draggedComponent ? (
          <div className="drag-ghost">
            <span className="drag-ghost-emoji">{draggedComponent.emoji}</span>
            {draggedComponent.label}
          </div>
        ) : null}
      </DragOverlay>
    </DndContext>
  );
}
