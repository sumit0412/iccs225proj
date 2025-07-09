BEGIN;

SELECT 'Testing admin authentication with invalid credentials...' AS test_name;
SELECT 'Authentication test with fake credentials (should return no results)' AS note,
       COUNT(*)                                                               as result_count
FROM authenticate_admin('sarah.johnson', 'wrongpassword');

SELECT 'Testing pending applications...' AS test_name;
SELECT *
FROM get_pending_property_applications(10);

-- Test with existing pending property (property ID 12 from seed data)
SELECT 'Testing property approval...' AS test_name;
SELECT approve_property_application(12, 1, 'Property meets all requirements');

-- Reset for rejection test
UPDATE properties
SET property_status = 'pending',
    content_status  = 'draft'
WHERE property_id = 12;

SELECT 'Testing property rejection...' AS test_name;
SELECT reject_property_application(12, 1, 'Missing required documentation');

SELECT 'Testing coupon creation...' AS test_name;
SELECT create_coupon(
               'TEST25'::VARCHAR(50),                                    -- p_coupon_code
               '25% Test Discount'::VARCHAR(200),                        -- p_coupon_name
               'percentage'::VARCHAR(20),                                -- p_discount_type
               25.00::NUMERIC,                                          -- p_discount_value
               1::INT,                                                  -- p_admin_id
               1000.00::NUMERIC,                                        -- p_minimum_booking_amount
               CURRENT_TIMESTAMP::TIMESTAMP,                            -- p_valid_from
               (CURRENT_TIMESTAMP + INTERVAL '30 days')::TIMESTAMP      -- p_valid_to
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