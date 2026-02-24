CREATE TABLE IF NOT EXISTS ordering.order_status_history (
  id UUID PRIMARY KEY,
  order_id UUID NOT NULL,
  status VARCHAR(24) NOT NULL,
  source VARCHAR(24) NOT NULL,
  note VARCHAR(255),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ordering_status_history_order_created
ON ordering.order_status_history(order_id, created_at DESC);
