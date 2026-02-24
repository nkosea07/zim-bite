ALTER TABLE user_mgmt.user_addresses
  ADD COLUMN IF NOT EXISTS line2 VARCHAR(200),
  ADD COLUMN IF NOT EXISTS area VARCHAR(80),
  ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

CREATE TABLE IF NOT EXISTS user_mgmt.user_favorite_items (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  menu_item_id UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_user_favorite UNIQUE (user_id, menu_item_id)
);

CREATE TABLE IF NOT EXISTS user_mgmt.user_order_history (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  order_id UUID NOT NULL,
  vendor_id UUID NOT NULL,
  status VARCHAR(24) NOT NULL,
  total_amount NUMERIC(12,2) NOT NULL,
  currency CHAR(3) NOT NULL CHECK (currency IN ('USD', 'ZWL')),
  placed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_order_history_user_placed_at
ON user_mgmt.user_order_history(user_id, placed_at DESC);
