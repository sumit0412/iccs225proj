CREATE OR REPLACE FUNCTION submit_review(
    p_booking_id INT,
    p_user_id INT,
    p_overall_rating INT,
    p_review_title VARCHAR(200) DEFAULT NULL,
    p_review_text TEXT DEFAULT NULL
) RETURNS INT AS
$$
DECLARE
    new_review_id  INT;
    booking_record RECORD;
BEGIN
    SELECT b.*, p.property_id
    INTO booking_record
    FROM bookings b
             JOIN properties p ON b.property_id = p.property_id
    WHERE b.booking_id = p_booking_id
      AND b.user_id = p_user_id
      AND b.booking_status = 'confirmed'
      AND b.check_out_date < CURRENT_DATE;

    IF booking_record IS NULL THEN
        RAISE EXCEPTION 'Booking not eligible for review';
    END IF;

    IF EXISTS (SELECT 1 FROM reviews r WHERE r.booking_id = p_booking_id) THEN
        RAISE EXCEPTION 'Review already submitted for this booking';
    END IF;

    IF p_overall_rating < 1 OR p_overall_rating > 10 THEN
        RAISE EXCEPTION 'Rating must be between 1 and 10';
    END IF;

    INSERT INTO reviews (booking_id, user_id, property_id, overall_rating,
                         review_title, review_text, review_status)
    VALUES (p_booking_id, p_user_id, booking_record.property_id, p_overall_rating,
            p_review_title, p_review_text, 'pending')
    RETURNING reviews.review_id INTO new_review_id;

    RETURN new_review_id;
END;
$$ LANGUAGE plpgsql;

-- Fixed get_property_reviews function
CREATE OR REPLACE FUNCTION get_property_reviews(
    p_property_id INT,
    p_limit_count INT DEFAULT 20,
    p_offset_count INT DEFAULT 0,
    p_status_filter VARCHAR(20) DEFAULT 'approved'
)
    RETURNS TABLE
            (
                review_id         INT,
                user_name         VARCHAR(201), -- first_name + ' ' + last_name
                overall_rating    INT,
                review_title      VARCHAR(200),
                review_text       TEXT,
                review_status     VARCHAR(20),
                booking_reference VARCHAR(20),
                room_type_name    VARCHAR(100),
                check_in_date     DATE,
                check_out_date    DATE,
                created_at        TIMESTAMP
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT r.review_id,
               (u.first_name || ' ' || u.last_name)::VARCHAR(201) AS user_name,
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
        WHERE r.property_id = p_property_id
          AND (p_status_filter = 'all' OR r.review_status = p_status_filter)
        ORDER BY r.created_at DESC
        LIMIT p_limit_count OFFSET p_offset_count;
END;
$$ LANGUAGE plpgsql;

-- Fixed get_property_review_summary function
CREATE OR REPLACE FUNCTION get_property_review_summary(p_property_id INT)
    RETURNS TABLE
            (
                total_reviews       BIGINT,
                avg_rating          NUMERIC,
                rating_distribution JSON,
                recent_review_count BIGINT
            )
AS
$$
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
           )
    INTO rating_dist
    FROM reviews r
    WHERE r.property_id = p_property_id
      AND r.review_status = 'approved';

    RETURN QUERY
        SELECT COUNT(r.review_id)                                                                 AS total_reviews,
               COALESCE(ROUND(AVG(r.overall_rating), 1), 0)::NUMERIC                              AS avg_rating,
               rating_dist                                                                        AS rating_distribution,
               COUNT(r.review_id) FILTER (WHERE r.created_at > CURRENT_DATE - INTERVAL '30 days') AS recent_review_count
        FROM reviews r
        WHERE r.property_id = p_property_id
          AND r.review_status = 'approved';
END;
$$ LANGUAGE plpgsql;

-- Fixed get_user_reviews function
CREATE OR REPLACE FUNCTION get_user_reviews(
    p_user_id INT,
    p_limit_count INT DEFAULT 10
)
    RETURNS TABLE
            (
                review_id         INT,
                property_name     VARCHAR(200),
                overall_rating    INT,
                review_title      VARCHAR(200),
                review_text       TEXT,
                review_status     VARCHAR(20),
                booking_reference VARCHAR(20),
                check_in_date     DATE,
                check_out_date    DATE,
                created_at        TIMESTAMP
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT r.review_id,
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
        WHERE r.user_id = p_user_id
        ORDER BY r.created_at DESC
        LIMIT p_limit_count;
END;
$$ LANGUAGE plpgsql;

-- Fixed get_partner_reviews function
CREATE OR REPLACE FUNCTION get_partner_reviews(
    p_partner_id INT,
    p_limit_count INT DEFAULT 20,
    p_status_filter VARCHAR(20) DEFAULT 'approved'
)
    RETURNS TABLE
            (
                review_id         INT,
                property_name     VARCHAR(200),
                user_name         VARCHAR(201), -- first_name + ' ' + last_name
                overall_rating    INT,
                review_title      VARCHAR(200),
                review_text       TEXT,
                review_status     VARCHAR(20),
                booking_reference VARCHAR(20),
                created_at        TIMESTAMP
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT r.review_id,
               p.property_name,
               (u.first_name || ' ' || u.last_name)::VARCHAR(201) AS user_name,
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
        WHERE p.partner_id = p_partner_id
          AND (p_status_filter = 'all' OR r.review_status = p_status_filter)
        ORDER BY r.created_at DESC
        LIMIT p_limit_count;
END;
$$ LANGUAGE plpgsql;