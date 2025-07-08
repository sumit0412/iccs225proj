CREATE OR REPLACE FUNCTION search_hotels(
    location TEXT, 
    check_in DATE, 
    check_out DATE, 
    guests INT,
    min_price NUMERIC DEFAULT 0,
    max_price NUMERIC DEFAULT 99999,
    amenities_list TEXT[] DEFAULT '{}'
) RETURNS TABLE (
    hotel_id INT,
    name TEXT,
    address TEXT,
    city TEXT,
    country TEXT,
    thumbnail_url TEXT,
    min_price_per_night NUMERIC,
    avg_rating NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        h.id,
        h.name,
        h.address,
        h.city,
        h.country,
        h.thumbnail_url,
        MIN(rm.price_per_night) AS min_price_per_night,
        COALESCE(ROUND(AVG(r.rating), 2)::NUMERIC AS avg_rating
    FROM hotels h
    JOIN rooms rm ON h.id = rm.hotel_id
    LEFT JOIN reviews r ON h.id = r.hotel_id
    WHERE 
        h.city ILIKE '%' || location || '%'
        AND rm.capacity >= guests
        AND rm.id IN (
            SELECT room_id
            FROM room_availability ra
            WHERE ra.date BETWEEN check_in AND check_out - INTERVAL '1 day'
            AND ra.available_rooms > 0
        )
        AND rm.price_per_night BETWEEN min_price AND max_price
        AND (amenities_list = '{}' OR h.id IN (
            SELECT ha.hotel_id
            FROM hotel_amenities ha
            JOIN amenities a ON ha.amenity_id = a.id
            WHERE a.name = ANY(amenities_list)
        )
    GROUP BY h.id
    HAVING MIN(rm.price_per_night) BETWEEN min_price AND max_price
    ORDER BY min_price_per_night;
END;
$$ LANGUAGE plpgsql;
