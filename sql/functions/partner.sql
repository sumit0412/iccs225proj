CREATE OR REPLACE FUNCTION update_room_availability(
    partner_id INT,
    room_type_id INT,
    dates DATE[],
    available_rooms INT[],
    rates NUMERIC[] DEFAULT NULL
) RETURNS VOID AS
$$
DECLARE
    i INT;
BEGIN
    -- Verify ownership
    IF NOT EXISTS (SELECT 1
                   FROM room_types rt
                            JOIN properties p ON rt.property_id = p.property_id
                   WHERE rt.room_type_id = update_room_availability.room_type_id
                     AND p.partner_id = update_room_availability.partner_id) THEN
        RAISE EXCEPTION 'Room type not owned by partner';
    END IF;

    -- Update availability for each date
    FOR i IN 1 .. array_length(dates, 1)
        LOOP
            INSERT INTO availability (room_type_id, available_date, total_rooms, available_rooms, rate, currency_code,
                                      updated_by)
            SELECT update_room_availability.room_type_id,
                   dates[i],
                   rt.total_rooms,
                   available_rooms[i],
                   COALESCE(rates[i], rt.base_rate),
                   rt.currency_code,
                   update_room_availability.partner_id
            FROM room_types rt
            WHERE rt.room_type_id = update_room_availability.room_type_id
            ON CONFLICT (room_type_id, available_date)
                DO UPDATE SET available_rooms = EXCLUDED.available_rooms,
                              rate            = EXCLUDED.rate,
                              last_updated    = CURRENT_TIMESTAMP,
                              updated_by      = EXCLUDED.updated_by;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_partner_properties(partner_id INT)
    RETURNS TABLE
            (
                property_id      INT,
                property_name    TEXT,
                property_type    TEXT,
                star_rating      INT,
                location_name    TEXT,
                city_name        TEXT,
                property_status  TEXT,
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
        WHERE p.partner_id = get_partner_properties.partner_id
        GROUP BY p.property_id, l.location_name, c.city_name
        ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_property_bookings(
    partner_id INT,
    property_id INT DEFAULT NULL,
    date_from DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    date_to DATE DEFAULT CURRENT_DATE + INTERVAL '30 days'
)
    RETURNS TABLE
            (
                booking_id        INT,
                booking_reference TEXT,
                property_name     TEXT,
                room_type_name    TEXT,
                check_in_date     DATE,
                check_out_date    DATE,
                total_nights      INT,
                guest_name        TEXT,
                guest_email       TEXT,
                guest_phone       TEXT,
                total_amount      NUMERIC,
                currency_code     TEXT,
                booking_status    TEXT,
                payment_status    TEXT,
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
               b.guest_first_name || ' ' || b.guest_last_name AS guest_name,
               b.guest_email,
               b.guest_phone,
               b.total_amount,
               b.currency_code,
               b.booking_status,
               pay.payment_status,
               b.special_requests,
               b.created_at
        FROM bookings b
                 JOIN properties p ON b.property_id = p.property_id
                 JOIN room_types rt ON b.room_type_id = rt.room_type_id
                 LEFT JOIN payments pay ON b.booking_id = pay.booking_id
        WHERE p.partner_id = get_property_bookings.partner_id
          AND (property_id IS NULL OR p.property_id = get_property_bookings.property_id)
          AND b.check_in_date BETWEEN date_from AND date_to
        ORDER BY b.check_in_date DESC, b.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_partner_notifications(partner_id INT, limit_count INT DEFAULT 10)
    RETURNS TABLE
            (
                notification_type TEXT,
                message           TEXT,
                property_name     TEXT,
                booking_reference TEXT,
                created_at        TIMESTAMP,
                priority          TEXT
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT CASE
                   WHEN b.booking_status = 'confirmed' AND b.created_at > CURRENT_TIMESTAMP - INTERVAL '24 hours' THEN 'New Booking'
                   WHEN pay.payment_status = 'completed' AND pay.processed_at > CURRENT_TIMESTAMP - INTERVAL '24 hours' THEN 'Payment Received'
                   WHEN r.review_status = 'approved' AND r.created_at > CURRENT_TIMESTAMP - INTERVAL '7 days' THEN 'New Review'
                   WHEN b.check_in_date = CURRENT_DATE THEN 'Check-in Today'
                   WHEN b.check_out_date = CURRENT_DATE THEN 'Check-out Today'
                   ELSE 'System Update'
                   END AS notification_type,
               CASE
                   WHEN b.booking_status = 'confirmed' AND b.created_at > CURRENT_TIMESTAMP - INTERVAL '24 hours' THEN
                       'New booking for ' || rt.room_type_name || ' from ' || b.guest_first_name || ' ' || b.guest_last_name
                   WHEN pay.payment_status = 'completed' AND pay.processed_at > CURRENT_TIMESTAMP - INTERVAL '24 hours' THEN
                       'Payment received: ' || pay.amount::TEXT || ' ' || pay.currency_code
                   WHEN r.review_status = 'approved' AND r.created_at > CURRENT_TIMESTAMP - INTERVAL '7 days' THEN
                       'New review: ' || r.overall_rating::TEXT || '/10 stars'
                   WHEN b.check_in_date = CURRENT_DATE THEN
                       'Guest checking in today: ' || b.guest_first_name || ' ' || b.guest_last_name
                   WHEN b.check_out_date = CURRENT_DATE THEN
                       'Guest checking out today: ' || b.guest_first_name || ' ' || b.guest_last_name
                   ELSE 'System notification'
                   END AS message,
               p.property_name,
               b.booking_reference,
               GREATEST(b.created_at, COALESCE(pay.processed_at, b.created_at), COALESCE(r.created_at, b.created_at)) AS created_at,
               CASE
                   WHEN b.check_in_date = CURRENT_DATE OR b.check_out_date = CURRENT_DATE THEN 'high'
                   WHEN b.created_at > CURRENT_TIMESTAMP - INTERVAL '24 hours' THEN 'medium'
                   ELSE 'low'
                   END AS priority
        FROM bookings b
                 JOIN properties p ON b.property_id = p.property_id
                 JOIN room_types rt ON b.room_type_id = rt.room_type_id
                 LEFT JOIN payments pay ON b.booking_id = pay.booking_id
                 LEFT JOIN reviews r ON b.booking_id = r.booking_id
        WHERE p.partner_id = get_partner_notifications.partner_id
          AND (
            (b.created_at > CURRENT_TIMESTAMP - INTERVAL '7 days') OR
            (pay.processed_at > CURRENT_TIMESTAMP - INTERVAL '7 days') OR
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
        LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION register_partner(
    company_name TEXT,
    contact_email TEXT,
    password TEXT,
    contact_person_first_name TEXT,
    contact_person_last_name TEXT,
    phone_number TEXT,
    country_code TEXT DEFAULT 'TH'
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
    SELECT country_id
    INTO target_country_id
    FROM countries
    WHERE country_code = register_partner.country_code;

    IF target_country_id IS NULL THEN
        target_country_id := 1; -- Default to Thailand
    END IF;

    INSERT INTO partners (company_name, contact_email, password_hash,
                          contact_person_first_name, contact_person_last_name,
                          phone_number, country_id)
    VALUES (company_name, contact_email, crypt(password, gen_salt('bf', 8)),
            contact_person_first_name, contact_person_last_name,
            phone_number, target_country_id)
    RETURNING partner_id, created_at INTO new_partner_id, new_created_at;

    RETURN QUERY SELECT new_partner_id, new_created_at;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION authenticate_partner(email TEXT, password TEXT)
    RETURNS TABLE
            (
                partner_id          INT,
                company_name        TEXT,
                contact_person_name TEXT,
                contact_email       TEXT,
                account_status      TEXT,
                verification_status TEXT
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT p.partner_id,
               p.company_name,
               p.contact_person_first_name || ' ' || p.contact_person_last_name AS contact_person_name,
               p.contact_email,
               p.account_status,
               p.verification_status
        FROM partners p
        WHERE p.contact_email = authenticate_partner.email
          AND password_hash = crypt(authenticate_partner.password, password_hash);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_property(
    partner_id INT,
    property_name TEXT,
    property_type TEXT,
    star_rating INT,
    city_name TEXT,
    street_address TEXT,
    location_name TEXT DEFAULT NULL,
    description TEXT DEFAULT NULL,
    contact_phone TEXT DEFAULT NULL,
    contact_email TEXT DEFAULT NULL
) RETURNS INT AS
$$
DECLARE
    new_property_id    INT;
    target_location_id INT;
    target_city_id     INT;
BEGIN
    -- Find city
    SELECT city_id
    INTO target_city_id
    FROM cities
    WHERE city_name ILIKE create_property.city_name;

    IF target_city_id IS NULL THEN
        RAISE EXCEPTION 'City not found: %', city_name;
    END IF;

    -- Handle location
    IF location_name IS NOT NULL THEN
        SELECT location_id
        INTO target_location_id
        FROM locations
        WHERE city_id = target_city_id
          AND location_name ILIKE create_property.location_name;

        IF target_location_id IS NULL THEN
            INSERT INTO locations (location_name, city_id, area_type)
            VALUES (location_name, target_city_id, 'General Area')
            RETURNING location_id INTO target_location_id;
        END IF;
    ELSE
        SELECT location_id
        INTO target_location_id
        FROM locations
        WHERE city_id = target_city_id
        LIMIT 1;

        IF target_location_id IS NULL THEN
            INSERT INTO locations (location_name, city_id, area_type)
            VALUES ('City Center', target_city_id, 'General Area')
            RETURNING location_id INTO target_location_id;
        END IF;
    END IF;

    INSERT INTO properties (partner_id, property_name, property_type, star_rating,
                            location_id, street_address, description, total_rooms,
                            contact_phone, contact_email)
    VALUES (partner_id, property_name, property_type, star_rating,
            target_location_id, street_address, description, 0,
            contact_phone, contact_email)
    RETURNING property_id INTO new_property_id;

    RETURN new_property_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_room_type(
    property_id INT,
    partner_id INT,
    room_type_name TEXT,
    max_occupancy INT,
    max_adults INT,
    max_children INT,
    bed_configuration TEXT,
    base_rate NUMERIC,
    currency_code TEXT,
    total_rooms INT
) RETURNS INT AS
$$
DECLARE
    new_room_type_id INT;
BEGIN
    -- Verify ownership
    IF NOT EXISTS (SELECT 1
                   FROM properties p
                   WHERE p.property_id = add_room_type.property_id
                     AND p.partner_id = add_room_type.partner_id) THEN
        RAISE EXCEPTION 'Property not owned by partner';
    END IF;

    INSERT INTO room_types (property_id, room_type_name, max_occupancy, max_adults,
                            max_children, bed_configuration, base_rate, currency_code, total_rooms)
    VALUES (property_id, room_type_name, max_occupancy, max_adults,
            max_children, bed_configuration, base_rate, currency_code, total_rooms)
    RETURNING room_type_id INTO new_room_type_id;

    -- Update property total rooms
    UPDATE properties
    SET total_rooms = (SELECT SUM(rt.total_rooms)
                       FROM room_types rt
                       WHERE rt.property_id = add_room_type.property_id)
    WHERE property_id = add_room_type.property_id;

    RETURN new_room_type_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_property_image(
    property_id INT,
    partner_id INT,
    image_url TEXT,
    image_category TEXT DEFAULT 'general',
    display_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE
) RETURNS INT AS
$$
DECLARE
    new_image_id INT;
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM properties p
                   WHERE p.property_id = add_property_image.property_id
                     AND p.partner_id = add_property_image.partner_id) THEN
        RAISE EXCEPTION 'Property not owned by partner';
    END IF;

    INSERT INTO property_images (property_id, image_url, image_category, display_order, is_primary)
    VALUES (property_id, image_url, image_category, display_order, is_primary)
    RETURNING image_id INTO new_image_id;

    RETURN new_image_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_property_amenities(
    property_id INT,
    partner_id INT,
    amenity_ids INT[]
) RETURNS BOOLEAN AS
$$
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM properties p
                   WHERE p.property_id = set_property_amenities.property_id
                     AND p.partner_id = set_property_amenities.partner_id) THEN
        RAISE EXCEPTION 'Property not owned by partner';
    END IF;

    DELETE FROM property_amenities
    WHERE property_id = set_property_amenities.property_id;

    -- Add new amenities
    INSERT INTO property_amenities (property_id, amenity_id, is_free)
    SELECT set_property_amenities.property_id,
           unnest(amenity_ids),
           TRUE;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;