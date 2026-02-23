CREATE TABLE IF NOT EXISTS delivery_mgmt.riders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES user_mgmt.users(id) ON DELETE CASCADE,
  vehicle_type VARCHAR(16) NOT NULL CHECK (vehicle_type IN ('BIKE', 'SCOOTER', 'CAR', 'WALKER')),
  license_number VARCHAR(80),
  is_online BOOLEAN NOT NULL DEFAULT FALSE,
  current_geo_point geometry(Point, 4326),
  current_status VARCHAR(24) NOT NULL CHECK (current_status IN ('OFFLINE', 'AVAILABLE', 'PICKING_UP', 'DELIVERING')),
  rating_avg NUMERIC(3,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS delivery_mgmt.deliveries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL UNIQUE REFERENCES ordering.orders(id) ON DELETE CASCADE,
  rider_id UUID REFERENCES delivery_mgmt.riders(id),
  status VARCHAR(24) NOT NULL CHECK (status IN ('PENDING_ASSIGNMENT', 'ASSIGNED', 'ARRIVED_VENDOR', 'PICKED_UP', 'OUT_FOR_DELIVERY', 'DELIVERED', 'FAILED')),
  pickup_geo_point geometry(Point, 4326) NOT NULL,
  dropoff_geo_point geometry(Point, 4326) NOT NULL,
  estimated_minutes INT CHECK (estimated_minutes >= 0),
  distance_km NUMERIC(6,2) CHECK (distance_km >= 0),
  assigned_at TIMESTAMPTZ,
  picked_up_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS delivery_mgmt.delivery_tracking_points (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  delivery_id UUID NOT NULL REFERENCES delivery_mgmt.deliveries(id) ON DELETE CASCADE,
  geo_point geometry(Point, 4326) NOT NULL,
  speed_kmh NUMERIC(5,2),
  heading_degrees SMALLINT CHECK (heading_degrees BETWEEN 0 AND 360),
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
