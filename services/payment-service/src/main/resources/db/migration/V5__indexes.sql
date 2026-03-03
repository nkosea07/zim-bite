-- Performance indexes for payment-service
-- payments.order_id: high-frequency lookup when order events trigger payment queries
CREATE INDEX IF NOT EXISTS idx_payments_order_id
    ON payment_mgmt.payments(order_id);

-- payments(status, created_at DESC): reconciliation job scans pending/processing payments
CREATE INDEX IF NOT EXISTS idx_payments_status_created
    ON payment_mgmt.payments(status, created_at DESC);
