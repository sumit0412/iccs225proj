BEGIN;

SELECT update_availability(2, 1, ARRAY['2024-12-01', '2024-12-02'], ARRAY[3, 3]);

SELECT * FROM get_hotel_bookings(2, 1);

ROLLBACK;
