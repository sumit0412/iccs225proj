CREATE OR REPLACE FUNCTION register_user(
    email TEXT,
    password TEXT,
    full_name TEXT,
    phone TEXT DEFAULT NULL
) RETURNS TABLE (user_id INT, created_at TIMESTAMP) AS $$
DECLARE
    new_user_id INT;
    new_created_at TIMESTAMP;
BEGIN
    INSERT INTO users (email, password_hash, full_name, phone)
    VALUES (
        email, 
        crypt(password, gen_salt('bf', 8)),  -- using bcrypt with 8 rounds
        full_name, 
        phone
    )
    RETURNING id, created_at INTO new_user_id, new_created_at;
    
    RETURN QUERY SELECT new_user_id, new_created_at;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION authenticate_user(email TEXT, password TEXT) 
RETURNS TABLE (user_id INT, full_name TEXT, role TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT id, full_name, role
    FROM users
    WHERE users.email = authenticate_user.email
    AND password_hash = crypt(authenticate_user.password, password_hash);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_booking_history(user_id INT)
RETURNS TABLE (
    booking_id INT,
    hotel_name TEXT,
    check_in DATE,
    check_out DATE,
    total_price NUMERIC,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id,
        h.name,
        b.check_in,
        b.check_out,
        p.amount,
        b.status
    FROM bookings b
    JOIN payments p ON b.id = p.booking_id
    JOIN rooms r ON b.room_id = r.id
    JOIN hotels h ON r.hotel_id = h.id
    WHERE b.user_id = user_id
    ORDER BY b.check_in DESC;
END;
$$ LANGUAGE plpgsql;
