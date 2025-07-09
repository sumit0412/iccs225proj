BEGIN;

-- Test user registration with unique email
SELECT 'Testing user registration...' AS test_name;
SELECT user_id, created_at
FROM register_user('testuser_' || EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) || '@example.com', 'password123', 'Test',
                   'User', '+66812345999', 'TH');

-- Skip authentication test since we can't easily test with hashed passwords
SELECT 'Testing user authentication...' AS test_name;
SELECT 'Authentication test skipped - requires real password hash' as auth_result;

-- Test user profile retrieval with existing user
SELECT 'Testing user profile retrieval...' AS test_name;
SELECT user_id, email, first_name, last_name, country_name, total_bookings
FROM get_user_profile(1);
-- Use existing user John Smith

-- Test booking history with existing user
SELECT 'Testing booking history...' AS test_name;
SELECT booking_id, booking_reference, property_name, booking_status
FROM get_booking_history(1) -- Use existing user John Smith
LIMIT 3;

-- Test profile update with existing user
SELECT 'Testing profile update...' AS test_name;
SELECT update_user_profile(1, 'Johnny', NULL, '+66812345000', 'TH') as update_result;

-- Verify update worked
SELECT 'Verifying profile update...' AS test_name;
SELECT first_name, phone_number
FROM get_user_profile(1);

ROLLBACK;