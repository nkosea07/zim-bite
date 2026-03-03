import { useDraggable } from '@dnd-kit/core';
import type { ReactNode } from 'react';

type DraggableIngredientProps = {
  componentId: string;
  disabled: boolean;
  children: ReactNode;
};

export function DraggableIngredient({
  componentId,
  disabled,
  children,
}: DraggableIngredientProps) {
  const { attributes, listeners, setNodeRef, isDragging } = useDraggable({
    id: componentId,
    disabled,
  });

  return (
    <div
      ref={setNodeRef}
      {...listeners}
      {...attributes}
      className={isDragging ? 'dragging-wrapper' : ''}
      style={{ opacity: isDragging ? 0.4 : 1, transition: 'opacity 0.15s' }}
    >
      {children}
    </div>
  );
}
