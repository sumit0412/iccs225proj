BEGIN;

-- Setup availability data for the test dates
SELECT update_room_availability(
        1::INT,                                                -- partner_id
        1::INT,                                                -- room_type_id
        ARRAY[(CURRENT_DATE + INTERVAL '60 days')::DATE,       -- dates array
              (CURRENT_DATE + INTERVAL '61 days')::DATE,
              (CURRENT_DATE + INTERVAL '62 days')::DATE,
              (CURRENT_DATE + INTERVAL '63 days')::DATE],
        ARRAY[10, 10, 10, 10],                                -- available_rooms array
        ARRAY[4500.00, 4500.00, 4500.00, 4500.00]            -- rates array
    );

SELECT 'Testing booking creation with future dates...' AS test_name;
SELECT booking_id, booking_reference, total_amount
FROM create_booking(
        1::INT,                                                -- user_id
        1::INT,                                                -- property_id
        1::INT,                                                -- room_type_id
        (CURRENT_DATE + INTERVAL '60 days')::DATE,             -- check_in_date
        (CURRENT_DATE + INTERVAL '63 days')::DATE,             -- check_out_date
        2::INT,                                                -- total_adults
        0::INT,                                                -- total_children
        1::INT,                                                -- total_rooms
        'John'::VARCHAR(100),                                  -- guest_first_name
        'Customer'::VARCHAR(100),                              -- guest_last_name
        'john.customer@gmail.com'::VARCHAR(255),               -- guest_email
        '+66812345678'::VARCHAR(20),                          -- guest_phone
        'Late check-in please'::TEXT                          -- special_requests
     );

SELECT 'Testing booking details from existing booking...' AS test_name;
SELECT booking_id, booking_reference, property_name, booking_status, total_amount
FROM get_booking_details(1); -- Use existing booking ID 1

SELECT 'Testing booking modification...' AS test_name;
SELECT modify_booking(
        1::INT,                                                -- booking_id
        (CURRENT_DATE + INTERVAL '61 days')::DATE,             -- new_check_in_date
        (CURRENT_DATE + INTERVAL '64 days')::DATE,             -- new_check_out_date
        1::INT,                                                -- new_total_rooms
        'Updated special requests'::TEXT                       -- new_special_requests
    ) as modification_result;

SELECT 'Testing booking cancellation...' AS test_name;
SELECT cancel_booking(1::INT, 1::INT) as cancellation_result;

ROLLBACK;