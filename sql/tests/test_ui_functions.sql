BEGIN;

-- Homepage Search Box Functions
SELECT 'UI Test: Homepage search autocomplete...' AS test_name;
SELECT *
FROM search_cities_autocomplete('Bang')
LIMIT 5;

-- Login Page Functions
SELECT 'UI Test: User login authentication...' AS test_name;
SELECT *
FROM authenticate_user('john.smith@email.com', 'password123');

-- Registration Page Functions
SELECT 'UI Test: New user registration...' AS test_name;
SELECT *
FROM register_user('ui.test@example.com', 'testpass123', 'UI', 'Tester', '+66123456789', 'TH');

-- Search Results Page Functions
SELECT 'UI Test: Property search results...' AS test_name;
SELECT property_id, property_name, min_price_per_night, avg_rating, total_reviews
FROM search_properties('Bangkok', CURRENT_DATE + 7, CURRENT_DATE + 10, 2)
LIMIT 10;

-- Hotel Detail Page Functions
SELECT 'UI Test: Property details display...' AS test_name;
SELECT *
FROM get_property_details(1);

SELECT 'UI Test: Property amenities list...' AS test_name;
SELECT *
FROM get_property_amenities(1);

SELECT 'UI Test: Property image gallery...' AS test_name;
SELECT *
FROM get_property_images(1);

-- Room Selection Functions
SELECT 'UI Test: Available room types...' AS test_name;
SELECT *
FROM get_available_room_types(1, CURRENT_DATE + 7, CURRENT_DATE + 10, 2);

-- Booking Form Functions
SELECT 'UI Test: Create new booking...' AS test_name;
SELECT *
FROM create_booking(
        1, 1, 1, CURRENT_DATE + 15, CURRENT_DATE + 18, 2, 0, 1,
        'UI', 'Tester', 'ui.test@example.com', '+66123456789', 'Test booking'
     );

-- My Bookings Page Functions
SELECT 'UI Test: User booking history...' AS test_name;
SELECT *
FROM get_booking_history(1)
LIMIT 5;

-- Partner Dashboard Functions
SELECT 'UI Test: Partner property list...' AS test_name;
SELECT *
FROM get_partner_properties(1);

SELECT 'UI Test: Partner notifications...' AS test_name;
SELECT *
FROM get_partner_notifications(1, 5);

SELECT 'UI Test: Property booking list...' AS test_name;
SELECT *
FROM get_property_bookings(1, 1)
LIMIT 5;

-- Admin Dashboard Functions
SELECT 'UI Test: Pending property applications...' AS test_name;
SELECT *
FROM get_pending_property_applications(5);

SELECT 'UI Test: Active coupon management...' AS test_name;
SELECT *
FROM get_active_coupons()
LIMIT 5;

ROLLBACK;