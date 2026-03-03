-- Performance indexes for delivery-service
-- deliveries.status: heavily used in findByStatus() and findByStatusIn() for rider availability
CREATE INDEX IF NOT EXISTS idx_deliveries_status
    ON delivery_mgmt.deliveries(status);

-- deliveries.customer_id: used for customer-facing delivery lookup
CREATE INDEX IF NOT EXISTS idx_deliveries_customer_id
    ON delivery_mgmt.deliveries(customer_id)
    WHERE customer_id IS NOT NULL;

-- deliveries.assigned_at: used in resolveAssignmentPlan() time-range query
CREATE INDEX IF NOT EXISTS idx_deliveries_assigned_at
    ON delivery_mgmt.deliveries(assigned_at)
    WHERE assigned_at IS NOT NULL;
