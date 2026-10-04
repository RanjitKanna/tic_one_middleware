-- ==============================================================================
-- TICONE BUS BOOKING APP SCHEMA
-- ==============================================================================

-- 1. Bus Operators
CREATE TABLE IF NOT EXISTS public.bus_operators (
    id SERIAL PRIMARY KEY,
    operator_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    logo_url TEXT,
    rating NUMERIC(3, 1) DEFAULT 4.5,
    total_reviews INTEGER DEFAULT 150,
    contact_number VARCHAR(30),
    email VARCHAR(100),
    cancellation_policy TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Buses
CREATE TABLE IF NOT EXISTS public.buses (
    id SERIAL PRIMARY KEY,
    bus_code VARCHAR(50) UNIQUE NOT NULL,
    operator_id INTEGER REFERENCES public.bus_operators(id) ON DELETE CASCADE NOT NULL,
    bus_name VARCHAR(150) NOT NULL,
    bus_number VARCHAR(30) NOT NULL,
    bus_type VARCHAR(100) NOT NULL, -- e.g. 'Volvo Multi-Axle AC Sleeper (2+1)', 'Scania AC Semi-Sleeper (2+2)', 'BharatBenz AC Seater (2+2)', 'Non-AC Sleeper (2+1)'
    category VARCHAR(50) NOT NULL DEFAULT 'sleeper', -- 'sleeper', 'seater', 'semi_sleeper'
    is_ac BOOLEAN DEFAULT true,
    deck_type VARCHAR(20) DEFAULT 'double', -- 'single', 'double'
    total_seats INTEGER NOT NULL DEFAULT 36,
    amenities JSONB DEFAULT '["WiFi", "Charging Point", "Water Bottle", "Blanket", "Reading Light", "Live Tracking", "Emergency Exit", "CCTV"]'::jsonb,
    live_tracking_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Bus Routes
CREATE TABLE IF NOT EXISTS public.bus_routes (
    id SERIAL PRIMARY KEY,
    route_code VARCHAR(50) UNIQUE NOT NULL,
    source_city VARCHAR(100) NOT NULL,
    destination_city VARCHAR(100) NOT NULL,
    source_state VARCHAR(100),
    destination_state VARCHAR(100),
    distance_km NUMERIC(8, 2) NOT NULL,
    estimated_duration_mins INTEGER NOT NULL,
    is_popular BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Bus Trips (Scheduled runs for specific dates & times)
CREATE TABLE IF NOT EXISTS public.bus_trips (
    id SERIAL PRIMARY KEY,
    trip_code VARCHAR(60) UNIQUE NOT NULL,
    bus_id INTEGER REFERENCES public.buses(id) ON DELETE CASCADE NOT NULL,
    route_id INTEGER REFERENCES public.bus_routes(id) ON DELETE CASCADE NOT NULL,
    travel_date DATE NOT NULL,
    departure_time TIMESTAMP WITH TIME ZONE NOT NULL,
    arrival_time TIMESTAMP WITH TIME ZONE NOT NULL,
    departure_time_formatted VARCHAR(30) NOT NULL, -- '10:30 PM'
    arrival_time_formatted VARCHAR(30) NOT NULL,   -- '06:00 AM'
    duration_formatted VARCHAR(30) NOT NULL,       -- '7h 30m'
    base_fare NUMERIC(10, 2) NOT NULL DEFAULT 750.00,
    status VARCHAR(30) DEFAULT 'active', -- 'active', 'filling_fast', 'almost_full', 'sold_out', 'cancelled'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Bus Seats (Seat layout matrix per bus)
CREATE TABLE IF NOT EXISTS public.bus_seats (
    id SERIAL PRIMARY KEY,
    bus_id INTEGER REFERENCES public.buses(id) ON DELETE CASCADE NOT NULL,
    seat_number VARCHAR(15) NOT NULL, -- 'L1', 'L2', 'U1', 'U2', 'A1', 'B2', etc.
    deck VARCHAR(10) DEFAULT 'lower', -- 'lower', 'upper'
    row_num INTEGER NOT NULL,
    column_num INTEGER NOT NULL,
    seat_type VARCHAR(30) DEFAULT 'sleeper', -- 'sleeper', 'seater', 'semi_sleeper'
    berth_type VARCHAR(30) DEFAULT 'single_berth', -- 'single_berth', 'double_berth', 'window_seat', 'aisle_seat'
    is_window BOOLEAN DEFAULT false,
    is_aisle BOOLEAN DEFAULT false,
    gender_preference VARCHAR(20) DEFAULT 'any', -- 'any', 'ladies_only', 'male_only'
    seat_tier VARCHAR(50) DEFAULT 'Standard', -- 'Standard', 'Premium Berth', 'Prime Recliner', 'Luxury Sleeper'
    price_multiplier NUMERIC(4, 2) DEFAULT 1.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(bus_id, seat_number)
);

-- 6. Boarding Points
CREATE TABLE IF NOT EXISTS public.boarding_points (
    id SERIAL PRIMARY KEY,
    trip_id INTEGER REFERENCES public.bus_trips(id) ON DELETE CASCADE,
    bus_id INTEGER REFERENCES public.buses(id) ON DELETE CASCADE,
    point_name VARCHAR(150) NOT NULL,
    landmark VARCHAR(200),
    address TEXT,
    contact_number VARCHAR(30),
    departure_time TIMESTAMP WITH TIME ZONE NOT NULL,
    time_formatted VARCHAR(30) NOT NULL,
    display_order INTEGER DEFAULT 1,
    latitude NUMERIC(10, 6),
    longitude NUMERIC(10, 6),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Dropping Points
CREATE TABLE IF NOT EXISTS public.dropping_points (
    id SERIAL PRIMARY KEY,
    trip_id INTEGER REFERENCES public.bus_trips(id) ON DELETE CASCADE,
    bus_id INTEGER REFERENCES public.buses(id) ON DELETE CASCADE,
    point_name VARCHAR(150) NOT NULL,
    landmark VARCHAR(200),
    address TEXT,
    contact_number VARCHAR(30),
    arrival_time TIMESTAMP WITH TIME ZONE NOT NULL,
    time_formatted VARCHAR(30) NOT NULL,
    display_order INTEGER DEFAULT 1,
    latitude NUMERIC(10, 6),
    longitude NUMERIC(10, 6),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. Bus Seat Locks (Concurrency control - 10 minutes hold)
CREATE TABLE IF NOT EXISTS public.bus_seat_locks (
    id SERIAL PRIMARY KEY,
    trip_id INTEGER REFERENCES public.bus_trips(id) ON DELETE CASCADE NOT NULL,
    seat_id INTEGER REFERENCES public.bus_seats(id) ON DELETE CASCADE NOT NULL,
    user_id INTEGER REFERENCES public.login_auth(id) ON DELETE CASCADE,
    lock_token VARCHAR(100) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(trip_id, seat_id)
);

-- 9. Bus Promos & Coupons
CREATE TABLE IF NOT EXISTS public.bus_promos (
    id SERIAL PRIMARY KEY,
    promo_code VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) DEFAULT 'percentage', -- 'percentage', 'flat'
    discount_value NUMERIC(10, 2) NOT NULL,
    min_booking_amount NUMERIC(10, 2) DEFAULT 300.00,
    max_discount_amount NUMERIC(10, 2) DEFAULT 250.00,
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. Bus Bookings
CREATE TABLE IF NOT EXISTS public.bus_bookings (
    id SERIAL PRIMARY KEY,
    booking_code VARCHAR(50) UNIQUE NOT NULL, -- 'TIC-BUS-2026-XXXXXX'
    pnr_number VARCHAR(50) UNIQUE NOT NULL,   -- 'PNR7481920'
    user_id INTEGER REFERENCES public.login_auth(id) ON DELETE CASCADE NOT NULL,
    trip_id INTEGER REFERENCES public.bus_trips(id) ON DELETE CASCADE NOT NULL,
    bus_id INTEGER REFERENCES public.buses(id) ON DELETE CASCADE NOT NULL,
    boarding_point_id INTEGER REFERENCES public.boarding_points(id) ON DELETE SET NULL,
    dropping_point_id INTEGER REFERENCES public.dropping_points(id) ON DELETE SET NULL,
    total_seats INTEGER NOT NULL,
    base_fare_amount NUMERIC(10, 2) NOT NULL,
    tax_amount NUMERIC(10, 2) DEFAULT 0.00, -- 5% GST
    convenience_fee NUMERIC(10, 2) DEFAULT 25.00,
    discount_amount NUMERIC(10, 2) DEFAULT 0.00,
    promo_code VARCHAR(50),
    total_amount NUMERIC(10, 2) NOT NULL,
    payment_status VARCHAR(30) DEFAULT 'completed', -- 'pending', 'completed', 'failed', 'refunded'
    booking_status VARCHAR(30) DEFAULT 'confirmed', -- 'confirmed', 'cancelled', 'completed'
    contact_email VARCHAR(150) NOT NULL,
    contact_phone VARCHAR(30) NOT NULL,
    qr_code_data TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 11. Bus Booking Passengers
CREATE TABLE IF NOT EXISTS public.bus_booking_passengers (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER REFERENCES public.bus_bookings(id) ON DELETE CASCADE NOT NULL,
    seat_id INTEGER REFERENCES public.bus_seats(id) ON DELETE SET NULL,
    seat_number VARCHAR(15) NOT NULL,
    passenger_name VARCHAR(150) NOT NULL,
    age INTEGER NOT NULL,
    gender VARCHAR(20) NOT NULL, -- 'Male', 'Female', 'Other'
    seat_fare NUMERIC(10, 2) NOT NULL,
    seat_tier VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 12. Bus Booking Seats
CREATE TABLE IF NOT EXISTS public.bus_booking_seats (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER REFERENCES public.bus_bookings(id) ON DELETE CASCADE NOT NULL,
    seat_id INTEGER REFERENCES public.bus_seats(id) ON DELETE CASCADE NOT NULL,
    seat_number VARCHAR(15) NOT NULL,
    deck VARCHAR(10) DEFAULT 'lower',
    tier_name VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

-- 13. Bus Payments
CREATE TABLE IF NOT EXISTS public.bus_payments (
    id SERIAL PRIMARY KEY,
    payment_id VARCHAR(80) UNIQUE NOT NULL, -- 'PAY-BUS-XXXXXXXX'
    booking_id INTEGER REFERENCES public.bus_bookings(id) ON DELETE SET NULL,
    user_id INTEGER REFERENCES public.login_auth(id) ON DELETE CASCADE NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'INR',
    payment_method VARCHAR(50) NOT NULL, -- 'upi', 'credit_card', 'debit_card', 'netbanking', 'wallet'
    transaction_reference VARCHAR(120),
    status VARCHAR(30) DEFAULT 'completed', -- 'initiated', 'pending', 'completed', 'failed', 'refunded'
    failure_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP WITH TIME ZONE
);

-- 14. Bus Cancellations
CREATE TABLE IF NOT EXISTS public.bus_cancellations (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER REFERENCES public.bus_bookings(id) ON DELETE CASCADE NOT NULL,
    user_id INTEGER REFERENCES public.login_auth(id) ON DELETE CASCADE NOT NULL,
    cancellation_code VARCHAR(60) UNIQUE NOT NULL,
    cancellation_reason TEXT,
    refund_percentage NUMERIC(5, 2) NOT NULL, -- e.g. 90.00
    refund_amount NUMERIC(10, 2) NOT NULL,
    cancellation_fee NUMERIC(10, 2) DEFAULT 0.00,
    cancelled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 15. Bus Refunds
CREATE TABLE IF NOT EXISTS public.bus_refunds (
    id SERIAL PRIMARY KEY,
    refund_id VARCHAR(80) UNIQUE NOT NULL, -- 'REF-BUS-XXXXXXXX'
    cancellation_id INTEGER REFERENCES public.bus_cancellations(id) ON DELETE CASCADE NOT NULL,
    booking_id INTEGER REFERENCES public.bus_bookings(id) ON DELETE CASCADE NOT NULL,
    user_id INTEGER REFERENCES public.login_auth(id) ON DELETE CASCADE NOT NULL,
    refund_amount NUMERIC(10, 2) NOT NULL,
    refund_method VARCHAR(50) DEFAULT 'original_payment_source',
    refund_status VARCHAR(30) DEFAULT 'completed', -- 'initiated', 'processing', 'completed', 'failed'
    transaction_reference VARCHAR(120),
    initiated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_bus_trips_travel_date ON public.bus_trips(travel_date);
CREATE INDEX IF NOT EXISTS idx_bus_trips_route_id ON public.bus_trips(route_id);
CREATE INDEX IF NOT EXISTS idx_bus_trips_bus_id ON public.bus_trips(bus_id);
CREATE INDEX IF NOT EXISTS idx_bus_routes_source_dest ON public.bus_routes(source_city, destination_city);
CREATE INDEX IF NOT EXISTS idx_bus_seats_bus_id ON public.bus_seats(bus_id);
CREATE INDEX IF NOT EXISTS idx_bus_seat_locks_trip_id ON public.bus_seat_locks(trip_id);
CREATE INDEX IF NOT EXISTS idx_bus_seat_locks_expiry ON public.bus_seat_locks(expires_at);
CREATE INDEX IF NOT EXISTS idx_bus_bookings_user_id ON public.bus_bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bus_bookings_code ON public.bus_bookings(booking_code);
CREATE INDEX IF NOT EXISTS idx_bus_bookings_pnr ON public.bus_bookings(pnr_number);
CREATE INDEX IF NOT EXISTS idx_bus_payments_payment_id ON public.bus_payments(payment_id);
CREATE INDEX IF NOT EXISTS idx_bus_cancellations_booking ON public.bus_cancellations(booking_id);
CREATE INDEX IF NOT EXISTS idx_bus_refunds_booking ON public.bus_refunds(booking_id);
