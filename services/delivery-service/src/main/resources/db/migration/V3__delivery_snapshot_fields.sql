ALTER TABLE delivery_mgmt.deliveries
    ADD COLUMN IF NOT EXISTS vendor_name          VARCHAR(180),
    ADD COLUMN IF NOT EXISTS customer_phone       VARCHAR(24),
    ADD COLUMN IF NOT EXISTS delivery_address_text TEXT,
    ADD COLUMN IF NOT EXISTS total_amount          NUMERIC(12,2),
    ADD COLUMN IF NOT EXISTS customer_id           UUID;
