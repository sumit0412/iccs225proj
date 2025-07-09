CREATE OR REPLACE FUNCTION register_user(
    p_email VARCHAR(255),
    p_password VARCHAR(255),
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_phone_number VARCHAR(20) DEFAULT NULL,
    p_country_code VARCHAR(2) DEFAULT 'TH'
)
    RETURNS TABLE
            (
                user_id    INT,
                created_at TIMESTAMP
            )
AS
$$
DECLARE
    new_user_id       INT;
    new_created_at    TIMESTAMP;
    target_country_id INT;
BEGIN
    -- Get country_id from country_code
    SELECT c.country_id
    INTO target_country_id
    FROM countries c
    WHERE c.country_code = p_country_code;

    IF target_country_id IS NULL THEN
        target_country_id := 1; -- Default to Thailand
    END IF;

    INSERT INTO users (email, password_hash, first_name, last_name, phone_number, country_id)
    VALUES (p_email,
            crypt(p_password, gen_salt('bf', 8)),
            p_first_name,
            p_last_name,
            p_phone_number,
            target_country_id)
    RETURNING users.user_id, users.created_at INTO new_user_id, new_created_at;

    RETURN QUERY SELECT new_user_id, new_created_at;
END;
$$ LANGUAGE plpgsql;

-- Fixed authenticate_user function
CREATE OR REPLACE FUNCTION authenticate_user(p_email VARCHAR(255), p_password VARCHAR(255))
    RETURNS TABLE
            (
                user_id      INT,
                full_name    VARCHAR(201), -- first_name + ' ' + last_name = 100 + 1 + 100 = 201
                email        VARCHAR(255),
                country_name VARCHAR(100),
                last_login   TIMESTAMP
            )
AS
$$
BEGIN
    -- Update last login
    UPDATE users u
    SET last_login = CURRENT_TIMESTAMP
    WHERE u.email = p_email
      AND u.password_hash = crypt(p_password, u.password_hash);

    RETURN QUERY
        SELECT u.user_id,
               (u.first_name || ' ' || u.last_name)::VARCHAR(201) AS full_name,
               u.email,
               c.country_name,
               u.last_login
        FROM users u
                 LEFT JOIN countries c ON u.country_id = c.country_id
        WHERE u.email = p_email
          AND u.password_hash = crypt(p_password, u.password_hash);
END;
$$ LANGUAGE plpgsql;

-- Fixed get_booking_history function
CREATE OR REPLACE FUNCTION get_booking_history(p_user_id INT)
    RETURNS TABLE
            (
                booking_id        INT,
                booking_reference VARCHAR(20),
                property_name     VARCHAR(200),
                room_type_name    VARCHAR(100),
                check_in_date     DATE,
                check_out_date    DATE,
                total_nights      INT,
                total_amount      NUMERIC,
                currency_code     VARCHAR(3),
                booking_status    VARCHAR(20),
                city_name         VARCHAR(100),
                country_name      VARCHAR(100)
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
               b.total_amount,
               b.currency_code,
               b.booking_status,
               c.city_name,
               co.country_name
        FROM bookings b
                 JOIN properties p ON b.property_id = p.property_id
                 JOIN room_types rt ON b.room_type_id = rt.room_type_id
                 JOIN locations l ON p.location_id = l.location_id
                 JOIN cities c ON l.city_id = c.city_id
                 JOIN countries co ON c.country_id = co.country_id
        WHERE b.user_id = p_user_id
        ORDER BY b.check_in_date DESC;
END;
$$ LANGUAGE plpgsql;

-- Fixed get_user_profile function
CREATE OR REPLACE FUNCTION get_user_profile(p_user_id INT)
    RETURNS TABLE
            (
                user_id        INT,
                email          VARCHAR(255),
                first_name     VARCHAR(100),
                last_name      VARCHAR(100),
                phone_number   VARCHAR(20),
                country_name   VARCHAR(100),
                account_status VARCHAR(20),
                total_bookings BIGINT,
                created_at     TIMESTAMP,
                last_login     TIMESTAMP
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT u.user_id,
               u.email,
               u.first_name,
               u.last_name,
               u.phone_number,
               c.country_name,
               u.account_status,
               COUNT(b.booking_id) AS total_bookings,
               u.created_at,
               u.last_login
        FROM users u
                 LEFT JOIN countries c ON u.country_id = c.country_id
                 LEFT JOIN bookings b ON u.user_id = b.user_id
        WHERE u.user_id = p_user_id
        GROUP BY u.user_id, c.country_name;
END;
$$ LANGUAGE plpgsql;

-- Fixed update_user_profile function
CREATE OR REPLACE FUNCTION update_user_profile(
    p_user_id INT,
    p_first_name VARCHAR(100) DEFAULT NULL,
    p_last_name VARCHAR(100) DEFAULT NULL,
    p_phone_number VARCHAR(20) DEFAULT NULL,
    p_country_code VARCHAR(2) DEFAULT NULL
) RETURNS BOOLEAN AS
$$
DECLARE
    target_country_id INT;
BEGIN
    -- Get country_id if country_code provided
    IF p_country_code IS NOT NULL THEN
        SELECT co.country_id
        INTO target_country_id
        FROM countries co
        WHERE co.country_code = p_country_code;
    END IF;

    UPDATE users u
    SET first_name   = COALESCE(p_first_name, u.first_name),
        last_name    = COALESCE(p_last_name, u.last_name),
        phone_number = COALESCE(p_phone_number, u.phone_number),
        country_id   = COALESCE(target_country_id, u.country_id)
    WHERE u.user_id = p_user_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;