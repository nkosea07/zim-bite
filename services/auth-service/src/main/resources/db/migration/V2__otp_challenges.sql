CREATE TABLE IF NOT EXISTS auth.otp_challenges (
    id UUID PRIMARY KEY,
    principal VARCHAR(160) NOT NULL,
    otp_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    attempts_remaining INT NOT NULL,
    consumed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_auth_otp_challenges_principal_created
ON auth.otp_challenges(principal, created_at DESC);
