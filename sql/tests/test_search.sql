BEGIN;

SELECT * FROM search_hotels('Bangkok', '2024-12-01', '2024-12-05', 2);

SELECT * FROM search_hotels('Phuket', '2024-12-01', '2024-12-05', 2, 150, 300);

SELECT * FROM search_hotels('Chiang Mai', '2024-12-01', '2024-12-05', 2, 0, 500, ARRAY['Free WiFi', 'Breakfast Included']);

ROLLBACK;
