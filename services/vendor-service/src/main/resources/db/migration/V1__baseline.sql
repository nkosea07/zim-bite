CREATE SCHEMA IF NOT EXISTS vendor_mgmt;

CREATE TABLE IF NOT EXISTS vendor_mgmt.vendors (
    id                    UUID PRIMARY KEY,
    owner_user_id         UUID         NOT NULL,
    name                  VARCHAR(180) NOT NULL,
    slug                  VARCHAR(180) NOT NULL UNIQUE,
    description           TEXT,
    phone_number          VARCHAR(24)  NOT NULL,
    support_email         VARCHAR(160),
    latitude              NUMERIC(9,6) NOT NULL,
    longitude             NUMERIC(9,6) NOT NULL,
    average_prep_minutes  SMALLINT     NOT NULL DEFAULT 20 CHECK (average_prep_minutes BETWEEN 5 AND 120),
    delivery_radius_km    NUMERIC(5,2) NOT NULL DEFAULT 6.00,
    min_order_value       NUMERIC(12,2) NOT NULL DEFAULT 0,
    accepts_cash          BOOLEAN      NOT NULL DEFAULT TRUE,
    is_active             BOOLEAN      NOT NULL DEFAULT TRUE,
    rating_avg            NUMERIC(3,2) NOT NULL DEFAULT 0,
    created_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS vendor_mgmt.vendor_operating_days (
    id          UUID PRIMARY KEY,
    vendor_id   UUID     NOT NULL REFERENCES vendor_mgmt.vendors(id) ON DELETE CASCADE,
    day_of_week SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    opens_at    TIME     NOT NULL,
    closes_at   TIME     NOT NULL,
    is_closed   BOOLEAN  NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (vendor_id, day_of_week)
);
