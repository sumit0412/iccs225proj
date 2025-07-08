BEGIN;

SELECT * FROM generate_financial_report('2024-01-01', '2024-12-31');

SELECT * FROM onboard_hotel_partner(
    'newpartner@example.com',
    'partnerpass',
    'New Partner',
    '+1234567890',
    'New Hotel',
    '123 New St',
    'Bangkok',
    'Thailand'
);

ROLLBACK;
