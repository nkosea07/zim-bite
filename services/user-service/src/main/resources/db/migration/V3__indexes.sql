-- Performance indexes for user-service
-- user_addresses.user_id: listAddresses() called on every checkout and account page load
CREATE INDEX IF NOT EXISTS idx_user_addresses_user_id
    ON user_mgmt.user_addresses(user_id);

-- user_favorite_items.user_id: listFavorites() query
CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id
    ON user_mgmt.user_favorite_items(user_id);
