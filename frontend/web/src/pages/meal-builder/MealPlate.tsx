import { useDroppable } from '@dnd-kit/core';

export type PlateIngredientData = {
  componentId: string;
  label: string;
  emoji: string;
  quantity: number;
  plateX: number;
  plateY: number;
};

type MealPlateProps = {
  ingredients: PlateIngredientData[];
  onRemove: (componentId: string) => void;
};

export function MealPlate({ ingredients, onRemove }: MealPlateProps) {
  const { setNodeRef, isOver } = useDroppable({ id: 'meal-plate' });

  const isEmpty = ingredients.length === 0;
  const count = ingredients.length;

  // Plate grows with items: base 220px, up to ~400px
  const plateSize = isEmpty ? 220 : Math.min(400, 220 + count * 22);

  return (
    <div
      ref={setNodeRef}
      className={`meal-plate${isOver ? ' meal-plate--active' : ''}${isEmpty ? ' meal-plate--empty' : ''}`}
      style={{ width: plateSize, height: plateSize }}
      role="region"
      aria-label="Meal plate — drop ingredients here"
    >
      {/* Outer rim */}
      <div className="meal-plate-rim" />
      {/* Inner ring */}
      <div className="meal-plate-ring" />

      {isEmpty ? (
        <div className="meal-plate-empty-content">
          <span className="plate-emoji">🍽️</span>
          <span className="plate-hint">Drag ingredients here</span>
        </div>
      ) : (
        <div className="meal-plate-items">
          {ingredients.map((ing, i) => {
            // Flow layout: arrange in concentric rings
            const pos = ringPosition(i, count, plateSize);
            return (
              <div
                key={ing.componentId}
                className="plate-ingredient"
                style={{ left: pos.x, top: pos.y }}
              >
                <span className="plate-ingredient-emoji">{ing.emoji}</span>
                <span className="plate-ingredient-label">{ing.label}</span>
                {ing.quantity > 1 && (
                  <span className="plate-ingredient-qty">x{ing.quantity}</span>
                )}
                <button
                  className="plate-ingredient-remove"
                  onClick={() => onRemove(ing.componentId)}
                  aria-label={`Remove ${ing.label}`}
                >
                  x
                </button>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

/**
 * Place items in concentric rings inside the plate.
 * Ring 0 = center (1 item), ring 1 = ~6 items, ring 2 = ~12, etc.
 * Each ring spreads items evenly in a circle at increasing radii.
 */
function ringPosition(
  index: number,
  total: number,
  plateSize: number,
): { x: number; y: number } {
  const center = plateSize / 2;
  const itemRadius = 32; // half the space each item needs

  if (total === 1) return { x: center, y: center };

  // Build ring capacities: center(1), ring1(6), ring2(12), ring3(18)...
  const rings: number[] = [1];
  let filled = 1;
  let ringNum = 1;
  while (filled < total) {
    const cap = ringNum * 6;
    rings.push(cap);
    filled += cap;
    ringNum++;
  }

  // Find which ring this index falls into
  let cumulative = 0;
  let ring = 0;
  let indexInRing = index;
  for (let r = 0; r < rings.length; r++) {
    if (index < cumulative + rings[r]) {
      ring = r;
      indexInRing = index - cumulative;
      break;
    }
    cumulative += rings[r];
  }

  if (ring === 0) return { x: center, y: center };

  // Radius for this ring — spread from center outward, staying inside plate
  const maxRadius = center - itemRadius - 8; // 8px inner padding from rim
  const totalRings = rings.length - 1; // exclude center
  const radius = (ring / totalRings) * maxRadius || maxRadius * 0.4;

  const angle = (indexInRing / rings[ring]) * Math.PI * 2 - Math.PI / 2;
  return {
    x: center + radius * Math.cos(angle),
    y: center + radius * Math.sin(angle),
  };
}
