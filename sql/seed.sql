INSERT INTO users (email, password_hash, full_name, role) VALUES 
('deedee@gmail.com', crypt('pass123', gen_salt('bf', 8)), 'John Customer', 'customer'),
('pakawut.jir@gmail.com', crypt('pass123', gen_salt('bf', 8)), 'Hotel Partner', 'partner'),
('sumit.sachdev@gmail.com', crypt('pass123', gen_salt('bf', 8)), 'Admin User', 'admin');

INSERT INTO hotels (name, address, city, country, partner_id) VALUES
('Otter Plaza Hotel', '123 Main St', 'Bangkok', 'Thailand', 2),
('Automorphism Resort', '456 Beach Rd', 'Phuket', 'Thailand', 2),
('Capybara Waterfall Lodge', '789 Hillside', 'Chiang Mai', 'Thailand', 2);

INSERT INTO amenities (name) VALUES
('Free WiFi'),
('Swimming Pool'),
('Spa'),
('Gym'),
('Restaurant'),
('Breakfast Included'),
('Airport Shuttle'),
('Pet Friendly');

INSERT INTO hotel_amenities (hotel_id, amenity_id) VALUES
(1, (SELECT id FROM amenities WHERE name = 'Free WiFi')),
(1, (SELECT id FROM amenities WHERE name = 'Swimming Pool')),
(1, (SELECT id FROM amenities WHERE name = 'Gym')),
(1, (SELECT id FROM amenities WHERE name = 'Restaurant'));

INSERT INTO hotel_amenities (hotel_id, amenity_id) VALUES
(2, (SELECT id FROM amenities WHERE name = 'Free WiFi')),
(2, (SELECT id FROM amenities WHERE name = 'Swimming Pool')),
(2, (SELECT id FROM amenities WHERE name = 'Spa')),
(2, (SELECT id FROM amenities WHERE name = 'Breakfast Included'));

INSERT INTO rooms (hotel_id, room_type, capacity, price_per_night) VALUES
(1, 'Standard', 2, 100.00),
(1, 'Deluxe', 3, 150.00),
(1, 'Suite', 4, 250.00),
(2, 'Ocean View', 2, 200.00),
(2, 'Beachfront Villa', 4, 400.00),
(3, 'Mountain Cabin', 2, 120.00),
(3, 'Forest Suite', 3, 180.00);

INSERT INTO room_availability (room_id, date, available_rooms)
SELECT room_id, date, 5
FROM generate_series(CURRENT_DATE, CURRENT_DATE + 365, '1 day') AS date
CROSS JOIN (SELECT id AS room_id FROM rooms) AS rooms;

WITH booking AS (
    INSERT INTO bookings (user_id, room_id, check_in, check_out)
    VALUES (1, 1, CURRENT_DATE + 3, CURRENT_DATE + 5)
    RETURNING id
)
INSERT INTO payments (booking_id, amount, payment_method, status)
SELECT id, 200.00, 'credit_card', 'completed'
FROM booking;

INSERT INTO reviews (booking_id, hotel_id, user_id, rating, comment)
VALUES (1, 1, 1, 5, 'Excellent stay! Would recommend.');
