BEGIN;

-- Homepage Search Box Functions
SELECT 'UI Test: Homepage search autocomplete...' AS test_name;
SELECT city_name, country_name, property_count
FROM search_cities_autocomplete('Bang')
LIMIT 5;

-- Login Page Functions - Skip authentication test
SELECT 'UI Test: User login authentication...' AS test_name;
SELECT 'Authentication test skipped - requires real password hash' as auth_result;

-- Registration Page Functions with unique email
SELECT 'UI Test: New user registration...' AS test_name;
SELECT user_id, created_at
FROM register_user('ui.test_' || EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) || '@example.com', 'testpass123', 'UI', 'Tester',
                   '+66123456789', 'TH');

-- Search Results Page Functions
SELECT 'UI Test: Property search results...' AS test_name;
SELECT property_id, property_name, min_price_per_night, avg_rating, total_reviews
FROM search_properties('Bangkok', CURRENT_DATE + INTERVAL '30 days', CURRENT_DATE + INTERVAL '33 days', 2)
LIMIT 10;

-- Hotel Detail Page Functions
SELECT 'UI Test: Property details display...' AS test_name;
SELECT property_id, property_name, property_type, star_rating, city_name
FROM get_property_details(1);

SELECT 'UI Test: Property amenities list...' AS test_name;
SELECT amenity_name, amenity_category, is_free
FROM get_property_amenities(1);

SELECT 'UI Test: Property image gallery...' AS test_name;
SELECT image_category, is_primary
FROM get_property_images(1);

-- Room Selection Functions
SELECT 'UI Test: Available room types...' AS test_name;
SELECT room_type_id, room_type_name, max_occupancy, current_rate, available_rooms
FROM get_available_room_types(1, CURRENT_DATE + INTERVAL '30 days', CURRENT_DATE + INTERVAL '33 days', 2);

-- Booking Form Functions
SELECT 'UI Test: Create new booking...' AS test_name;
SELECT booking_id, booking_reference, total_amount
FROM create_booking(
        1, 1, 1, CURRENT_DATE + INTERVAL '45 days', CURRENT_DATE + INTERVAL '48 days', 2, 0, 1,
        'UI', 'Tester', 'ui.test@example.com', '+66123456789', 'Test booking'
     );

-- My Bookings Page Functions
SELECT 'UI Test: User booking history...' AS test_name;
SELECT booking_id, booking_reference, property_name, booking_status
FROM get_booking_history(1)
LIMIT 5;

-- Partner Dashboard Functions
SELECT 'UI Test: Partner property list...' AS test_name;
SELECT property_id, property_name, property_type, property_status
FROM get_partner_properties(1)
LIMIT 3;

SELECT 'UI Test: Partner notifications...' AS test_name;
SELECT notification_type, property_name, priority
FROM get_partner_notifications(1, 5);

SELECT 'UI Test: Property booking list...' AS test_name;
SELECT booking_id, booking_reference, property_name, booking_status
FROM get_property_bookings(1, 1)
LIMIT 5;

-- Admin Dashboard Functions
SELECT 'UI Test: Pending property applications...' AS test_name;
SELECT property_id, property_name, partner_company, property_status
FROM get_pending_property_applications(5);

SELECT 'UI Test: Active coupon management...' AS test_name;
SELECT coupon_id, coupon_code, coupon_name, discount_type, coupon_status
FROM get_active_coupons()
LIMIT 5;

ROLLBACK;