CREATE TABLE IF NOT EXISTS subscription_mgmt.subscription_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vendor_id UUID NOT NULL REFERENCES vendor_mgmt.vendors(id) ON DELETE CASCADE,
  name VARCHAR(120) NOT NULL,
  description TEXT,
  frequency VARCHAR(20) NOT NULL CHECK (frequency IN ('DAILY', 'WEEKLY', 'MONTHLY')),
  meal_count SMALLINT NOT NULL CHECK (meal_count > 0),
  price NUMERIC(12,2) NOT NULL CHECK (price >= 0),
  currency CHAR(3) NOT NULL CHECK (currency IN ('USD', 'ZWL')),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS subscription_mgmt.user_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_mgmt.users(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES subscription_mgmt.subscription_plans(id) ON DELETE RESTRICT,
  status VARCHAR(20) NOT NULL CHECK (status IN ('ACTIVE', 'PAUSED', 'CANCELLED', 'EXPIRED')),
  starts_on DATE NOT NULL,
  ends_on DATE,
  next_billing_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, plan_id, starts_on)
);
