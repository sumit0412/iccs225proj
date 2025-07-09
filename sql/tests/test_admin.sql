BEGIN;

SELECT 'Testing admin authentication...' AS test_name;
SELECT * FROM authenticate_admin('admin_sarah', 'admin123');

SELECT 'Testing financial report...' AS test_name;
SELECT * FROM generate_financial_report(CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE);

SELECT 'Testing pending applications...' AS test_name;
SELECT * FROM get_pending_property_applications(10);

SELECT 'Testing platform statistics...' AS test_name;
SELECT * FROM get_platform_statistics();

SELECT 'Testing coupon creation...' AS test_name;
SELECT create_coupon(
               'TEST25',
               'Test Discount 25%',
               'percentage',
               25.00,
               1000.00,
               CURRENT_TIMESTAMP,
               CURRENT_TIMESTAMP + INTERVAL '30 days',
               1
       );

SELECT 'Testing active coupons...' AS test_name;
SELECT * FROM get_active_coupons();

SELECT 'Testing partner onboarding...' AS test_name;
SELECT * FROM onboard_partner_with_property(
        'New Test Hotel',
        'newtest@hotel.com',
        'password123',
        'New',
        'Owner',
        '+66812345555',
        'TH',
        'New Test Property',
        'Hotel',
        3,
        'Bangkok',
        '123 New Test Street'
              );

SELECT 'Testing pending reviews...' AS test_name;
SELECT * FROM get_pending_reviews_for_moderation(5);

ROLLBACK;