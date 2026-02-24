CREATE TABLE IF NOT EXISTS payment_mgmt.payment_methods_saved (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  provider VARCHAR(20) NOT NULL CHECK (provider IN ('ECOCASH', 'ONEMONEY', 'CARD')),
  token_reference VARCHAR(255) NOT NULL,
  last4 VARCHAR(8) NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_methods_saved_user_provider_token
ON payment_mgmt.payment_methods_saved(user_id, provider, token_reference);

CREATE INDEX IF NOT EXISTS idx_payment_methods_saved_user_order
ON payment_mgmt.payment_methods_saved(user_id, is_default DESC, created_at DESC);
