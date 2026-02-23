CREATE SCHEMA IF NOT EXISTS auth;

CREATE TABLE IF NOT EXISTS auth.auth_users (
    id              UUID PRIMARY KEY,
    email           VARCHAR(160) NOT NULL UNIQUE,
    phone_number    VARCHAR(24)  NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    first_name      VARCHAR(80)  NOT NULL,
    last_name       VARCHAR(80)  NOT NULL,
    role            VARCHAR(24)  NOT NULL CHECK (role IN ('CUSTOMER','VENDOR_ADMIN','VENDOR_STAFF','RIDER','SYSTEM_ADMIN')),
    status          VARCHAR(24)  NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','SUSPENDED','PENDING_VERIFICATION')),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS auth.refresh_tokens (
    id              UUID PRIMARY KEY,
    user_id         UUID         NOT NULL REFERENCES auth.auth_users(id) ON DELETE CASCADE,
    token_hash      VARCHAR(255) NOT NULL UNIQUE,
    expires_at      TIMESTAMPTZ  NOT NULL,
    revoked         BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
