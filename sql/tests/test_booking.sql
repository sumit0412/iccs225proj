BEGIN;

SELECT 'Testing booking creation...' AS test_name;
SELECT * FROM create_booking(
        1,
        1,
        1,
        CURRENT_DATE + 20,
        CURRENT_DATE + 23,
        2,
        0,
        1,
        'John',
        'Customer',
        'john.customer@gmail.com',
        '+66812345678',
        'Late check-in please',
        'credit_card'
              );

SELECT 'Testing booking details...' AS test_name;
SELECT * FROM get_booking_details(1);

SELECT 'Testing booking modification...' AS test_name;
SELECT modify_booking(1, CURRENT_DATE + 21, CURRENT_DATE + 24, 1, 'Updated special requests');

SELECT 'Testing booking cancellation...' AS test_name;
SELECT cancel_booking(1, 1);

ROLLBACK;