CREATE OR REPLACE FUNCTION get_pending_property_applications(limit_count INT DEFAULT 50)
    RETURNS TABLE
            (
                property_id     INT,
                property_name   TEXT,
                property_type   TEXT,
                partner_company TEXT,
                contact_person  TEXT,
                contact_email   TEXT,
                city_name       TEXT,
                country_name    TEXT,
                property_status TEXT,
                content_status  TEXT,
                created_at      TIMESTAMP
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT p.property_id,
               p.property_name,
               p.property_type,
               pt.company_name                                                    AS partner_company,
               pt.contact_person_first_name || ' ' || pt.contact_person_last_name AS contact_person,
               pt.contact_email,
               c.city_name,
               co.country_name,
               p.property_status,
               p.content_status,
               p.created_at
        FROM properties p
                 JOIN partners pt ON p.partner_id = pt.partner_id
                 JOIN locations l ON p.location_id = l.location_id
                 JOIN cities c ON l.city_id = c.city_id
                 JOIN countries co ON c.country_id = co.country_id
        WHERE p.property_status IN ('pending', 'under_review')
           OR p.content_status IN ('draft', 'pending_review')
        ORDER BY p.created_at ASC
        LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION approve_property_application(
    property_id INT,
    admin_id INT,
    approval_notes TEXT DEFAULT NULL
) RETURNS BOOLEAN AS
$$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM admin_users WHERE admin_id = approve_property_application.admin_id) THEN
        RAISE EXCEPTION 'Invalid admin user';
    END IF;

    UPDATE properties
    SET property_status = 'active',
        content_status  = 'approved',
        updated_at      = CURRENT_TIMESTAMP
    WHERE property_id = approve_property_application.property_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reject_property_application(
    property_id INT,
    admin_id INT,
    rejection_reason TEXT
) RETURNS BOOLEAN AS
$$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM admin_users WHERE admin_id = reject_property_application.admin_id) THEN
        RAISE EXCEPTION 'Invalid admin user';
    END IF;

    UPDATE properties
    SET property_status = 'rejected',
        content_status  = 'rejected',
        updated_at      = CURRENT_TIMESTAMP
    WHERE property_id = reject_property_application.property_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_coupon(
    coupon_code TEXT,
    coupon_name TEXT,
    discount_type TEXT,
    discount_value NUMERIC,
    admin_id INT,
    minimum_booking_amount NUMERIC DEFAULT NULL,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP DEFAULT CURRENT_TIMESTAMP + INTERVAL '30 days'
) RETURNS INT AS
$$
DECLARE
    new_coupon_id INT;
BEGIN
    IF discount_type NOT IN ('percentage', 'fixed_amount') THEN
        RAISE EXCEPTION 'Invalid discount type. Must be percentage or fixed_amount';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM admin_users WHERE admin_id = create_coupon.admin_id) THEN
        RAISE EXCEPTION 'Invalid admin user';
    END IF;

    INSERT INTO coupons (coupon_code, coupon_name, discount_type, discount_value,
                         minimum_booking_amount, valid_from, valid_to, created_by)
    VALUES (coupon_code, coupon_name, discount_type, discount_value,
            minimum_booking_amount, valid_from, valid_to, admin_id)
    RETURNING coupon_id INTO new_coupon_id;

    RETURN new_coupon_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_coupon_status(
    coupon_id INT,
    new_status TEXT,
    admin_id INT
) RETURNS BOOLEAN AS
$$
BEGIN
    -- Validate status
    IF new_status NOT IN ('active', 'inactive', 'expired') THEN
        RAISE EXCEPTION 'Invalid coupon status';
    END IF;

    -- Verify admin exists
    IF NOT EXISTS (SELECT 1 FROM admin_users WHERE admin_id = update_coupon_status.admin_id) THEN
        RAISE EXCEPTION 'Invalid admin user';
    END IF;

    UPDATE coupons
    SET coupon_status = new_status
    WHERE coupon_id = update_coupon_status.coupon_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION onboard_partner_with_property(
    company_name TEXT,
    contact_email TEXT,
    password TEXT,
    contact_person_first_name TEXT,
    contact_person_last_name TEXT,
    phone_number TEXT,
    country_code TEXT,
    property_name TEXT,
    property_type TEXT,
    star_rating INT,
    city_name TEXT,
    street_address TEXT
)
    RETURNS TABLE
            (
                partner_id  INT,
                property_id INT
            )
AS
$onboard$
DECLARE
    new_partner_id     INT;
    new_property_id    INT;
    target_country_id  INT;
    target_city_id     INT;
    target_location_id INT;
BEGIN
    SELECT country_id
    INTO target_country_id
    FROM countries
    WHERE country_code = onboard_partner_with_property.country_code;

    IF target_country_id IS NULL THEN
        RAISE EXCEPTION 'Invalid country code: %', country_code;
    END IF;

    INSERT INTO partners (company_name, contact_email, password_hash,
                          contact_person_first_name, contact_person_last_name,
                          phone_number, country_id, account_status, verification_status)
    VALUES (company_name, contact_email, crypt(password, gen_salt('bf', 8)),
            contact_person_first_name, contact_person_last_name,
            phone_number, target_country_id, 'pending', 'unverified')
    RETURNING partner_id INTO new_partner_id;

    SELECT city_id
    INTO target_city_id
    FROM cities
    WHERE city_name ILIKE onboard_partner_with_property.city_name;

    IF target_city_id IS NULL THEN
        RAISE EXCEPTION 'City not found: %', city_name;
    END IF;

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

    INSERT INTO properties (partner_id, property_name, property_type, star_rating,
                            location_id, street_address, total_rooms, property_status, content_status)
    VALUES (new_partner_id, property_name, property_type, star_rating,
            target_location_id, street_address, 0, 'pending', 'draft')
    RETURNING property_id INTO new_property_id;

    RETURN QUERY SELECT new_partner_id, new_property_id;
END;
$onboard$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_active_coupons()
    RETURNS TABLE
            (
                coupon_id              INT,
                coupon_code            TEXT,
                coupon_name            TEXT,
                discount_type          TEXT,
                discount_value         NUMERIC,
                minimum_booking_amount NUMERIC,
                valid_from             TIMESTAMP,
                valid_to               TIMESTAMP,
                coupon_status          TEXT,
                created_by_admin       TEXT,
                created_at             TIMESTAMP
            )
AS
$coupons$
BEGIN
    RETURN QUERY
        SELECT c.coupon_id,
               c.coupon_code,
               c.coupon_name,
               c.discount_type,
               c.discount_value,
               c.minimum_booking_amount,
               c.valid_from,
               c.valid_to,
               c.coupon_status,
               a.username AS created_by_admin,
               c.created_at
        FROM coupons c
                 JOIN admin_users a ON c.created_by = a.admin_id
        WHERE c.coupon_status = 'active'
          AND c.valid_to > CURRENT_TIMESTAMP
        ORDER BY c.created_at DESC;
END;
$coupons$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION authenticate_admin(admin_username TEXT, admin_password TEXT)
    RETURNS TABLE
            (
                admin_id       INT,
                username       VARCHAR(100),
                email          VARCHAR(255),
                role           VARCHAR(50),
                department     VARCHAR(100),
                account_status VARCHAR(20)
            )
AS
$auth$
BEGIN
    RETURN QUERY
        SELECT a.admin_id,
               a.username,
               a.email,
               a.role,
               a.department,
               a.account_status
        FROM admin_users a
        WHERE a.username = admin_username
          AND password_hash = crypt(admin_password, password_hash)
          AND a.account_status = 'active';
END;
$auth$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_properties_needing_content_review(limit_count INT DEFAULT 20)
    RETURNS TABLE
            (
                property_id       INT,
                property_name     TEXT,
                partner_company   TEXT,
                content_status    TEXT,
                issue_description TEXT,
                last_updated      TIMESTAMP
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT p.property_id,
               p.property_name,
               pt.company_name AS partner_company,
               p.content_status,
               CASE
                   WHEN p.content_status = 'under_review' THEN 'Content updates requested'
                   WHEN p.content_status = 'draft' THEN 'Initial content incomplete'
                   ELSE 'Review required'
                   END         AS issue_description,
               p.updated_at    AS last_updated
        FROM properties p
                 JOIN partners pt ON p.partner_id = pt.partner_id
        WHERE p.content_status IN ('under_review', 'draft', 'pending_review')
        ORDER BY p.updated_at ASC
        LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION deactivate_coupon(
    coupon_id INT,
    admin_id INT
) RETURNS BOOLEAN AS
$$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM admin_users WHERE admin_id = deactivate_coupon.admin_id) THEN
        RAISE EXCEPTION 'Invalid admin user';
    END IF;

    UPDATE coupons
    SET coupon_status = 'inactive'
    WHERE coupon_id = deactivate_coupon.coupon_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;