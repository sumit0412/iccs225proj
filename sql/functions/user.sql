CREATE OR REPLACE FUNCTION register_user(
    email TEXT,
    password TEXT,
    first_name TEXT,
    last_name TEXT,
    phone_number TEXT DEFAULT NULL,
    country_code TEXT DEFAULT 'TH'
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
    SELECT country_id
    INTO target_country_id
    FROM countries
    WHERE country_code = register_user.country_code;

    IF target_country_id IS NULL THEN
        target_country_id := 1; -- Default to Thailand
    END IF;

    INSERT INTO users (email, password_hash, first_name, last_name, phone_number, country_id)
    VALUES (email,
            crypt(password, gen_salt('bf', 8)),
            first_name,
            last_name,
            phone_number,
            target_country_id)
    RETURNING user_id, created_at INTO new_user_id, new_created_at;

    RETURN QUERY SELECT new_user_id, new_created_at;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION authenticate_user(email TEXT, password TEXT)
    RETURNS TABLE
            (
                user_id      INT,
                full_name    TEXT,
                email        TEXT,
                country_name TEXT,
                last_login   TIMESTAMP
            )
AS
$$
BEGIN
    -- Update last login
    UPDATE users
    SET last_login = CURRENT_TIMESTAMP
    WHERE users.email = authenticate_user.email
      AND password_hash = crypt(authenticate_user.password, password_hash);

    RETURN QUERY
        SELECT u.user_id,
               u.first_name || ' ' || u.last_name AS full_name,
               u.email,
               c.country_name,
               u.last_login
        FROM users u
                 LEFT JOIN countries c ON u.country_id = c.country_id
        WHERE u.email = authenticate_user.email
          AND password_hash = crypt(authenticate_user.password, password_hash);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_booking_history(target_user_id INT)
    RETURNS TABLE
            (
                booking_id        INT,
                booking_reference TEXT,
                property_name     TEXT,
                room_type_name    TEXT,
                check_in_date     DATE,
                check_out_date    DATE,
                total_nights      INT,
                total_amount      NUMERIC,
                currency_code     TEXT,
                booking_status    TEXT,
                city_name         TEXT,
                country_name      TEXT
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
        WHERE b.user_id = target_user_id
        ORDER BY b.check_in_date DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_user_profile(target_user_id INT)
    RETURNS TABLE
            (
                user_id        INT,
                email          TEXT,
                first_name     TEXT,
                last_name      TEXT,
                phone_number   TEXT,
                country_name   TEXT,
                account_status TEXT,
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
        WHERE u.user_id = target_user_id
        GROUP BY u.user_id, c.country_name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_user_profile(
    target_user_id INT,
    new_first_name TEXT DEFAULT NULL,
    new_last_name TEXT DEFAULT NULL,
    new_phone_number TEXT DEFAULT NULL,
    new_country_code TEXT DEFAULT NULL
) RETURNS BOOLEAN AS
$$
DECLARE
    target_country_id INT;
BEGIN
    -- Get country_id if country_code provided
    IF new_country_code IS NOT NULL THEN
        SELECT country_id
        INTO target_country_id
        FROM countries
        WHERE country_code = new_country_code;
    END IF;

    UPDATE users
    SET first_name   = COALESCE(new_first_name, first_name),
        last_name    = COALESCE(new_last_name, last_name),
        phone_number = COALESCE(new_phone_number, phone_number),
        country_id   = COALESCE(target_country_id, country_id)
    WHERE user_id = target_user_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;