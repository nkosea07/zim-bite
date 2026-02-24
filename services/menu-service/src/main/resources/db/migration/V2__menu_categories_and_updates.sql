ALTER TABLE menu_mgmt.menu_items
  ADD COLUMN IF NOT EXISTS category VARCHAR(80) NOT NULL DEFAULT 'General';

CREATE INDEX IF NOT EXISTS idx_menu_items_vendor_category
ON menu_mgmt.menu_items(vendor_id, category);
