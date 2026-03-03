-- Performance indexes for menu-service
-- menu_items.vendor_id: called on every menu page view via findByVendorId()
CREATE INDEX IF NOT EXISTS idx_menu_items_vendor_id
    ON menu_mgmt.menu_items(vendor_id);

-- Composite (vendor_id, is_available): supports filtered menu listings (available items only)
CREATE INDEX IF NOT EXISTS idx_menu_items_vendor_available
    ON menu_mgmt.menu_items(vendor_id, is_available);
