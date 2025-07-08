CREATE OR REPLACE FUNCTION create_booking(
    user_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    card_number TEXT,
    card_holder TEXT,
    total_amount NUMERIC
) RETURNS TABLE (booking_id INT, confirmation_code TEXT) AS $$
DECLARE
    new_booking_id INT;
    booking_duration INT;
    date_iterator DATE;
BEGIN
    booking_duration := (check_out - check_in);
    
    FOR date_iterator IN SELECT generate_series(check_in, check_out - INTERVAL '1 day', '1 day')::DATE
    LOOP
        IF NOT EXISTS (
            SELECT 1 
            FROM room_availability 
            WHERE room_id = room_id 
            AND date = date_iterator 
            AND available_rooms > 0
        ) THEN
            RAISE EXCEPTION 'Room not available on %', date_iterator;
        END IF;
    END LOOP;

    INSERT INTO bookings (user_id, room_id, check_in, check_out, status)
    VALUES (user_id, room_id, check_in, check_out, 'confirmed')
    RETURNING id INTO new_booking_id;
    
    INSERT INTO payments (booking_id, amount, payment_method, status)
    VALUES (new_booking_id, total_amount, 'credit_card', 'completed');
    
    FOR date_iterator IN SELECT generate_series(check_in, check_out - INTERVAL '1 day', '1 day')::DATE
    LOOP
        UPDATE room_availability
        SET available_rooms = available_rooms - 1
        WHERE room_id = room_id AND date = date_iterator;
    END LOOP;
    
    RETURN QUERY 
    SELECT 
        new_booking_id,
        'BKG-' || new_booking_id || '-' || substr(md5(random()::text), 1, 6);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cancel_booking(booking_id INT) RETURNS BOOLEAN AS $$
DECLARE
    booking_record RECORD;
    date_iterator DATE;
BEGIN
    SELECT * INTO booking_record FROM bookings WHERE id = booking_id;
    
    IF booking_record IS NULL THEN
        RETURN FALSE;
    END IF;
    
    IF booking_record.check_in <= (NOW() + INTERVAL '1 day') THEN
        RETURN FALSE;
    END IF;
    
    UPDATE bookings SET status = 'cancelled' WHERE id = booking_id;
    
    FOR date_iterator IN SELECT generate_series(
        booking_record.check_in, 
        booking_record.check_out - INTERVAL '1 day', 
        '1 day'
    )::DATE
    LOOP
        UPDATE room_availability
        SET available_rooms = available_rooms + 1
        WHERE room_id = booking_record.room_id AND date = date_iterator;
    END LOOP;
    
    UPDATE payments SET status = 'refunded' WHERE booking_id = booking_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
