CREATE OR REPLACE FUNCTION search_properties(
    search_location TEXT DEFAULT '',
    check_in_date DATE DEFAULT CURRENT_DATE,
    check_out_date DATE DEFAULT CURRENT_DATE + 1,
    guests INT DEFAULT 2,
    min_price NUMERIC DEFAULT 0,
    max_price NUMERIC DEFAULT 99999,
    star_ratings INT[] DEFAULT '{}',
    amenities_list TEXT[] DEFAULT '{}',
    sort_by TEXT DEFAULT 'price',
    limit_results INT DEFAULT 50
)
    RETURNS TABLE
            (
                property_id         INT,
                property_name       TEXT,
                property_type       TEXT,
                star_rating         INT,
                street_address      TEXT,
                location_name       TEXT,
                city_name           TEXT,
                country_name        TEXT,
                min_price_per_night NUMERIC,
                avg_rating          NUMERIC,
                total_reviews       BIGINT,
                primary_image_url   TEXT,
                available_rooms     INT
            )
AS $
BEGIN
RETURN QUERY
SELECT p.property_id,
       p.property_name,
       p.property_type,
       p.star_rating,
       p.street_address,
       l.location_name,
       c.city_name,
       co.country_name,
       MIN(a.rate)                                           AS min_price_per_night,
       COALESCE(ROUND(AVG(r.overall_rating), 1), 0)::NUMERIC AS avg_rating,
       COUNT(DISTINCT r.review_id)                           AS total_reviews,
       pi.image_url                                          AS primary_image_url,
       MIN(a.available_rooms)                                AS available_rooms
FROM properties p
         JOIN locations l ON p.location_id = l.location_id
         JOIN cities c ON l.city_id = c.city_id
         JOIN countries co ON c.country_id = co.country_id
         JOIN room_types rt ON p.property_id = rt.property_id
         JOIN availability a ON rt.room_type_id = a.room_type_id
         LEFT JOIN reviews r ON p.property_id = r.property_id AND r.review_status = 'approved'
         LEFT JOIN property_images pi ON p.property_id = pi.property_id AND pi.is_primary = true
WHERE p.property_status = 'active'
  AND (search_location = '' OR
       c.city_name ILIKE '%' || search_location || '%' OR
       l.location_name ILIKE '%' || search_location || '%' OR
       p.property_name ILIKE '%' || search_location || '%')
  AND rt.max_occupancy >= guests
  AND a.available_date BETWEEN check_in_date AND check_out_date - INTERVAL '1 day'
  AND a.available_rooms > 0
  AND a.rate BETWEEN min_price AND max_price
  AND (star_ratings = '{}' OR p.star_rating = ANY (star_ratings))
  AND (amenities_list = '{}' OR p.property_id IN (SELECT pa.property_id
                                                  FROM property_amenities pa
                                                           JOIN amenities am ON pa.amenity_id = am.amenity_id
                                                  WHERE am.amenity_name = ANY (amenities_list)
                                                  GROUP BY pa.property_id
                                                  HAVING COUNT(DISTINCT am.amenity_name) >= array_length(amenities_list, 1)))
GROUP BY p.property_id, l.location_name, c.city_name, co.country_name, pi.image_url
HAVING MIN(a.rate) BETWEEN min_price AND max_price
ORDER BY CASE
             WHEN sort_by = 'price' THEN MIN(a.rate)
             WHEN sort_by = 'rating' THEN -COALESCE(AVG(r.overall_rating), 0)
             WHEN sort_by = 'star_rating' THEN -p.star_rating
             ELSE MIN(a.rate)
             END
LIMIT limit_results;
END;
$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_property_details(target_property_id INT)
    RETURNS TABLE
            (
                property_id    INT,
                property_name  TEXT,
                property_type  TEXT,
                star_rating    INT,
                description    TEXT,
                street_address TEXT,
                location_name  TEXT,
                city_name      TEXT,
                country_name   TEXT,
                contact_phone  TEXT,
                contact_email  TEXT,
                total_rooms    INT,
                avg_rating     NUMERIC,
                total_reviews  BIGINT,
                latitude       DECIMAL,
                longitude      DECIMAL
            )
AS $
BEGIN
RETURN QUERY
SELECT p.property_id,
       p.property_name,
       p.property_type,
       p.star_rating,
       p.description,
       p.street_address,
       l.location_name,
       c.city_name,
       co.country_name,
       p.contact_phone,
       p.contact_email,
       p.total_rooms,
       COALESCE(ROUND(AVG(r.overall_rating), 1), 0)::NUMERIC AS avg_rating,
       COUNT(r.review_id)                                    AS total_reviews,
       c.latitude,
       c.longitude
FROM properties p
         JOIN locations l ON p.location_id = l.location_id
         JOIN cities c ON l.city_id = c.city_id
         JOIN countries co ON c.country_id = co.country_id
         LEFT JOIN reviews r ON p.property_id = r.property_id AND r.review_status = 'approved'
WHERE p.property_id = target_property_id
GROUP BY p.property_id, l.location_name, c.city_name, co.country_name, c.latitude, c.longitude;
END;
$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_property_amenities(target_property_id INT)
    RETURNS TABLE
            (
                amenity_name     TEXT,
                amenity_category TEXT,
                is_free          BOOLEAN
            )
AS $
BEGIN
RETURN QUERY
SELECT a.amenity_name,
       a.amenity_category,
       pa.is_free
FROM property_amenities pa
         JOIN amenities a ON pa.amenity_id = a.amenity_id
WHERE pa.property_id = target_property_id
ORDER BY a.amenity_category, a.amenity_name;
END;
$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_property_images(target_property_id INT)
    RETURNS TABLE
            (
                image_url      TEXT,
                image_category TEXT,
                display_order  INT,
                is_primary     BOOLEAN
            )
AS $
BEGIN
RETURN QUERY
SELECT pi.image_url,
       pi.image_category,
       pi.display_order,
       pi.is_primary
FROM property_images pi
WHERE pi.property_id = target_property_id
ORDER BY pi.is_primary DESC, pi.display_order, pi.image_id;
END;
$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_available_room_types(
    target_property_id INT,
    check_in_date DATE,
    check_out_date DATE,
    guests INT DEFAULT 2
)
    RETURNS TABLE
            (
                room_type_id      INT,
                room_type_name    TEXT,
                max_occupancy     INT,
                max_adults        INT,
                max_children      INT,
                bed_configuration TEXT,
                current_rate      NUMERIC,
                currency_code     TEXT,
                available_rooms   INT,
                total_rooms       INT
            )
AS $
BEGIN
RETURN QUERY
SELECT rt.room_type_id,
       rt.room_type_name,
       rt.max_occupancy,
       rt.max_adults,
       rt.max_children,
       rt.bed_configuration,
       MIN(a.rate)            AS current_rate,
       rt.currency_code,
       MIN(a.available_rooms) AS available_rooms,
       rt.total_rooms
FROM room_types rt
         JOIN availability a ON rt.room_type_id = a.room_type_id
WHERE rt.property_id = target_property_id
  AND rt.room_status = 'active'
  AND rt.max_occupancy >= guests
  AND a.available_date BETWEEN check_in_date AND check_out_date - INTERVAL '1 day'
  AND a.available_rooms > 0
GROUP BY rt.room_type_id
HAVING MIN(a.available_rooms) > 0
ORDER BY MIN(a.rate);
END;
$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_cities_autocomplete(search_term TEXT)
    RETURNS TABLE
            (
                city_name      TEXT,
                country_name   TEXT,
                property_count BIGINT
            )
AS $
BEGIN
RETURN QUERY
SELECT c.city_name,
       co.country_name,
       COUNT(DISTINCT p.property_id) AS property_count
FROM cities c
         JOIN countries co ON c.country_id = co.country_id
         JOIN locations l ON c.city_id = l.city_id
         JOIN properties p ON l.location_id = p.location_id
WHERE c.city_name ILIKE '%' || search_term || '%'
  AND p.property_status = 'active'
GROUP BY c.city_name, co.country_name
HAVING COUNT(DISTINCT p.property_id) > 0
ORDER BY COUNT(DISTINCT p.property_id) DESC, c.city_name
LIMIT 10;
END;
$ LANGUAGE plpgsql;