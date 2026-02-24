CREATE SCHEMA IF NOT EXISTS analytics_mgmt;

CREATE TABLE IF NOT EXISTS analytics_mgmt.order_projections (
  order_id UUID PRIMARY KEY,
  vendor_id UUID NOT NULL,
  currency CHAR(3) NOT NULL CHECK (currency IN ('USD', 'ZWL')),
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_order_vendor_created
ON analytics_mgmt.order_projections(vendor_id, created_at DESC);

CREATE TABLE IF NOT EXISTS analytics_mgmt.succeeded_payment_projections (
  payment_id UUID PRIMARY KEY,
  order_id UUID NOT NULL,
  amount NUMERIC(12,2) NOT NULL,
  currency CHAR(3) NOT NULL CHECK (currency IN ('USD', 'ZWL')),
  happened_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_succeeded_payment_order_happened
ON analytics_mgmt.succeeded_payment_projections(order_id, happened_at DESC);

CREATE TABLE IF NOT EXISTS analytics_mgmt.refunded_payment_projections (
  payment_id UUID PRIMARY KEY,
  order_id UUID NOT NULL,
  amount NUMERIC(12,2) NOT NULL,
  currency CHAR(3) NOT NULL CHECK (currency IN ('USD', 'ZWL')),
  happened_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_refunded_payment_order_happened
ON analytics_mgmt.refunded_payment_projections(order_id, happened_at DESC);

CREATE TABLE IF NOT EXISTS analytics_mgmt.delivery_projections (
  delivery_id UUID PRIMARY KEY,
  order_id UUID NOT NULL,
  rider_id UUID,
  assigned_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_delivery_order
ON analytics_mgmt.delivery_projections(order_id);
