BEGIN;

SELECT * FROM register_user('newuser@example.com', 'password123', 'New User', '+1234567890');

SELECT * FROM authenticate_user('customer@example.com', 'pass123');

SELECT * FROM get_booking_history(1);

ROLLBACK;
