CREATE TABLE IF NOT EXISTS feedback_mgmt.vendor_reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL UNIQUE REFERENCES ordering.orders(id) ON DELETE CASCADE,
  vendor_id UUID NOT NULL REFERENCES vendor_mgmt.vendors(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES user_mgmt.users(id) ON DELETE CASCADE,
  rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS feedback_mgmt.rider_reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL UNIQUE REFERENCES ordering.orders(id) ON DELETE CASCADE,
  rider_id UUID NOT NULL REFERENCES delivery_mgmt.riders(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES user_mgmt.users(id) ON DELETE CASCADE,
  rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
