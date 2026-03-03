import { useRef, useState, useCallback } from 'react';

export type MealTabsProps = {
  meals: { id: string; label: string }[];
  activeIndex: number;
  onSelect: (index: number) => void;
  onAdd: () => void;
  onRemove: (index: number) => void;
  onRename: (index: number, label: string) => void;
  maxMeals: number;
};

export function MealTabs({
  meals,
  activeIndex,
  onSelect,
  onAdd,
  onRemove,
  onRename,
  maxMeals,
}: MealTabsProps) {
  const [editingIndex, setEditingIndex] = useState<number | null>(null);
  const inputRef = useRef<HTMLSpanElement>(null);

  const handleDoubleClick = useCallback((index: number) => {
    setEditingIndex(index);
    requestAnimationFrame(() => inputRef.current?.focus());
  }, []);

  const commitEdit = useCallback(
    (index: number) => {
      const text = inputRef.current?.textContent?.trim();
      if (text) onRename(index, text);
      setEditingIndex(null);
    },
    [onRename],
  );

  return (
    <div className="meal-tabs" role="tablist" aria-label="Meals">
      {meals.map((meal, i) => (
        <button
          key={meal.id}
          role="tab"
          aria-selected={i === activeIndex}
          className={`meal-tab${i === activeIndex ? ' meal-tab--active' : ''}`}
          onClick={() => onSelect(i)}
        >
          {editingIndex === i ? (
            <span
              ref={inputRef}
              className="meal-tab-label"
              contentEditable
              suppressContentEditableWarning
              onBlur={() => commitEdit(i)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') {
                  e.preventDefault();
                  commitEdit(i);
                }
              }}
            >
              {meal.label}
            </span>
          ) : (
            <span
              className="meal-tab-label"
              onDoubleClick={() => handleDoubleClick(i)}
            >
              {meal.label}
            </span>
          )}
          {meals.length > 1 && (
            <button
              className="meal-tab-close"
              aria-label={`Remove ${meal.label}`}
              onClick={(e) => {
                e.stopPropagation();
                onRemove(i);
              }}
            >
              x
            </button>
          )}
        </button>
      ))}

      <button
        className="meal-tab meal-tab--add"
        onClick={onAdd}
        disabled={meals.length >= maxMeals}
        aria-label="Add another meal"
      >
        + Add Meal
      </button>
    </div>
  );
}
