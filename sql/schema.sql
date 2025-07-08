DROP TABLE IF EXISTS room_availability CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS hotel_amenities CASCADE;
DROP TABLE IF EXISTS amenities CASCADE;
DROP TABLE IF EXISTS hotels CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'customer', -- 'customer', 'partner', 'admin'
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE hotels (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state_province TEXT,
    country TEXT NOT NULL,
    thumbnail_url TEXT,
    description TEXT,
    partner_id INT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE amenities (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE hotel_amenities (
    hotel_id INT NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    amenity_id INT NOT NULL REFERENCES amenities(id) ON DELETE CASCADE,
    PRIMARY KEY (hotel_id, amenity_id)
);

CREATE TABLE rooms (
    id SERIAL PRIMARY KEY,
    hotel_id INT NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    room_type TEXT NOT NULL,
    description TEXT,
    capacity INT NOT NULL CHECK (capacity > 0),
    price_per_night NUMERIC(10, 2) NOT NULL CHECK (price_per_night > 0),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE room_availability (
    room_id INT NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    available_rooms INT NOT NULL CHECK (available_rooms >= 0),
    PRIMARY KEY (room_id, date)
);

CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    room_id INT NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'confirmed', -- 'confirmed', 'cancelled', 'completed'
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (check_out > check_in)
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    payment_method TEXT NOT NULL, -- 'credit_card', 'debit_card', 'paypal', etc.
    status TEXT NOT NULL, -- 'pending', 'completed', 'failed', 'refunded'
    transaction_time TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    hotel_id INT NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_hotels_city ON hotels(city);
CREATE INDEX idx_room_availability_date ON room_availability(date);
CREATE INDEX idx_bookings_check_in ON bookings(check_in);
CREATE INDEX idx_bookings_check_out ON bookings(check_out);
CREATE INDEX idx_rooms_hotel_id ON rooms(hotel_id);
CREATE INDEX idx_payments_status ON payments(status);
