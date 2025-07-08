CREATE OR REPLACE FUNCTION generate_financial_report(
    start_date DATE, 
    end_date DATE
) RETURNS TABLE (
    hotel_name TEXT,
    total_bookings BIGINT,
    total_revenue NUMERIC,
    commission_earned NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        h.name,
        COUNT(b.id) AS total_bookings,
        SUM(p.amount) AS total_revenue,
        SUM(p.amount * 0.15) AS commission_earned  -- 15% commission
    FROM bookings b
    JOIN payments p ON b.id = p.booking_id
    JOIN rooms r ON b.room_id = r.id
    JOIN hotels h ON r.hotel_id = h.id
    WHERE p.transaction_time BETWEEN start_date AND end_date
      AND p.status = 'completed'
    GROUP BY h.id, h.name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION onboard_hotel_partner(
    email TEXT,
    password TEXT,
    full_name TEXT,
    phone TEXT,
    hotel_name TEXT,
    hotel_address TEXT,
    hotel_city TEXT,
    hotel_country TEXT
) RETURNS TABLE (partner_id INT, hotel_id INT) AS $$
DECLARE
    new_partner_id INT;
    new_hotel_id INT;
BEGIN
    INSERT INTO users (email, password_hash, full_name, phone, role)
    VALUES (
        email, 
        crypt(password, gen_salt('bf', 8)),
        full_name, 
        phone,
        'partner'
    )
    RETURNING id INTO new_partner_id;
    
    INSERT INTO hotels (name, address, city, country, partner_id)
    VALUES (
        hotel_name,
        hotel_address,
        hotel_city,
        hotel_country,
        new_partner_id
    )
    RETURNING id INTO new_hotel_id;
    
    RETURN QUERY SELECT new_partner_id, new_hotel_id;
END;
$$ LANGUAGE plpgsql;
