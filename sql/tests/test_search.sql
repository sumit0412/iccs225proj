BEGIN;

SELECT 'Testing basic property search...' AS test_name;
SELECT * FROM search_properties('Bangkok', CURRENT_DATE + 5, CURRENT_DATE + 8, 2);

SELECT 'Testing search with price filters...' AS test_name;
SELECT * FROM search_properties('Phuket', CURRENT_DATE + 10, CURRENT_DATE + 13, 2, 1000, 5000);

SELECT 'Testing search with amenities...' AS test_name;
SELECT * FROM search_properties('Bangkok', CURRENT_DATE + 15, CURRENT_DATE + 18, 2, 0, 10000, '{}', ARRAY['Free WiFi', 'Swimming Pool']);

SELECT 'Testing property details...' AS test_name;
SELECT * FROM get_property_details(1);

SELECT 'Testing property amenities...' AS test_name;
SELECT * FROM get_property_amenities(1);

SELECT 'Testing property images...' AS test_name;
SELECT * FROM get_property_images(1);

SELECT 'Testing available room types...' AS test_name;
SELECT * FROM get_available_room_types(1, CURRENT_DATE + 5, CURRENT_DATE + 8, 2);

SELECT 'Testing city autocomplete...' AS test_name;
SELECT * FROM search_cities_autocomplete('Bang');

ROLLBACK;