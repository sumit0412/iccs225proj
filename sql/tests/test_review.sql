BEGIN;

-- Use existing completed booking for review submission (booking ID 10 is completed)
SELECT 'Testing review submission...' AS test_name;
SELECT submit_review(10, 10, 9, 'Great stay!', 'Excellent service and clean rooms. Highly recommend.');

-- Test with existing property reviews
SELECT 'Testing get property reviews...' AS test_name;
SELECT review_id, user_name, overall_rating, review_title, review_status
FROM get_property_reviews(1, 5, 0, 'approved');

SELECT 'Testing property review summary...' AS test_name;
SELECT total_reviews, avg_rating, recent_review_count
FROM get_property_review_summary(1);

-- Test with existing user reviews
SELECT 'Testing get user reviews...' AS test_name;
SELECT review_id, property_name, overall_rating, review_title, review_status
FROM get_user_reviews(1, 3);

-- Test with existing partner reviews
SELECT 'Testing get partner reviews...' AS test_name;
SELECT review_id, property_name, user_name, overall_rating, review_status
FROM get_partner_reviews(1, 5, 'approved');

ROLLBACK;