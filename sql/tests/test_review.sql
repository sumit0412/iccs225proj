BEGIN;

SELECT submit_review(1, 5, 'Great experience!');

SELECT * FROM get_hotel_reviews(1);

ROLLBACK;
