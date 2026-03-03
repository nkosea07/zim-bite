-- Performance indexes for vendor-service
-- vendors.is_active: called on every GET /vendors request via findByActiveTrue()
CREATE INDEX IF NOT EXISTS idx_vendors_is_active
    ON vendor_mgmt.vendors(is_active);

-- vendors.owner_user_id: used in findByOwnerUserId() for vendor management
CREATE INDEX IF NOT EXISTS idx_vendors_owner_user_id
    ON vendor_mgmt.vendors(owner_user_id);

-- vendor_operating_days(vendor_id, day_of_week): schedule availability checks
CREATE INDEX IF NOT EXISTS idx_vendor_operating_days_vendor_day
    ON vendor_mgmt.vendor_operating_days(vendor_id, day_of_week);
