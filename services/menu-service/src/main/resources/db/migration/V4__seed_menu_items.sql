-- Seed menu items for the four seeded vendors.
-- Vendor IDs must match V4__seed_vendors.sql in vendor-service.

-- ── Sunrise Kitchen (bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001) ──────────────────
INSERT INTO menu_mgmt.menu_items (id, vendor_id, name, category, base_price, currency, is_available, created_at)
VALUES
    ('cc000001-0000-0000-0000-000000000001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', 'Classic Sadza Breakfast Bowl', 'Breakfast Bowls', 6.50, 'USD', TRUE, NOW()),
    ('cc000001-0000-0000-0000-000000000002', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', 'Boiled Eggs & Toast',          'Breakfast Bowls', 4.00, 'USD', TRUE, NOW()),
    ('cc000001-0000-0000-0000-000000000003', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', 'Bacon & Egg Roll',             'Breakfast Rolls', 5.50, 'USD', TRUE, NOW()),
    ('cc000001-0000-0000-0000-000000000004', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', 'Avocado Toast',                'Breakfast Rolls', 5.00, 'USD', TRUE, NOW()),
    ('cc000001-0000-0000-0000-000000000005', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', 'Ginger Tea',                   'Drinks',          1.20, 'USD', TRUE, NOW()),
    ('cc000001-0000-0000-0000-000000000006', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', 'Maheu (Fermented Porridge)',   'Drinks',          1.50, 'USD', TRUE, NOW()),
    ('cc000001-0000-0000-0000-000000000007', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', 'Mixed Fruit Bowl',             'Sides',           2.50, 'USD', FALSE, NOW())
ON CONFLICT (id) DO NOTHING;

-- ── Morning Plate (bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002) ────────────────────
INSERT INTO menu_mgmt.menu_items (id, vendor_id, name, category, base_price, currency, is_available, created_at)
VALUES
    ('cc000002-0000-0000-0000-000000000001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', 'Sadza ne Nyama',               'Breakfast Bowls', 7.00, 'USD', TRUE, NOW()),
    ('cc000002-0000-0000-0000-000000000002', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', 'Scrambled Egg Plate',          'Breakfast Bowls', 4.50, 'USD', TRUE, NOW()),
    ('cc000002-0000-0000-0000-000000000003', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', 'Sausage Roll',                 'Breakfast Rolls', 3.50, 'USD', TRUE, NOW()),
    ('cc000002-0000-0000-0000-000000000004', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', 'Cheese & Tomato Toast',        'Breakfast Rolls', 3.80, 'USD', TRUE, NOW()),
    ('cc000002-0000-0000-0000-000000000005', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', 'Rooibos Tea',                  'Drinks',          1.00, 'USD', TRUE, NOW()),
    ('cc000002-0000-0000-0000-000000000006', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', 'Fresh Orange Juice',           'Drinks',          2.00, 'USD', TRUE, NOW()),
    ('cc000002-0000-0000-0000-000000000007', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', 'Banana & Peanut Butter Toast', 'Sides',           2.80, 'USD', TRUE, NOW())
ON CONFLICT (id) DO NOTHING;

-- ── Zim Brekkie Co. (bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003) ─────────────────
INSERT INTO menu_mgmt.menu_items (id, vendor_id, name, category, base_price, currency, is_available, created_at)
VALUES
    ('cc000003-0000-0000-0000-000000000001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003', 'Bulawayo Breakfast Bowl',      'Breakfast Bowls', 6.00, 'USD', TRUE, NOW()),
    ('cc000003-0000-0000-0000-000000000002', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003', 'Umngqusho & Egg',              'Breakfast Bowls', 5.50, 'USD', TRUE, NOW()),
    ('cc000003-0000-0000-0000-000000000003', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003', 'Beef Sausage Roll',            'Breakfast Rolls', 4.50, 'USD', TRUE, NOW()),
    ('cc000003-0000-0000-0000-000000000004', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003', 'Peanut Butter Toast',          'Breakfast Rolls', 3.00, 'USD', TRUE, NOW()),
    ('cc000003-0000-0000-0000-000000000005', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003', 'Zim Ginger Beer',              'Drinks',          1.80, 'USD', TRUE, NOW()),
    ('cc000003-0000-0000-0000-000000000006', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003', 'Black Tea',                    'Drinks',          0.80, 'USD', TRUE, NOW()),
    ('cc000003-0000-0000-0000-000000000007', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003', 'Roasted Sweet Potato',         'Sides',           2.00, 'USD', FALSE, NOW())
ON CONFLICT (id) DO NOTHING;

-- ── Golden Sadza (bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004) ────────────────────
INSERT INTO menu_mgmt.menu_items (id, vendor_id, name, category, base_price, currency, is_available, created_at)
VALUES
    ('cc000004-0000-0000-0000-000000000001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004', 'Golden Sadza Bowl',            'Breakfast Bowls', 7.50, 'USD', TRUE, NOW()),
    ('cc000004-0000-0000-0000-000000000002', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004', 'Sadza ne Muriwo',              'Breakfast Bowls', 5.00, 'USD', TRUE, NOW()),
    ('cc000004-0000-0000-0000-000000000003', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004', 'Grilled Chicken Wrap',         'Breakfast Rolls', 6.50, 'USD', TRUE, NOW()),
    ('cc000004-0000-0000-0000-000000000004', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004', 'Spinach & Feta Roll',          'Breakfast Rolls', 4.80, 'USD', TRUE, NOW()),
    ('cc000004-0000-0000-0000-000000000005', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004', 'Hibiscus Juice',               'Drinks',          1.50, 'USD', TRUE, NOW()),
    ('cc000004-0000-0000-0000-000000000006', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004', 'Maheu Special',                'Drinks',          1.80, 'USD', TRUE, NOW()),
    ('cc000004-0000-0000-0000-000000000007', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004', 'Roasted Groundnuts',           'Sides',           1.20, 'USD', TRUE, NOW())
ON CONFLICT (id) DO NOTHING;
