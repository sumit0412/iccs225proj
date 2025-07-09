CREATE OR REPLACE FUNCTION submit_review(
    booking_id INT,
    user_id INT,
    overall_rating INT,
    review_title TEXT DEFAULT NULL,
    review_text TEXT DEFAULT NULL
) RETURNS INT AS $$
DECLARE
new_review_id INT;
    booking_record RECORD;
BEGIN
SELECT b.*, p.property_id INTO booking_record
FROM bookings b
         JOIN properties p ON b.property_id = p.property_id
WHERE b.booking_id = submit_review.booking_id
  AND b.user_id = submit_review.user_id
  AND b.booking_status = 'confirmed'
  AND b.check_out_date < CURRENT_DATE;

IF booking_record IS NULL THEN
        RAISE EXCEPTION 'Booking not eligible for review';
END IF;

    IF EXISTS (SELECT 1 FROM reviews WHERE booking_id = submit_review.booking_id) THEN
        RAISE EXCEPTION 'Review already submitted for this booking';
END IF;

    IF overall_rating < 1 OR overall_rating > 10 THEN
        RAISE EXCEPTION 'Rating must be between 1 and 10';
END IF;

INSERT INTO reviews (
    booking_id, user_id, property_id, overall_rating,
    review_title, review_text, review_status
)
VALUES (
           booking_id, user_id, booking_record.property_id, overall_rating,
           review_title, review_text, 'pending'
       )
    RETURNING review_id INTO new_review_id;

RETURN new_review_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_property_reviews(
    target_property_id INT,
    limit_count INT DEFAULT 20,
    offset_count INT DEFAULT 0,
    status_filter TEXT DEFAULT 'approved'
)
RETURNS TABLE (
    review_id INT,
    user_name TEXT,
    overall_rating INT,
    review_title TEXT,
    review_text TEXT,
    review_status TEXT,
    booking_reference TEXT,
    room_type_name TEXT,
    check_in_date DATE,
    check_out_date DATE,
    created_at TIMESTAMP
) AS $$
BEGIN
RETURN QUERY
SELECT
    r.review_id,
    u.first_name || ' ' || u.last_name AS user_name,
    r.overall_rating,
    r.review_title,
    r.review_text,
    r.review_status,
    b.booking_reference,
    rt.room_type_name,
    b.check_in_date,
    b.check_out_date,
    r.created_at
FROM reviews r
         JOIN users u ON r.user_id = u.user_id
         JOIN bookings b ON r.booking_id = b.booking_id
         JOIN room_types rt ON b.room_type_id = rt.room_type_id
WHERE r.property_id = target_property_id
  AND (status_filter = 'all' OR r.review_status = status_filter)
ORDER BY r.created_at DESC
    LIMIT limit_count OFFSET offset_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_property_review_summary(target_property_id INT)
RETURNS TABLE (
    total_reviews BIGINT,
    avg_rating NUMERIC,
    rating_distribution JSON,
    recent_review_count BIGINT
) AS $$
DECLARE
rating_dist JSON;
BEGIN
    -- Calculate rating distribution
SELECT json_build_object(
               '1_star', COUNT(*) FILTER (WHERE overall_rating = 1),
               '2_star', COUNT(*) FILTER (WHERE overall_rating = 2),
               '3_star', COUNT(*) FILTER (WHERE overall_rating = 3),
               '4_star', COUNT(*) FILTER (WHERE overall_rating = 4),
               '5_star', COUNT(*) FILTER (WHERE overall_rating = 5),
               '6_star', COUNT(*) FILTER (WHERE overall_rating = 6),
               '7_star', COUNT(*) FILTER (WHERE overall_rating = 7),
               '8_star', COUNT(*) FILTER (WHERE overall_rating = 8),
               '9_star', COUNT(*) FILTER (WHERE overall_rating = 9),
               '10_star', COUNT(*) FILTER (WHERE overall_rating = 10)
       ) INTO rating_dist
FROM reviews
WHERE property_id = target_property_id AND review_status = 'approved';

RETURN QUERY
SELECT
    COUNT(r.review_id) AS total_reviews,
    COALESCE(ROUND(AVG(r.overall_rating), 1), 0)::NUMERIC AS avg_rating,
    rating_dist AS rating_distribution,
    COUNT(r.review_id) FILTER (WHERE r.created_at > CURRENT_DATE - INTERVAL '30 days') AS recent_review_count
FROM reviews r
WHERE r.property_id = target_property_id
  AND r.review_status = 'approved';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_user_reviews(
    target_user_id INT,
    limit_count INT DEFAULT 10
)
RETURNS TABLE (
    review_id INT,
    property_name TEXT,
    overall_rating INT,
    review_title TEXT,
    review_text TEXT,
    review_status TEXT,
    booking_reference TEXT,
    check_in_date DATE,
    check_out_date DATE,
    created_at TIMESTAMP
) AS $$
BEGIN
RETURN QUERY
SELECT
    r.review_id,
    p.property_name,
    r.overall_rating,
    r.review_title,
    r.review_text,
    r.review_status,
    b.booking_reference,
    b.check_in_date,
    b.check_out_date,
    r.created_at
FROM reviews r
         JOIN properties p ON r.property_id = p.property_id
         JOIN bookings b ON r.booking_id = b.booking_id
WHERE r.user_id = target_user_id
ORDER BY r.created_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_partner_reviews(
    partner_id INT,
    limit_count INT DEFAULT 20,
    status_filter TEXT DEFAULT 'approved'
)
RETURNS TABLE (
    review_id INT,
    property_name TEXT,
    user_name TEXT,
    overall_rating INT,
    review_title TEXT,
    review_text TEXT,
    review_status TEXT,
    booking_reference TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
RETURN QUERY
SELECT
    r.review_id,
    p.property_name,
    u.first_name || ' ' || u.last_name AS user_name,
    r.overall_rating,
    r.review_title,
    r.review_text,
    r.review_status,
    b.booking_reference,
    r.created_at
FROM reviews r
         JOIN properties p ON r.property_id = p.property_id
         JOIN users u ON r.user_id = u.user_id
         JOIN bookings b ON r.booking_id = b.booking_id
WHERE p.partner_id = get_partner_reviews.partner_id
  AND (status_filter = 'all' OR r.review_status = status_filter)
ORDER BY r.created_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;