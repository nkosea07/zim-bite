-- Performance indexes for auth-service
-- auth_users.status: used in token refresh and account status checks
CREATE INDEX IF NOT EXISTS idx_auth_users_status
    ON auth.auth_users(status);

-- refresh_tokens.user_id: used in deleteByUserId (token revocation on logout)
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id
    ON auth.refresh_tokens(user_id);
