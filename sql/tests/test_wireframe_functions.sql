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
SELECT update_room_availability(1, 1, ARRAY [CURRENT_DATE + 1], ARRAY [5], ARRAY [4000.00]);

SELECT 'Wireframe Test: Recent booking notifications...' AS test_name;
SELECT *
FROM get_partner_notifications(1, 3);

-- Property Setup/Onboarding Wireframe Tests
SELECT 'Wireframe Test: Property registration...' AS test_name;
SELECT create_property(1, 'Wireframe Test Hotel', 'Hotel', 4, 'Bangkok', '123 Wireframe St');

SELECT 'Wireframe Test: Room type setup...' AS test_name;
SELECT add_room_type(1, 1, 'Standard Room', 2, 2, 0, '1 King Bed', 3000.00, 'THB', 20);

SELECT 'Wireframe Test: Property amenity setup...' AS test_name;
SELECT set_property_amenities(1, 1, ARRAY [1, 2, 3, 4]);

-- Content Management Dashboard Wireframe Tests
SELECT 'Wireframe Test: Pending hotel applications...' AS test_name;
SELECT *
FROM get_pending_property_applications(3);

SELECT 'Wireframe Test: Property approval process...' AS test_name;
SELECT approve_property_application(1, 1, 'Approved after review');

SELECT 'Wireframe Test: Coupon creation...' AS test_name;
SELECT create_coupon('WIRE25', 'Wireframe Test 25%', 'percentage', 25.00, 1, 500.00);

SELECT 'Wireframe Test: Coupon management...' AS test_name;
SELECT *
FROM get_active_coupons()
LIMIT 3;

ROLLBACK;