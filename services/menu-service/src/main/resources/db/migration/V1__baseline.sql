CREATE SCHEMA IF NOT EXISTS menu_mgmt;

CREATE TABLE IF NOT EXISTS menu_mgmt.menu_items (
  id UUID PRIMARY KEY,
  vendor_id UUID NOT NULL,
  name VARCHAR(160) NOT NULL,
  base_price NUMERIC(12,2) NOT NULL CHECK (base_price >= 0),
  currency CHAR(3) NOT NULL CHECK (currency IN ('USD', 'ZWL')),
  is_available BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
