DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS coupons CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS availability CASCADE;
DROP TABLE IF EXISTS property_images CASCADE;
DROP TABLE IF EXISTS room_type_amenities CASCADE;
DROP TABLE IF EXISTS property_amenities CASCADE;
DROP TABLE IF EXISTS room_types CASCADE;
DROP TABLE IF EXISTS properties CASCADE;
DROP TABLE IF EXISTS amenities CASCADE;
DROP TABLE IF EXISTS admin_users CASCADE;
DROP TABLE IF EXISTS partners CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS locations CASCADE;
DROP TABLE IF EXISTS cities CASCADE;
DROP TABLE IF EXISTS countries CASCADE;

CREATE TABLE countries
(
    country_id    SERIAL PRIMARY KEY,
    country_code  VARCHAR(2) UNIQUE NOT NULL,
    country_name  VARCHAR(100)      NOT NULL,
    currency_code VARCHAR(3)        NOT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cities
(
    city_id    SERIAL PRIMARY KEY,
    city_name  VARCHAR(100) NOT NULL,
    country_id INTEGER      NOT NULL,
    latitude   DECIMAL(10, 8),
    longitude  DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (country_id) REFERENCES countries (country_id)
);

CREATE TABLE locations
(
    location_id   SERIAL PRIMARY KEY,
    location_name VARCHAR(200) NOT NULL,
    city_id       INTEGER      NOT NULL,
    area_type     VARCHAR(50),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (city_id) REFERENCES cities (city_id)
);

CREATE TABLE users
(
    user_id        SERIAL PRIMARY KEY,
    email          VARCHAR(255) UNIQUE NOT NULL,
    password_hash  VARCHAR(255)        NOT NULL,
    first_name     VARCHAR(100)        NOT NULL,
    last_name      VARCHAR(100)        NOT NULL,
    phone_number   VARCHAR(20),
    country_id     INTEGER,
    account_status VARCHAR(20) DEFAULT 'active',
    created_at     TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    last_login     TIMESTAMP,
    FOREIGN KEY (country_id) REFERENCES countries (country_id)
);

CREATE TABLE partners
(
    partner_id                SERIAL PRIMARY KEY,
    company_name              VARCHAR(200)        NOT NULL,
    contact_email             VARCHAR(255) UNIQUE NOT NULL,
    password_hash             VARCHAR(255)        NOT NULL,
    contact_person_first_name VARCHAR(100)        NOT NULL,
    contact_person_last_name  VARCHAR(100)        NOT NULL,
    phone_number              VARCHAR(20)         NOT NULL,
    country_id                INTEGER             NOT NULL,
    account_status            VARCHAR(20) DEFAULT 'pending',
    verification_status       VARCHAR(20) DEFAULT 'unverified',
    created_at                TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (country_id) REFERENCES countries (country_id)
);

CREATE TABLE admin_users
(
    admin_id       SERIAL PRIMARY KEY,
    username       VARCHAR(100) UNIQUE NOT NULL,
    email          VARCHAR(255) UNIQUE NOT NULL,
    password_hash  VARCHAR(255)        NOT NULL,
    role           VARCHAR(50)         NOT NULL,
    department     VARCHAR(100),
    account_status VARCHAR(20) DEFAULT 'active',
    created_at     TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE amenities
(
    amenity_id       SERIAL PRIMARY KEY,
    amenity_name     VARCHAR(100) UNIQUE NOT NULL,
    amenity_category VARCHAR(50)         NOT NULL,
    is_active        BOOLEAN DEFAULT TRUE
);

CREATE TABLE properties
(
    property_id     SERIAL PRIMARY KEY,
    partner_id      INTEGER      NOT NULL,
    property_name   VARCHAR(200) NOT NULL,
    property_type   VARCHAR(50)  NOT NULL,
    star_rating     INTEGER CHECK (star_rating BETWEEN 1 AND 5),
    location_id     INTEGER      NOT NULL,
    street_address  VARCHAR(300) NOT NULL,
    description     TEXT,
    total_rooms     INTEGER      NOT NULL,
    property_status VARCHAR(20) DEFAULT 'pending',
    content_status  VARCHAR(20) DEFAULT 'draft',
    contact_phone   VARCHAR(20),
    contact_email   VARCHAR(255),
    created_at      TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (partner_id) REFERENCES partners (partner_id),
    FOREIGN KEY (location_id) REFERENCES locations (location_id)
);

CREATE TABLE room_types
(
    room_type_id      SERIAL PRIMARY KEY,
    property_id       INTEGER        NOT NULL,
    room_type_name    VARCHAR(100)   NOT NULL,
    max_occupancy     INTEGER        NOT NULL,
    max_adults        INTEGER        NOT NULL,
    max_children      INTEGER        NOT NULL,
    bed_configuration VARCHAR(200),
    base_rate         DECIMAL(10, 2) NOT NULL,
    currency_code     VARCHAR(3)     NOT NULL,
    total_rooms       INTEGER        NOT NULL,
    room_status       VARCHAR(20) DEFAULT 'active',
    created_at        TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties (property_id) ON DELETE CASCADE
);

CREATE TABLE property_amenities
(
    property_id INTEGER NOT NULL,
    amenity_id  INTEGER NOT NULL,
    is_free     BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (property_id, amenity_id),
    FOREIGN KEY (property_id) REFERENCES properties (property_id) ON DELETE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES amenities (amenity_id)
);

CREATE TABLE room_type_amenities
(
    room_type_id INTEGER NOT NULL,
    amenity_id   INTEGER NOT NULL,
    PRIMARY KEY (room_type_id, amenity_id),
    FOREIGN KEY (room_type_id) REFERENCES room_types (room_type_id) ON DELETE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES amenities (amenity_id)
);

CREATE TABLE property_images
(
    image_id       SERIAL PRIMARY KEY,
    property_id    INTEGER      NOT NULL,
    image_url      VARCHAR(500) NOT NULL,
    image_category VARCHAR(50)  NOT NULL,
    display_order  INTEGER   DEFAULT 0,
    is_primary     BOOLEAN   DEFAULT FALSE,
    upload_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties (property_id) ON DELETE CASCADE
);

CREATE TABLE availability
(
    availability_id SERIAL PRIMARY KEY,
    room_type_id    INTEGER        NOT NULL,
    available_date  DATE           NOT NULL,
    total_rooms     INTEGER        NOT NULL,
    available_rooms INTEGER        NOT NULL,
    rate            DECIMAL(10, 2) NOT NULL,
    currency_code   VARCHAR(3)     NOT NULL,
    last_updated    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by      INTEGER,
    UNIQUE (room_type_id, available_date),
    FOREIGN KEY (room_type_id) REFERENCES room_types (room_type_id) ON DELETE CASCADE
);

CREATE TABLE bookings
(
    booking_id        SERIAL PRIMARY KEY,
    booking_reference VARCHAR(20) UNIQUE NOT NULL,
    user_id           INTEGER            NOT NULL,
    property_id       INTEGER            NOT NULL,
    room_type_id      INTEGER            NOT NULL,
    check_in_date     DATE               NOT NULL,
    check_out_date    DATE               NOT NULL,
    total_nights      INTEGER            NOT NULL,
    total_adults      INTEGER            NOT NULL,
    total_children    INTEGER            NOT NULL,
    total_rooms       INTEGER            NOT NULL,
    total_amount      DECIMAL(12, 2)     NOT NULL,
    currency_code     VARCHAR(3)         NOT NULL,
    booking_status    VARCHAR(20) DEFAULT 'pending',
    guest_first_name  VARCHAR(100)       NOT NULL,
    guest_last_name   VARCHAR(100)       NOT NULL,
    guest_email       VARCHAR(255)       NOT NULL,
    guest_phone       VARCHAR(20),
    special_requests  TEXT,
    created_at        TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (property_id) REFERENCES properties (property_id),
    FOREIGN KEY (room_type_id) REFERENCES room_types (room_type_id)
);

CREATE TABLE coupons
(
    coupon_id              SERIAL PRIMARY KEY,
    coupon_code            VARCHAR(50) UNIQUE NOT NULL,
    coupon_name            VARCHAR(200)       NOT NULL,
    discount_type          VARCHAR(20)        NOT NULL,
    discount_value         DECIMAL(10, 2)     NOT NULL,
    minimum_booking_amount DECIMAL(10, 2),
    valid_from             TIMESTAMP          NOT NULL,
    valid_to               TIMESTAMP          NOT NULL,
    coupon_status          VARCHAR(20) DEFAULT 'active',
    created_by             INTEGER            NOT NULL,
    created_at             TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES admin_users (admin_id)
);

CREATE TABLE reviews
(
    review_id      SERIAL PRIMARY KEY,
    booking_id     INTEGER NOT NULL,
    user_id        INTEGER NOT NULL,
    property_id    INTEGER NOT NULL,
    overall_rating INTEGER CHECK (overall_rating BETWEEN 1 AND 10),
    review_title   VARCHAR(200),
    review_text    TEXT,
    review_status  VARCHAR(20) DEFAULT 'pending',
    created_at     TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings (booking_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (property_id) REFERENCES properties (property_id)
);

CREATE INDEX idx_properties_location_status ON properties (location_id, property_status);
CREATE INDEX idx_availability_date_room ON availability (room_type_id, available_date);
CREATE INDEX idx_bookings_user_date ON bookings (user_id, check_in_date);
CREATE INDEX idx_properties_partner_status ON properties (partner_id, property_status);
CREATE INDEX idx_reviews_property_status ON reviews (property_id, review_status);
CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_partners_email ON partners (contact_email);
CREATE INDEX idx_cities_country ON cities (country_id);
CREATE INDEX idx_locations_city ON locations (city_id);
CREATE INDEX idx_room_types_property ON room_types (property_id);
CREATE INDEX idx_bookings_property_date ON bookings (property_id, check_in_date);
CREATE INDEX idx_availability_date_available ON availability (available_date, available_rooms);