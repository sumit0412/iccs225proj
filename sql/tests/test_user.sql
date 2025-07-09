BEGIN;

SELECT 'Testing user registration...' AS test_name;
SELECT *
FROM register_user('newuser@example.com', 'password123', 'John', 'Doe', '+66812345999', 'TH');

SELECT 'Testing user authentication...' AS test_name;
SELECT *
FROM authenticate_user('john.smith@email.com', 'password123');

SELECT 'Testing user profile retrieval...' AS test_name;
SELECT *
FROM get_user_profile(1);

SELECT 'Testing booking history...' AS test_name;
SELECT *
FROM get_booking_history(1);

SELECT 'Testing profile update...' AS test_name;
SELECT update_user_profile(1, 'Johnny', NULL, '+66812345000', 'TH');

ROLLBACK;