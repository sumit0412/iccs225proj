BEGIN;

SELECT * FROM create_booking(1, 1, '2024-12-01', '2024-12-03', '4111111111111111', 'John Doe', 200.00);

SELECT cancel_booking(1);

ROLLBACK;
