INSERT INTO user_mgmt.corporates (id, company_name, contact_email, billing_currency)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'ZimBite HQ', 'corp@zimbite.co.zw', 'USD')
ON CONFLICT (id) DO NOTHING;

INSERT INTO user_mgmt.users (id, corporate_id, role, first_name, last_name, email, phone_number, password_hash)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', NULL, 'CUSTOMER', 'Tariro', 'Moyo', 'tariro@example.com', '+263771000001', 'hashed-password'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', NULL, 'VENDOR_ADMIN', 'Nyasha', 'Dube', 'vendor.admin@example.com', '+263771000002', 'hashed-password'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', NULL, 'RIDER', 'Kuda', 'Ncube', 'rider.one@example.com', '+263771000003', 'hashed-password'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', '11111111-1111-1111-1111-111111111111', 'SYSTEM_ADMIN', 'Admin', 'User', 'admin@example.com', '+263771000004', 'hashed-password')
ON CONFLICT (email) DO NOTHING;

INSERT INTO vendor_mgmt.vendors (id, owner_user_id, name, slug, phone_number, geo_point, average_prep_minutes)
VALUES
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'Sunrise Kitchen', 'sunrise-kitchen', '+263772000001', ST_SetSRID(ST_MakePoint(31.0530, -17.8252), 4326), 18)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO vendor_mgmt.vendor_operating_days (vendor_id, day_of_week, opens_at, closes_at)
VALUES
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 1, '05:00', '10:00'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 2, '05:00', '10:00'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 3, '05:00', '10:00'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 4, '05:00', '10:00'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 5, '05:00', '10:00')
ON CONFLICT (vendor_id, day_of_week) DO NOTHING;

INSERT INTO menu_mgmt.menu_categories (id, vendor_id, name, display_order)
VALUES
  ('cccccccc-cccc-cccc-cccc-ccccccccccc1', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'Breakfast Bowls', 1),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc2', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'Drinks', 2)
ON CONFLICT (vendor_id, name) DO NOTHING;

INSERT INTO menu_mgmt.menu_items (id, vendor_id, category_id, name, base_price, currency, is_available)
VALUES
  ('dddddddd-dddd-dddd-dddd-ddddddddddd1', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'cccccccc-cccc-cccc-cccc-ccccccccccc1', 'Classic Sadza Breakfast Bowl', 5.50, 'USD', TRUE),
  ('dddddddd-dddd-dddd-dddd-ddddddddddd2', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'cccccccc-cccc-cccc-cccc-ccccccccccc2', 'Ginger Tea', 1.20, 'USD', TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO menu_mgmt.menu_item_components (menu_item_id, component_name, component_type, price_delta, calories)
VALUES
  ('dddddddd-dddd-dddd-dddd-ddddddddddd1', 'Egg', 'PROTEIN', 1.00, 78),
  ('dddddddd-dddd-dddd-dddd-ddddddddddd1', 'Avocado', 'TOPPING', 1.20, 80),
  ('dddddddd-dddd-dddd-dddd-ddddddddddd1', 'Bacon', 'ADDON', 1.50, 140)
ON CONFLICT DO NOTHING;

INSERT INTO menu_mgmt.inventory (id, vendor_id, menu_item_id, quantity_available, reorder_level)
VALUES
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 120, 20),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee2', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'dddddddd-dddd-dddd-dddd-ddddddddddd2', 200, 30)
ON CONFLICT (vendor_id, menu_item_id) DO NOTHING;

INSERT INTO ordering.orders (
  id, order_number, user_id, vendor_id, order_type, status,
  subtotal_amount, delivery_fee, discount_amount, total_amount, currency
)
VALUES
  ('ffffffff-ffff-ffff-ffff-fffffffffff1', 'ZB-20260222-0001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'ON_DEMAND', 'PAID', 6.50, 1.50, 0, 8.00, 'USD')
ON CONFLICT (order_number) DO NOTHING;

INSERT INTO ordering.order_items (order_id, menu_item_id, item_name_snapshot, unit_price_snapshot, quantity, line_total)
VALUES
  ('ffffffff-ffff-ffff-ffff-fffffffffff1', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 'Classic Sadza Breakfast Bowl', 6.50, 1, 6.50)
ON CONFLICT DO NOTHING;

INSERT INTO payment_mgmt.payments (
  id, order_id, idempotency_key, provider, status, amount, currency, provider_reference, completed_at
)
VALUES
  ('99999999-9999-9999-9999-999999999991', 'ffffffff-ffff-ffff-ffff-fffffffffff1', 'idem-0001', 'ECOCASH', 'SUCCEEDED', 8.00, 'USD', 'ECO-REF-0001', NOW())
ON CONFLICT (idempotency_key) DO NOTHING;

INSERT INTO delivery_mgmt.riders (id, user_id, vehicle_type, is_online, current_status, current_geo_point)
VALUES
  ('77777777-7777-7777-7777-777777777771', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'BIKE', TRUE, 'AVAILABLE', ST_SetSRID(ST_MakePoint(31.0400, -17.8200), 4326))
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO delivery_mgmt.deliveries (
  id, order_id, rider_id, status, pickup_geo_point, dropoff_geo_point, estimated_minutes, distance_km, assigned_at
)
VALUES
  (
    '66666666-6666-6666-6666-666666666661',
    'ffffffff-ffff-ffff-ffff-fffffffffff1',
    '77777777-7777-7777-7777-777777777771',
    'ASSIGNED',
    ST_SetSRID(ST_MakePoint(31.0530, -17.8252), 4326),
    ST_SetSRID(ST_MakePoint(31.0600, -17.8300), 4326),
    15,
    3.4,
    NOW()
  )
ON CONFLICT (order_id) DO NOTHING;
