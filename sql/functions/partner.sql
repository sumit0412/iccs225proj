CREATE OR REPLACE FUNCTION update_availability(
    partner_id INT,
    room_id INT,
    dates DATE[],
    available_rooms INT[]
) RETURNS VOID AS $$
DECLARE
    i INT;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM rooms r
        JOIN hotels h ON r.hotel_id = h.id
        WHERE r.id = room_id AND h.partner_id = partner_id
    ) THEN
        RAISE EXCEPTION 'Room not owned by partner';
    END IF;

    FOR i IN 1 .. array_length(dates, 1)
    LOOP
        INSERT INTO room_availability (room_id, date, available_rooms)
        VALUES (room_id, dates[i], available_rooms[i])
        ON CONFLICT (room_id, date)
        DO UPDATE SET available_rooms = EXCLUDED.available_rooms;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_hotel_bookings(partner_id INT, hotel_id INT)
RETURNS TABLE (
    booking_id INT,
    room_type TEXT,
    check_in DATE,
    check_out DATE,
    guest_name TEXT,
    total_amount NUMERIC,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id,
        r.room_type,
        b.check_in,
        b.check_out,
        u.full_name,
        p.amount,
        b.status
    FROM bookings b
    JOIN payments p ON b.id = p.booking_id
    JOIN rooms r ON b.room_id = r.id
    JOIN users u ON b.user_id = u.id
    WHERE r.hotel_id = get_hotel_bookings.hotel_id
      AND EXISTS (
          SELECT 1
          FROM hotels h
          WHERE h.id = r.hotel_id
          AND h.partner_id = get_hotel_bookings.partner_id
      );
END;
$$ LANGUAGE plpgsql;
