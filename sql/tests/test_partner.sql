BEGIN;

SELECT 'Testing partner registration...' AS test_name;
SELECT *
FROM register_partner(
        'Test Hotel Group',
        'test@testhotel.com',
        'partner123',
        'Test',
        'Manager',
        '+66812345000',
        'TH'
     );

SELECT 'Testing partner authentication...' AS test_name;
SELECT *
FROM authenticate_partner('manager@bangkokgrand.com', 'partner123');

SELECT 'Testing get partner properties...' AS test_name;
SELECT *
FROM get_partner_properties(1);

SELECT 'Testing get property bookings...' AS test_name;
SELECT *
FROM get_property_bookings(1, 1);

SELECT 'Testing partner notifications...' AS test_name;
SELECT *
FROM get_partner_notifications(1, 5);

SELECT 'Testing availability update...' AS test_name;
SELECT update_room_availability(
               1, 1,
               ARRAY [CURRENT_DATE + 30, CURRENT_DATE + 31, CURRENT_DATE + 32],
               ARRAY [5, 4, 3],
               ARRAY [3000.00, 3200.00, 3400.00]
       );

SELECT 'Testing property creation...' AS test_name;
SELECT create_property(
               1, 'Test Property', 'Hotel', 4,
               'Bangkok', '999 Test Street', 'Silom District',
               'Test property description',
               '+66812345000', 'test@property.com'
       );

SELECT 'Testing room type addition...' AS test_name;
SELECT add_room_type(
               1, 1, 'Test Room Type', 2, 2, 0,
               '1 King Bed', 2500.00, 'THB', 10
       );

SELECT 'Testing property image addition...' AS test_name;
SELECT add_property_image(
               1, 1, 'https://test.com/image.jpg',
               'exterior', 1, TRUE
       );

SELECT 'Testing property amenities setting...' AS test_name;
SELECT set_property_amenities(1, 1, ARRAY [1, 2, 3]);

ROLLBACK;