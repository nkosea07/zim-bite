CREATE INDEX IF NOT EXISTS idx_users_phone ON user_mgmt.users(phone_number);
CREATE INDEX IF NOT EXISTS idx_users_role ON user_mgmt.users(role);

CREATE INDEX IF NOT EXISTS idx_user_addresses_user ON user_mgmt.user_addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_user_addresses_geo ON user_mgmt.user_addresses USING GIST (geo_point);

CREATE INDEX IF NOT EXISTS idx_vendors_geo ON vendor_mgmt.vendors USING GIST (geo_point);
CREATE INDEX IF NOT EXISTS idx_vendors_active ON vendor_mgmt.vendors(is_active);
CREATE INDEX IF NOT EXISTS idx_vendor_operating_days_vendor ON vendor_mgmt.vendor_operating_days(vendor_id, day_of_week);

CREATE INDEX IF NOT EXISTS idx_menu_items_vendor ON menu_mgmt.menu_items(vendor_id);
CREATE INDEX IF NOT EXISTS idx_menu_items_name_trgm ON menu_mgmt.menu_items USING GIN (name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_menu_items_available ON menu_mgmt.menu_items(is_available);
CREATE INDEX IF NOT EXISTS idx_inventory_vendor_item ON menu_mgmt.inventory(vendor_id, menu_item_id);

CREATE INDEX IF NOT EXISTS idx_orders_user_created ON ordering.orders(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_vendor_status ON ordering.orders(vendor_id, status);
CREATE INDEX IF NOT EXISTS idx_order_status_history_order ON ordering.order_status_history(order_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON ordering.order_items(order_id);

CREATE INDEX IF NOT EXISTS idx_payments_order_status ON payment_mgmt.payments(order_id, status);
CREATE INDEX IF NOT EXISTS idx_payments_provider_ref ON payment_mgmt.payments(provider, provider_reference);
CREATE INDEX IF NOT EXISTS idx_payment_callbacks_received ON payment_mgmt.payment_callbacks(received_at DESC);

CREATE INDEX IF NOT EXISTS idx_riders_status ON delivery_mgmt.riders(current_status, is_online);
CREATE INDEX IF NOT EXISTS idx_riders_geo ON delivery_mgmt.riders USING GIST (current_geo_point);
CREATE INDEX IF NOT EXISTS idx_deliveries_status ON delivery_mgmt.deliveries(status);
CREATE INDEX IF NOT EXISTS idx_deliveries_rider ON delivery_mgmt.deliveries(rider_id);
CREATE INDEX IF NOT EXISTS idx_delivery_tracking_delivery_time ON delivery_mgmt.delivery_tracking_points(delivery_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_delivery_tracking_geo ON delivery_mgmt.delivery_tracking_points USING GIST (geo_point);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_status ON subscription_mgmt.user_subscriptions(user_id, status);
CREATE INDEX IF NOT EXISTS idx_vendor_reviews_vendor ON feedback_mgmt.vendor_reviews(vendor_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_rider_reviews_rider ON feedback_mgmt.rider_reviews(rider_id, created_at DESC);
