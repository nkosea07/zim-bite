CREATE SCHEMA IF NOT EXISTS ordering;

CREATE TABLE IF NOT EXISTS ordering.orders (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  vendor_id UUID NOT NULL,
  status VARCHAR(24) NOT NULL,
  total_amount NUMERIC(12,2) NOT NULL,
  currency CHAR(3) NOT NULL CHECK (currency IN ('USD', 'ZWL')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ordering.order_items (
  id UUID PRIMARY KEY,
  order_id UUID NOT NULL,
  menu_item_id UUID NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(12,2) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
