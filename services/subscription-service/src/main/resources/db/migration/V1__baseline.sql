CREATE SCHEMA IF NOT EXISTS subscription_mgmt;

CREATE TABLE IF NOT EXISTS subscription_mgmt.subscriptions (
    id                  UUID PRIMARY KEY,
    user_id             UUID            NOT NULL,
    vendor_id           UUID            NOT NULL,
    plan_type           VARCHAR(20)     NOT NULL CHECK (plan_type IN ('DAILY', 'WEEKLY', 'MONTHLY')),
    status              VARCHAR(20)     NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'PAUSED', 'CANCELLED')),
    delivery_address_id UUID            NOT NULL,
    currency            CHAR(3)         NOT NULL CHECK (currency IN ('USD', 'ZWL')),
    preset_name         VARCHAR(120),
    notes               TEXT,
    next_delivery_at    TIMESTAMPTZ     NOT NULL,
    paused_at           TIMESTAMPTZ,
    cancelled_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id
    ON subscription_mgmt.subscriptions(user_id);

CREATE INDEX IF NOT EXISTS idx_subscriptions_vendor_id
    ON subscription_mgmt.subscriptions(vendor_id);

CREATE INDEX IF NOT EXISTS idx_subscriptions_status_next_delivery
    ON subscription_mgmt.subscriptions(status, next_delivery_at)
    WHERE status = 'ACTIVE';

CREATE TABLE IF NOT EXISTS subscription_mgmt.subscription_items (
    id              UUID PRIMARY KEY,
    subscription_id UUID            NOT NULL REFERENCES subscription_mgmt.subscriptions(id) ON DELETE CASCADE,
    menu_item_id    UUID            NOT NULL,
    quantity        SMALLINT        NOT NULL DEFAULT 1 CHECK (quantity > 0),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_subscription_items_subscription_id
    ON subscription_mgmt.subscription_items(subscription_id);

CREATE TABLE IF NOT EXISTS subscription_mgmt.subscription_deliveries (
    id              UUID PRIMARY KEY,
    subscription_id UUID            NOT NULL REFERENCES subscription_mgmt.subscriptions(id) ON DELETE CASCADE,
    order_id        UUID,
    scheduled_for   TIMESTAMPTZ     NOT NULL,
    status          VARCHAR(20)     NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'ORDER_PLACED', 'SKIPPED', 'FAILED')),
    failure_reason  TEXT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_subscription_deliveries_subscription_id
    ON subscription_mgmt.subscription_deliveries(subscription_id);

CREATE INDEX IF NOT EXISTS idx_subscription_deliveries_pending
    ON subscription_mgmt.subscription_deliveries(scheduled_for)
    WHERE status = 'PENDING';
