CREATE OR REPLACE FUNCTION get_pending_property_applications(limit_count INT DEFAULT 50)
    RETURNS TABLE
            (
                property_id     INT,
                property_name   VARCHAR(200),
                property_type   VARCHAR(50),
                partner_company VARCHAR(200),
                contact_person  VARCHAR(201), -- first_name + ' ' + last_name
                contact_email   VARCHAR(255),
                city_name       VARCHAR(100),
                country_name    VARCHAR(100),
                property_status VARCHAR(20),
                content_status  VARCHAR(20),
                created_at      TIMESTAMP
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT p.property_id,
               p.property_name,
               p.property_type,
               pt.company_name                                                                    AS partner_company,
               (pt.contact_person_first_name || ' ' || pt.contact_person_last_name)::VARCHAR(201) AS contact_person,
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

-- Fixed approve_property_application function
CREATE OR REPLACE FUNCTION approve_property_application(
    p_property_id INT,
    p_admin_id INT,
    p_approval_notes TEXT DEFAULT NULL
) RETURNS BOOLEAN AS
$$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM admin_users au WHERE au.admin_id = p_admin_id) THEN
        RAISE EXCEPTION 'Invalid admin user';
    END IF;

    UPDATE properties p
    SET property_status = 'active',
        content_status  = 'approved',
        updated_at      = CURRENT_TIMESTAMP
    WHERE p.property_id = p_property_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Fixed reject_property_application function
CREATE OR REPLACE FUNCTION reject_property_application(
    p_property_id INT,
    p_admin_id INT,
    p_rejection_reason TEXT
) RETURNS BOOLEAN AS
$$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM admin_users au WHERE au.admin_id = p_admin_id) THEN
        RAISE EXCEPTION 'Invalid admin user';
    END IF;

    UPDATE properties p
    SET property_status = 'rejected',
        content_status  = 'rejected',
        updated_at      = CURRENT_TIMESTAMP
    WHERE p.property_id = p_property_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Fixed create_coupon function
CREATE OR REPLACE FUNCTION create_coupon(
    p_coupon_code VARCHAR(50),
    p_coupon_name VARCHAR(200),
    p_discount_type VARCHAR(20),
    p_discount_value NUMERIC,
    p_admin_id INT,
    p_minimum_booking_amount NUMERIC DEFAULT NULL,
    p_valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    p_valid_to TIMESTAMP DEFAULT CURRENT_TIMESTAMP + INTERVAL '30 days'
) RETURNS INT AS
$$
DECLARE
    new_coupon_id INT;
BEGIN
    IF p_discount_type NOT IN ('percentage', 'fixed_amount') THEN
        RAISE EXCEPTION 'Invalid discount type. Must be percentage or fixed_amount';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM admin_users au WHERE au.admin_id = p_admin_id) THEN
        RAISE EXCEPTION 'Invalid admin user';
    END IF;

    INSERT INTO coupons (coupon_code, coupon_name, discount_type, discount_value,
                         minimum_booking_amount, valid_from, valid_to, created_by)
    VALUES (p_coupon_code, p_coupon_name, p_discount_type, p_discount_value,
            p_minimum_booking_amount, p_valid_from, p_valid_to, p_admin_id)
    RETURNING coupons.coupon_id INTO new_coupon_id;

    RETURN new_coupon_id;
END;
$$ LANGUAGE plpgsql;

-- Fixed update_coupon_status function
CREATE OR REPLACE FUNCTION update_coupon_status(
    p_coupon_id INT,
    p_new_status VARCHAR(20),
    p_admin_id INT
) RETURNS BOOLEAN AS
$$
BEGIN
    -- Validate status
    IF p_new_status NOT IN ('active', 'inactive', 'expired') THEN
        RAISE EXCEPTION 'Invalid coupon status';
    END IF;

    -- Verify admin exists
    IF NOT EXISTS (SELECT 1 FROM admin_users au WHERE au.admin_id = p_admin_id) THEN
        RAISE EXCEPTION 'Invalid admin user';
    END IF;

    UPDATE coupons c
    SET coupon_status = p_new_status
    WHERE c.coupon_id = p_coupon_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Fixed onboard_partner_with_property function
CREATE OR REPLACE FUNCTION onboard_partner_with_property(
    p_company_name VARCHAR(200),
    p_contact_email VARCHAR(255),
    p_password VARCHAR(255),
    p_contact_person_first_name VARCHAR(100),
    p_contact_person_last_name VARCHAR(100),
    p_phone_number VARCHAR(20),
    p_country_code VARCHAR(2),
    p_property_name VARCHAR(200),
    p_property_type VARCHAR(50),
    p_star_rating INT,
    p_city_name VARCHAR(100),
    p_street_address VARCHAR(300)
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
    SELECT co.country_id
    INTO target_country_id
    FROM countries co
    WHERE co.country_code = p_country_code;

    IF target_country_id IS NULL THEN
        RAISE EXCEPTION 'Invalid country code: %', p_country_code;
    END IF;

    INSERT INTO partners (company_name, contact_email, password_hash,
                          contact_person_first_name, contact_person_last_name,
                          phone_number, country_id, account_status, verification_status)
    VALUES (p_company_name, p_contact_email, crypt(p_password, gen_salt('bf', 8)),
            p_contact_person_first_name, p_contact_person_last_name,
            p_phone_number, target_country_id, 'pending', 'unverified')
    RETURNING partners.partner_id INTO new_partner_id;

    SELECT c.city_id
    INTO target_city_id
    FROM cities c
    WHERE c.city_name ILIKE p_city_name;

    IF target_city_id IS NULL THEN
        RAISE EXCEPTION 'City not found: %', p_city_name;
    END IF;

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

    INSERT INTO properties (partner_id, property_name, property_type, star_rating,
                            location_id, street_address, total_rooms, property_status, content_status)
    VALUES (new_partner_id, p_property_name, p_property_type, p_star_rating,
            target_location_id, p_street_address, 0, 'pending', 'draft')
    RETURNING properties.property_id INTO new_property_id;

    RETURN QUERY SELECT new_partner_id, new_property_id;
END;
$onboard$ LANGUAGE plpgsql;

-- Fixed get_active_coupons function
CREATE OR REPLACE FUNCTION get_active_coupons()
    RETURNS TABLE
            (
                coupon_id              INT,
                coupon_code            VARCHAR(50),
                coupon_name            VARCHAR(200),
                discount_type          VARCHAR(20),
                discount_value         NUMERIC,
                minimum_booking_amount NUMERIC,
                valid_from             TIMESTAMP,
                valid_to               TIMESTAMP,
                coupon_status          VARCHAR(20),
                created_by_admin       VARCHAR(100),
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

-- Fixed authenticate_admin function
CREATE OR REPLACE FUNCTION authenticate_admin(p_admin_username VARCHAR(100), p_admin_password VARCHAR(255))
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
        WHERE a.username = p_admin_username
          AND a.password_hash = crypt(p_admin_password, a.password_hash)
          AND a.account_status = 'active';
END;
$auth$ LANGUAGE plpgsql;

-- Fixed get_properties_needing_content_review function
CREATE OR REPLACE FUNCTION get_properties_needing_content_review(limit_count INT DEFAULT 20)
    RETURNS TABLE
            (
                property_id       INT,
                property_name     VARCHAR(200),
                partner_company   VARCHAR(200),
                content_status    VARCHAR(20),
                issue_description VARCHAR(100),
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
                   WHEN p.content_status = 'under_review' THEN 'Content updates requested'::VARCHAR(100)
                   WHEN p.content_status = 'draft' THEN 'Initial content incomplete'::VARCHAR(100)
                   ELSE 'Review required'::VARCHAR(100)
                   END         AS issue_description,
               p.updated_at    AS last_updated
        FROM properties p
                 JOIN partners pt ON p.partner_id = pt.partner_id
        WHERE p.content_status IN ('under_review', 'draft', 'pending_review')
        ORDER BY p.updated_at ASC
        LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Fixed deactivate_coupon function
CREATE OR REPLACE FUNCTION deactivate_coupon(
    p_coupon_id INT,
    p_admin_id INT
) RETURNS BOOLEAN AS
$$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM admin_users au WHERE au.admin_id = p_admin_id) THEN
        RAISE EXCEPTION 'Invalid admin user';
    END IF;

    UPDATE coupons c
    SET coupon_status = 'inactive'
    WHERE c.coupon_id = p_coupon_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;