CREATE TABLE IF NOT EXISTS payment_mgmt.payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES ordering.orders(id) ON DELETE CASCADE,
  idempotency_key VARCHAR(80) NOT NULL,
  provider VARCHAR(20) NOT NULL CHECK (provider IN ('ECOCASH', 'ONEMONEY', 'CARD', 'CASH')),
  status VARCHAR(20) NOT NULL CHECK (status IN ('INITIATED', 'PENDING', 'SUCCEEDED', 'FAILED', 'REFUNDED', 'CANCELLED')),
  amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  currency CHAR(3) NOT NULL CHECK (currency IN ('USD', 'ZWL')),
  provider_reference VARCHAR(120),
  provider_payload JSONB,
  failure_reason VARCHAR(255),
  initiated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  UNIQUE (idempotency_key),
  UNIQUE (order_id, provider_reference)
);

CREATE TABLE IF NOT EXISTS payment_mgmt.payment_callbacks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  payment_id UUID REFERENCES payment_mgmt.payments(id) ON DELETE CASCADE,
  provider VARCHAR(20) NOT NULL CHECK (provider IN ('ECOCASH', 'ONEMONEY', 'CARD')),
  callback_id VARCHAR(120),
  signature_valid BOOLEAN NOT NULL DEFAULT FALSE,
  payload JSONB NOT NULL,
  received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (provider, callback_id)
);

CREATE TABLE IF NOT EXISTS payment_mgmt.payment_methods_saved (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_mgmt.users(id) ON DELETE CASCADE,
  method_type VARCHAR(20) NOT NULL CHECK (method_type IN ('ECOCASH', 'ONEMONEY', 'CARD')),
  masked_identifier VARCHAR(60) NOT NULL,
  provider_token VARCHAR(255),
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, method_type, masked_identifier)
);
