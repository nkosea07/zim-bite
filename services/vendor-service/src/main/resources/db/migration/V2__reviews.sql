CREATE TABLE IF NOT EXISTS vendor_mgmt.reviews (
    id           UUID PRIMARY KEY,
    vendor_id    UUID           NOT NULL REFERENCES vendor_mgmt.vendors(id) ON DELETE CASCADE,
    user_id      UUID           NOT NULL,
    order_id     UUID           NOT NULL,
    rating       SMALLINT       NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment      TEXT,
    created_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    UNIQUE (order_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_vendor_id
    ON vendor_mgmt.reviews(vendor_id);

CREATE INDEX IF NOT EXISTS idx_reviews_user_id
    ON vendor_mgmt.reviews(user_id);
