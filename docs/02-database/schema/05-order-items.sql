CREATE TABLE IF NOT EXISTS ordering.order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES ordering.orders(id) ON DELETE CASCADE,
  menu_item_id UUID,
  item_name_snapshot VARCHAR(180) NOT NULL,
  item_description_snapshot TEXT,
  unit_price_snapshot NUMERIC(12,2) NOT NULL CHECK (unit_price_snapshot >= 0),
  quantity INT NOT NULL CHECK (quantity > 0),
  line_total NUMERIC(12,2) NOT NULL CHECK (line_total >= 0),
  customization_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
