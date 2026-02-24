import { useMutation } from '@tanstack/react-query';
import { useMemo, useState } from 'react';
import { zimbiteApi, type MealCalcResponse } from '../../services/zimbiteApi';

type BuilderComponent = { componentId: string; label: string; quantity: number };

const START_COMPONENTS: BuilderComponent[] = [
  { componentId: '11111111-1111-1111-1111-111111111111', label: 'Egg', quantity: 1 },
  { componentId: '22222222-2222-2222-2222-222222222222', label: 'Avocado', quantity: 1 },
  { componentId: '33333333-3333-3333-3333-333333333333', label: 'Bacon', quantity: 1 }
];

export function MealBuilderPage() {
  const [components, setComponents] = useState<BuilderComponent[]>(START_COMPONENTS);
  const [result, setResult] = useState<MealCalcResponse>({ totalPrice: 6.6, estimatedCalories: 505, available: true });

  const payload = useMemo(
    () => ({
      vendorId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001',
      baseItemId: 'dddddddd-dddd-dddd-dddd-ddddddddddd1',
      components: components.map((component) => ({ componentId: component.componentId, quantity: component.quantity }))
    }),
    [components]
  );

  const calculateMutation = useMutation({
    mutationFn: zimbiteApi.calculateMeal,
    onMutate: (nextPayload) => {
      const previous = result;
      const optimistic: MealCalcResponse = {
        totalPrice: Number((3 + nextPayload.components.reduce((sum, c) => sum + c.quantity * 1.2, 0)).toFixed(2)),
        estimatedCalories: 250 + nextPayload.components.reduce((sum, c) => sum + c.quantity * 85, 0),
        available: true
      };
      setResult(optimistic);
      return { previous };
    },
    onError: (_error, _variables, context) => {
      if (context?.previous) {
        setResult(context.previous);
      }
    },
    onSuccess: (data) => setResult(data)
  });

  function setQuantity(componentId: string, quantity: number) {
    const normalized = Math.max(0, Math.min(10, quantity));
    setComponents((prev) => prev.map((c) => (c.componentId === componentId ? { ...c, quantity: normalized } : c)));

    const nextPayload = {
      ...payload,
      components: payload.components.map((component) =>
        component.componentId === componentId ? { ...component, quantity: normalized } : component
      )
    };
    calculateMutation.mutate(nextPayload);
  }

  return (
    <section className="panel">
      <h2>Meal Builder</h2>
      <p>Drag-and-drop UI comes next. This version focuses on real-time pricing and optimistic updates.</p>
      <div className="builder-list">
        {components.map((component) => (
          <label key={component.componentId} className="builder-row">
            <span>{component.label}</span>
            <input
              type="range"
              min={0}
              max={10}
              value={component.quantity}
              onChange={(event) => setQuantity(component.componentId, Number(event.target.value))}
            />
            <strong>{component.quantity}</strong>
          </label>
        ))}
      </div>
      <div className="metric-grid">
        <div>
          <small>Estimated Price</small>
          <p>USD {result.totalPrice.toFixed(2)}</p>
        </div>
        <div>
          <small>Estimated Calories</small>
          <p>{result.estimatedCalories} kcal</p>
        </div>
        <div>
          <small>Availability</small>
          <p>{result.available ? 'Available' : 'Unavailable'}</p>
        </div>
      </div>
      {calculateMutation.isPending ? <p className="status">Recalculating...</p> : null}
    </section>
  );
}
