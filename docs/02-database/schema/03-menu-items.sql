CREATE TABLE IF NOT EXISTS menu_mgmt.menu_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vendor_id UUID NOT NULL REFERENCES vendor_mgmt.vendors(id) ON DELETE CASCADE,
  name VARCHAR(120) NOT NULL,
  display_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (vendor_id, name)
);

CREATE TABLE IF NOT EXISTS menu_mgmt.menu_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vendor_id UUID NOT NULL REFERENCES vendor_mgmt.vendors(id) ON DELETE CASCADE,
  category_id UUID REFERENCES menu_mgmt.menu_categories(id) ON DELETE SET NULL,
  name VARCHAR(160) NOT NULL,
  description TEXT,
  base_price NUMERIC(12,2) NOT NULL CHECK (base_price >= 0),
  currency CHAR(3) NOT NULL CHECK (currency IN ('USD', 'ZWL')),
  is_available BOOLEAN NOT NULL DEFAULT TRUE,
  is_breakfast_only BOOLEAN NOT NULL DEFAULT TRUE,
  image_url TEXT,
  nutrition_json JSONB,
  allergens_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS menu_mgmt.menu_item_components (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  menu_item_id UUID NOT NULL REFERENCES menu_mgmt.menu_items(id) ON DELETE CASCADE,
  component_name VARCHAR(120) NOT NULL,
  component_type VARCHAR(30) NOT NULL CHECK (component_type IN ('BASE', 'PROTEIN', 'SIDE', 'TOPPING', 'DRINK', 'ADDON')),
  price_delta NUMERIC(12,2) NOT NULL DEFAULT 0,
  calories INT NOT NULL DEFAULT 0,
  is_optional BOOLEAN NOT NULL DEFAULT TRUE,
  is_available BOOLEAN NOT NULL DEFAULT TRUE,
  metadata_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS menu_mgmt.saved_meal_presets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_mgmt.users(id) ON DELETE CASCADE,
  vendor_id UUID NOT NULL REFERENCES vendor_mgmt.vendors(id) ON DELETE CASCADE,
  name VARCHAR(120) NOT NULL,
  meal_json JSONB NOT NULL,
  estimated_price NUMERIC(12,2) NOT NULL,
  currency CHAR(3) NOT NULL CHECK (currency IN ('USD', 'ZWL')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
