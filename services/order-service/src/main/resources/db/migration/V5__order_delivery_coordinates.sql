ALTER TABLE ordering.orders
  ADD COLUMN IF NOT EXISTS delivery_address_id UUID,
  ADD COLUMN IF NOT EXISTS pickup_lat NUMERIC(9,6),
  ADD COLUMN IF NOT EXISTS pickup_lng NUMERIC(9,6),
  ADD COLUMN IF NOT EXISTS dropoff_lat NUMERIC(9,6),
  ADD COLUMN IF NOT EXISTS dropoff_lng NUMERIC(9,6);

CREATE INDEX IF NOT EXISTS idx_ordering_orders_vendor_created
ON ordering.orders(vendor_id, created_at DESC);
