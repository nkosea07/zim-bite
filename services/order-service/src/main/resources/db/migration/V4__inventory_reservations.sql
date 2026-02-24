CREATE TABLE IF NOT EXISTS ordering.inventory_reservations (
  id UUID PRIMARY KEY,
  order_id UUID NOT NULL,
  vendor_id UUID NOT NULL,
  menu_item_id UUID NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  status VARCHAR(20) NOT NULL CHECK (status IN ('RESERVED', 'RELEASED', 'COMMITTED')),
  reason VARCHAR(120),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (order_id, menu_item_id)
);

CREATE INDEX IF NOT EXISTS idx_ordering_inventory_reservations_order_status
ON ordering.inventory_reservations(order_id, status);
