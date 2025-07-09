BEGIN;

SELECT 'Testing review submission...' AS test_name;
SELECT submit_review(10, 10, 9, 'Great stay!', 'Excellent service and clean rooms. Highly recommend.');

SELECT 'Testing get property reviews...' AS test_name;
SELECT *
FROM get_property_reviews(1, 10, 0, 'approved');

SELECT 'Testing property review summary...' AS test_name;
SELECT *
FROM get_property_review_summary(1);

SELECT 'Testing get user reviews...' AS test_name;
SELECT *
FROM get_user_reviews(1, 5);

SELECT 'Testing get partner reviews...' AS test_name;
SELECT *
FROM get_partner_reviews(1, 10, 'approved');

SELECT 'Testing review status update...' AS test_name;
SELECT update_review_status(1, 'approved', 1);

ROLLBACK;