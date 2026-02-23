CREATE TABLE IF NOT EXISTS menu_mgmt.inventory (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vendor_id UUID NOT NULL REFERENCES vendor_mgmt.vendors(id) ON DELETE CASCADE,
  menu_item_id UUID NOT NULL REFERENCES menu_mgmt.menu_items(id) ON DELETE CASCADE,
  quantity_available INT NOT NULL DEFAULT 0 CHECK (quantity_available >= 0),
  reorder_level INT NOT NULL DEFAULT 0 CHECK (reorder_level >= 0),
  unit VARCHAR(24) NOT NULL DEFAULT 'portion',
  last_restocked_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (vendor_id, menu_item_id)
);

CREATE TABLE IF NOT EXISTS menu_mgmt.inventory_ledger (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  inventory_id UUID NOT NULL REFERENCES menu_mgmt.inventory(id) ON DELETE CASCADE,
  change_type VARCHAR(20) NOT NULL CHECK (change_type IN ('RESTOCK', 'SALE', 'WASTE', 'ADJUSTMENT')),
  quantity_delta INT NOT NULL,
  reason VARCHAR(160),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
