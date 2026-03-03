-- Performance indexes for order-service
-- orders(user_id, created_at DESC): primary query for user order history
CREATE INDEX IF NOT EXISTS idx_orders_user_created
    ON ordering.orders(user_id, created_at DESC);

-- orders(status, created_at DESC): admin/vendor order list filtered by status
CREATE INDEX IF NOT EXISTS idx_orders_status_created
    ON ordering.orders(status, created_at DESC);

-- order_items.order_id: joining order items to orders (high frequency)
CREATE INDEX IF NOT EXISTS idx_order_items_order_id
    ON ordering.order_items(order_id);

-- order_items.menu_item_id: pricing validation and analytics
CREATE INDEX IF NOT EXISTS idx_order_items_menu_item_id
    ON ordering.order_items(menu_item_id);

-- inventory_reservations(vendor_id, status): vendor-scoped reservation queries
CREATE INDEX IF NOT EXISTS idx_inventory_reservations_vendor_status
    ON ordering.inventory_reservations(vendor_id, status);

-- inventory_reservations(menu_item_id, status): item-level reservation lookup
CREATE INDEX IF NOT EXISTS idx_inventory_reservations_item_status
    ON ordering.inventory_reservations(menu_item_id, status);
