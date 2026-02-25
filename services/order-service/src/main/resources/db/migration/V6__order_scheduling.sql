-- Add scheduled delivery time to orders.
-- When null the order is placed for immediate fulfilment.
-- When set it must fall within the 05:00–10:00 Africa/Harare delivery window.
ALTER TABLE ordering.orders
    ADD COLUMN IF NOT EXISTS scheduled_for TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_orders_scheduled_for
    ON ordering.orders(scheduled_for)
    WHERE scheduled_for IS NOT NULL;
