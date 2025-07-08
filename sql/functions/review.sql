CREATE OR REPLACE FUNCTION submit_review(
    booking_id INT,
    rating INT,
    comment TEXT
) RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM bookings b
        WHERE b.id = booking_id
          AND b.status = 'completed'
          AND b.check_out < CURRENT_DATE
    ) THEN
        RAISE EXCEPTION 'Booking not eligible for review';
    END IF;

    IF EXISTS (SELECT 1 FROM reviews WHERE booking_id = submit_review.booking_id) THEN
        RAISE EXCEPTION 'Review already submitted for this booking';
    END IF;

    INSERT INTO reviews (booking_id, hotel_id, user_id, rating, comment)
    SELECT 
        booking_id,
        r.hotel_id,
        b.user_id,
        rating,
        comment
    FROM bookings b
    JOIN rooms r ON b.room_id = r.id
    WHERE b.id = booking_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_hotel_reviews(hotel_id INT)
RETURNS TABLE (
    user_name TEXT,
    rating INT,
    comment TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.full_name,
        r.rating,
        r.comment,
        r.created_at
    FROM reviews r
    JOIN users u ON r.user_id = u.id
    WHERE r.hotel_id = get_hotel_reviews.hotel_id
    ORDER BY r.created_at DESC;
END;
$$ LANGUAGE plpgsql;
