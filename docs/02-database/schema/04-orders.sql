CREATE TABLE IF NOT EXISTS ordering.orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number VARCHAR(32) NOT NULL UNIQUE,
  user_id UUID NOT NULL REFERENCES user_mgmt.users(id),
  vendor_id UUID NOT NULL REFERENCES vendor_mgmt.vendors(id),
  delivery_address_id UUID REFERENCES user_mgmt.user_addresses(id),
  pickup_lat NUMERIC(9,6),
  pickup_lng NUMERIC(9,6),
  dropoff_lat NUMERIC(9,6),
  dropoff_lng NUMERIC(9,6),
  order_type VARCHAR(20) NOT NULL CHECK (order_type IN ('ON_DEMAND', 'SCHEDULED', 'CORPORATE', 'SUBSCRIPTION')),
  status VARCHAR(24) NOT NULL CHECK (status IN ('PENDING_PAYMENT', 'PAID', 'PREPARING', 'READY_FOR_PICKUP', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED', 'PAYMENT_FAILED')),
  scheduled_for TIMESTAMPTZ,
  subtotal_amount NUMERIC(12,2) NOT NULL CHECK (subtotal_amount >= 0),
  delivery_fee NUMERIC(12,2) NOT NULL DEFAULT 0,
  discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
  currency CHAR(3) NOT NULL CHECK (currency IN ('USD', 'ZWL')),
  customization_json JSONB,
  special_instructions VARCHAR(320),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ordering.order_status_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES ordering.orders(id) ON DELETE CASCADE,
  status VARCHAR(24) NOT NULL CHECK (status IN ('PENDING_PAYMENT', 'PAID', 'PREPARING', 'READY_FOR_PICKUP', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED', 'PAYMENT_FAILED')),
  source VARCHAR(24) NOT NULL CHECK (source IN ('SYSTEM', 'CUSTOMER', 'VENDOR', 'RIDER', 'PAYMENT')),
  note VARCHAR(255),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
