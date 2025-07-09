BEGIN;

SELECT 'Testing admin authentication...' AS test_name;
SELECT *
FROM authenticate_admin('sarah.johnson', 'admin123');

SELECT 'Testing pending applications...' AS test_name;
SELECT *
FROM get_pending_property_applications(10);

SELECT 'Testing property approval...' AS test_name;
SELECT approve_property_application(12, 1, 'Property meets all requirements');

SELECT 'Testing property rejection...' AS test_name;
SELECT reject_property_application(12, 1, 'Missing required documentation');

SELECT 'Testing coupon creation...' AS test_name;
SELECT create_coupon(
               'TEST25', '25% Test Discount', 'percentage', 25.00, 1,
               1000.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '30 days'
       );

SELECT 'Testing coupon status update...' AS test_name;
SELECT update_coupon_status(1, 'inactive', 1);

SELECT 'Testing partner onboarding...' AS test_name;
SELECT *
FROM onboard_partner_with_property(
        'New Test Hotel', 'newtest@hotel.com', 'password123',
        'New', 'Owner', '+66812345555', 'TH',
        'New Test Property', 'Hotel', 3,
        'Bangkok', '123 New Test Street'
     );

SELECT 'Testing active coupons...' AS test_name;
SELECT *
FROM get_active_coupons();

SELECT 'Testing properties needing review...' AS test_name;
SELECT *
FROM get_properties_needing_content_review(5);

SELECT 'Testing coupon deactivation...' AS test_name;
SELECT deactivate_coupon(1, 1);

ROLLBACK;