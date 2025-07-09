CREATE
    OR REPLACE FUNCTION create_booking(
    user_id INT,
    property_id INT,
    room_type_id INT,
    check_in_date DATE,
    check_out_date DATE,
    total_adults INT,
    total_children INT DEFAULT 0,
    total_rooms INT DEFAULT 1,
    guest_first_name TEXT DEFAULT NULL,
    guest_last_name TEXT DEFAULT NULL,
    guest_email TEXT DEFAULT NULL,
    guest_phone TEXT DEFAULT NULL,
    special_requests TEXT DEFAULT NULL,
    payment_method TEXT DEFAULT 'credit_card'
)
    RETURNS TABLE
            (
                booking_id        INT,
                booking_reference TEXT,
                total_amount      NUMERIC
            )
AS
$$
DECLARE
    new_booking_id INT;
    new_booking_reference
                   TEXT;
    calculated_total
                   NUMERIC;
    total_nights
                   INT;
    date_iterator
                   DATE;
    room_rate
                   NUMERIC;
    currency
                   VARCHAR(3);
    new_payment_id
                   INT;
BEGIN
    IF
        check_out_date <= check_in_date THEN
        RAISE EXCEPTION 'Check-out date must be after check-in date';
    END IF;

    total_nights
        := (check_out_date - check_in_date);

    FOR date_iterator IN
        SELECT generate_series(check_in_date, check_out_date - INTERVAL '1 day', '1 day') ::DATE
        LOOP
            IF NOT EXISTS (SELECT 1
                           FROM availability a
                           WHERE a.room_type_id = create_booking.room_type_id
                             AND a.available_date = date_iterator
                             AND a.available_rooms >= total_rooms) THEN
                RAISE EXCEPTION 'Room type not available on %', date_iterator;
            END IF;
        END LOOP;

    SELECT AVG(a.rate), rt.currency_code
    INTO room_rate, currency
    FROM availability a
             JOIN room_types rt ON a.room_type_id = rt.room_type_id
    WHERE a.room_type_id = create_booking.room_type_id
      AND a.available_date BETWEEN check_in_date AND check_out_date - INTERVAL '1 day';

    calculated_total
        := room_rate * total_nights * total_rooms;

    IF
        guest_first_name IS NULL OR guest_last_name IS NULL OR guest_email IS NULL THEN
        SELECT u.first_name, u.last_name, u.email
        INTO guest_first_name, guest_last_name, guest_email
        FROM users u
        WHERE u.user_id = create_booking.user_id;
    END IF;

    new_booking_reference
        := 'AGD-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD') || '-' ||
           LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0');

    INSERT INTO bookings (booking_reference, user_id, property_id, room_type_id,
                          check_in_date, check_out_date, total_nights, total_adults,
                          total_children, total_rooms, total_amount, currency_code,
                          booking_status, guest_first_name, guest_last_name,
                          guest_email, guest_phone, special_requests)
    VALUES (new_booking_reference, user_id, property_id, room_type_id,
            check_in_date, check_out_date, total_nights, total_adults,
            total_children, total_rooms, calculated_total, currency,
            'confirmed', guest_first_name, guest_last_name,
            guest_email, guest_phone, special_requests)
    RETURNING booking_id
        INTO new_booking_id;

    INSERT INTO payments (booking_id, amount, currency_code, payment_method,
                          payment_status, transaction_id, processed_at)
    VALUES (new_booking_id, calculated_total, currency, payment_method,
            'completed', 'TXN-' || new_booking_reference, CURRENT_TIMESTAMP)
    RETURNING payment_id
        INTO new_payment_id;

    FOR date_iterator IN
        SELECT generate_series(check_in_date, check_out_date - INTERVAL '1 day', '1 day') ::DATE
        LOOP
            UPDATE availability
            SET available_rooms = available_rooms - total_rooms
            WHERE room_type_id = create_booking.room_type_id
              AND available_date = date_iterator;
        END LOOP;

    RETURN QUERY
        SELECT new_booking_id, new_booking_reference, calculated_total;
END;
$$
    LANGUAGE plpgsql;

CREATE
    OR REPLACE FUNCTION cancel_booking(target_booking_id INT, user_id INT DEFAULT NULL)
    RETURNS BOOLEAN AS
$$
DECLARE
    booking_record RECORD;
    date_iterator
                   DATE;
BEGIN
    SELECT *
    INTO booking_record
    FROM bookings
    WHERE booking_id = target_booking_id
      AND (user_id IS NULL OR bookings.user_id = cancel_booking.user_id);

    IF
        booking_record IS NULL THEN
        RETURN FALSE;
    END IF;

    IF
        booking_record.check_in_date <= CURRENT_DATE + INTERVAL '1 day' THEN
        RETURN FALSE;
    END IF;

    IF
        booking_record.booking_status = 'cancelled' THEN
        RETURN FALSE;
    END IF;

    UPDATE bookings
    SET booking_status = 'cancelled'
    WHERE booking_id = target_booking_id;

    FOR date_iterator IN
        SELECT generate_series(
                       booking_record.check_in_date,
                       booking_record.check_out_date - INTERVAL '1 day',
                       '1 day'
               ) ::DATE
        LOOP
            UPDATE availability
            SET available_rooms = available_rooms + booking_record.total_rooms
            WHERE room_type_id = booking_record.room_type_id
              AND available_date = date_iterator;
        END LOOP;

    UPDATE payments
    SET payment_status = 'refunded'
    WHERE booking_id = target_booking_id;

    RETURN TRUE;
END;
$$
    LANGUAGE plpgsql;

CREATE
    OR REPLACE FUNCTION get_booking_details(target_booking_id INT)
    RETURNS TABLE
            (
                booking_id        INT,
                booking_reference TEXT,
                property_name     TEXT,
                room_type_name    TEXT,
                check_in_date     DATE,
                check_out_date    DATE,
                total_nights      INT,
                total_adults      INT,
                total_children    INT,
                total_rooms       INT,
                total_amount      NUMERIC,
                currency_code     TEXT,
                booking_status    TEXT,
                guest_first_name  TEXT,
                guest_last_name   TEXT,
                guest_email       TEXT,
                guest_phone       TEXT,
                special_requests  TEXT,
                property_address  TEXT,
                city_name         TEXT,
                country_name      TEXT,
                contact_phone     TEXT,
                payment_status    TEXT,
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
               pay.payment_status,
               b.created_at
        FROM bookings b
                 JOIN properties p ON b.property_id = p.property_id
                 JOIN room_types rt ON b.room_type_id = rt.room_type_id
                 JOIN locations l ON p.location_id = l.location_id
                 JOIN cities c ON l.city_id = c.city_id
                 JOIN countries co ON c.country_id = co.country_id
                 LEFT JOIN payments pay ON b.booking_id = pay.booking_id
        WHERE b.booking_id = target_booking_id;
END;
$$
    LANGUAGE plpgsql;

CREATE
    OR REPLACE FUNCTION modify_booking(
    target_booking_id INT,
    new_check_in_date DATE DEFAULT NULL,
    new_check_out_date DATE DEFAULT NULL,
    new_total_rooms INT DEFAULT NULL,
    new_special_requests TEXT DEFAULT NULL
) RETURNS BOOLEAN AS
$$
DECLARE
    booking_record RECORD;
    new_total_nights
                   INT;
    new_total_amount
                   NUMERIC;
    date_iterator
                   DATE;
    room_rate
                   NUMERIC;
BEGIN
    SELECT *
    INTO booking_record
    FROM bookings
    WHERE booking_id = target_booking_id
      AND booking_status = 'confirmed';

    IF
        booking_record IS NULL THEN
        RETURN FALSE;
    END IF;

    new_check_in_date
        := COALESCE(new_check_in_date, booking_record.check_in_date);
    new_check_out_date
        := COALESCE(new_check_out_date, booking_record.check_out_date);
    new_total_rooms
        := COALESCE(new_total_rooms, booking_record.total_rooms);
    new_special_requests
        := COALESCE(new_special_requests, booking_record.special_requests);

    IF
        new_check_out_date <= new_check_in_date THEN
        RETURN FALSE;
    END IF;

    new_total_nights
        := (new_check_out_date - new_check_in_date);

    IF
        new_check_in_date != booking_record.check_in_date OR
        new_check_out_date != booking_record.check_out_date OR
        new_total_rooms != booking_record.total_rooms THEN

        FOR date_iterator IN
            SELECT generate_series(new_check_in_date, new_check_out_date - INTERVAL '1 day', '1 day') ::DATE
            LOOP
                IF NOT EXISTS (SELECT 1
                               FROM availability a
                               WHERE a.room_type_id = booking_record.room_type_id
                                 AND a.available_date = date_iterator
                                 AND a.available_rooms >= new_total_rooms) THEN
                    RETURN FALSE;
                END IF;
            END LOOP;

        FOR date_iterator IN
            SELECT generate_series(
                           booking_record.check_in_date,
                           booking_record.check_out_date - INTERVAL '1 day',
                           '1 day'
                   ) ::DATE
            LOOP
                UPDATE availability
                SET available_rooms = available_rooms + booking_record.total_rooms
                WHERE room_type_id = booking_record.room_type_id
                  AND available_date = date_iterator;
            END LOOP;

        FOR date_iterator IN
            SELECT generate_series(new_check_in_date, new_check_out_date - INTERVAL '1 day', '1 day') ::DATE
            LOOP
                UPDATE availability
                SET available_rooms = available_rooms - new_total_rooms
                WHERE room_type_id = booking_record.room_type_id
                  AND available_date = date_iterator;
            END LOOP;

        SELECT AVG(a.rate)
        INTO room_rate
        FROM availability a
        WHERE a.room_type_id = booking_record.room_type_id
          AND a.available_date BETWEEN new_check_in_date AND new_check_out_date - INTERVAL '1 day';

        new_total_amount
            := room_rate * new_total_nights * new_total_rooms;

        UPDATE payments
        SET amount = new_total_amount
        WHERE booking_id = target_booking_id;
    ELSE
        new_total_amount := booking_record.total_amount;
    END IF;

    UPDATE bookings
    SET check_in_date    = new_check_in_date,
        check_out_date   = new_check_out_date,
        total_nights     = new_total_nights,
        total_rooms      = new_total_rooms,
        total_amount     = new_total_amount,
        special_requests = new_special_requests
    WHERE booking_id = target_booking_id;

    RETURN TRUE;
END;
$$
    LANGUAGE plpgsql;