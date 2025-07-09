CREATE OR REPLACE FUNCTION update_room_availability(
    p_partner_id INT,
    p_room_type_id INT,
    p_dates DATE[],
    p_available_rooms INT[],
    p_rates NUMERIC[] DEFAULT NULL
) RETURNS VOID AS
$$
DECLARE
    i INT;
BEGIN
    -- Verify ownership
    IF NOT EXISTS (SELECT 1
                   FROM room_types rt
                            JOIN properties p ON rt.property_id = p.property_id
                   WHERE rt.room_type_id = p_room_type_id
                     AND p.partner_id = p_partner_id) THEN
        RAISE EXCEPTION 'Room type not owned by partner';
    END IF;

    -- Update availability for each date
    FOR i IN 1 .. array_length(p_dates, 1)
        LOOP
            INSERT INTO availability (room_type_id, available_date, total_rooms, available_rooms, rate, currency_code,
                                      updated_by)
            SELECT p_room_type_id,
                   p_dates[i],
                   rt.total_rooms,
                   p_available_rooms[i],
                   COALESCE(p_rates[i], rt.base_rate),
                   rt.currency_code,
                   p_partner_id
            FROM room_types rt
            WHERE rt.room_type_id = p_room_type_id
            ON CONFLICT (room_type_id, available_date)
                DO UPDATE SET available_rooms = EXCLUDED.available_rooms,
                              rate            = EXCLUDED.rate,
                              last_updated    = CURRENT_TIMESTAMP,
                              updated_by      = EXCLUDED.updated_by;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_partner_properties(p_partner_id INT)
    RETURNS TABLE
            (
                property_id      INT,
                property_name    VARCHAR(200),
                property_type    VARCHAR(50),
                star_rating      INT,
                location_name    VARCHAR(200),
                city_name        VARCHAR(100),
                property_status  VARCHAR(20),
                total_rooms      INT,
                total_room_types BIGINT,
                total_bookings   BIGINT,
                avg_rating       NUMERIC,
                created_at       TIMESTAMP
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT p.property_id,
               p.property_name,
               p.property_type,
               p.star_rating,
               l.location_name,
               c.city_name,
               p.property_status,
               p.total_rooms,
               COUNT(DISTINCT rt.room_type_id)                       AS total_room_types,
               COUNT(DISTINCT b.booking_id)                          AS total_bookings,
               COALESCE(ROUND(AVG(r.overall_rating), 1), 0)::NUMERIC AS avg_rating,
               p.created_at
        FROM properties p
                 JOIN locations l ON p.location_id = l.location_id
                 JOIN cities c ON l.city_id = c.city_id
                 LEFT JOIN room_types rt ON p.property_id = rt.property_id
                 LEFT JOIN bookings b ON p.property_id = b.property_id
                 LEFT JOIN reviews r ON p.property_id = r.property_id AND r.review_status = 'approved'
        WHERE p.partner_id = p_partner_id
        GROUP BY p.property_id, l.location_name, c.city_name
        ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_property_bookings(
    p_partner_id INT,
    p_property_id INT DEFAULT NULL,
    p_date_from DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    p_date_to DATE DEFAULT CURRENT_DATE + INTERVAL '30 days'
)
    RETURNS TABLE
            (
                booking_id        INT,
                booking_reference VARCHAR(20),
                property_name     VARCHAR(200),
                room_type_name    VARCHAR(100),
                check_in_date     DATE,
                check_out_date    DATE,
                total_nights      INT,
                guest_name        VARCHAR(201), -- first_name + ' ' + last_name
                guest_email       VARCHAR(255),
                guest_phone       VARCHAR(20),
                total_amount      NUMERIC,
                currency_code     VARCHAR(3),
                booking_status    VARCHAR(20),
                special_requests  TEXT,
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
               (b.guest_first_name || ' ' || b.guest_last_name)::VARCHAR(201) AS guest_name,
               b.guest_email,
               b.guest_phone,
               b.total_amount,
               b.currency_code,
               b.booking_status,
               b.special_requests,
               b.created_at
        FROM bookings b
                 JOIN properties p ON b.property_id = p.property_id
                 JOIN room_types rt ON b.room_type_id = rt.room_type_id
        WHERE p.partner_id = p_partner_id
          AND (p_property_id IS NULL OR p.property_id = p_property_id)
          AND b.check_in_date BETWEEN p_date_from AND p_date_to
        ORDER BY b.check_in_date DESC, b.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_partner_notifications(p_partner_id INT, p_limit_count INT DEFAULT 10)
    RETURNS TABLE
            (
                notification_type VARCHAR(50),
                message           TEXT,
                property_name     VARCHAR(200),
                booking_reference VARCHAR(20),
                created_at        TIMESTAMP,
                priority          VARCHAR(10)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT CASE
                   WHEN b.booking_status = 'confirmed' AND b.created_at > CURRENT_TIMESTAMP - INTERVAL '24 hours'
                       THEN 'New Booking'::VARCHAR(50)
                   WHEN r.review_status = 'approved' AND r.created_at > CURRENT_TIMESTAMP - INTERVAL '7 days'
                       THEN 'New Review'::VARCHAR(50)
                   WHEN b.check_in_date = CURRENT_DATE THEN 'Check-in Today'::VARCHAR(50)
                   WHEN b.check_out_date = CURRENT_DATE THEN 'Check-out Today'::VARCHAR(50)
                   ELSE 'System Update'::VARCHAR(50)
                   END                                        AS notification_type,
               CASE
                   WHEN b.booking_status = 'confirmed' AND b.created_at > CURRENT_TIMESTAMP - INTERVAL '24 hours' THEN
                       'New booking for ' || rt.room_type_name || ' from ' || b.guest_first_name || ' ' ||
                       b.guest_last_name
                   WHEN r.review_status = 'approved' AND r.created_at > CURRENT_TIMESTAMP - INTERVAL '7 days' THEN
                       'New review: ' || r.overall_rating::TEXT || '/10 stars'
                   WHEN b.check_in_date = CURRENT_DATE THEN
                       'Guest checking in today: ' || b.guest_first_name || ' ' || b.guest_last_name
                   WHEN b.check_out_date = CURRENT_DATE THEN
                       'Guest checking out today: ' || b.guest_first_name || ' ' || b.guest_last_name
                   ELSE 'System notification'
                   END                                        AS message,
               p.property_name,
               b.booking_reference,
               GREATEST(b.created_at, COALESCE(r.created_at, b.created_at)) AS created_at,
               CASE
                   WHEN b.check_in_date = CURRENT_DATE OR b.check_out_date = CURRENT_DATE THEN 'high'::VARCHAR(10)
                   WHEN b.created_at > CURRENT_TIMESTAMP - INTERVAL '24 hours' THEN 'medium'::VARCHAR(10)
                   ELSE 'low'::VARCHAR(10)
                   END                                        AS priority
        FROM bookings b
                 JOIN properties p ON b.property_id = p.property_id
                 JOIN room_types rt ON b.room_type_id = rt.room_type_id
                 LEFT JOIN reviews r ON b.booking_id = r.booking_id
        WHERE p.partner_id = p_partner_id
          AND (
            (b.created_at > CURRENT_TIMESTAMP - INTERVAL '7 days') OR
            (r.created_at > CURRENT_TIMESTAMP - INTERVAL '7 days') OR
            (b.check_in_date = CURRENT_DATE) OR
            (b.check_out_date = CURRENT_DATE)
            )
        ORDER BY CASE priority
                     WHEN 'high' THEN 1
                     WHEN 'medium' THEN 2
                     ELSE 3
                     END,
                 created_at DESC
        LIMIT p_limit_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION register_partner(
    p_company_name VARCHAR(200),
    p_contact_email VARCHAR(255),
    p_password VARCHAR(255),
    p_contact_person_first_name VARCHAR(100),
    p_contact_person_last_name VARCHAR(100),
    p_phone_number VARCHAR(20),
    p_country_code VARCHAR(2) DEFAULT 'TH'
)
    RETURNS TABLE
            (
                partner_id INT,
                created_at TIMESTAMP
            )
AS
$$
DECLARE
    new_partner_id    INT;
    new_created_at    TIMESTAMP;
    target_country_id INT;
BEGIN
    -- Get country_id from country_code
    SELECT co.country_id
    INTO target_country_id
    FROM countries co
    WHERE co.country_code = p_country_code;

    IF target_country_id IS NULL THEN
        target_country_id := 1; -- Default to Thailand
    END IF;

    INSERT INTO partners (company_name, contact_email, password_hash,
                          contact_person_first_name, contact_person_last_name,
                          phone_number, country_id)
    VALUES (p_company_name, p_contact_email, crypt(p_password, gen_salt('bf', 8)),
            p_contact_person_first_name, p_contact_person_last_name,
            p_phone_number, target_country_id)
    RETURNING partners.partner_id, partners.created_at INTO new_partner_id, new_created_at;

    RETURN QUERY SELECT new_partner_id, new_created_at;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION authenticate_partner(p_email VARCHAR(255), p_password VARCHAR(255))
    RETURNS TABLE
            (
                partner_id          INT,
                company_name        VARCHAR(200),
                contact_person_name VARCHAR(201), -- first_name + ' ' + last_name
                contact_email       VARCHAR(255),
                account_status      VARCHAR(20),
                verification_status VARCHAR(20)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT p.partner_id,
               p.company_name,
               (p.contact_person_first_name || ' ' || p.contact_person_last_name)::VARCHAR(201) AS contact_person_name,
               p.contact_email,
               p.account_status,
               p.verification_status
        FROM partners p
        WHERE p.contact_email = p_email
          AND p.password_hash = crypt(p_password, p.password_hash);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_property(
    p_partner_id INT,
    p_property_name VARCHAR(200),
    p_property_type VARCHAR(50),
    p_star_rating INT,
    p_city_name VARCHAR(100),
    p_street_address VARCHAR(300),
    p_location_name VARCHAR(200) DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_contact_phone VARCHAR(20) DEFAULT NULL,
    p_contact_email VARCHAR(255) DEFAULT NULL
) RETURNS INT AS
$$
DECLARE
    new_property_id    INT;
    target_location_id INT;
    target_city_id     INT;
BEGIN
    -- Find city
    SELECT c.city_id
    INTO target_city_id
    FROM cities c
    WHERE c.city_name ILIKE p_city_name;

    IF target_city_id IS NULL THEN
        RAISE EXCEPTION 'City not found: %', p_city_name;
    END IF;

    -- Handle location
    IF p_location_name IS NOT NULL THEN
        SELECT l.location_id
        INTO target_location_id
        FROM locations l
        WHERE l.city_id = target_city_id
          AND l.location_name ILIKE p_location_name;

        IF target_location_id IS NULL THEN
            INSERT INTO locations (location_name, city_id, area_type)
            VALUES (p_location_name, target_city_id, 'General Area')
            RETURNING locations.location_id INTO target_location_id;
        END IF;
    ELSE
        SELECT l.location_id
        INTO target_location_id
        FROM locations l
        WHERE l.city_id = target_city_id
        LIMIT 1;

        IF target_location_id IS NULL THEN
            INSERT INTO locations (location_name, city_id, area_type)
            VALUES ('City Center', target_city_id, 'General Area')
            RETURNING locations.location_id INTO target_location_id;
        END IF;
    END IF;

    INSERT INTO properties (partner_id, property_name, property_type, star_rating,
                            location_id, street_address, description, total_rooms,
                            contact_phone, contact_email)
    VALUES (p_partner_id, p_property_name, p_property_type, p_star_rating,
            target_location_id, p_street_address, p_description, 0,
            p_contact_phone, p_contact_email)
    RETURNING properties.property_id INTO new_property_id;

    RETURN new_property_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_room_type(
    p_property_id INT,
    p_partner_id INT,
    p_room_type_name VARCHAR(100),
    p_max_occupancy INT,
    p_max_adults INT,
    p_max_children INT,
    p_bed_configuration VARCHAR(200),
    p_base_rate NUMERIC,
    p_currency_code VARCHAR(3),
    p_total_rooms INT
) RETURNS INT AS
$$
DECLARE
    new_room_type_id INT;
BEGIN
    -- Verify ownership
    IF NOT EXISTS (SELECT 1
                   FROM properties p
                   WHERE p.property_id = p_property_id
                     AND p.partner_id = p_partner_id) THEN
        RAISE EXCEPTION 'Property not owned by partner';
    END IF;

    INSERT INTO room_types (property_id, room_type_name, max_occupancy, max_adults,
                            max_children, bed_configuration, base_rate, currency_code, total_rooms)
    VALUES (p_property_id, p_room_type_name, p_max_occupancy, p_max_adults,
            p_max_children, p_bed_configuration, p_base_rate, p_currency_code, p_total_rooms)
    RETURNING room_types.room_type_id INTO new_room_type_id;

    -- Update property total rooms
    UPDATE properties prop
    SET total_rooms = (SELECT SUM(rt.total_rooms)
                       FROM room_types rt
                       WHERE rt.property_id = p_property_id)
    WHERE prop.property_id = p_property_id;

    RETURN new_room_type_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_property_image(
    p_property_id INT,
    p_partner_id INT,
    p_image_url VARCHAR(500),
    p_image_category VARCHAR(50) DEFAULT 'general',
    p_display_order INT DEFAULT 0,
    p_is_primary BOOLEAN DEFAULT FALSE
) RETURNS INT AS
$$
DECLARE
    new_image_id INT;
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM properties p
                   WHERE p.property_id = p_property_id
                     AND p.partner_id = p_partner_id) THEN
        RAISE EXCEPTION 'Property not owned by partner';
    END IF;

    INSERT INTO property_images (property_id, image_url, image_category, display_order, is_primary)
    VALUES (p_property_id, p_image_url, p_image_category, p_display_order, p_is_primary)
    RETURNING property_images.image_id INTO new_image_id;

    RETURN new_image_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_property_amenities(
    p_property_id INT,
    p_partner_id INT,
    p_amenity_ids INT[]
) RETURNS BOOLEAN AS
$$
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM properties p
                   WHERE p.property_id = p_property_id
                     AND p.partner_id = p_partner_id) THEN
        RAISE EXCEPTION 'Property not owned by partner';
    END IF;

    DELETE
    FROM property_amenities pa
    WHERE pa.property_id = p_property_id;

    -- Add new amenities
    INSERT INTO property_amenities (property_id, amenity_id, is_free)
    SELECT p_property_id,
           unnest(p_amenity_ids),
           TRUE;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;