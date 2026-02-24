CREATE TABLE IF NOT EXISTS menu_mgmt.inventory (
  id UUID PRIMARY KEY,
  vendor_id UUID NOT NULL,
  menu_item_id UUID NOT NULL,
  quantity_available INT NOT NULL DEFAULT 0 CHECK (quantity_available >= 0),
  reorder_level INT NOT NULL DEFAULT 0 CHECK (reorder_level >= 0),
  unit VARCHAR(24) NOT NULL DEFAULT 'portion',
  last_restocked_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (vendor_id, menu_item_id)
);

CREATE INDEX IF NOT EXISTS idx_inventory_vendor_item
ON menu_mgmt.inventory(vendor_id, menu_item_id);
