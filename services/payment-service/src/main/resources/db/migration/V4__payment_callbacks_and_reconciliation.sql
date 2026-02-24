CREATE TABLE IF NOT EXISTS payment_mgmt.payment_callbacks (
  id UUID PRIMARY KEY,
  payment_id UUID NOT NULL,
  provider VARCHAR(20) NOT NULL,
  callback_id VARCHAR(120) NOT NULL,
  outcome VARCHAR(20) NOT NULL,
  signature_valid BOOLEAN NOT NULL,
  reason VARCHAR(255),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (provider, callback_id)
);

CREATE INDEX IF NOT EXISTS idx_payment_callbacks_payment_created
ON payment_mgmt.payment_callbacks(payment_id, created_at DESC);
