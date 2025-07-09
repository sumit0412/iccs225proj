INSERT INTO countries (country_code, country_name, currency_code)
VALUES ('TH', 'Thailand', 'THB'),
       ('SG', 'Singapore', 'SGD'),
       ('MY', 'Malaysia', 'MYR'),
       ('ID', 'Indonesia', 'IDR'),
       ('VN', 'Vietnam', 'VND'),
       ('PH', 'Philippines', 'PHP'),
       ('JP', 'Japan', 'JPY'),
       ('KR', 'South Korea', 'KRW'),
       ('US', 'United States', 'USD'),
       ('GB', 'United Kingdom', 'GBP'),
       ('AU', 'Australia', 'AUD'),
       ('FR', 'France', 'EUR');

INSERT INTO cities (city_name, country_id, latitude, longitude)
VALUES ('Bangkok', 1, 13.7563, 100.5018),
       ('Phuket', 1, 7.8804, 98.3923),
       ('Chiang Mai', 1, 18.7883, 98.9853),
       ('Singapore', 2, 1.3521, 103.8198),
       ('Kuala Lumpur', 3, 3.1390, 101.6869),
       ('Penang', 3, 5.4164, 100.3327),
       ('Jakarta', 4, -6.2088, 106.8456),
       ('Bali', 4, -8.4095, 115.1889),
       ('Ho Chi Minh City', 5, 10.8231, 106.6297),
       ('Hanoi', 5, 21.0285, 105.8542),
       ('Manila', 6, 14.5995, 120.9842),
       ('Tokyo', 7, 35.6762, 139.6503),
       ('Seoul', 8, 37.5665, 126.9780),
       ('New York', 9, 40.7128, -74.0060),
       ('London', 10, 51.5074, -0.1278);

INSERT INTO locations (location_name, city_id, area_type)
VALUES ('Sukhumvit', 1, 'Downtown'),
       ('Silom', 1, 'Business District'),
       ('Chatuchak', 1, 'Shopping'),
       ('Suvarnabhumi Airport', 1, 'Airport'),
       ('Patong Beach', 2, 'Beach'),
       ('Kata Beach', 2, 'Beach'),
       ('Phuket Airport', 2, 'Airport'),
       ('Old City', 3, 'Historic'),
       ('Nimman', 3, 'Trendy'),
       ('Orchard Road', 4, 'Shopping'),
       ('Marina Bay', 4, 'Waterfront'),
       ('Changi Airport', 4, 'Airport'),
       ('Bukit Bintang', 5, 'Entertainment'),
       ('KLCC', 5, 'Business District'),
       ('Georgetown', 6, 'Historic'),
       ('Seminyak', 8, 'Beach'),
       ('Ubud', 8, 'Cultural'),
       ('District 1', 9, 'Downtown'),
       ('Shibuya', 12, 'Entertainment'),
       ('Gangnam', 13, 'Business District');

INSERT INTO users (email, password_hash, first_name, last_name, phone_number, country_id, account_status, last_login)
VALUES ('john.smith@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LdZnH7', 'John', 'Smith', '+1234567890', 9,
        'active', '2025-01-10 14:30:00'),
       ('sarah.jones@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LdZnH8', 'Sarah', 'Jones', '+1234567891',
        9, 'active', '2025-01-09 09:15:00'),
       ('mike.wilson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LdZnH9', 'Mike', 'Wilson', '+1234567892',
        10, 'active', '2025-01-08 16:45:00'),
       ('lisa.chen@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LdZnH0', 'Lisa', 'Chen', '+65987654321', 2,
        'active', '2025-01-10 11:20:00'),
       ('david.kim@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LdZnH1', 'David', 'Kim', '+821012345678', 8,
        'active', '2025-01-07 13:30:00'),
       ('anna.mueller@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LdZnH2', 'Anna', 'Mueller',
        '+33123456789', 12, 'active', '2025-01-06 18:00:00'),
       ('tom.brown@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LdZnH3', 'Tom', 'Brown', '+61412345678', 11,
        'active', '2025-01-09 20:15:00'),
       ('maria.garcia@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LdZnH4', 'Maria', 'Garcia', '+1234567893',
        9, 'active', '2025-01-10 08:30:00'),
       ('raj.patel@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LdZnH5', 'Raj', 'Patel', '+65987654322', 2,
        'active', '2025-01-05 12:45:00'),
       ('yuki.tanaka@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LdZnH6', 'Yuki', 'Tanaka', '+81901234567',
        7, 'active', '2025-01-04 15:20:00'),
       ('emma.white@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LdZnH7', 'Emma', 'White', '+44207123456',
        10, 'active', '2025-01-10 10:00:00'),
       ('alex.wong@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LdZnH8', 'Alex', 'Wong', '+60123456789', 3,
        'active', '2025-01-08 14:30:00');

INSERT INTO partners (company_name, contact_email, password_hash, contact_person_first_name, contact_person_last_name,
                      phone_number, country_id, account_status, verification_status)
VALUES ('Bangkok Grand Hotels', 'manager@bangkokgrand.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/P1', 'Somchai',
        'Wongsiri', '+6621234567', 1, 'active', 'verified'),
       ('Phuket Beach Resorts', 'admin@phuketbeach.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/P2', 'Niran',
        'Suksawat', '+6676123456', 1, 'active', 'verified'),
       ('Singapore Luxury Suites', 'contact@sgluxury.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/P3', 'Wei Ming',
        'Lim', '+6563456789', 2, 'active', 'verified'),
       ('KL Premium Properties', 'info@klpremium.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/P4', 'Ahmad',
        'Hassan', '+60321234567', 3, 'active', 'verified'),
       ('Bali Paradise Hotels', 'manager@baliparadise.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/P5', 'Made',
        'Wirawan', '+62361234567', 4, 'active', 'verified'),
       ('Saigon City Hotels', 'admin@saigoncity.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/P6', 'Nguyen',
        'Van Minh', '+8428123456', 5, 'active', 'verified'),
       ('Manila Bay Resorts', 'contact@manilabay.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/P7', 'Jose',
        'Santos', '+632123456789', 6, 'pending', 'unverified'),
       ('Tokyo Modern Hotels', 'info@tokyomodern.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/P8', 'Hiroshi',
        'Yamamoto', '+81312345678', 7, 'active', 'verified'),
       ('Seoul Business Hotels', 'manager@seoulbiz.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/P9', 'Park',
        'Min-jun', '+82212345678', 8, 'active', 'verified'),
       ('Chiang Mai Boutique', 'admin@cmboutique.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/P0', 'Pensri',
        'Nakorn', '+6653123456', 1, 'pending', 'under_review');

INSERT INTO admin_users (username, email, password_hash, role, department, account_status)
VALUES ('sarah.johnson', 'sarah.johnson@agoda.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/A1', 'content_manager',
        'Content', 'active'),
       ('mike.roberts', 'mike.roberts@agoda.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/A2', 'customer_service',
        'Support', 'active'),
       ('lisa.anderson', 'lisa.anderson@agoda.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/A3', 'super_admin',
        'Technology', 'active'),
       ('david.lee', 'david.lee@agoda.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/A4', 'finance', 'Finance',
        'active'),
       ('anna.wilson', 'anna.wilson@agoda.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/A5', 'content_manager',
        'Content', 'active'),
       ('tom.clark', 'tom.clark@agoda.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/A6', 'customer_service',
        'Support', 'active'),
       ('emma.davis', 'emma.davis@agoda.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/A7', 'marketing', 'Marketing',
        'active'),
       ('james.miller', 'james.miller@agoda.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/A8', 'partner_relations',
        'Partnerships', 'active'),
       ('olivia.brown', 'olivia.brown@agoda.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/A9', 'content_manager',
        'Content', 'active'),
       ('alex.taylor', 'alex.taylor@agoda.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/A0', 'super_admin',
        'Technology', 'active');

INSERT INTO amenities (amenity_name, amenity_category, is_active)
VALUES ('Free WiFi', 'property', TRUE),
       ('Swimming Pool', 'property', TRUE),
       ('Fitness Center', 'property', TRUE),
       ('Restaurant', 'property', TRUE),
       ('Bar/Lounge', 'property', TRUE),
       ('Spa', 'property', TRUE),
       ('Business Center', 'property', TRUE),
       ('Free Parking', 'property', TRUE),
       ('Airport Shuttle', 'property', TRUE),
       ('Air Conditioning', 'room', TRUE),
       ('Mini Bar', 'room', TRUE),
       ('Safe Box', 'room', TRUE),
       ('TV', 'room', TRUE),
       ('Room Service', 'room', TRUE),
       ('Balcony', 'room', TRUE);

INSERT INTO properties (partner_id, property_name, property_type, star_rating, location_id, street_address, description,
                        total_rooms, property_status, content_status, contact_phone, contact_email)
VALUES (1, 'Grand Palace Hotel Bangkok', 'hotel', 5, 1, '123 Sukhumvit Road',
        'Luxury hotel in the heart of Bangkok with world-class amenities and service.', 250, 'active', 'approved',
        '+6621234567', 'info@grandpalacebkk.com'),
       (1, 'Silom Business Suites', 'hotel', 4, 2, '456 Silom Road',
        'Modern business hotel perfect for corporate travelers.', 180, 'active', 'approved', '+6621234568',
        'reservations@silomsuites.com'),
       (2, 'Patong Beach Resort', 'resort', 4, 5, '789 Beach Road, Patong',
        'Beachfront resort with stunning ocean views and tropical ambiance.', 120, 'active', 'approved', '+6676123456',
        'booking@patongresort.com'),
       (2, 'Kata Sunset Villa', 'villa', 3, 6, '321 Sunset Drive, Kata',
        'Intimate villa resort overlooking the beautiful Kata Beach.', 45, 'active', 'approved', '+6676123457',
        'info@katasunset.com'),
       (3, 'Marina Bay Luxury Hotel', 'hotel', 5, 11, '100 Marina Bay Drive',
        'Iconic luxury hotel with breathtaking views of Marina Bay.', 300, 'active', 'approved', '+6563456789',
        'reservations@marinabaylux.com'),
       (3, 'Orchard Premier Suites', 'hotel', 4, 10, '200 Orchard Boulevard',
        'Premium suites in the shopping district of Singapore.', 150, 'active', 'approved', '+6563456788',
        'booking@orchardpremier.com'),
       (4, 'KLCC Tower Hotel', 'hotel', 5, 14, '88 KLCC Plaza',
        'Sophisticated hotel connected to KLCC with panoramic city views.', 400, 'active', 'approved', '+60321234567',
        'info@klcctower.com'),
       (4, 'Bukit Bintang Boutique', 'hotel', 3, 13, '77 Bintang Walk',
        'Trendy boutique hotel in the entertainment district.', 80, 'active', 'approved', '+60321234568',
        'hello@bukitbintanghotel.com'),
       (5, 'Seminyak Beach Club', 'resort', 4, 16, '555 Seminyak Beach',
        'Chic beachfront resort with modern Balinese design.', 90, 'active', 'approved', '+62361234567',
        'reservations@seminyakclub.com'),
       (5, 'Ubud Cultural Retreat', 'resort', 4, 17, '123 Monkey Forest Road',
        'Peaceful retreat surrounded by rice fields and culture.', 60, 'active', 'approved', '+62361234568',
        'booking@ubudretreat.com'),
       (6, 'Saigon Central Hotel', 'hotel', 4, 18, '999 Dong Khoi Street',
        'Modern hotel in the heart of Ho Chi Minh Citys business district.', 200, 'active', 'approved', '+8428123456',
        'info@saigoncentral.com'),
       (7, 'Manila Bay Grand', 'hotel', 4, 6, '777 Roxas Boulevard',
        'Grand hotel overlooking Manila Bay with world-class facilities.', 350, 'pending', 'under_review',
        '+632123456789', 'reservations@manilabaygrand.com');

INSERT INTO room_types (property_id, room_type_name, max_occupancy, max_adults, max_children, bed_configuration,
                        base_rate, currency_code, total_rooms)
VALUES (1, 'Deluxe King Room', 2, 2, 1, '1 King Bed', 4500.00, 'THB', 100),
       (1, 'Executive Suite', 4, 3, 2, '1 King Bed + Sofa Bed', 7500.00, 'THB', 50),
       (2, 'Business King', 2, 2, 1, '1 King Bed', 3200.00, 'THB', 90),
       (2, 'Junior Suite', 3, 2, 2, '1 King Bed + Day Bed', 4800.00, 'THB', 45),
       (3, 'Ocean View Room', 2, 2, 1, '1 King Bed', 3800.00, 'THB', 80),
       (3, 'Beach Villa', 4, 3, 2, '1 King Bed + Twin Beds', 6500.00, 'THB', 40),
       (4, 'Sunset Room', 2, 2, 1, '1 Queen Bed', 2800.00, 'THB', 30),
       (4, 'Villa Suite', 6, 4, 3, '2 King Beds', 5200.00, 'THB', 15),
       (5, 'Marina View Room', 2, 2, 1, '1 King Bed', 450.00, 'SGD', 200),
       (5, 'Presidential Suite', 6, 4, 3, '2 King Beds + Living Room', 1200.00, 'SGD', 20),
       (6, 'Premier Room', 2, 2, 1, '1 King Bed', 320.00, 'SGD', 100),
       (6, 'Family Suite', 4, 3, 2, '1 King + 1 Twin Bed', 480.00, 'SGD', 50),
       (7, 'City View Room', 2, 2, 1, '1 King Bed', 280.00, 'MYR', 250),
       (7, 'Executive Suite', 4, 3, 2, '1 King Bed + Sofa Bed', 450.00, 'MYR', 80),
       (8, 'Standard Room', 2, 2, 1, '1 Queen Bed', 180.00, 'MYR', 60),
       (8, 'Deluxe Twin', 2, 2, 1, '2 Twin Beds', 200.00, 'MYR', 20),
       (9, 'Beach Room', 2, 2, 1, '1 King Bed', 2800000.00, 'IDR', 60),
       (9, 'Pool Villa', 4, 3, 2, '1 King Bed + Private Pool', 4500000.00, 'IDR', 30),
       (10, 'Garden View', 2, 2, 1, '1 King Bed', 2200000.00, 'IDR', 40),
       (10, 'Rice Field Villa', 4, 3, 2, '1 King Bed + Living Area', 3800000.00, 'IDR', 20),
       (11, 'Standard Room', 2, 2, 1, '1 King Bed', 2800000.00, 'VND', 120),
       (11, 'Executive Room', 3, 2, 2, '1 King Bed + Day Bed', 3800000.00, 'VND', 80),
       (12, 'Bay View Room', 2, 2, 1, '1 King Bed', 6500.00, 'PHP', 200),
       (12, 'Family Suite', 4, 3, 2, '1 King + 1 Twin Bed', 9500.00, 'PHP', 80);

INSERT INTO property_amenities (property_id, amenity_id, is_free)
VALUES (1, 1, TRUE),
       (1, 2, TRUE),
       (1, 3, TRUE),
       (1, 4, TRUE),
       (1, 5, TRUE),
       (1, 6, FALSE),
       (1, 7, TRUE),
       (1, 8, FALSE),
       (1, 9, TRUE);

INSERT INTO property_amenities (property_id, amenity_id, is_free)
VALUES (2, 1, TRUE),
       (2, 3, TRUE),
       (2, 4, TRUE),
       (2, 7, TRUE),
       (2, 9, TRUE);

INSERT INTO property_amenities (property_id, amenity_id, is_free)
VALUES (3, 1, TRUE),
       (3, 2, TRUE),
       (3, 4, TRUE),
       (3, 5, TRUE),
       (3, 6, FALSE),
       (3, 8, TRUE);

INSERT INTO property_amenities (property_id, amenity_id, is_free)
VALUES (4, 1, TRUE),
       (4, 2, TRUE),
       (4, 8, TRUE);

INSERT INTO property_amenities (property_id, amenity_id, is_free)
VALUES (5, 1, TRUE),
       (5, 2, TRUE),
       (5, 3, TRUE),
       (5, 4, TRUE),
       (5, 5, TRUE),
       (5, 6, FALSE),
       (5, 7, TRUE),
       (5, 8, FALSE),
       (5, 9, TRUE);

INSERT INTO property_amenities (property_id, amenity_id, is_free)
VALUES (6, 1, TRUE),
       (6, 3, TRUE),
       (6, 4, TRUE),
       (6, 7, TRUE);

INSERT INTO property_amenities (property_id, amenity_id, is_free)
VALUES (7, 1, TRUE),
       (7, 2, TRUE),
       (7, 3, TRUE),
       (7, 4, TRUE),
       (7, 5, TRUE),
       (7, 6, FALSE),
       (7, 7, TRUE),
       (7, 9, TRUE);

INSERT INTO property_amenities (property_id, amenity_id, is_free)
VALUES (8, 1, TRUE),
       (8, 4, TRUE),
       (8, 5, TRUE);

INSERT INTO property_amenities (property_id, amenity_id, is_free)
VALUES (9, 1, TRUE),
       (9, 2, TRUE),
       (9, 4, TRUE),
       (9, 5, TRUE),
       (9, 6, FALSE);

INSERT INTO property_amenities (property_id, amenity_id, is_free)
VALUES (10, 1, TRUE),
       (10, 2, TRUE),
       (10, 6, FALSE),
       (10, 8, TRUE);

INSERT INTO property_amenities (property_id, amenity_id, is_free)
VALUES (11, 1, TRUE),
       (11, 3, TRUE),
       (11, 4, TRUE),
       (11, 7, TRUE),
       (11, 9, TRUE);

INSERT INTO property_amenities (property_id, amenity_id, is_free)
VALUES (12, 1, TRUE),
       (12, 2, TRUE),
       (12, 3, TRUE),
       (12, 4, TRUE),
       (12, 5, TRUE);

INSERT INTO room_type_amenities (room_type_id, amenity_id)
VALUES
(1, 10),
(1, 13),
(1, 12),
(1, 11),
(1, 14),
(1, 15),
(2, 10),
(2, 13),
(2, 12),
(2, 11),
(2, 14),
(2, 15),
(3, 10),
(3, 13),
(3, 12),
(3, 11),
(3, 14),
(4, 10),
(4, 13),
(4, 12),
(4, 11),
(4, 14),
(4, 15),
(5, 10),
(5, 13),
(5, 12),
(5, 11),
(5, 14),
(5, 15),
(6, 10),
(6, 13),
(6, 12),
(6, 11),
(6, 14),
(6, 15),
(7, 10),
(7, 13),
(7, 12),
(7, 11),
(7, 14),
(7, 15),
(8, 10),
(8, 13),
(8, 12),
(8, 11),
(8, 14),
(8, 15),
(9, 10),
(9, 13),
(9, 12),
(9, 11),
(9, 14),
(9, 15),
(10, 10),
(10, 13),
(10, 12),
(10, 11),
(10, 14),
(10, 15),
(11, 10),
(11, 13),
(11, 12),
(11, 11),
(11, 14),
(12, 10),
(12, 13),
(12, 12),
(12, 11),
(12, 14),
(12, 15),
(13, 10),
(13, 13),
(13, 12),
(13, 11),
(13, 14),
(14, 10),
(14, 13),
(14, 12),
(14, 11),
(14, 14),
(15, 10),
(15, 13),
(15, 12),
(15, 11),
(15, 14),
(16, 10),
(16, 13),
(16, 12),
(16, 11),
(16, 14),
(16, 15),
(17, 10),
(17, 13),
(17, 12),
(17, 11),
(17, 14),
(17, 15),
(18, 10),
(18, 13),
(18, 12),
(18, 11),
(18, 14),
(18, 15),
(19, 10),
(19, 13),
(19, 12),
(19, 11),
(19, 14),
(20, 10),
(20, 13),
(20, 12),
(20, 11),
(20, 14),
(20, 15),
(21, 10),
(21, 13),
(21, 12),
(21, 11),
(21, 14),
(22, 10),
(22, 13),
(22, 12),
(22, 11),
(22, 14),
(23, 10),
(23, 13),
(23, 12),
(23, 11),
(23, 14),
(23, 15),
(24, 10),
(24, 13),
(24, 12),
(24, 11),
(24, 14),
(24, 15);

INSERT INTO property_images (property_id, image_url, image_category, display_order, is_primary)
VALUES
-- Grand Palace Hotel Bangkok
(1, 'https://images.agoda.com/properties/grandpalace/exterior1.jpg', 'exterior', 1, TRUE),
(1, 'https://images.agoda.com/properties/grandpalace/lobby1.jpg', 'lobby', 2, FALSE),
(1, 'https://images.agoda.com/properties/grandpalace/room1.jpg', 'room', 3, FALSE),
(1, 'https://images.agoda.com/properties/grandpalace/pool1.jpg', 'amenity', 4, FALSE),
(1, 'https://images.agoda.com/properties/grandpalace/restaurant1.jpg', 'restaurant', 5, FALSE),
(1, 'https://images.agoda.com/properties/grandpalace/spa1.jpg', 'amenity', 6, FALSE),

-- Silom Business Suites
(2, 'https://images.agoda.com/properties/silom/exterior1.jpg', 'exterior', 1, TRUE),
(2, 'https://images.agoda.com/properties/silom/lobby1.jpg', 'lobby', 2, FALSE),
(2, 'https://images.agoda.com/properties/silom/room1.jpg', 'room', 3, FALSE),
(2, 'https://images.agoda.com/properties/silom/business1.jpg', 'amenity', 4, FALSE),
(2, 'https://images.agoda.com/properties/silom/gym1.jpg', 'amenity', 5, FALSE),
(2, 'https://images.agoda.com/properties/silom/restaurant1.jpg', 'restaurant', 6, FALSE),

-- Patong Beach Resort
(3, 'https://images.agoda.com/properties/patong/exterior1.jpg', 'exterior', 1, TRUE),
(3, 'https://images.agoda.com/properties/patong/beach1.jpg', 'exterior', 2, FALSE),
(3, 'https://images.agoda.com/properties/patong/room1.jpg', 'room', 3, FALSE),
(3, 'https://images.agoda.com/properties/patong/pool1.jpg', 'amenity', 4, FALSE),
(3, 'https://images.agoda.com/properties/patong/bar1.jpg', 'restaurant', 5, FALSE),
(3, 'https://images.agoda.com/properties/patong/spa1.jpg', 'amenity', 6, FALSE),

-- Kata Sunset Villa
(4, 'https://images.agoda.com/properties/kata/exterior1.jpg', 'exterior', 1, TRUE),
(4, 'https://images.agoda.com/properties/kata/sunset1.jpg', 'exterior', 2, FALSE),
(4, 'https://images.agoda.com/properties/kata/room1.jpg', 'room', 3, FALSE),
(4, 'https://images.agoda.com/properties/kata/pool1.jpg', 'amenity', 4, FALSE),
(4, 'https://images.agoda.com/properties/kata/terrace1.jpg', 'amenity', 5, FALSE),
(4, 'https://images.agoda.com/properties/kata/beach1.jpg', 'exterior', 6, FALSE),

-- Marina Bay Luxury Hotel
(5, 'https://images.agoda.com/properties/marina/exterior1.jpg', 'exterior', 1, TRUE),
(5, 'https://images.agoda.com/properties/marina/lobby1.jpg', 'lobby', 2, FALSE),
(5, 'https://images.agoda.com/properties/marina/room1.jpg', 'room', 3, FALSE),
(5, 'https://images.agoda.com/properties/marina/pool1.jpg', 'amenity', 4, FALSE),
(5, 'https://images.agoda.com/properties/marina/restaurant1.jpg', 'restaurant', 5, FALSE),
(5, 'https://images.agoda.com/properties/marina/skybar1.jpg', 'restaurant', 6, FALSE),

-- Orchard Premier Suites
(6, 'https://images.agoda.com/properties/orchard/exterior1.jpg', 'exterior', 1, TRUE),
(6, 'https://images.agoda.com/properties/orchard/lobby1.jpg', 'lobby', 2, FALSE),
(6, 'https://images.agoda.com/properties/orchard/suite1.jpg', 'room', 3, FALSE),
(6, 'https://images.agoda.com/properties/orchard/gym1.jpg', 'amenity', 4, FALSE),
(6, 'https://images.agoda.com/properties/orchard/restaurant1.jpg', 'restaurant', 5, FALSE),
(6, 'https://images.agoda.com/properties/orchard/business1.jpg', 'amenity', 6, FALSE);

INSERT INTO availability (room_type_id, available_date, total_rooms, available_rooms, rate, currency_code, updated_by)
VALUES (1, '2025-01-15', 100, 85, 4500.00, 'THB', 1),
       (1, '2025-01-16', 100, 78, 4500.00, 'THB', 1),
       (1, '2025-01-17', 100, 92, 4200.00, 'THB', 1),
       (1, '2025-01-18', 100, 67, 4800.00, 'THB', 1),
       (1, '2025-01-19', 100, 45, 5200.00, 'THB', 1),
       (1, '2025-01-20', 100, 23, 5500.00, 'THB', 1),
       (1, '2025-01-21', 100, 12, 5800.00, 'THB', 1),
       (1, '2025-01-22', 100, 8, 6000.00, 'THB', 1),
       (1, '2025-01-23', 100, 15, 5800.00, 'THB', 1),
       (1, '2025-01-24', 100, 34, 5200.00, 'THB', 1),
       (1, '2025-01-25', 100, 56, 4800.00, 'THB', 1),
       (1, '2025-01-26', 100, 73, 4500.00, 'THB', 1),
       (1, '2025-01-27', 100, 81, 4200.00, 'THB', 1),
       (1, '2025-01-28', 100, 88, 4200.00, 'THB', 1),
       (1, '2025-01-29', 100, 91, 4200.00, 'THB', 1),

       (3, '2025-01-15', 90, 75, 3200.00, 'THB', 1),
       (3, '2025-01-16', 90, 68, 3200.00, 'THB', 1),
       (3, '2025-01-17', 90, 82, 2900.00, 'THB', 1),
       (3, '2025-01-18', 90, 45, 3500.00, 'THB', 1),
       (3, '2025-01-19', 90, 23, 3800.00, 'THB', 1),
       (3, '2025-01-20', 90, 12, 4200.00, 'THB', 1),
       (3, '2025-01-21', 90, 8, 4500.00, 'THB', 1),
       (3, '2025-01-22', 90, 5, 4800.00, 'THB', 1),
       (3, '2025-01-23', 90, 12, 4500.00, 'THB', 1),
       (3, '2025-01-24', 90, 28, 3800.00, 'THB', 1),
       (3, '2025-01-25', 90, 45, 3500.00, 'THB', 1),
       (3, '2025-01-26', 90, 62, 3200.00, 'THB', 1),
       (3, '2025-01-27', 90, 71, 2900.00, 'THB', 1),
       (3, '2025-01-28', 90, 78, 2900.00, 'THB', 1),
       (3, '2025-01-29', 90, 83, 2900.00, 'THB', 1),

       (5, '2025-01-15', 80, 65, 3800.00, 'THB', 2),
       (5, '2025-01-16', 80, 58, 3800.00, 'THB', 2),
       (5, '2025-01-17', 80, 72, 3500.00, 'THB', 2),
       (5, '2025-01-18', 80, 42, 4200.00, 'THB', 2),
       (5, '2025-01-19', 80, 25, 4800.00, 'THB', 2),
       (5, '2025-01-20', 80, 8, 5500.00, 'THB', 2),
       (5, '2025-01-21', 80, 3, 6200.00, 'THB', 2),
       (5, '2025-01-22', 80, 1, 6800.00, 'THB', 2),
       (5, '2025-01-23', 80, 5, 6200.00, 'THB', 2),
       (5, '2025-01-24', 80, 18, 5500.00, 'THB', 2),
       (5, '2025-01-25', 80, 35, 4800.00, 'THB', 2),
       (5, '2025-01-26', 80, 52, 4200.00, 'THB', 2),
       (5, '2025-01-27', 80, 63, 3800.00, 'THB', 2),
       (5, '2025-01-28', 80, 71, 3500.00, 'THB', 2),
       (5, '2025-01-29', 80, 76, 3500.00, 'THB', 2),

       (9, '2025-01-15', 200, 165, 450.00, 'SGD', 3),
       (9, '2025-01-16', 200, 148, 450.00, 'SGD', 3),
       (9, '2025-01-17', 200, 172, 420.00, 'SGD', 3),
       (9, '2025-01-18', 200, 125, 480.00, 'SGD', 3),
       (9, '2025-01-19', 200, 89, 520.00, 'SGD', 3),
       (9, '2025-01-20', 200, 45, 580.00, 'SGD', 3),
       (9, '2025-01-21', 200, 23, 650.00, 'SGD', 3),
       (9, '2025-01-22', 200, 12, 720.00, 'SGD', 3),
       (9, '2025-01-23', 200, 28, 650.00, 'SGD', 3),
       (9, '2025-01-24', 200, 67, 580.00, 'SGD', 3),
       (9, '2025-01-25', 200, 98, 520.00, 'SGD', 3),
       (9, '2025-01-26', 200, 134, 480.00, 'SGD', 3),
       (9, '2025-01-27', 200, 156, 450.00, 'SGD', 3),
       (9, '2025-01-28', 200, 171, 420.00, 'SGD', 3),
       (9, '2025-01-29', 200, 183, 420.00, 'SGD', 3);

INSERT INTO bookings (booking_reference, user_id, property_id, room_type_id, check_in_date, check_out_date,
                      total_nights, total_adults, total_children, total_rooms, total_amount, currency_code,
                      booking_status, guest_first_name, guest_last_name, guest_email, guest_phone, special_requests,
                      created_at)
VALUES ('AGD-BKK001', 1, 1, 1, '2025-01-20', '2025-01-23', 3, 2, 0, 1, 16500.00, 'THB', 'confirmed', 'John', 'Smith',
        'john.smith@email.com', '+1234567890', 'Late check-in requested', '2025-01-10 10:30:00'),
       ('AGD-BKK002', 2, 1, 2, '2025-01-18', '2025-01-21', 3, 2, 1, 1, 22500.00, 'THB', 'confirmed', 'Sarah', 'Jones',
        'sarah.jones@email.com', '+1234567891', 'Extra bed for child', '2025-01-09 14:15:00'),
       ('AGD-PHU001', 3, 3, 5, '2025-01-22', '2025-01-25', 3, 2, 0, 1, 13800.00, 'THB', 'confirmed', 'Mike', 'Wilson',
        'mike.wilson@email.com', '+1234567892', 'Honeymoon package', '2025-01-08 16:45:00'),
       ('AGD-SIN001', 4, 5, 9, '2025-01-19', '2025-01-21', 2, 1, 0, 1, 1040.00, 'SGD', 'confirmed', 'Lisa', 'Chen',
        'lisa.chen@email.com', '+65987654321', NULL, '2025-01-07 09:20:00'),
       ('AGD-SIN002', 5, 6, 11, '2025-01-25', '2025-01-28', 3, 2, 0, 1, 960.00, 'SGD', 'pending', 'David', 'Kim',
        'david.kim@email.com', '+821012345678', 'Airport pickup', '2025-01-10 11:30:00'),
       ('AGD-KL001', 6, 7, 13, '2025-01-17', '2025-01-20', 3, 2, 1, 1, 840.00, 'MYR', 'confirmed', 'Anna', 'Mueller',
        'anna.mueller@email.com', '+33123456789', 'Vegetarian meals', '2025-01-06 13:45:00'),
       ('AGD-BAL001', 7, 9, 17, '2025-01-21', '2025-01-24', 3, 2, 0, 1, 8400000.00, 'IDR', 'confirmed', 'Tom', 'Brown',
        'tom.brown@email.com', '+61412345678', 'Yoga session', '2025-01-05 15:20:00'),
       ('AGD-BAL002', 8, 10, 19, '2025-01-16', '2025-01-19', 3, 2, 0, 1, 6600000.00, 'IDR', 'confirmed', 'Maria',
        'Garcia', 'maria.garcia@email.com', '+1234567893', 'Cultural tour', '2025-01-04 10:15:00'),
       ('AGD-SGN001', 9, 11, 21, '2025-01-23', '2025-01-26', 3, 1, 0, 1, 8400000.00, 'VND', 'confirmed', 'Raj', 'Patel',
        'raj.patel@email.com', '+65987654322', NULL, '2025-01-03 12:30:00'),
       ('AGD-BKK003', 10, 2, 3, '2025-01-15', '2025-01-17', 2, 1, 0, 1, 6400.00, 'THB', 'completed', 'Yuki', 'Tanaka',
        'yuki.tanaka@email.com', '+81901234567', 'Business traveler', '2024-12-28 14:20:00'),
       ('AGD-PHU002', 11, 4, 7, '2025-01-12', '2025-01-15', 3, 4, 2, 2, 16800.00, 'THB', 'completed', 'Emma', 'White',
        'emma.white@email.com', '+44207123456', 'Family vacation', '2024-12-25 16:45:00'),
       ('AGD-SIN003', 12, 5, 10, '2025-01-08', '2025-01-11', 3, 4, 2, 1, 3600.00, 'SGD', 'completed', 'Alex', 'Wong',
        'alex.wong@email.com', '+60123456789', 'Family suite', '2024-12-20 09:30:00'),
       ('AGD-KL002', 1, 8, 15, '2025-01-14', '2025-01-16', 2, 2, 0, 1, 560.00, 'MYR', 'cancelled', 'John', 'Smith',
        'john.smith@email.com', '+1234567890', 'Change of plans', '2024-12-15 11:20:00'),
       ('AGD-BKK004', 2, 1, 1, '2025-02-01', '2025-02-03', 2, 2, 0, 1, 9000.00, 'THB', 'pending', 'Sarah', 'Jones',
        'sarah.jones@email.com', '+1234567891', 'Valentine special', '2025-01-10 18:30:00'),
       ('AGD-SIN004', 3, 6, 12, '2025-02-05', '2025-02-08', 3, 3, 1, 1, 1440.00, 'SGD', 'pending', 'Mike', 'Wilson',
        'mike.wilson@email.com', '+1234567892', 'Family trip', '2025-01-11 10:45:00');

-- ========================================
-- 15. COUPONS (10 rows)
-- ========================================

INSERT INTO coupons (coupon_code, coupon_name, discount_type, discount_value, minimum_booking_amount, valid_from,
                     valid_to, coupon_status, created_by)
VALUES ('SUMMER25', '25% OFF Summer Special', 'percentage', 25.00, 1000.00, '2025-01-01 00:00:00',
        '2025-03-31 23:59:59', 'active', 1),
       ('WEEKEND15', '15% OFF Weekend Getaway', 'percentage', 15.00, 500.00, '2025-01-01 00:00:00',
        '2025-06-30 23:59:59', 'active', 1),
       ('NEWUSER50', '$50 OFF First Booking', 'fixed_amount', 50.00, 200.00, '2025-01-01 00:00:00',
        '2025-12-31 23:59:59', 'active', 2),
       ('LOYALTY20', '20% OFF Loyalty Members', 'percentage', 20.00, 800.00, '2025-01-01 00:00:00',
        '2025-12-31 23:59:59', 'active', 2),
       ('FLASH30', '30% OFF Flash Sale', 'percentage', 30.00, 1500.00, '2025-01-15 00:00:00', '2025-01-31 23:59:59',
        'active', 3),
       ('FAMILY100', '$100 OFF Family Packages', 'fixed_amount', 100.00, 2000.00, '2025-01-01 00:00:00',
        '2025-08-31 23:59:59', 'active', 3),
       ('EARLY10', '10% OFF Early Bird', 'percentage', 10.00, 300.00, '2025-01-01 00:00:00', '2025-05-31 23:59:59',
        'active', 4),
       ('WINTER50', '$50 OFF Winter Special', 'fixed_amount', 50.00, 600.00, '2024-12-01 00:00:00',
        '2025-02-28 23:59:59', 'expired', 4),
       ('VALENTINE15', '15% OFF Valentine Package', 'percentage', 15.00, 800.00, '2025-02-01 00:00:00',
        '2025-02-20 23:59:59', 'active', 5),
       ('LASTMIN25', '25% OFF Last Minute Deals', 'percentage', 25.00, 400.00, '2025-01-01 00:00:00',
        '2025-12-31 23:59:59', 'active', 5);

INSERT INTO reviews (booking_id, user_id, property_id, overall_rating, review_title, review_text, review_status)
VALUES (10, 10, 2, 8, 'Great Business Hotel',
        'Perfect location for business meetings. Clean rooms and good service. The wifi was excellent and breakfast was decent.',
        'approved'),
       (11, 11, 4, 9, 'Amazing Family Vacation',
        'The kids loved the sunset views and the pool was perfect. Staff was very friendly and accommodating. Highly recommend for families!',
        'approved'),
       (12, 12, 5, 10, 'Luxury at its Best',
        'Absolutely stunning hotel with incredible views of Marina Bay. The service was impeccable and the rooms were spotless. Will definitely return!',
        'approved'),
       (1, 1, 1, 9, 'Excellent Stay in Bangkok',
        'Beautiful hotel with great amenities. The spa was amazing and the location is perfect for exploring the city. Room was spacious and comfortable.',
        'approved'),
       (2, 2, 1, 8, 'Good for Families',
        'Nice hotel with good facilities for children. The extra bed was comfortable and the staff helped us with restaurant recommendations.',
        'approved'),
       (3, 3, 3, 10, 'Perfect Honeymoon',
        'Could not have asked for a better honeymoon destination. The beach access was private and the sunset views were breathtaking. Romantic dining was excellent.',
        'approved'),
       (4, 4, 5, 9, 'Business Trip Success',
        'Great location for my business meetings in Singapore. The hotel provided excellent conference facilities and the room was perfect for working.',
        'approved'),
       (6, 6, 7, 7, 'Good Value Hotel',
        'Decent hotel in a great location. Rooms were clean but could use some updating. Staff was helpful and the breakfast was good.',
        'approved'),
       (7, 7, 9, 9, 'Relaxing Beach Getaway',
        'Perfect for a relaxing vacation. The beach club atmosphere was exactly what we needed. Yoga sessions were a great addition to our stay.',
        'approved'),
       (8, 8, 10, 8, 'Cultural Experience',
        'Loved the cultural immersion aspect of this hotel. The rice field views were stunning and the cultural tour was educational and fun.',
        'approved'),
       (9, 9, 11, 7, 'Business Travel',
        'Good hotel for business travel. Location is convenient and rooms are comfortable. WiFi could be faster but overall a decent stay.',
        'approved'),
       (5, 5, 6, 6, 'Average Experience',
        'Hotel was okay but not exceptional. Room was clean but service was slow. Location is good for shopping but value for money could be better.',
        'pending');

SELECT 'countries' as table_name, COUNT(*) as row_count
FROM countries
UNION ALL
SELECT 'cities', COUNT(*)
FROM cities
UNION ALL
SELECT 'locations', COUNT(*)
FROM locations
UNION ALL
SELECT 'users', COUNT(*)
FROM users
UNION ALL
SELECT 'partners', COUNT(*)
FROM partners
UNION ALL
SELECT 'admin_users', COUNT(*)
FROM admin_users
UNION ALL
SELECT 'amenities', COUNT(*)
FROM amenities
UNION ALL
SELECT 'properties', COUNT(*)
FROM properties
UNION ALL
SELECT 'room_types', COUNT(*)
FROM room_types
UNION ALL
SELECT 'property_amenities', COUNT(*)
FROM property_amenities
UNION ALL
SELECT 'room_type_amenities', COUNT(*)
FROM room_type_amenities
UNION ALL
SELECT 'property_images', COUNT(*)
FROM property_images
UNION ALL
SELECT 'availability', COUNT(*)
FROM availability
UNION ALL
SELECT 'bookings', COUNT(*)
FROM bookings
UNION ALL
SELECT 'coupons', COUNT(*)
FROM coupons
UNION ALL
SELECT 'reviews', COUNT(*)
FROM reviews
ORDER BY table_name;