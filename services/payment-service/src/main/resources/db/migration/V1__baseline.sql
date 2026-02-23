CREATE SCHEMA IF NOT EXISTS payment_mgmt;

CREATE TABLE IF NOT EXISTS payment_mgmt.payments (
  id UUID PRIMARY KEY,
  order_id UUID NOT NULL,
  provider VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL,
  amount NUMERIC(12,2) NOT NULL,
  currency CHAR(3) NOT NULL CHECK (currency IN ('USD', 'ZWL')),
  idempotency_key VARCHAR(80),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payments_idempotency_key
ON payment_mgmt.payments(idempotency_key)
WHERE idempotency_key IS NOT NULL;
