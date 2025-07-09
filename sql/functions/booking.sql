CREATE OR REPLACE FUNCTION create_booking(
    p_user_id INT,
    p_property_id INT,
    p_room_type_id INT,
    p_check_in_date DATE,
    p_check_out_date DATE,
    p_total_adults INT,
    p_total_children INT DEFAULT 0,
    p_total_rooms INT DEFAULT 1,
    p_guest_first_name VARCHAR(100) DEFAULT NULL,
    p_guest_last_name VARCHAR(100) DEFAULT NULL,
    p_guest_email VARCHAR(255) DEFAULT NULL,
    p_guest_phone VARCHAR(20) DEFAULT NULL,
    p_special_requests TEXT DEFAULT NULL
)
    RETURNS TABLE
            (
                booking_id        INT,
                booking_reference VARCHAR(20),
                total_amount      NUMERIC
            )
AS
$$
DECLARE
    new_booking_id        INT;
    new_booking_reference VARCHAR(20);
    calculated_total      NUMERIC;
    total_nights          INT;
    date_iterator         DATE;
    room_rate             NUMERIC;
    currency              VARCHAR(3);
BEGIN
    -- Validate dates
    IF p_check_out_date <= p_check_in_date THEN
        RAISE EXCEPTION 'Check-out date must be after check-in date';
    END IF;

    total_nights := (p_check_out_date - p_check_in_date);

    -- Check room availability for all dates
    FOR date_iterator IN
        SELECT generate_series(p_check_in_date, p_check_out_date - INTERVAL '1 day', '1 day')::DATE
        LOOP
            IF NOT EXISTS (SELECT 1
                           FROM availability a
                           WHERE a.room_type_id = p_room_type_id
                             AND a.available_date = date_iterator
                             AND a.available_rooms >= p_total_rooms) THEN
                RAISE EXCEPTION 'Room type not available on %', date_iterator;
            END IF;
        END LOOP;

    -- Get average rate and currency for the booking period
    SELECT AVG(a.rate), rt.currency_code
    INTO room_rate, currency
    FROM availability a
             JOIN room_types rt ON a.room_type_id = rt.room_type_id
    WHERE a.room_type_id = p_room_type_id
      AND a.available_date BETWEEN p_check_in_date AND p_check_out_date - INTERVAL '1 day';

    calculated_total := room_rate * total_nights * p_total_rooms;

    -- Use user information if guest details not provided
    IF p_guest_first_name IS NULL OR p_guest_last_name IS NULL OR p_guest_email IS NULL THEN
        SELECT u.first_name, u.last_name, u.email
        INTO p_guest_first_name, p_guest_last_name, p_guest_email
        FROM users u
        WHERE u.user_id = p_user_id;
    END IF;

    -- Generate booking reference
    new_booking_reference := 'AGD-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD') || '-' ||
                             LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0');

    -- Create booking
    INSERT INTO bookings (booking_reference, user_id, property_id, room_type_id,
                          check_in_date, check_out_date, total_nights, total_adults,
                          total_children, total_rooms, total_amount, currency_code,
                          booking_status, guest_first_name, guest_last_name,
                          guest_email, guest_phone, special_requests)
    VALUES (new_booking_reference, p_user_id, p_property_id, p_room_type_id,
            p_check_in_date, p_check_out_date, total_nights, p_total_adults,
            p_total_children, p_total_rooms, calculated_total, currency,
            'confirmed', p_guest_first_name, p_guest_last_name,
            p_guest_email, p_guest_phone, p_special_requests)
    RETURNING bookings.booking_id INTO new_booking_id;

    -- Update availability (reduce available rooms)
    FOR date_iterator IN
        SELECT generate_series(p_check_in_date, p_check_out_date - INTERVAL '1 day', '1 day')::DATE
        LOOP
            UPDATE availability a
            SET available_rooms = a.available_rooms - p_total_rooms,
                last_updated    = CURRENT_TIMESTAMP
            WHERE a.room_type_id = p_room_type_id
              AND a.available_date = date_iterator;
        END LOOP;

    RETURN QUERY SELECT new_booking_id, new_booking_reference, calculated_total;
END;
$$ LANGUAGE plpgsql;

-- Fixed cancel_booking function
CREATE OR REPLACE FUNCTION cancel_booking(p_booking_id INT, p_user_id INT DEFAULT NULL)
    RETURNS BOOLEAN AS
$$
DECLARE
    booking_record RECORD;
    date_iterator  DATE;
BEGIN
    -- Get booking details
    SELECT *
    INTO booking_record
    FROM bookings b
    WHERE b.booking_id = p_booking_id
      AND (p_user_id IS NULL OR b.user_id = p_user_id);

    IF booking_record IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Check if booking can be cancelled (not too close to check-in)
    IF booking_record.check_in_date <= CURRENT_DATE + INTERVAL '1 day' THEN
        RETURN FALSE;
    END IF;

    -- Check if already cancelled
    IF booking_record.booking_status = 'cancelled' THEN
        RETURN FALSE;
    END IF;

    -- Update booking status
    UPDATE bookings b
    SET booking_status = 'cancelled'
    WHERE b.booking_id = p_booking_id;

    -- Restore availability
    FOR date_iterator IN
        SELECT generate_series(
                       booking_record.check_in_date,
                       booking_record.check_out_date - INTERVAL '1 day',
                       '1 day'
               )::DATE
        LOOP
            UPDATE availability a
            SET available_rooms = a.available_rooms + booking_record.total_rooms,
                last_updated    = CURRENT_TIMESTAMP
            WHERE a.room_type_id = booking_record.room_type_id
              AND a.available_date = date_iterator;
        END LOOP;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Fixed get_booking_details function
CREATE OR REPLACE FUNCTION get_booking_details(p_booking_id INT)
    RETURNS TABLE
            (
                booking_id        INT,
                booking_reference VARCHAR(20),
                property_name     VARCHAR(200),
                room_type_name    VARCHAR(100),
                check_in_date     DATE,
                check_out_date    DATE,
                total_nights      INT,
                total_adults      INT,
                total_children    INT,
                total_rooms       INT,
                total_amount      NUMERIC,
                currency_code     VARCHAR(3),
                booking_status    VARCHAR(20),
                guest_first_name  VARCHAR(100),
                guest_last_name   VARCHAR(100),
                guest_email       VARCHAR(255),
                guest_phone       VARCHAR(20),
                special_requests  TEXT,
                property_address  VARCHAR(300),
                city_name         VARCHAR(100),
                country_name      VARCHAR(100),
                contact_phone     VARCHAR(20),
                created_at        TIMESTAMP
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT b.booking_id,
               b.booking_reference,
               p.property_name,
               rt.room_type_name,
               b.check_in_date,
               b.check_out_date,
               b.total_nights,
               b.total_adults,
               b.total_children,
               b.total_rooms,
               b.total_amount,
               b.currency_code,
               b.booking_status,
               b.guest_first_name,
               b.guest_last_name,
               b.guest_email,
               b.guest_phone,
               b.special_requests,
               p.street_address,
               c.city_name,
               co.country_name,
               p.contact_phone,
               b.created_at
        FROM bookings b
                 JOIN properties p ON b.property_id = p.property_id
                 JOIN room_types rt ON b.room_type_id = rt.room_type_id
                 JOIN locations l ON p.location_id = l.location_id
                 JOIN cities c ON l.city_id = c.city_id
                 JOIN countries co ON c.country_id = co.country_id
        WHERE b.booking_id = p_booking_id;
END;
$$ LANGUAGE plpgsql;

-- Fixed modify_booking function
CREATE OR REPLACE FUNCTION modify_booking(
    p_booking_id INT,
    p_new_check_in_date DATE DEFAULT NULL,
    p_new_check_out_date DATE DEFAULT NULL,
    p_new_total_rooms INT DEFAULT NULL,
    p_new_special_requests TEXT DEFAULT NULL
) RETURNS BOOLEAN AS
$$
DECLARE
    booking_record   RECORD;
    new_total_nights INT;
    new_total_amount NUMERIC;
    date_iterator    DATE;
    room_rate        NUMERIC;
BEGIN
    -- Get current booking details
    SELECT *
    INTO booking_record
    FROM bookings b
    WHERE b.booking_id = p_booking_id
      AND b.booking_status = 'confirmed';

    IF booking_record IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Set defaults to current values
    p_new_check_in_date := COALESCE(p_new_check_in_date, booking_record.check_in_date);
    p_new_check_out_date := COALESCE(p_new_check_out_date, booking_record.check_out_date);
    p_new_total_rooms := COALESCE(p_new_total_rooms, booking_record.total_rooms);
    p_new_special_requests := COALESCE(p_new_special_requests, booking_record.special_requests);

    -- Validate new dates
    IF p_new_check_out_date <= p_new_check_in_date THEN
        RETURN FALSE;
    END IF;

    new_total_nights := (p_new_check_out_date - p_new_check_in_date);

    -- If dates or room count changed, check availability and update
    IF p_new_check_in_date != booking_record.check_in_date OR
       p_new_check_out_date != booking_record.check_out_date OR
       p_new_total_rooms != booking_record.total_rooms THEN

        -- Check availability for new dates/rooms
        FOR date_iterator IN
            SELECT generate_series(p_new_check_in_date, p_new_check_out_date - INTERVAL '1 day', '1 day')::DATE
            LOOP
                IF NOT EXISTS (SELECT 1
                               FROM availability a
                               WHERE a.room_type_id = booking_record.room_type_id
                                 AND a.available_date = date_iterator
                                 AND a.available_rooms >= p_new_total_rooms) THEN
                    RETURN FALSE;
                END IF;
            END LOOP;

        -- Restore availability for old dates
        FOR date_iterator IN
            SELECT generate_series(
                           booking_record.check_in_date,
                           booking_record.check_out_date - INTERVAL '1 day',
                           '1 day'
                   )::DATE
            LOOP
                UPDATE availability a
                SET available_rooms = a.available_rooms + booking_record.total_rooms,
                    last_updated    = CURRENT_TIMESTAMP
                WHERE a.room_type_id = booking_record.room_type_id
                  AND a.available_date = date_iterator;
            END LOOP;

        -- Reserve new dates
        FOR date_iterator IN
            SELECT generate_series(p_new_check_in_date, p_new_check_out_date - INTERVAL '1 day', '1 day')::DATE
            LOOP
                UPDATE availability a
                SET available_rooms = a.available_rooms - p_new_total_rooms,
                    last_updated    = CURRENT_TIMESTAMP
                WHERE a.room_type_id = booking_record.room_type_id
                  AND a.available_date = date_iterator;
            END LOOP;

        -- Calculate new total amount
        SELECT AVG(a.rate)
        INTO room_rate
        FROM availability a
        WHERE a.room_type_id = booking_record.room_type_id
          AND a.available_date BETWEEN p_new_check_in_date AND p_new_check_out_date - INTERVAL '1 day';

        new_total_amount := room_rate * new_total_nights * p_new_total_rooms;
    ELSE
        new_total_amount := booking_record.total_amount;
    END IF;

    -- Update booking
    UPDATE bookings b
    SET check_in_date    = p_new_check_in_date,
        check_out_date   = p_new_check_out_date,
        total_nights     = new_total_nights,
        total_rooms      = p_new_total_rooms,
        total_amount     = new_total_amount,
        special_requests = p_new_special_requests
    WHERE b.booking_id = p_booking_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;