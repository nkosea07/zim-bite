CREATE SCHEMA IF NOT EXISTS delivery_mgmt;

CREATE TABLE IF NOT EXISTS delivery_mgmt.deliveries (
    id              UUID PRIMARY KEY,
    order_id        UUID         NOT NULL UNIQUE,
    rider_id        UUID,
    status          VARCHAR(30)  NOT NULL DEFAULT 'PENDING',
    pickup_lat      NUMERIC(9,6),
    pickup_lng      NUMERIC(9,6),
    dropoff_lat     NUMERIC(9,6),
    dropoff_lng     NUMERIC(9,6),
    assigned_at     TIMESTAMPTZ,
    picked_up_at    TIMESTAMPTZ,
    delivered_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_deliveries_order_id ON delivery_mgmt.deliveries(order_id);
CREATE INDEX idx_deliveries_rider_id ON delivery_mgmt.deliveries(rider_id);

CREATE TABLE IF NOT EXISTS delivery_mgmt.delivery_locations (
    id            UUID PRIMARY KEY,
    delivery_id   UUID         NOT NULL REFERENCES delivery_mgmt.deliveries(id) ON DELETE CASCADE,
    latitude      NUMERIC(9,6) NOT NULL,
    longitude     NUMERIC(9,6) NOT NULL,
    recorded_at   TIMESTAMPTZ  NOT NULL,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_delivery_locations_delivery ON delivery_mgmt.delivery_locations(delivery_id, recorded_at DESC);
