BEGIN;

-- Hotel Partner Dashboard Wireframe Tests
SELECT 'Wireframe Test: Room availability calendar...' AS test_name;
SELECT room_type_id, available_date, available_rooms, rate
FROM availability
WHERE room_type_id IN (SELECT room_type_id FROM room_types WHERE property_id = 1)
  AND available_date BETWEEN CURRENT_DATE AND CURRENT_DATE + 30
ORDER BY available_date
LIMIT 10;

SELECT 'Wireframe Test: Rate update functionality...' AS test_name;
SELECT update_room_availability(1, 1, ARRAY [CURRENT_DATE + INTERVAL '50 days'], ARRAY [5], ARRAY [4000.00]);

SELECT 'Wireframe Test: Recent booking notifications...' AS test_name;
SELECT notification_type, property_name, priority
FROM get_partner_notifications(1, 3);

-- Property Setup/Onboarding Wireframe Tests - Create new entities to avoid conflicts
SELECT 'Wireframe Test: Property registration...' AS test_name;
SELECT create_property(1, 'Wireframe Test Hotel ' || EXTRACT(EPOCH FROM CURRENT_TIMESTAMP), 'Hotel', 4, 'Bangkok',
                       '123 Wireframe St', NULL, 'Test property for wireframe', NULL, NULL) as new_property_id;

-- Use property ID 1 for room type test since it exists
SELECT 'Wireframe Test: Room type setup...' AS test_name;
SELECT add_room_type(1, 1, 'Wireframe Room ' || EXTRACT(EPOCH FROM CURRENT_TIMESTAMP), 2, 2, 0, '1 King Bed', 3000.00,
                     'THB', 20) as new_room_type_id;

SELECT 'Wireframe Test: Property amenity setup...' AS test_name;
SELECT set_property_amenities(1, 1, ARRAY [1, 2, 3, 4]) as amenity_setup_result;

-- Content Management Dashboard Wireframe Tests
SELECT 'Wireframe Test: Pending hotel applications...' AS test_name;
SELECT property_id, property_name, partner_company, property_status
FROM get_pending_property_applications(3);

-- Test approval on property 12 which is pending in seed data
SELECT 'Wireframe Test: Property approval process...' AS test_name;
SELECT approve_property_application(12, 1, 'Approved after review') as approval_result;

SELECT 'Wireframe Test: Coupon creation...' AS test_name;
SELECT create_coupon('WIRE' || EXTRACT(EPOCH FROM CURRENT_TIMESTAMP), 'Wireframe Test 25%', 'percentage', 25.00, 1,
                     500.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '30 days') as new_coupon_id;

SELECT 'Wireframe Test: Coupon management...' AS test_name;
SELECT coupon_id, coupon_code, coupon_name, coupon_status
FROM get_active_coupons()
LIMIT 3;

ROLLBACK;