BEGIN;

SELECT 'Testing partner registration...' AS test_name;
SELECT * FROM register_partner(
        'Test Hotel Group',
        'test@testhotel.com',
        'partner123',
        'Test',
        'Manager',
        '+66812345000',
        'TH'
              );

SELECT 'Testing partner authentication...' AS test_name;
SELECT * FROM authenticate_partner('manager@bangkokgrand.com', 'partner123');

SELECT 'Testing get partner properties...' AS test_name;
SELECT * FROM get_partner_properties(1);

SELECT 'Testing get property bookings...' AS test_name;
SELECT * FROM get_property_bookings(1, 1);

SELECT 'Testing partner notifications...' AS test_name;
SELECT * FROM get_partner_notifications(1, 5);

SELECT 'Testing availability update...' AS test_name;
SELECT update_room_availability(
               1,
               1,
               ARRAY[CURRENT_DATE + 30, CURRENT_DATE + 31, CURRENT_DATE + 32],
               ARRAY[5, 4, 3],
               ARRAY[3000.00, 3200.00, 3400.00]
       );

SELECT 'Testing property creation...' AS test_name;
SELECT create_property(
               1,
               'Test Property',
               'Hotel',
               4,
               'Bangkok',
               'Silom District',
               '999 Test Street',
               'Test property description',
               '+66812345000',
               'test@property.com'
       );

ROLLBACK;