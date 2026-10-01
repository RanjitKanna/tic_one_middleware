-- ==============================================================================
-- MOVIE BOOKING APP SCHEMA
-- ==============================================================================

-- 1. Cities
CREATE TABLE IF NOT EXISTS public.cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    is_popular BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Movies
CREATE TABLE IF NOT EXISTS public.movies (
    id SERIAL PRIMARY KEY,
    movie_code VARCHAR(50) UNIQUE NOT NULL,
    slug VARCHAR(120) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    subtitle VARCHAR(300),
    synopsis TEXT,
    genre VARCHAR(150) NOT NULL,
    language VARCHAR(100) NOT NULL,
    duration_mins INTEGER DEFAULT 120,
    certificate VARCHAR(20) DEFAULT 'UA',
    rating NUMERIC(3, 1) DEFAULT 0.0,
    rating_count VARCHAR(20) DEFAULT '0',
    image_url TEXT NOT NULL,
    banner_url TEXT,
    trailer_url TEXT,
    status VARCHAR(30) DEFAULT 'now_showing', -- 'now_showing', 'upcoming', 'ended'
    release_date DATE DEFAULT CURRENT_DATE,
    format VARCHAR(100) DEFAULT '2D / 3D / IMAX',
    badge_text VARCHAR(100),
    match_percent VARCHAR(20),
    is_trending BOOLEAN DEFAULT false,
    is_filling_fast BOOLEAN DEFAULT false,
    is_advance_booking_open BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Banners / Hero Carousel
CREATE TABLE IF NOT EXISTS public.banners (
    id SERIAL PRIMARY KEY,
    banner_code VARCHAR(50) UNIQUE NOT NULL,
    movie_id INTEGER REFERENCES public.movies(id) ON DELETE SET NULL,
    slug VARCHAR(120),
    title VARCHAR(200) NOT NULL,
    subtitle VARCHAR(300),
    image_url TEXT NOT NULL,
    rating NUMERIC(3, 1),
    rating_count VARCHAR(20),
    format VARCHAR(100),
    is_trending BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Trailers
CREATE TABLE IF NOT EXISTS public.trailers (
    id SERIAL PRIMARY KEY,
    trailer_code VARCHAR(50) UNIQUE NOT NULL,
    movie_id INTEGER REFERENCES public.movies(id) ON DELETE SET NULL,
    title VARCHAR(250) NOT NULL,
    subtitle VARCHAR(300),
    image_url TEXT NOT NULL,
    video_url TEXT,
    duration VARCHAR(20) DEFAULT '02:30',
    tag_label VARCHAR(100) DEFAULT 'Official Trailer',
    display_order INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Theaters
CREATE TABLE IF NOT EXISTS public.theaters (
    id SERIAL PRIMARY KEY,
    theater_code VARCHAR(50) UNIQUE NOT NULL,
    city_id INTEGER REFERENCES public.cities(id) ON DELETE CASCADE NOT NULL,
    name VARCHAR(200) NOT NULL,
    distance_info VARCHAR(100) DEFAULT '1.5 km away',
    landmark VARCHAR(150),
    address TEXT,
    formats VARCHAR(200) DEFAULT 'IMAX, Dolby Atmos, 4DX',
    latitude NUMERIC(10, 6),
    longitude NUMERIC(10, 6),
    is_fast_filling BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Screens
CREATE TABLE IF NOT EXISTS public.screens (
    id SERIAL PRIMARY KEY,
    theater_id INTEGER REFERENCES public.theaters(id) ON DELETE CASCADE NOT NULL,
    screen_name VARCHAR(100) NOT NULL,
    total_seats INTEGER DEFAULT 100,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Seats Layout per Screen
CREATE TABLE IF NOT EXISTS public.seats (
    id SERIAL PRIMARY KEY,
    screen_id INTEGER REFERENCES public.screens(id) ON DELETE CASCADE NOT NULL,
    row_label VARCHAR(5) NOT NULL, -- 'A', 'B', 'C', etc.
    seat_number INTEGER NOT NULL,   -- 1, 2, 3, etc.
    seat_identifier VARCHAR(15) NOT NULL, -- 'A1', 'A2', 'B5', etc.
    tier_name VARCHAR(50) DEFAULT 'Gold', -- 'Silver', 'Gold', 'Platinum', 'Recliner'
    seat_type VARCHAR(50) DEFAULT 'normal', -- 'normal', 'couple', 'wheelchair'
    multiplier NUMERIC(3, 2) DEFAULT 1.00,
    UNIQUE(screen_id, row_label, seat_number)
);

-- 8. Shows / Showtimes
CREATE TABLE IF NOT EXISTS public.shows (
    id SERIAL PRIMARY KEY,
    movie_id INTEGER REFERENCES public.movies(id) ON DELETE CASCADE NOT NULL,
    screen_id INTEGER REFERENCES public.screens(id) ON DELETE CASCADE NOT NULL,
    show_time TIMESTAMP WITH TIME ZONE NOT NULL,
    show_time_formatted VARCHAR(30) NOT NULL, -- '01:15 PM', '04:30 PM', etc.
    language VARCHAR(50) DEFAULT 'English',
    format VARCHAR(50) DEFAULT 'IMAX 3D',
    base_price NUMERIC(10, 2) DEFAULT 250.00,
    status VARCHAR(30) DEFAULT 'active', -- 'active', 'filling_fast', 'housefull', 'cancelled'
    is_fast_filling BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. Seat Locks (temporary hold during checkout to prevent double booking)
CREATE TABLE IF NOT EXISTS public.seat_locks (
    id SERIAL PRIMARY KEY,
    show_id INTEGER REFERENCES public.shows(id) ON DELETE CASCADE NOT NULL,
    seat_id INTEGER REFERENCES public.seats(id) ON DELETE CASCADE NOT NULL,
    user_id INTEGER REFERENCES public.login_auth(id) ON DELETE CASCADE,
    lock_token VARCHAR(100) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(show_id, seat_id)
);

-- 10. Bookings (Tickets)
CREATE TABLE IF NOT EXISTS public.bookings (
    id SERIAL PRIMARY KEY,
    booking_code VARCHAR(50) UNIQUE NOT NULL, -- 'TIC-2026-XXXXX'
    user_id INTEGER REFERENCES public.login_auth(id) ON DELETE CASCADE NOT NULL,
    show_id INTEGER REFERENCES public.shows(id) ON DELETE CASCADE NOT NULL,
    total_seats INTEGER NOT NULL,
    ticket_amount NUMERIC(10, 2) NOT NULL,
    convenience_fee NUMERIC(10, 2) DEFAULT 35.40,
    total_amount NUMERIC(10, 2) NOT NULL,
    payment_status VARCHAR(30) DEFAULT 'completed', -- 'pending', 'completed', 'failed', 'refunded'
    booking_status VARCHAR(30) DEFAULT 'confirmed', -- 'confirmed', 'cancelled', 'checked_in'
    qr_code_data TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 11. Booking Seats
CREATE TABLE IF NOT EXISTS public.booking_seats (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER REFERENCES public.bookings(id) ON DELETE CASCADE NOT NULL,
    seat_id INTEGER REFERENCES public.seats(id) ON DELETE CASCADE NOT NULL,
    seat_identifier VARCHAR(15) NOT NULL,
    tier_name VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_movies_status ON public.movies(status);
CREATE INDEX IF NOT EXISTS idx_movies_slug ON public.movies(slug);
CREATE INDEX IF NOT EXISTS idx_shows_movie_id ON public.shows(movie_id);
CREATE INDEX IF NOT EXISTS idx_shows_screen_id ON public.shows(screen_id);
CREATE INDEX IF NOT EXISTS idx_theaters_city_id ON public.theaters(city_id);
CREATE INDEX IF NOT EXISTS idx_seat_locks_expiry ON public.seat_locks(expires_at);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_code ON public.bookings(booking_code);
