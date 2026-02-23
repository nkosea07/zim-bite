CREATE TABLE IF NOT EXISTS user_mgmt.corporates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_name VARCHAR(160) NOT NULL,
  contact_email VARCHAR(160) NOT NULL UNIQUE,
  billing_currency CHAR(3) NOT NULL CHECK (billing_currency IN ('USD', 'ZWL')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_mgmt.users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  corporate_id UUID REFERENCES user_mgmt.corporates(id) ON DELETE SET NULL,
  role VARCHAR(24) NOT NULL CHECK (role IN ('CUSTOMER', 'VENDOR_ADMIN', 'VENDOR_STAFF', 'RIDER', 'SYSTEM_ADMIN')),
  first_name VARCHAR(80) NOT NULL,
  last_name VARCHAR(80) NOT NULL,
  email VARCHAR(160) NOT NULL UNIQUE,
  phone_number VARCHAR(24) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  preferred_language VARCHAR(8) NOT NULL DEFAULT 'en',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_mgmt.user_addresses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_mgmt.users(id) ON DELETE CASCADE,
  label VARCHAR(64) NOT NULL,
  line1 VARCHAR(200) NOT NULL,
  line2 VARCHAR(200),
  city VARCHAR(80) NOT NULL,
  area VARCHAR(80),
  geo_point geometry(Point, 4326),
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  delivery_instructions VARCHAR(280),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_mgmt.user_favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_mgmt.users(id) ON DELETE CASCADE,
  menu_item_id UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, menu_item_id)
);

CREATE TABLE IF NOT EXISTS auth.refresh_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_mgmt.users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
