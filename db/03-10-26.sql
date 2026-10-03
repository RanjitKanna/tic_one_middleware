--
-- PostgreSQL database dump
--

\restrict hATSpFsTt2l6v4Yqrobroc5OFGUmbEHhrj0yAlMV8nWnamQL8Nm8lyCF5sBshq9

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

-- Started on 2026-10-03 10:24:10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 230 (class 1259 OID 16536)
-- Name: banners; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.banners (
    id integer NOT NULL,
    banner_code character varying(50) NOT NULL,
    movie_id integer,
    slug character varying(120),
    title character varying(200) NOT NULL,
    subtitle character varying(300),
    image_url text NOT NULL,
    rating numeric(3,1),
    rating_count character varying(20),
    format character varying(100),
    is_trending boolean DEFAULT true,
    display_order integer DEFAULT 1,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.banners OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16535)
-- Name: banners_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.banners_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.banners_id_seq OWNER TO postgres;

--
-- TOC entry 5240 (class 0 OID 0)
-- Dependencies: 229
-- Name: banners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.banners_id_seq OWNED BY public.banners.id;


--
-- TOC entry 246 (class 1259 OID 16739)
-- Name: booking_seats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.booking_seats (
    id integer NOT NULL,
    booking_id integer NOT NULL,
    seat_id integer NOT NULL,
    seat_identifier character varying(15) NOT NULL,
    tier_name character varying(50) NOT NULL,
    price numeric(10,2) NOT NULL
);


ALTER TABLE public.booking_seats OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 16738)
-- Name: booking_seats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.booking_seats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.booking_seats_id_seq OWNER TO postgres;

--
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 245
-- Name: booking_seats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.booking_seats_id_seq OWNED BY public.booking_seats.id;


--
-- TOC entry 244 (class 1259 OID 16706)
-- Name: bookings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bookings (
    id integer NOT NULL,
    booking_code character varying(50) NOT NULL,
    user_id integer NOT NULL,
    show_id integer NOT NULL,
    total_seats integer NOT NULL,
    ticket_amount numeric(10,2) NOT NULL,
    convenience_fee numeric(10,2) DEFAULT 35.40,
    total_amount numeric(10,2) NOT NULL,
    payment_status character varying(30) DEFAULT 'completed'::character varying,
    booking_status character varying(30) DEFAULT 'confirmed'::character varying,
    qr_code_data text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.bookings OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16705)
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bookings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bookings_id_seq OWNER TO postgres;

--
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 243
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bookings_id_seq OWNED BY public.bookings.id;


--
-- TOC entry 226 (class 1259 OID 16492)
-- Name: cities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cities (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    is_popular boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.cities OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16491)
-- Name: cities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cities_id_seq OWNER TO postgres;

--
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 225
-- Name: cities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cities_id_seq OWNED BY public.cities.id;


--
-- TOC entry 220 (class 1259 OID 16416)
-- Name: login_auth; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.login_auth (
    id integer CONSTRAINT users_id_not_null NOT NULL,
    name character varying(100) CONSTRAINT users_name_not_null NOT NULL,
    email character varying(150) CONSTRAINT users_email_not_null NOT NULL,
    password_hash text CONSTRAINT users_password_hash_not_null NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    phone character varying(25)
);


ALTER TABLE public.login_auth OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16505)
-- Name: movies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.movies (
    id integer NOT NULL,
    movie_code character varying(50) NOT NULL,
    slug character varying(120) NOT NULL,
    title character varying(200) NOT NULL,
    subtitle character varying(300),
    synopsis text,
    genre character varying(150) NOT NULL,
    language character varying(100) NOT NULL,
    duration_mins integer DEFAULT 120,
    certificate character varying(20) DEFAULT 'UA'::character varying,
    rating numeric(3,1) DEFAULT 0.0,
    rating_count character varying(20) DEFAULT '0'::character varying,
    image_url text NOT NULL,
    banner_url text,
    trailer_url text,
    status character varying(30) DEFAULT 'now_showing'::character varying,
    release_date date DEFAULT CURRENT_DATE,
    format character varying(100) DEFAULT '2D / 3D / IMAX'::character varying,
    badge_text character varying(100),
    match_percent character varying(20),
    is_trending boolean DEFAULT false,
    is_filling_fast boolean DEFAULT false,
    is_advance_booking_open boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.movies OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16504)
-- Name: movies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.movies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.movies_id_seq OWNER TO postgres;

--
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 227
-- Name: movies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.movies_id_seq OWNED BY public.movies.id;


--
-- TOC entry 224 (class 1259 OID 16454)
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_tokens (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.password_reset_tokens OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16453)
-- Name: password_reset_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.password_reset_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.password_reset_tokens_id_seq OWNER TO postgres;

--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 223
-- Name: password_reset_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.password_reset_tokens_id_seq OWNED BY public.password_reset_tokens.id;


--
-- TOC entry 222 (class 1259 OID 16432)
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refresh_tokens (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.refresh_tokens OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16431)
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.refresh_tokens_id_seq OWNER TO postgres;

--
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 221
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.refresh_tokens_id_seq OWNED BY public.refresh_tokens.id;


--
-- TOC entry 236 (class 1259 OID 16609)
-- Name: screens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.screens (
    id integer NOT NULL,
    theater_id integer NOT NULL,
    screen_name character varying(100) NOT NULL,
    total_seats integer DEFAULT 100,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.screens OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16608)
-- Name: screens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.screens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.screens_id_seq OWNER TO postgres;

--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 235
-- Name: screens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.screens_id_seq OWNED BY public.screens.id;


--
-- TOC entry 242 (class 1259 OID 16676)
-- Name: seat_locks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seat_locks (
    id integer NOT NULL,
    show_id integer NOT NULL,
    seat_id integer NOT NULL,
    user_id integer,
    lock_token character varying(100) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.seat_locks OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 16675)
-- Name: seat_locks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seat_locks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seat_locks_id_seq OWNER TO postgres;

--
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 241
-- Name: seat_locks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seat_locks_id_seq OWNED BY public.seat_locks.id;


--
-- TOC entry 238 (class 1259 OID 16626)
-- Name: seats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seats (
    id integer NOT NULL,
    screen_id integer NOT NULL,
    row_label character varying(5) NOT NULL,
    seat_number integer NOT NULL,
    seat_identifier character varying(15) NOT NULL,
    tier_name character varying(50) DEFAULT 'Gold'::character varying,
    seat_type character varying(50) DEFAULT 'normal'::character varying,
    multiplier numeric(3,2) DEFAULT 1.00
);


ALTER TABLE public.seats OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16625)
-- Name: seats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seats_id_seq OWNER TO postgres;

--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 237
-- Name: seats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seats_id_seq OWNED BY public.seats.id;


--
-- TOC entry 240 (class 1259 OID 16648)
-- Name: shows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shows (
    id integer NOT NULL,
    movie_id integer NOT NULL,
    screen_id integer NOT NULL,
    show_time timestamp with time zone NOT NULL,
    show_time_formatted character varying(30) NOT NULL,
    language character varying(50) DEFAULT 'English'::character varying,
    format character varying(50) DEFAULT 'IMAX 3D'::character varying,
    base_price numeric(10,2) DEFAULT 250.00,
    status character varying(30) DEFAULT 'active'::character varying,
    is_fast_filling boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.shows OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16647)
-- Name: shows_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shows_id_seq OWNER TO postgres;

--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 239
-- Name: shows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shows_id_seq OWNED BY public.shows.id;


--
-- TOC entry 234 (class 1259 OID 16585)
-- Name: theaters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.theaters (
    id integer NOT NULL,
    theater_code character varying(50) NOT NULL,
    city_id integer NOT NULL,
    name character varying(200) NOT NULL,
    distance_info character varying(100) DEFAULT '1.5 km away'::character varying,
    landmark character varying(150),
    address text,
    formats character varying(200) DEFAULT 'IMAX, Dolby Atmos, 4DX'::character varying,
    latitude numeric(10,6),
    longitude numeric(10,6),
    is_fast_filling boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.theaters OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16584)
-- Name: theaters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.theaters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.theaters_id_seq OWNER TO postgres;

--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 233
-- Name: theaters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.theaters_id_seq OWNED BY public.theaters.id;


--
-- TOC entry 232 (class 1259 OID 16560)
-- Name: trailers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trailers (
    id integer NOT NULL,
    trailer_code character varying(50) NOT NULL,
    movie_id integer,
    title character varying(250) NOT NULL,
    subtitle character varying(300),
    image_url text NOT NULL,
    video_url text,
    duration character varying(20) DEFAULT '02:30'::character varying,
    tag_label character varying(100) DEFAULT 'Official Trailer'::character varying,
    display_order integer DEFAULT 1,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.trailers OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16559)
-- Name: trailers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.trailers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.trailers_id_seq OWNER TO postgres;

--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 231
-- Name: trailers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.trailers_id_seq OWNED BY public.trailers.id;


--
-- TOC entry 219 (class 1259 OID 16415)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.login_auth.id;


--
-- TOC entry 4942 (class 2604 OID 16539)
-- Name: banners id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.banners ALTER COLUMN id SET DEFAULT nextval('public.banners_id_seq'::regclass);


--
-- TOC entry 4979 (class 2604 OID 16742)
-- Name: booking_seats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_seats ALTER COLUMN id SET DEFAULT nextval('public.booking_seats_id_seq'::regclass);


--
-- TOC entry 4974 (class 2604 OID 16709)
-- Name: bookings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings ALTER COLUMN id SET DEFAULT nextval('public.bookings_id_seq'::regclass);


--
-- TOC entry 4927 (class 2604 OID 16495)
-- Name: cities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cities ALTER COLUMN id SET DEFAULT nextval('public.cities_id_seq'::regclass);


--
-- TOC entry 4921 (class 2604 OID 16419)
-- Name: login_auth id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_auth ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4930 (class 2604 OID 16508)
-- Name: movies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movies ALTER COLUMN id SET DEFAULT nextval('public.movies_id_seq'::regclass);


--
-- TOC entry 4925 (class 2604 OID 16457)
-- Name: password_reset_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens ALTER COLUMN id SET DEFAULT nextval('public.password_reset_tokens_id_seq'::regclass);


--
-- TOC entry 4923 (class 2604 OID 16435)
-- Name: refresh_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('public.refresh_tokens_id_seq'::regclass);


--
-- TOC entry 4958 (class 2604 OID 16612)
-- Name: screens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.screens ALTER COLUMN id SET DEFAULT nextval('public.screens_id_seq'::regclass);


--
-- TOC entry 4972 (class 2604 OID 16679)
-- Name: seat_locks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seat_locks ALTER COLUMN id SET DEFAULT nextval('public.seat_locks_id_seq'::regclass);


--
-- TOC entry 4961 (class 2604 OID 16629)
-- Name: seats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seats ALTER COLUMN id SET DEFAULT nextval('public.seats_id_seq'::regclass);


--
-- TOC entry 4965 (class 2604 OID 16651)
-- Name: shows id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shows ALTER COLUMN id SET DEFAULT nextval('public.shows_id_seq'::regclass);


--
-- TOC entry 4953 (class 2604 OID 16588)
-- Name: theaters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theaters ALTER COLUMN id SET DEFAULT nextval('public.theaters_id_seq'::regclass);


--
-- TOC entry 4947 (class 2604 OID 16563)
-- Name: trailers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trailers ALTER COLUMN id SET DEFAULT nextval('public.trailers_id_seq'::regclass);


--
-- TOC entry 5218 (class 0 OID 16536)
-- Dependencies: 230
-- Data for Name: banners; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.banners (id, banner_code, movie_id, slug, title, subtitle, image_url, rating, rating_count, format, is_trending, display_order, is_active, created_at) FROM stdin;
1	BAN_001	6	dune-part-two	DUNE: PART TWO	Sci-Fi • 2h 46m • Rated PG-13 • Directed by Denis Villeneuve	https://i.pinimg.com/736x/ec/53/e6/ec53e6a1733537aba98ef4198c1c1af0.jpg	8.8	150K	IMAX 3D	t	1	t	2026-10-01 11:44:52.727765+05:30
2	BAN_002	14	leo	LEO	Action / Crime • 2h 44m • Rated UA16+ • Directed by Lokesh Kanagaraj	https://i.pinimg.com/1200x/67/44/ad/6744ad32c42af773315935a926493b99.jpg	8.1	190K	IMAX / Dolby Atmos	t	2	t	2026-10-01 11:44:52.727765+05:30
5	BAN_003	20	kalki-2898-ad	KALKI 2898 AD	Sci-Fi / Action • 3h 01m • Rated UA • Directed by Nag Ashwin	https://i.pinimg.com/1200x/e7/c9/b2/e7c9b243526feb237724693a7157ac13.jpg	8.6	240K	IMAX 3D	t	3	t	2026-10-01 12:27:57.496608+05:30
6	BAN_004	24	manjummel-boys	MANJUMMEL BOYS	Survival / Thriller • 2h 15m • Rated U • Directed by Chidambaram	https://i.pinimg.com/736x/fb/e8/3d/fbe83d23bb26082243a59932458a2b8e.jpg	8.9	160K	Dolby Atmos	t	4	t	2026-10-01 12:27:57.496608+05:30
\.


--
-- TOC entry 5234 (class 0 OID 16739)
-- Dependencies: 246
-- Data for Name: booking_seats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.booking_seats (id, booking_id, seat_id, seat_identifier, tier_name, price) FROM stdin;
13	5	892	F4	Platinum Recliner	608.00
14	5	893	F5	Platinum Recliner	608.00
15	6	894	F6	Platinum Recliner	608.00
16	6	896	F8	Platinum Recliner	608.00
\.


--
-- TOC entry 5232 (class 0 OID 16706)
-- Dependencies: 244
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bookings (id, booking_code, user_id, show_id, total_seats, ticket_amount, convenience_fee, total_amount, payment_status, booking_status, qr_code_data, created_at) FROM stdin;
5	TIC-2026-518099	16	101	2	1216.00	35.40	1251.40	completed	confirmed	eyJjb2RlIjoiVElDLTIwMjYtNTE4MDk5Iiwic2hvd0lkIjoxMDEsInVzZXJJZCI6MTYsInNlYXRzIjpbIkY0IiwiRjUiXSwiaXNzdWVkQXQiOiIyMDI2LTEwLTAxVDE4OjQxOjQ2Ljg2MzMwMSJ9	2026-10-01 18:41:46.864998+05:30
6	TIC-2026-446405	16	101	2	1216.00	35.40	1251.40	completed	confirmed	eyJjb2RlIjoiVElDLTIwMjYtNDQ2NDA1Iiwic2hvd0lkIjoxMDEsInVzZXJJZCI6MTYsInNlYXRzIjpbIkY2IiwiRjgiXSwiaXNzdWVkQXQiOiIyMDI2LTEwLTAxVDE4OjQyOjAzLjYzMjY5OSJ9	2026-10-01 18:42:03.634454+05:30
\.


--
-- TOC entry 5214 (class 0 OID 16492)
-- Dependencies: 226
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cities (id, name, is_popular, created_at) FROM stdin;
1	Mumbai	t	2026-10-01 17:44:29.321271+05:30
2	Bengaluru	t	2026-10-01 17:44:29.321271+05:30
3	Chennai	t	2026-10-01 17:44:29.321271+05:30
4	Hyderabad	t	2026-10-01 17:44:29.321271+05:30
5	Pune	t	2026-10-01 17:44:29.321271+05:30
6	Kolkata	t	2026-10-01 17:44:29.321271+05:30
7	Kochi	t	2026-10-01 17:44:29.321271+05:30
\.


--
-- TOC entry 5208 (class 0 OID 16416)
-- Dependencies: 220
-- Data for Name: login_auth; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.login_auth (id, name, email, password_hash, created_at, phone) FROM stdin;
1	Ranjith	ranjith@example.com	$2a$10$hAQa8yobKyvSciLEXqqCIuW3LsS1EDIbRaMGNpvLIsYMYca34nm7y	2026-09-24 07:26:53.122521	\N
4	Ranjith	ranjith@45645example.com	$2a$10$14LJrLFJxBeXuV979PhOreOtuJTyu4njl8Pe05T2K/5Nl9.1U4bR6	2026-09-24 09:09:23.714938	\N
10	Ranjith	ranjith@45645exatymple.com	$2a$10$ta.phRXThTJlR4h2XPMSxuqJWYjqwhg.YLsxEBPzoKZZ/7A4nGg/a	2026-09-24 11:38:14.374385	\N
11	Ranjith	ranjith@dfgsfgdsfdsg.com	$2a$10$RrB36FpkgAf9NgfW1vZnVeI4QjxcVacN7lSUk67anF0hrSQ4PDgua	2026-09-24 11:46:28.012256	\N
14	Rdaseanjith	ranjith@rtere.com	$2a$10$W8r89TqDC3bLvo2lqtfAB.TMayouNZpjedKhJL9E0l3mEOsT5I0/e	2026-09-25 06:32:39.356213	\N
16	Ranjith	test@gmail.com	$2a$10$4v.LFVZc1PNQxUi9i/EUWOsOGaheI3j/tviAz2gFkS9646HLWJqVG	2026-09-30 13:53:23.410331	\N
17	123	123@gmail.com	$2a$10$CUEJ1XQ00GpedIfSC8B4lOclpvvZNDeUoPWWW6lzEgLPPi1cRxKry	2026-09-30 14:08:41.15797	\N
18	Sam	sam@gamil.com	$2a$10$fvRR1it4f0l1qfmIFjGxne2RxU8RrxT6.GiMjCbeJ7ukatLloIQo.	2026-09-30 14:21:46.919369	9876543210
19	9876543210	9876543210@gmail.com	$2a$10$F1sORmcITTXIfILNh791Su16ncRbl8oefoXIggZN2nyLtRKb7VfP2	2026-09-30 14:24:36.889128	\N
22	Test	testt@gmail.com	$2a$10$qlZfIUEZbCbyqOsvhhxLtOCOo/GfOx3ZwLJWXYMEcCEg7mc9P4VDS	2026-10-01 04:05:24.927152	+919876543210
23	Test	tes4tt@gmail.com	$2a$10$QozvblwoDdE9Xyli1AqT3.QisPEBQOuq7OCZK3EJ63I6MeATNaU6W	2026-10-01 04:06:36.008661	+919876543215
20	2134	1234@gmail.com	$2a$10$KuCPdPtbtaU2IdgUyAdCFOtiL.0Mn.uPpP/kGsHReWhMuubmni/XC	2026-09-30 14:55:08.151969	+919876543212
24	Test User	testuser@example.com	$2a$10$UOTmKknKt.aVIBfl9GphqOu62F6zrcYL2okwv4IUX5IfqndI6tS5G	2026-10-01 06:21:03.723665	9876543219
25	demo	demo@gmail.copm	$2a$10$cFbcRbLNIcB0C6bKQWc3oOsiJoGlbER3SfunmCy/JBz4bnqDR.4zy	2026-10-01 07:21:50.768473	+917894561300
\.


--
-- TOC entry 5216 (class 0 OID 16505)
-- Dependencies: 228
-- Data for Name: movies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.movies (id, movie_code, slug, title, subtitle, synopsis, genre, language, duration_mins, certificate, rating, rating_count, image_url, banner_url, trailer_url, status, release_date, format, badge_text, match_percent, is_trending, is_filling_fast, is_advance_booking_open, created_at) FROM stdin;
1	MOV_CYBER_2026	cyberpunk-odyssey-2026	CYBERPUNK: ODYSSEY	Sci-Fi • 2h 48m • Rated R • Directed by Denis Villeneuve	In a neo-futuristic metropolis, an augmented detective uncovers a conspiracy that threatens the fragile boundary between synthetic intelligence and human consciousness.	Sci-Fi / Action	English	168	Rated R	9.6	120K	https://lh3.googleusercontent.com/aida-public/AB6AXuBGkHApAjlxaiOuTN0L4bMbZVg_UsXzeviYQSoOQgaIUYb5TOB4lX2CNK9mPiu6KPQmBFqoXOQvvZc2Sj7vMs1o6nSJY-LD1fH1DIw4imYRlbpiQtm7azLTOTyrygTD0PfkxMTP27YBFdN02GDKT9wdcbhzmeg-OiHrMhwhO0iw8exlZUWXmIxE6DNFSF8HmSuqyAOJmuDXROIaweU54gav7VX5ZvzYozD4ZD36tf8kF0fP8LFpcbY	https://lh3.googleusercontent.com/aida-public/AB6AXuBGkHApAjlxaiOuTN0L4bMbZVg_UsXzeviYQSoOQgaIUYb5TOB4lX2CNK9mPiu6KPQmBFqoXOQvvZc2Sj7vMs1o6nSJY-LD1fH1DIw4imYRlbpiQtm7azLTOTyrygTD0PfkxMTP27YBFdN02GDKT9wdcbhzmeg-OiHrMhwhO0iw8exlZUWXmIxE6DNFSF8HmSuqyAOJmuDXROIaweU54gav7VX5ZvzYozD4ZD36tf8kF0fP8LFpcbY	\N	now_showing	2026-09-15	IMAX 70MM	Trending #1	99% Match	t	t	f	2026-10-01 11:44:52.724611+05:30
2	MOV_DUNE3_2026	dune-part-three-2026	DUNE: PART THREE	Sci-Fi • 3h 02m • Rated PG-13 • Directed by Denis Villeneuve	Paul Atreides confronts the galactic jihad unleashed across the cosmos as prophecy and reality clash on Arrakis.	Sci-Fi / Adventure	English	182	PG-13	9.4	85K	https://lh3.googleusercontent.com/aida-public/AB6AXuBaHX4H0QA72R5wqiDSV2k_Po7b6V4Cz_PAtIHJ0F4tmsaC7UWP2MIYIGRr2tyRWXs4eJ9fnk46Jh__VV7d3d7lal-FHCK0KBo8WDG2qApnAcCfNKeOsll80uAoP2Gmh50eAzy19rlgJkMnhXcri3CRUe3u6kJNFcrSMlqp6TyknjKd27o-2Q-C2_DAi6cW6SRfFUmPGrcqoWossWEDoU3EXy-nmqzqdwHgfBqlHf6UQDWab0ALpsk	https://lh3.googleusercontent.com/aida-public/AB6AXuBaHX4H0QA72R5wqiDSV2k_Po7b6V4Cz_PAtIHJ0F4tmsaC7UWP2MIYIGRr2tyRWXs4eJ9fnk46Jh__VV7d3d7lal-FHCK0KBo8WDG2qApnAcCfNKeOsll80uAoP2Gmh50eAzy19rlgJkMnhXcri3CRUe3u6kJNFcrSMlqp6TyknjKd27o-2Q-C2_DAi6cW6SRfFUmPGrcqoWossWEDoU3EXy-nmqzqdwHgfBqlHf6UQDWab0ALpsk	\N	now_showing	2026-09-20	DOLBY ATMOS	Critically Acclaimed	96% Match	t	f	f	2026-10-01 11:44:52.724611+05:30
3	MOV_SINGULARITY_2026	singularity-horizon	Singularity Horizon	Action / Sci-Fi • 2h 15m • Rated UA16+	An elite deep-space salvage crew discovers a derelict vessel trapped at the edge of an artificial event horizon.	Action / Sci-Fi	English	135	UA16+	9.2	45K	https://lh3.googleusercontent.com/aida-public/AB6AXuBGkHApAjlxaiOuTN0L4bMbZVg_UsXzeviYQSoOQgaIUYb5TOB4lX2CNK9mPiu6KPQmBFqoXOQvvZc2Sj7vMs1o6nSJY-LD1fH1DIw4imYRlbpiQtm7azLTOTyrygTD0PfkxMTP27YBFdN02GDKT9wdcbhzmeg-OiHrMhwhO0iw8exlZUWXmIxE6DNFSF8HmSuqyAOJmuDXROIaweU54gav7VX5ZvzYozD4ZD36tf8kF0fP8LFpcbY	https://lh3.googleusercontent.com/aida-public/AB6AXuBGkHApAjlxaiOuTN0L4bMbZVg_UsXzeviYQSoOQgaIUYb5TOB4lX2CNK9mPiu6KPQmBFqoXOQvvZc2Sj7vMs1o6nSJY-LD1fH1DIw4imYRlbpiQtm7azLTOTyrygTD0PfkxMTP27YBFdN02GDKT9wdcbhzmeg-OiHrMhwhO0iw8exlZUWXmIxE6DNFSF8HmSuqyAOJmuDXROIaweU54gav7VX5ZvzYozD4ZD36tf8kF0fP8LFpcbY	\N	now_showing	2026-09-28	IMAX 3D	Filling Fast	98% Match	f	t	f	2026-10-01 11:44:52.724611+05:30
4	MOV_SHADOWS_PRAGUE_2026	shadows-of-prague	Shadows of Prague	Mystery / Thriller • 2h 05m • Rated A	A noir mystery tracing international espionage across the foggy cobblestone bridges of historic Prague.	Mystery / Thriller	English	125	A	8.8	28K	https://lh3.googleusercontent.com/aida-public/AB6AXuDCQd5U6h8dK_J_sA4iWf8Hl4q64a8vQj_FkM8kPqS0j7oK-XgNqV12N8-L9e-K3pW4sF5t7u6vY8rZ_9xW12019-3829104-9218204-9812401	https://lh3.googleusercontent.com/aida-public/AB6AXuDCQd5U6h8dK_J_sA4iWf8Hl4q64a8vQj_FkM8kPqS0j7oK-XgNqV12N8-L9e-K3pW4sF5t7u6vY8rZ_9xW12019-3829104-9218204-9812401	\N	now_showing	2026-09-25	Dolby Vision	Dolby Vision	92% Match	f	f	f	2026-10-01 11:44:52.724611+05:30
5	MOV_AVATAR3_2026	avatar-fire-and-ash	AVATAR: FIRE & ASH	Sci-Fi • Adventure • Directed by James Cameron	Jake Sully and Neytiri travel to unexplored volcanic domains of Pandora, meeting the fiery Ash People tribe.	Sci-Fi • Adventure	English	195	UA16+	9.8	500K	https://lh3.googleusercontent.com/aida-public/AB6AXuBGkHApAjlxaiOuTN0L4bMbZVg_UsXzeviYQSoOQgaIUYb5TOB4lX2CNK9mPiu6KPQmBFqoXOQvvZc2Sj7vMs1o6nSJY-LD1fH1DIw4imYRlbpiQtm7azLTOTyrygTD0PfkxMTP27YBFdN02GDKT9wdcbhzmeg-OiHrMhwhO0iw8exlZUWXmIxE6DNFSF8HmSuqyAOJmuDXROIaweU54gav7VX5ZvzYozD4ZD36tf8kF0fP8LFpcbY	https://lh3.googleusercontent.com/aida-public/AB6AXuBGkHApAjlxaiOuTN0L4bMbZVg_UsXzeviYQSoOQgaIUYb5TOB4lX2CNK9mPiu6KPQmBFqoXOQvvZc2Sj7vMs1o6nSJY-LD1fH1DIw4imYRlbpiQtm7azLTOTyrygTD0PfkxMTP27YBFdN02GDKT9wdcbhzmeg-OiHrMhwhO0iw8exlZUWXmIxE6DNFSF8HmSuqyAOJmuDXROIaweU54gav7VX5ZvzYozD4ZD36tf8kF0fP8LFpcbY	\N	upcoming	2026-12-19	IMAX 3D Laser	Advance Open	99% Anticipation	t	f	t	2026-10-01 11:44:52.724611+05:30
6	MOV_DUNE2_2024	dune-part-two	Dune: Part Two	Sci-Fi • 2h 46m • Rated PG-13 • Directed by Denis Villeneuve	Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.	Action / Sci-Fi	English	166	PG-13	8.8	150K	https://i.pinimg.com/736x/ec/53/e6/ec53e6a1733537aba98ef4198c1c1af0.jpg	https://i.pinimg.com/736x/ec/53/e6/ec53e6a1733537aba98ef4198c1c1af0.jpg	\N	now_showing	2024-03-01	IMAX 3D	IMAX 3D	98% Match	t	t	f	2026-10-01 12:27:57.492467+05:30
7	MOV_DEADPOOL_WOLV_2024	deadpool-and-wolverine	Deadpool & Wolverine	Action / Comedy • 2h 08m • Rated R • Directed by Shawn Levy	Deadpool is offered a place in the Marvel Cinematic Universe by the Time Variance Authority, but instead recruits a variant of Wolverine to save his universe.	Action / Comedy	English	128	Rated R	8.5	130K	https://i.pinimg.com/736x/31/13/14/311314e91ce4cfa69b7988df690ffb2b.jpg	https://i.pinimg.com/736x/31/13/14/311314e91ce4cfa69b7988df690ffb2b.jpg	\N	now_showing	2024-07-26	DOLBY ATMOS	Filling Fast	96% Match	t	t	f	2026-10-01 12:27:57.492467+05:30
8	MOV_OPPENHEIMER_2023	oppenheimer	Oppenheimer	Biography / Drama • 3h 00m • Rated R • Directed by Christopher Nolan	The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb.	Biography / Drama	English	180	Rated R	8.9	220K	https://i.pinimg.com/736x/ba/31/b2/ba31b22d9a89a4c0fcc67fd7009fc795.jpg	https://i.pinimg.com/736x/ba/31/b2/ba31b22d9a89a4c0fcc67fd7009fc795.jpg	\N	now_showing	2023-07-21	IMAX 70MM	Dolby Vision	95% Match	t	f	f	2026-10-01 12:27:57.492467+05:30
9	MOV_AVATAR2_2022	avatar-the-way-of-water	Avatar: The Way of Water	Sci-Fi / Adventure • 3h 12m • Rated PG-13 • Directed by James Cameron	Jake Sully lives with his newfound family formed on the extrasolar moon Pandora. Once a familiar threat returns to finish what was previously started, Jake must work with Neytiri and the army of the Na'vi race to protect their home.	Sci-Fi / Adventure	English	192	PG-13	7.9	180K	https://i.pinimg.com/736x/ba/53/60/ba536014bc2e0327270ec3ebdb7abff9.jpg	https://i.pinimg.com/736x/ba/53/60/ba536014bc2e0327270ec3ebdb7abff9.jpg	\N	now_showing	2022-12-16	4DX 3D	4DX	90% Match	f	f	f	2026-10-01 12:27:57.492467+05:30
10	MOV_JOHNWICK4_2023	john-wick-chapter-4	John Wick: Chapter 4	Action / Thriller • 2h 49m • Rated R • Directed by Chad Stahelski	John Wick uncovers a path to defeating The High Table. But before he can earn his freedom, Wick must face off against a new enemy with powerful alliances across the globe.	Action / Thriller	English	169	Rated R	8.4	95K	https://i.pinimg.com/736x/c7/69/95/c7699589f93e08b8b96605e2ca3993a9.jpg	https://i.pinimg.com/736x/c7/69/95/c7699589f93e08b8b96605e2ca3993a9.jpg	\N	now_showing	2023-03-24	DOLBY ATMOS	Must Watch	92% Match	f	t	f	2026-10-01 12:27:57.492467+05:30
11	MOV_STREE2_2024	stree-2	Stree 2	Horror / Comedy • 2h 29m • Rated UA16+ • Directed by Amar Kaushik	The town of Chanderi is being haunted again, this time by a headless entity named Sarkata who is abducting progressive women.	Horror / Comedy	Hindi	149	UA16+	8.2	110K	https://i.pinimg.com/1200x/52/4a/0b/524a0b94987b696e5b9a70e514e02e89.jpg	https://i.pinimg.com/1200x/52/4a/0b/524a0b94987b696e5b9a70e514e02e89.jpg	\N	now_showing	2024-08-15	2D / Dolby Atmos	Blockbuster	94% Match	t	t	f	2026-10-01 12:27:57.492467+05:30
12	MOV_JAWAN_2023	jawan	Jawan	Action / Thriller • 2h 49m • Rated UA • Directed by Atlee	A high-octane action thriller which outlines the emotional journey of a man who is set to rectify the wrongs in the society.	Action / Thriller	Hindi	169	UA	7.8	140K	https://i.pinimg.com/736x/9c/f1/9c/9cf19c40df2598d150d6e5cd6f9d0b58.jpg	https://i.pinimg.com/736x/9c/f1/9c/9cf19c40df2598d150d6e5cd6f9d0b58.jpg	\N	now_showing	2023-09-07	IMAX / Dolby Atmos	Dolby Atmos	89% Match	f	f	f	2026-10-01 12:27:57.492467+05:30
13	MOV_PATHAAN_2023	pathaan	Pathaan	Action / Spy • 2h 26m • Rated UA • Directed by Siddharth Anand	An Indian RAW agent takes on a rogue former agent and the private terrorist outfit Outfit X aiming to unleash biological warfare.	Action / Spy	Hindi	146	UA	7.6	105K	https://i.pinimg.com/736x/75/9a/e7/759ae7145996c2e84ec479bc902e1d4e.jpg	https://i.pinimg.com/736x/75/9a/e7/759ae7145996c2e84ec479bc902e1d4e.jpg	\N	now_showing	2023-01-25	IMAX 2D	Trending	85% Match	f	f	f	2026-10-01 12:27:57.492467+05:30
14	MOV_LEO_2023	leo	Leo	Action / Crime • 2h 44m • Rated UA16+ • Directed by Lokesh Kanagaraj	Parthiban, a mild-mannered cafe owner in Himachal Pradesh, is pursued by dangerous gangsters who suspect him to be their estranged kin Leo Das.	Action / Crime	Tamil	164	UA16+	8.1	190K	https://i.pinimg.com/1200x/67/44/ad/6744ad32c42af773315935a926493b99.jpg	https://i.pinimg.com/1200x/67/44/ad/6744ad32c42af773315935a926493b99.jpg	\N	now_showing	2023-10-19	IMAX / Dolby Atmos	Filling Fast	97% Match	t	t	f	2026-10-01 12:27:57.492467+05:30
15	MOV_JAILER_2023	jailer	Jailer	Action / Comedy • 2h 48m • Rated UA • Directed by Nelson Dilipkumar	A retired jailer goes on a manhunt to find his son's killers, unraveling high-stakes criminal syndicates with legendary swagger.	Action / Comedy	Tamil	168	UA	8.3	170K	https://i.pinimg.com/736x/91/7f/44/917f44b1d81e5ebabf48ef399404ead0.jpg	https://i.pinimg.com/736x/91/7f/44/917f44b1d81e5ebabf48ef399404ead0.jpg	\N	now_showing	2023-08-10	Dolby Atmos	Blockbuster	95% Match	t	f	f	2026-10-01 12:27:57.492467+05:30
16	MOV_THEGOAT_2024	the-goat	The Greatest of All Time	Action / Sci-Fi • 3h 03m • Rated UA • Directed by Venkat Prabhu	An elite field agent and former leader of the Special Anti-Terrorist Squad is summoned for a perilous mission that pits him against his own past.	Action / Sci-Fi	Tamil	183	UA	7.9	115K	https://i.pinimg.com/736x/68/d8/ce/68d8ce8f9a925f5f068d97e96078612e.jpg	https://i.pinimg.com/736x/68/d8/ce/68d8ce8f9a925f5f068d97e96078612e.jpg	\N	now_showing	2024-09-05	IMAX 2D	IMAX	91% Match	t	t	f	2026-10-01 12:27:57.492467+05:30
17	MOV_VIKRAM_2022	vikram	Vikram	Action / Thriller • 2h 55m • Rated UA • Directed by Lokesh Kanagaraj	A high-ranking special investigator tracks a masked vigilante group carrying out executions of corrupt drug lords.	Action / Thriller	Tamil	175	UA	8.8	210K	https://i.pinimg.com/1200x/e1/6d/f6/e16df60fcc3eab0e291c54bfaece748c.jpg	https://i.pinimg.com/1200x/e1/6d/f6/e16df60fcc3eab0e291c54bfaece748c.jpg	\N	now_showing	2022-06-03	Dolby Atmos	Dolby Atmos	98% Match	t	f	f	2026-10-01 12:27:57.492467+05:30
18	MOV_PS1_2022	ponniyin-selvan-1	Ponniyin Selvan: I	Historical / Drama • 2h 47m • Rated UA • Directed by Mani Ratnam	Vandiyathevan sets out to cross the Chola land to deliver a message from Crown Prince Aditha Karikalan amid palace conspiracies.	Historical / Drama	Tamil	167	UA	8.0	130K	https://i.pinimg.com/1200x/37/c5/27/37c5271179908f1921b41f77544a0e19.jpg	https://i.pinimg.com/1200x/37/c5/27/37c5271179908f1921b41f77544a0e19.jpg	\N	now_showing	2022-09-30	EPIQ / IMAX	EPIQ	88% Match	f	f	f	2026-10-01 12:27:57.492467+05:30
19	MOV_CAPTMILLER_2024	captain-miller	Captain Miller	Action / Period • 2h 37m • Rated UA16+ • Directed by Arun Matheswaran	A former British army soldier wages war against British oppressors and feudal lords to protect his people's sacred heritage.	Action / Period	Tamil	157	UA16+	7.8	80K	https://i.pinimg.com/1200x/e8/c5/61/e8c561d35cf4ee215d72fa10082a4808.jpg	https://i.pinimg.com/1200x/e8/c5/61/e8c561d35cf4ee215d72fa10082a4808.jpg	\N	now_showing	2024-01-12	Dolby Atmos	Trending	86% Match	f	t	f	2026-10-01 12:27:57.492467+05:30
20	MOV_KALKI_2024	kalki-2898-ad	Kalki 2898 AD	Sci-Fi / Action • 3h 01m • Rated UA • Directed by Nag Ashwin	A modern avatar of Vishnu descends on earth to protect the world from evil forces in a dystopian future metropolis of Kasi.	Sci-Fi / Action	Telugu	181	UA	8.6	240K	https://i.pinimg.com/1200x/e7/c9/b2/e7c9b243526feb237724693a7157ac13.jpg	https://i.pinimg.com/1200x/e7/c9/b2/e7c9b243526feb237724693a7157ac13.jpg	\N	now_showing	2024-06-27	IMAX 3D	IMAX 3D	97% Match	t	t	f	2026-10-01 12:27:57.492467+05:30
21	MOV_SALAAR_2023	salaar-part-1	Salaar: Part 1 - Ceasefire	Action / Thriller • 2h 55m • Rated A • Directed by Prashanth Neel	A gang leader makes a promise to a dying friend and takes on other criminal gangs in the dystopian city-state of Khansaar.	Action / Thriller	Telugu	175	A	8.1	165K	https://i.pinimg.com/736x/b1/1c/0c/b11c0c8f4fe00ced09b813d6c53018db.jpg	https://i.pinimg.com/736x/b1/1c/0c/b11c0c8f4fe00ced09b813d6c53018db.jpg	\N	now_showing	2023-12-22	Dolby Vision	Dolby Vision	92% Match	f	f	f	2026-10-01 12:27:57.492467+05:30
22	MOV_RRR_2022	rrr	RRR	Action / Drama • 3h 07m • Rated UA • Directed by S.S. Rajamouli	A fearless warrior on a perilous mission comes face to face with a steely cop serving the British forces in 1920s India.	Action / Drama	Telugu	187	UA	9.0	310K	https://i.pinimg.com/736x/60/f6/43/60f6438d07c414f36db349badab2db9b.jpg	https://i.pinimg.com/736x/60/f6/43/60f6438d07c414f36db349badab2db9b.jpg	\N	now_showing	2022-03-25	IMAX 3D / Dolby Atmos	Oscar Winner	99% Match	t	f	f	2026-10-01 12:27:57.492467+05:30
23	MOV_PUSHPA2_2024	pushpa-2	Pushpa 2: The Rule	Action / Drama • 3h 10m • Rated UA • Directed by Sukumar	Pushpa Raj expands his red sandalwood smuggling empire while confronting Bhanwar Singh Shekhawat in a fiery showdown.	Action / Drama	Telugu	190	UA	8.5	180K	https://i.pinimg.com/736x/59/cc/c0/59ccc0fb92ca811abe487383a749e31b.jpg	https://i.pinimg.com/736x/59/cc/c0/59ccc0fb92ca811abe487383a749e31b.jpg	\N	now_showing	2024-12-05	Dolby Atmos	Filling Fast	94% Match	t	t	f	2026-10-01 12:27:57.492467+05:30
24	MOV_MANJUMMEL_2024	manjummel-boys	Manjummel Boys	Survival / Thriller • 2h 15m • Rated U • Directed by Chidambaram	A group of friends from Kochi embark on a trip to Kodaikanal where one of them falls into the infamous Guna Caves, triggering an extraordinary rescue operation.	Survival / Thriller	Malayalam	135	U	8.9	160K	https://i.pinimg.com/736x/fb/e8/3d/fbe83d23bb26082243a59932458a2b8e.jpg	https://i.pinimg.com/736x/fb/e8/3d/fbe83d23bb26082243a59932458a2b8e.jpg	\N	now_showing	2024-02-22	Dolby Atmos	Blockbuster	98% Match	t	t	f	2026-10-01 12:27:57.492467+05:30
25	MOV_AAVESHAM_2024	aavesham	Aavesham	Action / Comedy • 2h 38m • Rated UA • Directed by Jithu Madhavan	Three engineering students in Bengaluru find an eccentric local gangster named Ranga to help them seek revenge on their senior bullies.	Action / Comedy	Malayalam	158	UA	8.7	140K	https://i.pinimg.com/736x/3f/ff/d7/3fffd702d48852ede79ed71d04f36a2b.jpg	https://i.pinimg.com/736x/3f/ff/d7/3fffd702d48852ede79ed71d04f36a2b.jpg	\N	now_showing	2024-04-11	Dolby Atmos	Trending	96% Match	t	t	f	2026-10-01 12:27:57.492467+05:30
26	MOV_BRAMAYUGAM_2024	bramayugam	Bramayugam	Horror / Mystery • 2h 19m • Rated UA16+ • Directed by Rahul Sadasivan	A folk singer escaping slavery stumbles upon a mysterious ancestral mansion where the landlord harbors sinister occult secrets.	Horror / Mystery	Malayalam	139	UA16+	8.5	110K	https://i.pinimg.com/736x/ea/ba/83/eaba83c4b631bbc26b8c5a209055b214.jpg	https://i.pinimg.com/736x/ea/ba/83/eaba83c4b631bbc26b8c5a209055b214.jpg	\N	now_showing	2024-02-15	Dolby Atmos	Critically Acclaimed	93% Match	f	f	f	2026-10-01 12:27:57.492467+05:30
27	MOV_PREMALU_2024	premalu	Premalu	Romance / Comedy • 2h 36m • Rated U • Directed by Girish A.D.	Sachin pursues romance in Hyderabad while navigating GATE preparation, comedy of errors, and hilarious friendships.	Romance / Comedy	Malayalam	156	U	8.4	125K	https://i.pinimg.com/736x/18/3e/9d/183e9d1a8b3204a628a01a98756d0b57.jpg	https://i.pinimg.com/736x/18/3e/9d/183e9d1a8b3204a628a01a98756d0b57.jpg	\N	now_showing	2024-02-09	Dolby Atmos	Family Pick	90% Match	f	f	f	2026-10-01 12:27:57.492467+05:30
28	MOV_AADUJEEVITHAM_2024	aadujeevitham	Aadujeevitham (The Goat Life)	Drama / Survival • 2h 53m • Rated UA • Directed by Blessy	The harrowing true survival journey of Najeeb, an Indian migrant worker held hostage as a goatherd in the remote Saudi Arabian desert.	Drama / Survival	Malayalam	173	UA	8.8	135K	https://i.pinimg.com/1200x/8e/d4/1d/8ed41db765e8efabc87d2c300f9bb68c.jpg	https://i.pinimg.com/1200x/8e/d4/1d/8ed41db765e8efabc87d2c300f9bb68c.jpg	\N	now_showing	2024-03-28	Dolby Atmos	Dolby Atmos	95% Match	f	f	f	2026-10-01 12:27:57.492467+05:30
29	MOV_KGF2_2022	kgf-chapter-2	KGF: Chapter 2	Action / Drama • 2h 48m • Rated UA • Directed by Prashanth Neel	Rocky establishes total dominion over KGF while defending his throne against the relentless Adheera and government forces.	Action / Drama	Kannada	168	UA	8.9	290K	https://i.pinimg.com/736x/9c/a2/91/9ca291ac23b69ed5580cdf6e73fd913d.jpg	https://i.pinimg.com/736x/9c/a2/91/9ca291ac23b69ed5580cdf6e73fd913d.jpg	\N	now_showing	2022-04-14	IMAX / Dolby Atmos	All-Time Blockbuster	98% Match	t	f	f	2026-10-01 12:27:57.492467+05:30
30	MOV_KANTARA_2022	kantara	Kantara	Action / Thriller • 2h 28m • Rated UA • Directed by Rishab Shetty	In a coastal Karnataka forest village, a champion rebel confronts divine spirits, traditions, and an encroaching landlord.	Action / Thriller	Kannada	148	UA	9.1	250K	https://i.pinimg.com/736x/e4/be/a1/e4bea11b766f0a9c91d8c6217c16fff4.jpg	https://i.pinimg.com/736x/e4/be/a1/e4bea11b766f0a9c91d8c6217c16fff4.jpg	\N	now_showing	2022-09-30	Dolby Atmos	Must Watch	97% Match	t	t	f	2026-10-01 12:27:57.492467+05:30
31	MOV_SSE_2023	sapta-sagaradaache-ello	Sapta Sagaradaache Ello	Romance / Drama • 2h 22m • Rated UA • Directed by Hemanth M. Rao	Manu and Priya dream of a peaceful life together, until a fateful decision turns their world upside down.	Romance / Drama	Kannada	142	UA	8.3	75K	https://i.pinimg.com/1200x/7c/68/8f/7c688fcccd70f2f3d214e5c1ca38e086.jpg	https://i.pinimg.com/1200x/7c/68/8f/7c688fcccd70f2f3d214e5c1ca38e086.jpg	\N	now_showing	2023-09-01	Dolby 7.1	Trending	89% Match	f	f	f	2026-10-01 12:27:57.492467+05:30
\.


--
-- TOC entry 5212 (class 0 OID 16454)
-- Dependencies: 224
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_tokens (id, user_id, token_hash, expires_at, used_at, created_at) FROM stdin;
1	1	117fcf93b10971bc2421399e61b15112abff99cfa5e6f3e629a7518b73b2c224	2026-09-25 12:51:21.756244+05:30	\N	2026-09-25 12:36:21.760265+05:30
2	18	bbc8817e9861c09ee07a5e2397f0928866933e8e78db62a89826a139977b8bf8	2026-09-30 20:19:31.305879+05:30	\N	2026-09-30 20:09:31.306718+05:30
3	20	c9276d8bee5cd6a9d0eaed873b95e22d30f8790f8df7398ce560b8adad518c3a	2026-10-01 09:47:35.031917+05:30	2026-10-01 09:38:07.217314+05:30	2026-10-01 09:37:35.033349+05:30
\.


--
-- TOC entry 5210 (class 0 OID 16432)
-- Dependencies: 222
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refresh_tokens (id, user_id, token_hash, expires_at, revoked_at, created_at) FROM stdin;
1	1	385f9ff7d0ab8a8edf9c20fcfca7973e85d45a72addbeaa2b2cb678c4d7cc6e3	2026-10-24 17:26:26.732362+05:30	\N	2026-09-24 17:26:26.734709+05:30
2	1	839b15215690796dae2aa833f16c7e549f15aeac9c64e314f5259b1c16715685	2026-10-24 17:40:06.463184+05:30	\N	2026-09-24 17:40:06.46666+05:30
3	1	e2d512ae4c31fc7dd0f7f40c89ce19bf15e24e6585b1b9c3062b28cdc7428a22	2026-10-24 17:40:51.576281+05:30	\N	2026-09-24 17:40:51.577686+05:30
4	1	fe95af7cec42736ec75029e2e884dc8842e6b5567d45d5da0f5729573e7f6ce4	2026-10-24 17:40:52.885125+05:30	\N	2026-09-24 17:40:52.886805+05:30
5	1	ae6f6c18d277ffae18923381a1790119a84cc581fc08fc8284e63735e808f959	2026-10-24 17:41:48.803113+05:30	\N	2026-09-24 17:41:48.804508+05:30
6	1	f497dd471ea5d13feb0338987e93b1ee09086ea61fce2d178b114e67f7cc0f70	2026-10-24 17:44:52.431816+05:30	\N	2026-09-24 17:44:52.442474+05:30
7	1	0be146475032a113097c59f9eb4cfd4530247b198227095872bf1a18a12e7f21	2026-10-24 17:50:46.087921+05:30	\N	2026-09-24 17:50:46.095856+05:30
8	1	26c0a2d814d5d574dbde4461992b7f4f9f88f49d187d26e7e85ab7f01ac6eb84	2026-10-25 11:44:09.064859+05:30	\N	2026-09-25 11:44:09.068442+05:30
9	1	78c99274c2ae43ee1199d044bf136809e20779b4b2e10ec968d68b793c5acf89	2026-10-25 11:44:21.540283+05:30	\N	2026-09-25 11:44:21.541484+05:30
10	1	98dbefd26a6fbc92af678f6b1f1b663321edf7701633dd46e0a9683d6ddfbe11	2026-10-25 11:50:21.9623+05:30	\N	2026-09-25 11:50:21.963713+05:30
11	14	c1bb1cacca821b23ace059e77c30fcbd38616e19336ef834d678de838ea4a824	2026-10-25 12:03:15.365224+05:30	\N	2026-09-25 12:03:15.367305+05:30
12	14	257f941b8bee493b64d3a3ec8c755de885c0435a35020419e86d523ad3d3fa43	2026-10-25 12:04:58.074192+05:30	\N	2026-09-25 12:04:58.07554+05:30
13	14	aee71526ee121be64eec1f8e0bcac7257beb3ff231f5af20cfeb1f856964fbfc	2026-10-25 12:05:10.119854+05:30	\N	2026-09-25 12:05:10.123402+05:30
14	14	58c4e2c07a46d72c4f03dc8ac2db4025573f3fc6325ebb739f3c8ec5b6c1f11a	2026-10-25 12:08:00.702364+05:30	\N	2026-09-25 12:08:00.70782+05:30
15	14	e81b998b592d0d3c7d4a0796383ace0ed835641f6a2a719cc54fa5dbda5bfbc3	2026-10-25 12:13:49.886359+05:30	\N	2026-09-25 12:13:49.890721+05:30
16	14	3d9dfbbd716143b01b705e86a2cac016cdf84881ea71985f5f7b9f03acbfa9e9	2026-10-25 12:18:53.633101+05:30	\N	2026-09-25 12:18:53.634052+05:30
17	14	6e9dadc3df371ab5dba43011fc3dc5fe25006b446fcb05736c0684e3cb915608	2026-10-25 12:22:30.834665+05:30	2026-09-25 12:23:08.038847+05:30	2026-09-25 12:22:30.835678+05:30
18	14	5f29185ee4a51877cc1a9c7b401eeb8aed6935257e076c0bb7d7d72b436ef1bb	2026-10-25 12:23:08.04228+05:30	\N	2026-09-25 12:23:08.04454+05:30
19	14	59112646fdbae7b623520e621c38b446b22bcbb655c1c43ee432da0c69592161	2026-10-25 12:30:20.504426+05:30	2026-09-25 12:31:20.183124+05:30	2026-09-25 12:30:20.506299+05:30
20	14	92f18e23dea7ce90167b849c100cf585f41040ab7ff143a6ecaf6a0762b39334	2026-10-30 19:21:54.950811+05:30	\N	2026-09-30 19:21:54.953704+05:30
21	14	b0648af681fb2e83c83e40fcc3bc124e048dd54410840848fafb65ba2c86ea93	2026-10-30 19:22:02.726392+05:30	\N	2026-09-30 19:22:02.727646+05:30
22	16	410259d6cd82693e12ee0ac660c95ed1b9b941409dcbe3fe499df1388afccdb1	2026-10-30 19:23:23.929385+05:30	\N	2026-09-30 19:23:23.930731+05:30
23	16	a3fa2b4b43fc99a66c9564d2f0a570bfda0ce17e05590ead6e361615bb1829ac	2026-10-30 19:23:59.485513+05:30	\N	2026-09-30 19:23:59.487301+05:30
24	16	a8eb6ef2851270ed272dc2dc4864975ae70ca97b5e0ecc709f637f38a17df111	2026-10-30 19:28:07.658593+05:30	2026-09-30 19:30:10.201543+05:30	2026-09-30 19:28:07.66002+05:30
25	16	cba0d34e9e341dbd9120d81f776e6c9ebbaec07947c15cb498eca20a720e2ddd	2026-10-30 19:35:27.070848+05:30	2026-09-30 19:35:43.007186+05:30	2026-09-30 19:35:27.072456+05:30
26	18	87380804797cb3e448ddb2593274f1aa3f65ca825f41909f75f94e543b8b48ca	2026-10-30 19:51:47.399036+05:30	2026-09-30 19:52:16.987838+05:30	2026-09-30 19:51:47.400936+05:30
27	20	7f3b4f9ad24dd12190773d8bb2cc130416d043ef8a04b3a3439287924ddd5a87	2026-10-30 20:25:08.610683+05:30	2026-09-30 20:25:26.317033+05:30	2026-09-30 20:25:08.612678+05:30
28	22	43f715eae0720249f58514a0a5816f28667f266ec57f56408b75bff181a9746e	2026-10-31 09:35:25.45726+05:30	2026-10-01 09:36:00.034443+05:30	2026-10-01 09:35:25.459078+05:30
29	23	4544c12c4bba9c6bdffe8c0b966ee9a9a7bb4dcea13cece8bed284206006ff81	2026-10-31 09:36:36.36629+05:30	2026-10-01 09:36:49.742813+05:30	2026-10-01 09:36:36.369191+05:30
30	20	968eda4723eaaff2e6847584f05b5a4f12b9dc461a4fb73fcf57f36c1ca4ef8f	2026-10-31 09:38:40.780637+05:30	\N	2026-10-01 09:38:40.781958+05:30
31	22	4593f0f3763987904a96a6857af9307299af47ece4b9130977a0dfdc554a6fca	2026-10-31 09:41:03.411444+05:30	\N	2026-10-01 09:41:03.414077+05:30
32	22	54a7298dc461a1807ab3fdc6dc1ee8bdc3536a39958af28ae848061eadfc0f9d	2026-10-31 09:42:50.766597+05:30	2026-10-01 09:46:56.098318+05:30	2026-10-01 09:42:50.768294+05:30
33	22	e9d2170cf4c79361b7e71ee6ed9b4f44daf10f28573a5246946e7c257af82aa5	2026-10-31 09:50:48.018009+05:30	2026-10-01 10:05:53.156235+05:30	2026-10-01 09:50:48.019305+05:30
34	22	c7a4de797497bf7f8fdf6061483f36d1cd0a0b97bf59161e92678de46507e29f	2026-10-31 10:05:53.165666+05:30	2026-10-01 10:22:48.522706+05:30	2026-10-01 10:05:53.166498+05:30
35	22	2e28a664a83d728b06202fc70a6dbbdb08772927451cbd9075191681ef67c3a9	2026-10-31 10:22:48.527889+05:30	2026-10-01 10:45:24.520283+05:30	2026-10-01 10:22:48.529291+05:30
36	22	153db808deab11eb3805fff0ce3f71907264af20e94a4e2e3241c0a82399aa76	2026-10-31 10:45:24.526971+05:30	2026-10-01 11:15:35.290906+05:30	2026-10-01 10:45:24.529359+05:30
37	22	472616e41a387617528bbc19a4f78667a9b2e4cdedcaa2bfdd5ae8773213e521	2026-10-31 11:15:35.303423+05:30	2026-10-01 11:33:49.901562+05:30	2026-10-01 11:15:35.309015+05:30
39	24	00704547df285cb78343032ec6de48f965766cf7b838a2518a7f4bae9c026154	2026-10-31 11:51:03.923169+05:30	\N	2026-10-01 11:51:03.924903+05:30
38	22	1014998acdf9a0c5407502c7856cf2d17da9af90b904a5e61a97bd793327746b	2026-10-31 11:33:49.908428+05:30	2026-10-01 12:03:54.173411+05:30	2026-10-01 11:33:49.912471+05:30
40	22	430fb13a6492984684b62b27a2519c1d455f2a3a4bd95977ae8e14a4c3468a2c	2026-10-31 12:03:54.179175+05:30	2026-10-01 12:24:23.352508+05:30	2026-10-01 12:03:54.182865+05:30
42	24	1ed5c826321515e6f9eda8e03dd38ce4a9cb99a54157b82f5c29d22fcb1c4359	2026-10-31 12:30:53.164345+05:30	\N	2026-10-01 12:30:53.165492+05:30
41	22	2ff888087d07c05787d28a2179dde47f189ca6dcbd66b509f52a6dee3706c7c7	2026-10-31 12:24:23.353878+05:30	2026-10-01 12:45:49.30883+05:30	2026-10-01 12:24:23.354909+05:30
43	22	376c74324e26fc4ff17d44df1881b194890c00d7e79500ea9a33ecced23c9106	2026-10-31 12:45:49.315307+05:30	2026-10-01 12:51:10.400089+05:30	2026-10-01 12:45:49.3173+05:30
44	25	25860731491481b036271aa0853fbea99297031df0a571ddab6b14e925d8d4e1	2026-10-31 12:51:51.303208+05:30	2026-10-01 13:07:57.918765+05:30	2026-10-01 12:51:51.304752+05:30
45	25	c2d30a6bfb6868cefcaad6f4d65cc541d4fae47756a0aefd69434ebe3c2438e1	2026-10-31 13:07:57.920631+05:30	2026-10-01 13:08:04.17632+05:30	2026-10-01 13:07:57.921366+05:30
46	16	fdf97d79b48dba7e2d3929cc789fca1b094ec9e4d0d955556eddfd67290d7179	2026-10-31 13:08:23.511414+05:30	2026-10-01 15:34:23.614733+05:30	2026-10-01 13:08:23.512235+05:30
47	16	c90cba5dd647651d05181e19c0e1287369608eeab92499a4abc85bf41a42b6b5	2026-10-31 15:34:23.618482+05:30	2026-10-01 15:58:53.546781+05:30	2026-10-01 15:34:23.620477+05:30
48	16	3225ab1d03c9b63494d923b9d891cf1643570dc399cd6398769c73946cd71377	2026-10-31 15:58:53.550712+05:30	2026-10-01 16:19:18.32376+05:30	2026-10-01 15:58:53.552932+05:30
49	16	b73e17ced84e7371883767ca02b1d3ed368d77859b3a5a9ea8c1cf6c90459d6e	2026-10-31 16:19:18.328998+05:30	2026-10-01 16:36:31.41676+05:30	2026-10-01 16:19:18.32976+05:30
50	16	913e2afdc01715f6cbff6e41b6403b6d6504ae739f9d466b91d9721002114312	2026-10-31 16:36:31.421005+05:30	2026-10-01 16:56:10.216744+05:30	2026-10-01 16:36:31.422293+05:30
51	16	ad687c714d763aaadb2049fbf46393fdc16bc050e8f34f6e4775c9ea59b5b4da	2026-10-31 16:56:10.221158+05:30	2026-10-01 17:12:28.410551+05:30	2026-10-01 16:56:10.222802+05:30
52	16	e4db2242b304344b72d84f1dffb5f4540db7c0e4234c428d60c32cb13026efee	2026-10-31 17:12:28.412261+05:30	2026-10-01 17:30:08.25003+05:30	2026-10-01 17:12:28.413698+05:30
53	16	6e82bf7b9346ff6ab9c282ec5cd65366dd76084df63f39788e1a40a0d7159f97	2026-10-31 17:30:08.254979+05:30	2026-10-01 17:53:23.082761+05:30	2026-10-01 17:30:08.25593+05:30
54	16	c97fb39d83ff1e78c1b4283732e9c259b3f2ca9dddfd0e37c2cc7db2d5f9cba5	2026-10-31 17:53:23.084135+05:30	2026-10-01 18:14:03.01981+05:30	2026-10-01 17:53:23.085473+05:30
55	16	fbb3997154a466ea0bd2163dd88100467620e9d09b045ea70f2ed928b864f6d9	2026-10-31 18:14:03.02411+05:30	2026-10-01 18:29:50.613903+05:30	2026-10-01 18:14:03.026356+05:30
56	16	bbb631523be214beeb1b96c1aa2c44d949a6c45bd2e86fa5a0daa7d685897b52	2026-10-31 18:29:50.616703+05:30	\N	2026-10-01 18:29:50.617533+05:30
\.


--
-- TOC entry 5224 (class 0 OID 16609)
-- Dependencies: 236
-- Data for Name: screens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.screens (id, theater_id, screen_name, total_seats, created_at) FROM stdin;
1	1	Audi 1 - IMAX Laser	140	2026-10-01 17:50:24.354896+05:30
2	1	Audi 2 - LUXE Suite Recliner	60	2026-10-01 17:50:24.357423+05:30
3	1	Audi 3 - Dolby Atmos Premiere	120	2026-10-01 17:50:24.358286+05:30
4	2	Audi 1 - 4DX Dynamic Motion	96	2026-10-01 17:50:24.359067+05:30
5	2	Audi 2 - VIP Dolby Atmos	72	2026-10-01 17:50:24.359721+05:30
6	2	Audi 3 - RealD 3D Laser	120	2026-10-01 17:50:24.360371+05:30
7	3	Living Room 1 - Dolby Vision	48	2026-10-01 17:50:24.360983+05:30
8	3	Living Room 2 - Private Luxe	40	2026-10-01 17:50:24.361585+05:30
9	4	Screen 1 - 3D Dolby 7.1	120	2026-10-01 17:50:24.362179+05:30
10	4	Screen 2 - Digital 2D Classic	96	2026-10-01 17:50:24.362756+05:30
11	5	Audi 1 - IMAX 3D Laser	130	2026-10-01 17:50:24.363491+05:30
12	5	Audi 2 - P[XL] Giant Screen	150	2026-10-01 17:50:24.364171+05:30
13	5	Audi 3 - Dolby Atmos Prime	100	2026-10-01 17:50:24.364772+05:30
14	6	Audi 1 - Laser IMAX Large Screen	140	2026-10-01 17:50:24.365449+05:30
15	6	Audi 2 - Dolby Atmos 7.1.4	110	2026-10-01 17:50:24.366183+05:30
16	7	Audi 1 - IMAX Laser 70mm	150	2026-10-01 17:50:24.36676+05:30
17	7	Audi 2 - 4DX Sensory Screen	96	2026-10-01 17:50:24.36741+05:30
18	7	Audi 3 - ICE Immersive Theatre	100	2026-10-01 17:50:24.36801+05:30
19	8	Audi 1 - Dolby Atmos Macro XE	130	2026-10-01 17:50:24.368606+05:30
20	8	Audi 2 - VIP Recliner Class	60	2026-10-01 17:50:24.369118+05:30
21	9	Audi 1 - Dolby Atmos 3D	120	2026-10-01 17:50:24.36973+05:30
22	9	Audi 2 - 4K Laser Digital	96	2026-10-01 17:50:24.370278+05:30
23	10	Audi 1 - Director Cut Ultra Luxury	48	2026-10-01 17:50:24.370828+05:30
24	10	Audi 2 - Platinum Gold Class	40	2026-10-01 17:50:24.371316+05:30
25	11	Main Screen - Laser 4K RGB Giant	180	2026-10-01 17:50:24.371794+05:30
26	11	Balcony Screen - Dolby Atmos VIP	90	2026-10-01 17:50:24.37241+05:30
27	12	Audi 1 - IMAX 3D with Laser	140	2026-10-01 17:50:24.372914+05:30
28	12	Audi 2 - 4DX Interactive	88	2026-10-01 17:50:24.373549+05:30
29	12	Audi 3 - Dolby Atmos Premiere	110	2026-10-01 17:50:24.374163+05:30
30	13	Sathyam - RDX 4K Laser & Atmos	160	2026-10-01 17:50:24.374741+05:30
31	13	Santham - Dolby Atmos 7.1.4	120	2026-10-01 17:50:24.375314+05:30
32	13	Studio 5 - VIP Recliner	60	2026-10-01 17:50:24.375964+05:30
33	14	Audi 1 - IMAX Laser Commercial	140	2026-10-01 17:50:24.376491+05:30
34	14	Audi 2 - Luxe Recliner Lounge	56	2026-10-01 17:50:24.377279+05:30
35	15	Audi 1 - Palazzo Dolby Atmos Grand	150	2026-10-01 17:50:24.377849+05:30
36	15	Audi 2 - Italian VIP Suite	60	2026-10-01 17:50:24.378434+05:30
37	16	Screen 1 - Blind Velvet Atmos	110	2026-10-01 17:50:24.379038+05:30
38	16	Screen 2 - Velvet 2D Laser	90	2026-10-01 17:50:24.379548+05:30
39	17	Audi 1 - EPIQ Premium Large Format	170	2026-10-01 17:50:24.379987+05:30
40	17	Audi 2 - 4DX Motion Theatre	96	2026-10-01 17:50:24.380564+05:30
41	18	Screen 1 - 4K Laser Dolby Atmos	130	2026-10-01 17:50:24.381187+05:30
42	18	Screen 2 - Digital 3D Surround	100	2026-10-01 17:50:24.381713+05:30
43	19	Screen 6 - Large Screen PCX 4K Giant	200	2026-10-01 17:50:24.382239+05:30
44	19	Screen 1 - 4K 3D Dolby Atmos	130	2026-10-01 17:50:24.382865+05:30
45	19	Screen 2 - Digital Laser Luxe	90	2026-10-01 17:50:24.383436+05:30
46	20	Audi 1 - Superplex Laser Dolby Atmos	160	2026-10-01 17:50:24.384034+05:30
47	20	Audi 2 - VIP M-Lounge Recliner	60	2026-10-01 17:50:24.384564+05:30
48	20	Audi 3 - 4K Barco Laser	120	2026-10-01 17:50:24.385179+05:30
49	21	Audi 1 - IMAX Laser 3D	140	2026-10-01 17:50:24.38576+05:30
50	21	Audi 2 - Dolby Atmos Prime	110	2026-10-01 17:50:24.386269+05:30
51	22	Audi 1 - Macro XE Giant Screen	150	2026-10-01 17:50:24.386784+05:30
52	22	Audi 2 - 4DX Sensory Experience	96	2026-10-01 17:50:24.387319+05:30
53	23	Audi 1 - Insignia Luxury Recliner	60	2026-10-01 17:50:24.387935+05:30
54	23	Audi 2 - 4K Dolby Atmos	120	2026-10-01 17:50:24.388516+05:30
55	24	Audi 1 - IMAX 3D Laser	140	2026-10-01 17:50:24.389002+05:30
56	24	Audi 2 - 4DX Motion Effects	96	2026-10-01 17:50:24.389471+05:30
57	24	Audi 3 - Dolby Atmos Premiere	110	2026-10-01 17:50:24.390029+05:30
58	25	Audi 1 - VIP Dolby Atmos Recliner	64	2026-10-01 17:50:24.390519+05:30
59	25	Audi 2 - RealD 3D Laser	120	2026-10-01 17:50:24.390978+05:30
60	26	Audi 1 - Laser 4K Dolby 7.1	110	2026-10-01 17:50:24.391447+05:30
61	26	Audi 2 - Executive Recliner	56	2026-10-01 17:50:24.392066+05:30
62	27	Audi 1 - P[XL] Premium Giant Screen	160	2026-10-01 17:50:24.392633+05:30
63	27	Audi 2 - 4K Dolby Atmos Laser	120	2026-10-01 17:50:24.393237+05:30
64	28	Audi 1 - RealD 3D Dolby Atmos	130	2026-10-01 17:50:24.393778+05:30
65	28	Audi 2 - Digital 2D Surround	96	2026-10-01 17:50:24.3943+05:30
66	29	Audi 1 - IMAX Laser Commercial	150	2026-10-01 17:50:24.394855+05:30
67	29	Audi 2 - Insignia Gold Recliner	56	2026-10-01 17:50:24.395424+05:30
68	29	Audi 3 - Dolby Atmos Prime	120	2026-10-01 17:50:24.396018+05:30
69	30	Audi 1 - 4DX Sensory Theatre	96	2026-10-01 17:50:24.396683+05:30
70	30	Audi 2 - Dolby Atmos 7.1	120	2026-10-01 17:50:24.397454+05:30
71	31	Audi 1 - Insignia Luxe Recliner	56	2026-10-01 17:50:24.398209+05:30
72	31	Audi 2 - 4K Laser Dolby Atmos	120	2026-10-01 17:50:24.398874+05:30
73	32	Audi 1 - RealD 3D Dolby 7.1	120	2026-10-01 17:50:24.399468+05:30
74	32	Audi 2 - Digital 2D Laser	96	2026-10-01 17:50:24.400075+05:30
75	33	Main Audi - Dolby Atmos 4K Laser	170	2026-10-01 17:50:24.400663+05:30
76	33	Mini Audi - Digital 2D Classic	80	2026-10-01 17:50:24.401123+05:30
77	34	Audi 1 - IMAX 3D Laser	150	2026-10-01 17:50:24.401563+05:30
78	34	Audi 2 - 4DX Motion Experience	96	2026-10-01 17:50:24.401993+05:30
79	34	Audi 3 - Luxe Recliner Suite	56	2026-10-01 17:50:24.402419+05:30
80	34	Audi 4 - Dolby Atmos 7.1.4	120	2026-10-01 17:50:24.402865+05:30
81	35	Audi 1 - Dolby Atmos Macro XE	130	2026-10-01 17:50:24.403344+05:30
82	35	Audi 2 - RealD 3D Laser	100	2026-10-01 17:50:24.403942+05:30
83	36	Screen 1 - 4K Dolby Atmos RGB Laser	160	2026-10-01 17:50:24.404518+05:30
84	36	Screen 2 - Christie Laser 4K 3D	120	2026-10-01 17:50:24.405005+05:30
85	37	Audi 1 - P[XL] Giant Screen 4K	160	2026-10-01 17:50:24.405576+05:30
86	37	Audi 2 - Dolby Atmos Prime	120	2026-10-01 17:50:24.406138+05:30
87	38	Main Screen - Dolby 7.1 2D Classic	140	2026-10-01 17:50:24.406623+05:30
\.


--
-- TOC entry 5230 (class 0 OID 16676)
-- Dependencies: 242
-- Data for Name: seat_locks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.seat_locks (id, show_id, seat_id, user_id, lock_token, expires_at, created_at) FROM stdin;
\.


--
-- TOC entry 5226 (class 0 OID 16626)
-- Dependencies: 238
-- Data for Name: seats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.seats (id, screen_id, row_label, seat_number, seat_identifier, tier_name, seat_type, multiplier) FROM stdin;
1	1	A	1	A1	Silver	normal	1.00
2	1	A	2	A2	Silver	normal	1.00
3	1	A	3	A3	Silver	normal	1.00
4	1	A	4	A4	Silver	normal	1.00
5	1	A	5	A5	Silver	normal	1.00
6	1	A	6	A6	Silver	normal	1.00
7	1	A	7	A7	Silver	normal	1.00
8	1	A	8	A8	Silver	normal	1.00
9	1	A	9	A9	Silver	normal	1.00
10	1	A	10	A10	Silver	normal	1.00
11	1	A	11	A11	Silver	normal	1.00
12	1	A	12	A12	Silver	normal	1.00
13	1	B	1	B1	Silver	normal	1.00
14	1	B	2	B2	Silver	normal	1.00
15	1	B	3	B3	Silver	normal	1.00
16	1	B	4	B4	Silver	normal	1.00
17	1	B	5	B5	Silver	normal	1.00
18	1	B	6	B6	Silver	normal	1.00
19	1	B	7	B7	Silver	normal	1.00
20	1	B	8	B8	Silver	normal	1.00
21	1	B	9	B9	Silver	normal	1.00
22	1	B	10	B10	Silver	normal	1.00
23	1	B	11	B11	Silver	normal	1.00
24	1	B	12	B12	Silver	normal	1.00
25	1	C	1	C1	Gold	normal	1.25
26	1	C	2	C2	Gold	normal	1.25
27	1	C	3	C3	Gold	normal	1.25
28	1	C	4	C4	Gold	normal	1.25
29	1	C	5	C5	Gold	normal	1.25
30	1	C	6	C6	Gold	normal	1.25
31	1	C	7	C7	Gold	normal	1.25
32	1	C	8	C8	Gold	normal	1.25
33	1	C	9	C9	Gold	normal	1.25
34	1	C	10	C10	Gold	normal	1.25
35	1	C	11	C11	Gold	normal	1.25
36	1	C	12	C12	Gold	normal	1.25
37	1	D	1	D1	Gold	normal	1.25
38	1	D	2	D2	Gold	normal	1.25
39	1	D	3	D3	Gold	normal	1.25
40	1	D	4	D4	Gold	normal	1.25
41	1	D	5	D5	Gold	normal	1.25
42	1	D	6	D6	Gold	normal	1.25
43	1	D	7	D7	Gold	normal	1.25
44	1	D	8	D8	Gold	normal	1.25
45	1	D	9	D9	Gold	normal	1.25
46	1	D	10	D10	Gold	normal	1.25
47	1	D	11	D11	Gold	normal	1.25
48	1	D	12	D12	Gold	normal	1.25
49	1	E	1	E1	Platinum Recliner	normal	1.60
50	1	E	2	E2	Platinum Recliner	normal	1.60
51	1	E	3	E3	Platinum Recliner	normal	1.60
52	1	E	4	E4	Platinum Recliner	normal	1.60
53	1	E	5	E5	Platinum Recliner	normal	1.60
54	1	E	6	E6	Platinum Recliner	normal	1.60
55	1	E	7	E7	Platinum Recliner	normal	1.60
56	1	E	8	E8	Platinum Recliner	normal	1.60
57	1	E	9	E9	Platinum Recliner	normal	1.60
58	1	E	10	E10	Platinum Recliner	normal	1.60
59	1	E	11	E11	Platinum Recliner	normal	1.60
60	1	E	12	E12	Platinum Recliner	normal	1.60
61	1	F	1	F1	Platinum Recliner	normal	1.60
62	1	F	2	F2	Platinum Recliner	normal	1.60
63	1	F	3	F3	Platinum Recliner	normal	1.60
64	1	F	4	F4	Platinum Recliner	normal	1.60
65	1	F	5	F5	Platinum Recliner	normal	1.60
66	1	F	6	F6	Platinum Recliner	normal	1.60
67	1	F	7	F7	Platinum Recliner	normal	1.60
68	1	F	8	F8	Platinum Recliner	normal	1.60
69	1	F	9	F9	Platinum Recliner	normal	1.60
70	1	F	10	F10	Platinum Recliner	normal	1.60
71	1	F	11	F11	Platinum Recliner	normal	1.60
72	1	F	12	F12	Platinum Recliner	normal	1.60
73	2	A	1	A1	Silver	normal	1.00
74	2	A	2	A2	Silver	normal	1.00
75	2	A	3	A3	Silver	normal	1.00
76	2	A	4	A4	Silver	normal	1.00
77	2	A	5	A5	Silver	normal	1.00
78	2	A	6	A6	Silver	normal	1.00
79	2	A	7	A7	Silver	normal	1.00
80	2	A	8	A8	Silver	normal	1.00
81	2	B	1	B1	Silver	normal	1.00
82	2	B	2	B2	Silver	normal	1.00
83	2	B	3	B3	Silver	normal	1.00
84	2	B	4	B4	Silver	normal	1.00
85	2	B	5	B5	Silver	normal	1.00
86	2	B	6	B6	Silver	normal	1.00
87	2	B	7	B7	Silver	normal	1.00
88	2	B	8	B8	Silver	normal	1.00
89	2	C	1	C1	Gold	normal	1.25
90	2	C	2	C2	Gold	normal	1.25
91	2	C	3	C3	Gold	normal	1.25
92	2	C	4	C4	Gold	normal	1.25
93	2	C	5	C5	Gold	normal	1.25
94	2	C	6	C6	Gold	normal	1.25
95	2	C	7	C7	Gold	normal	1.25
96	2	C	8	C8	Gold	normal	1.25
97	2	D	1	D1	Gold	normal	1.25
98	2	D	2	D2	Gold	normal	1.25
99	2	D	3	D3	Gold	normal	1.25
100	2	D	4	D4	Gold	normal	1.25
101	2	D	5	D5	Gold	normal	1.25
102	2	D	6	D6	Gold	normal	1.25
103	2	D	7	D7	Gold	normal	1.25
104	2	D	8	D8	Gold	normal	1.25
105	2	E	1	E1	Platinum Recliner	normal	1.60
106	2	E	2	E2	Platinum Recliner	normal	1.60
107	2	E	3	E3	Platinum Recliner	normal	1.60
108	2	E	4	E4	Platinum Recliner	normal	1.60
109	2	E	5	E5	Platinum Recliner	normal	1.60
110	2	E	6	E6	Platinum Recliner	normal	1.60
111	2	E	7	E7	Platinum Recliner	normal	1.60
112	2	E	8	E8	Platinum Recliner	normal	1.60
113	2	F	1	F1	Platinum Recliner	normal	1.60
114	2	F	2	F2	Platinum Recliner	normal	1.60
115	2	F	3	F3	Platinum Recliner	normal	1.60
116	2	F	4	F4	Platinum Recliner	normal	1.60
117	2	F	5	F5	Platinum Recliner	normal	1.60
118	2	F	6	F6	Platinum Recliner	normal	1.60
119	2	F	7	F7	Platinum Recliner	normal	1.60
120	2	F	8	F8	Platinum Recliner	normal	1.60
121	3	A	1	A1	Silver	normal	1.00
122	3	A	2	A2	Silver	normal	1.00
123	3	A	3	A3	Silver	normal	1.00
124	3	A	4	A4	Silver	normal	1.00
125	3	A	5	A5	Silver	normal	1.00
126	3	A	6	A6	Silver	normal	1.00
127	3	A	7	A7	Silver	normal	1.00
128	3	A	8	A8	Silver	normal	1.00
129	3	A	9	A9	Silver	normal	1.00
130	3	A	10	A10	Silver	normal	1.00
131	3	A	11	A11	Silver	normal	1.00
132	3	A	12	A12	Silver	normal	1.00
133	3	B	1	B1	Silver	normal	1.00
134	3	B	2	B2	Silver	normal	1.00
135	3	B	3	B3	Silver	normal	1.00
136	3	B	4	B4	Silver	normal	1.00
137	3	B	5	B5	Silver	normal	1.00
138	3	B	6	B6	Silver	normal	1.00
139	3	B	7	B7	Silver	normal	1.00
140	3	B	8	B8	Silver	normal	1.00
141	3	B	9	B9	Silver	normal	1.00
142	3	B	10	B10	Silver	normal	1.00
143	3	B	11	B11	Silver	normal	1.00
144	3	B	12	B12	Silver	normal	1.00
145	3	C	1	C1	Gold	normal	1.25
146	3	C	2	C2	Gold	normal	1.25
147	3	C	3	C3	Gold	normal	1.25
148	3	C	4	C4	Gold	normal	1.25
149	3	C	5	C5	Gold	normal	1.25
150	3	C	6	C6	Gold	normal	1.25
151	3	C	7	C7	Gold	normal	1.25
152	3	C	8	C8	Gold	normal	1.25
153	3	C	9	C9	Gold	normal	1.25
154	3	C	10	C10	Gold	normal	1.25
155	3	C	11	C11	Gold	normal	1.25
156	3	C	12	C12	Gold	normal	1.25
157	3	D	1	D1	Gold	normal	1.25
158	3	D	2	D2	Gold	normal	1.25
159	3	D	3	D3	Gold	normal	1.25
160	3	D	4	D4	Gold	normal	1.25
161	3	D	5	D5	Gold	normal	1.25
162	3	D	6	D6	Gold	normal	1.25
163	3	D	7	D7	Gold	normal	1.25
164	3	D	8	D8	Gold	normal	1.25
165	3	D	9	D9	Gold	normal	1.25
166	3	D	10	D10	Gold	normal	1.25
167	3	D	11	D11	Gold	normal	1.25
168	3	D	12	D12	Gold	normal	1.25
169	3	E	1	E1	Platinum Recliner	normal	1.60
170	3	E	2	E2	Platinum Recliner	normal	1.60
171	3	E	3	E3	Platinum Recliner	normal	1.60
172	3	E	4	E4	Platinum Recliner	normal	1.60
173	3	E	5	E5	Platinum Recliner	normal	1.60
174	3	E	6	E6	Platinum Recliner	normal	1.60
175	3	E	7	E7	Platinum Recliner	normal	1.60
176	3	E	8	E8	Platinum Recliner	normal	1.60
177	3	E	9	E9	Platinum Recliner	normal	1.60
178	3	E	10	E10	Platinum Recliner	normal	1.60
179	3	E	11	E11	Platinum Recliner	normal	1.60
180	3	E	12	E12	Platinum Recliner	normal	1.60
181	3	F	1	F1	Platinum Recliner	normal	1.60
182	3	F	2	F2	Platinum Recliner	normal	1.60
183	3	F	3	F3	Platinum Recliner	normal	1.60
184	3	F	4	F4	Platinum Recliner	normal	1.60
185	3	F	5	F5	Platinum Recliner	normal	1.60
186	3	F	6	F6	Platinum Recliner	normal	1.60
187	3	F	7	F7	Platinum Recliner	normal	1.60
188	3	F	8	F8	Platinum Recliner	normal	1.60
189	3	F	9	F9	Platinum Recliner	normal	1.60
190	3	F	10	F10	Platinum Recliner	normal	1.60
191	3	F	11	F11	Platinum Recliner	normal	1.60
192	3	F	12	F12	Platinum Recliner	normal	1.60
193	4	A	1	A1	Silver	normal	1.00
194	4	A	2	A2	Silver	normal	1.00
195	4	A	3	A3	Silver	normal	1.00
196	4	A	4	A4	Silver	normal	1.00
197	4	A	5	A5	Silver	normal	1.00
198	4	A	6	A6	Silver	normal	1.00
199	4	A	7	A7	Silver	normal	1.00
200	4	A	8	A8	Silver	normal	1.00
201	4	A	9	A9	Silver	normal	1.00
202	4	A	10	A10	Silver	normal	1.00
203	4	B	1	B1	Silver	normal	1.00
204	4	B	2	B2	Silver	normal	1.00
205	4	B	3	B3	Silver	normal	1.00
206	4	B	4	B4	Silver	normal	1.00
207	4	B	5	B5	Silver	normal	1.00
208	4	B	6	B6	Silver	normal	1.00
209	4	B	7	B7	Silver	normal	1.00
210	4	B	8	B8	Silver	normal	1.00
211	4	B	9	B9	Silver	normal	1.00
212	4	B	10	B10	Silver	normal	1.00
213	4	C	1	C1	Gold	normal	1.25
214	4	C	2	C2	Gold	normal	1.25
215	4	C	3	C3	Gold	normal	1.25
216	4	C	4	C4	Gold	normal	1.25
217	4	C	5	C5	Gold	normal	1.25
218	4	C	6	C6	Gold	normal	1.25
219	4	C	7	C7	Gold	normal	1.25
220	4	C	8	C8	Gold	normal	1.25
221	4	C	9	C9	Gold	normal	1.25
222	4	C	10	C10	Gold	normal	1.25
223	4	D	1	D1	Gold	normal	1.25
224	4	D	2	D2	Gold	normal	1.25
225	4	D	3	D3	Gold	normal	1.25
226	4	D	4	D4	Gold	normal	1.25
227	4	D	5	D5	Gold	normal	1.25
228	4	D	6	D6	Gold	normal	1.25
229	4	D	7	D7	Gold	normal	1.25
230	4	D	8	D8	Gold	normal	1.25
231	4	D	9	D9	Gold	normal	1.25
232	4	D	10	D10	Gold	normal	1.25
233	4	E	1	E1	Platinum Recliner	normal	1.60
234	4	E	2	E2	Platinum Recliner	normal	1.60
235	4	E	3	E3	Platinum Recliner	normal	1.60
236	4	E	4	E4	Platinum Recliner	normal	1.60
237	4	E	5	E5	Platinum Recliner	normal	1.60
238	4	E	6	E6	Platinum Recliner	normal	1.60
239	4	E	7	E7	Platinum Recliner	normal	1.60
240	4	E	8	E8	Platinum Recliner	normal	1.60
241	4	E	9	E9	Platinum Recliner	normal	1.60
242	4	E	10	E10	Platinum Recliner	normal	1.60
243	4	F	1	F1	Platinum Recliner	normal	1.60
244	4	F	2	F2	Platinum Recliner	normal	1.60
245	4	F	3	F3	Platinum Recliner	normal	1.60
246	4	F	4	F4	Platinum Recliner	normal	1.60
247	4	F	5	F5	Platinum Recliner	normal	1.60
248	4	F	6	F6	Platinum Recliner	normal	1.60
249	4	F	7	F7	Platinum Recliner	normal	1.60
250	4	F	8	F8	Platinum Recliner	normal	1.60
251	4	F	9	F9	Platinum Recliner	normal	1.60
252	4	F	10	F10	Platinum Recliner	normal	1.60
253	5	A	1	A1	Silver	normal	1.00
254	5	A	2	A2	Silver	normal	1.00
255	5	A	3	A3	Silver	normal	1.00
256	5	A	4	A4	Silver	normal	1.00
257	5	A	5	A5	Silver	normal	1.00
258	5	A	6	A6	Silver	normal	1.00
259	5	A	7	A7	Silver	normal	1.00
260	5	A	8	A8	Silver	normal	1.00
261	5	A	9	A9	Silver	normal	1.00
262	5	A	10	A10	Silver	normal	1.00
263	5	B	1	B1	Silver	normal	1.00
264	5	B	2	B2	Silver	normal	1.00
265	5	B	3	B3	Silver	normal	1.00
266	5	B	4	B4	Silver	normal	1.00
267	5	B	5	B5	Silver	normal	1.00
268	5	B	6	B6	Silver	normal	1.00
269	5	B	7	B7	Silver	normal	1.00
270	5	B	8	B8	Silver	normal	1.00
271	5	B	9	B9	Silver	normal	1.00
272	5	B	10	B10	Silver	normal	1.00
273	5	C	1	C1	Gold	normal	1.25
274	5	C	2	C2	Gold	normal	1.25
275	5	C	3	C3	Gold	normal	1.25
276	5	C	4	C4	Gold	normal	1.25
277	5	C	5	C5	Gold	normal	1.25
278	5	C	6	C6	Gold	normal	1.25
279	5	C	7	C7	Gold	normal	1.25
280	5	C	8	C8	Gold	normal	1.25
281	5	C	9	C9	Gold	normal	1.25
282	5	C	10	C10	Gold	normal	1.25
283	5	D	1	D1	Gold	normal	1.25
284	5	D	2	D2	Gold	normal	1.25
285	5	D	3	D3	Gold	normal	1.25
286	5	D	4	D4	Gold	normal	1.25
287	5	D	5	D5	Gold	normal	1.25
288	5	D	6	D6	Gold	normal	1.25
289	5	D	7	D7	Gold	normal	1.25
290	5	D	8	D8	Gold	normal	1.25
291	5	D	9	D9	Gold	normal	1.25
292	5	D	10	D10	Gold	normal	1.25
293	5	E	1	E1	Platinum Recliner	normal	1.60
294	5	E	2	E2	Platinum Recliner	normal	1.60
295	5	E	3	E3	Platinum Recliner	normal	1.60
296	5	E	4	E4	Platinum Recliner	normal	1.60
297	5	E	5	E5	Platinum Recliner	normal	1.60
298	5	E	6	E6	Platinum Recliner	normal	1.60
299	5	E	7	E7	Platinum Recliner	normal	1.60
300	5	E	8	E8	Platinum Recliner	normal	1.60
301	5	E	9	E9	Platinum Recliner	normal	1.60
302	5	E	10	E10	Platinum Recliner	normal	1.60
303	5	F	1	F1	Platinum Recliner	normal	1.60
304	5	F	2	F2	Platinum Recliner	normal	1.60
305	5	F	3	F3	Platinum Recliner	normal	1.60
306	5	F	4	F4	Platinum Recliner	normal	1.60
307	5	F	5	F5	Platinum Recliner	normal	1.60
308	5	F	6	F6	Platinum Recliner	normal	1.60
309	5	F	7	F7	Platinum Recliner	normal	1.60
310	5	F	8	F8	Platinum Recliner	normal	1.60
311	5	F	9	F9	Platinum Recliner	normal	1.60
312	5	F	10	F10	Platinum Recliner	normal	1.60
313	6	A	1	A1	Silver	normal	1.00
314	6	A	2	A2	Silver	normal	1.00
315	6	A	3	A3	Silver	normal	1.00
316	6	A	4	A4	Silver	normal	1.00
317	6	A	5	A5	Silver	normal	1.00
318	6	A	6	A6	Silver	normal	1.00
319	6	A	7	A7	Silver	normal	1.00
320	6	A	8	A8	Silver	normal	1.00
321	6	A	9	A9	Silver	normal	1.00
322	6	A	10	A10	Silver	normal	1.00
323	6	A	11	A11	Silver	normal	1.00
324	6	A	12	A12	Silver	normal	1.00
325	6	B	1	B1	Silver	normal	1.00
326	6	B	2	B2	Silver	normal	1.00
327	6	B	3	B3	Silver	normal	1.00
328	6	B	4	B4	Silver	normal	1.00
329	6	B	5	B5	Silver	normal	1.00
330	6	B	6	B6	Silver	normal	1.00
331	6	B	7	B7	Silver	normal	1.00
332	6	B	8	B8	Silver	normal	1.00
333	6	B	9	B9	Silver	normal	1.00
334	6	B	10	B10	Silver	normal	1.00
335	6	B	11	B11	Silver	normal	1.00
336	6	B	12	B12	Silver	normal	1.00
337	6	C	1	C1	Gold	normal	1.25
338	6	C	2	C2	Gold	normal	1.25
339	6	C	3	C3	Gold	normal	1.25
340	6	C	4	C4	Gold	normal	1.25
341	6	C	5	C5	Gold	normal	1.25
342	6	C	6	C6	Gold	normal	1.25
343	6	C	7	C7	Gold	normal	1.25
344	6	C	8	C8	Gold	normal	1.25
345	6	C	9	C9	Gold	normal	1.25
346	6	C	10	C10	Gold	normal	1.25
347	6	C	11	C11	Gold	normal	1.25
348	6	C	12	C12	Gold	normal	1.25
349	6	D	1	D1	Gold	normal	1.25
350	6	D	2	D2	Gold	normal	1.25
351	6	D	3	D3	Gold	normal	1.25
352	6	D	4	D4	Gold	normal	1.25
353	6	D	5	D5	Gold	normal	1.25
354	6	D	6	D6	Gold	normal	1.25
355	6	D	7	D7	Gold	normal	1.25
356	6	D	8	D8	Gold	normal	1.25
357	6	D	9	D9	Gold	normal	1.25
358	6	D	10	D10	Gold	normal	1.25
359	6	D	11	D11	Gold	normal	1.25
360	6	D	12	D12	Gold	normal	1.25
361	6	E	1	E1	Platinum Recliner	normal	1.60
362	6	E	2	E2	Platinum Recliner	normal	1.60
363	6	E	3	E3	Platinum Recliner	normal	1.60
364	6	E	4	E4	Platinum Recliner	normal	1.60
365	6	E	5	E5	Platinum Recliner	normal	1.60
366	6	E	6	E6	Platinum Recliner	normal	1.60
367	6	E	7	E7	Platinum Recliner	normal	1.60
368	6	E	8	E8	Platinum Recliner	normal	1.60
369	6	E	9	E9	Platinum Recliner	normal	1.60
370	6	E	10	E10	Platinum Recliner	normal	1.60
371	6	E	11	E11	Platinum Recliner	normal	1.60
372	6	E	12	E12	Platinum Recliner	normal	1.60
373	6	F	1	F1	Platinum Recliner	normal	1.60
374	6	F	2	F2	Platinum Recliner	normal	1.60
375	6	F	3	F3	Platinum Recliner	normal	1.60
376	6	F	4	F4	Platinum Recliner	normal	1.60
377	6	F	5	F5	Platinum Recliner	normal	1.60
378	6	F	6	F6	Platinum Recliner	normal	1.60
379	6	F	7	F7	Platinum Recliner	normal	1.60
380	6	F	8	F8	Platinum Recliner	normal	1.60
381	6	F	9	F9	Platinum Recliner	normal	1.60
382	6	F	10	F10	Platinum Recliner	normal	1.60
383	6	F	11	F11	Platinum Recliner	normal	1.60
384	6	F	12	F12	Platinum Recliner	normal	1.60
385	7	A	1	A1	Silver	normal	1.00
386	7	A	2	A2	Silver	normal	1.00
387	7	A	3	A3	Silver	normal	1.00
388	7	A	4	A4	Silver	normal	1.00
389	7	A	5	A5	Silver	normal	1.00
390	7	A	6	A6	Silver	normal	1.00
391	7	A	7	A7	Silver	normal	1.00
392	7	A	8	A8	Silver	normal	1.00
393	7	B	1	B1	Silver	normal	1.00
394	7	B	2	B2	Silver	normal	1.00
395	7	B	3	B3	Silver	normal	1.00
396	7	B	4	B4	Silver	normal	1.00
397	7	B	5	B5	Silver	normal	1.00
398	7	B	6	B6	Silver	normal	1.00
399	7	B	7	B7	Silver	normal	1.00
400	7	B	8	B8	Silver	normal	1.00
401	7	C	1	C1	Gold	normal	1.25
402	7	C	2	C2	Gold	normal	1.25
403	7	C	3	C3	Gold	normal	1.25
404	7	C	4	C4	Gold	normal	1.25
405	7	C	5	C5	Gold	normal	1.25
406	7	C	6	C6	Gold	normal	1.25
407	7	C	7	C7	Gold	normal	1.25
408	7	C	8	C8	Gold	normal	1.25
409	7	D	1	D1	Gold	normal	1.25
410	7	D	2	D2	Gold	normal	1.25
411	7	D	3	D3	Gold	normal	1.25
412	7	D	4	D4	Gold	normal	1.25
413	7	D	5	D5	Gold	normal	1.25
414	7	D	6	D6	Gold	normal	1.25
415	7	D	7	D7	Gold	normal	1.25
416	7	D	8	D8	Gold	normal	1.25
417	7	E	1	E1	Platinum Recliner	normal	1.60
418	7	E	2	E2	Platinum Recliner	normal	1.60
419	7	E	3	E3	Platinum Recliner	normal	1.60
420	7	E	4	E4	Platinum Recliner	normal	1.60
421	7	E	5	E5	Platinum Recliner	normal	1.60
422	7	E	6	E6	Platinum Recliner	normal	1.60
423	7	E	7	E7	Platinum Recliner	normal	1.60
424	7	E	8	E8	Platinum Recliner	normal	1.60
425	7	F	1	F1	Platinum Recliner	normal	1.60
426	7	F	2	F2	Platinum Recliner	normal	1.60
427	7	F	3	F3	Platinum Recliner	normal	1.60
428	7	F	4	F4	Platinum Recliner	normal	1.60
429	7	F	5	F5	Platinum Recliner	normal	1.60
430	7	F	6	F6	Platinum Recliner	normal	1.60
431	7	F	7	F7	Platinum Recliner	normal	1.60
432	7	F	8	F8	Platinum Recliner	normal	1.60
433	8	A	1	A1	Silver	normal	1.00
434	8	A	2	A2	Silver	normal	1.00
435	8	A	3	A3	Silver	normal	1.00
436	8	A	4	A4	Silver	normal	1.00
437	8	A	5	A5	Silver	normal	1.00
438	8	A	6	A6	Silver	normal	1.00
439	8	A	7	A7	Silver	normal	1.00
440	8	A	8	A8	Silver	normal	1.00
441	8	B	1	B1	Silver	normal	1.00
442	8	B	2	B2	Silver	normal	1.00
443	8	B	3	B3	Silver	normal	1.00
444	8	B	4	B4	Silver	normal	1.00
445	8	B	5	B5	Silver	normal	1.00
446	8	B	6	B6	Silver	normal	1.00
447	8	B	7	B7	Silver	normal	1.00
448	8	B	8	B8	Silver	normal	1.00
449	8	C	1	C1	Gold	normal	1.25
450	8	C	2	C2	Gold	normal	1.25
451	8	C	3	C3	Gold	normal	1.25
452	8	C	4	C4	Gold	normal	1.25
453	8	C	5	C5	Gold	normal	1.25
454	8	C	6	C6	Gold	normal	1.25
455	8	C	7	C7	Gold	normal	1.25
456	8	C	8	C8	Gold	normal	1.25
457	8	D	1	D1	Gold	normal	1.25
458	8	D	2	D2	Gold	normal	1.25
459	8	D	3	D3	Gold	normal	1.25
460	8	D	4	D4	Gold	normal	1.25
461	8	D	5	D5	Gold	normal	1.25
462	8	D	6	D6	Gold	normal	1.25
463	8	D	7	D7	Gold	normal	1.25
464	8	D	8	D8	Gold	normal	1.25
465	8	E	1	E1	Platinum Recliner	normal	1.60
466	8	E	2	E2	Platinum Recliner	normal	1.60
467	8	E	3	E3	Platinum Recliner	normal	1.60
468	8	E	4	E4	Platinum Recliner	normal	1.60
469	8	E	5	E5	Platinum Recliner	normal	1.60
470	8	E	6	E6	Platinum Recliner	normal	1.60
471	8	E	7	E7	Platinum Recliner	normal	1.60
472	8	E	8	E8	Platinum Recliner	normal	1.60
473	8	F	1	F1	Platinum Recliner	normal	1.60
474	8	F	2	F2	Platinum Recliner	normal	1.60
475	8	F	3	F3	Platinum Recliner	normal	1.60
476	8	F	4	F4	Platinum Recliner	normal	1.60
477	8	F	5	F5	Platinum Recliner	normal	1.60
478	8	F	6	F6	Platinum Recliner	normal	1.60
479	8	F	7	F7	Platinum Recliner	normal	1.60
480	8	F	8	F8	Platinum Recliner	normal	1.60
481	9	A	1	A1	Silver	normal	1.00
482	9	A	2	A2	Silver	normal	1.00
483	9	A	3	A3	Silver	normal	1.00
484	9	A	4	A4	Silver	normal	1.00
485	9	A	5	A5	Silver	normal	1.00
486	9	A	6	A6	Silver	normal	1.00
487	9	A	7	A7	Silver	normal	1.00
488	9	A	8	A8	Silver	normal	1.00
489	9	A	9	A9	Silver	normal	1.00
490	9	A	10	A10	Silver	normal	1.00
491	9	A	11	A11	Silver	normal	1.00
492	9	A	12	A12	Silver	normal	1.00
493	9	B	1	B1	Silver	normal	1.00
494	9	B	2	B2	Silver	normal	1.00
495	9	B	3	B3	Silver	normal	1.00
496	9	B	4	B4	Silver	normal	1.00
497	9	B	5	B5	Silver	normal	1.00
498	9	B	6	B6	Silver	normal	1.00
499	9	B	7	B7	Silver	normal	1.00
500	9	B	8	B8	Silver	normal	1.00
501	9	B	9	B9	Silver	normal	1.00
502	9	B	10	B10	Silver	normal	1.00
503	9	B	11	B11	Silver	normal	1.00
504	9	B	12	B12	Silver	normal	1.00
505	9	C	1	C1	Gold	normal	1.25
506	9	C	2	C2	Gold	normal	1.25
507	9	C	3	C3	Gold	normal	1.25
508	9	C	4	C4	Gold	normal	1.25
509	9	C	5	C5	Gold	normal	1.25
510	9	C	6	C6	Gold	normal	1.25
511	9	C	7	C7	Gold	normal	1.25
512	9	C	8	C8	Gold	normal	1.25
513	9	C	9	C9	Gold	normal	1.25
514	9	C	10	C10	Gold	normal	1.25
515	9	C	11	C11	Gold	normal	1.25
516	9	C	12	C12	Gold	normal	1.25
517	9	D	1	D1	Gold	normal	1.25
518	9	D	2	D2	Gold	normal	1.25
519	9	D	3	D3	Gold	normal	1.25
520	9	D	4	D4	Gold	normal	1.25
521	9	D	5	D5	Gold	normal	1.25
522	9	D	6	D6	Gold	normal	1.25
523	9	D	7	D7	Gold	normal	1.25
524	9	D	8	D8	Gold	normal	1.25
525	9	D	9	D9	Gold	normal	1.25
526	9	D	10	D10	Gold	normal	1.25
527	9	D	11	D11	Gold	normal	1.25
528	9	D	12	D12	Gold	normal	1.25
529	9	E	1	E1	Platinum Recliner	normal	1.60
530	9	E	2	E2	Platinum Recliner	normal	1.60
531	9	E	3	E3	Platinum Recliner	normal	1.60
532	9	E	4	E4	Platinum Recliner	normal	1.60
533	9	E	5	E5	Platinum Recliner	normal	1.60
534	9	E	6	E6	Platinum Recliner	normal	1.60
535	9	E	7	E7	Platinum Recliner	normal	1.60
536	9	E	8	E8	Platinum Recliner	normal	1.60
537	9	E	9	E9	Platinum Recliner	normal	1.60
538	9	E	10	E10	Platinum Recliner	normal	1.60
539	9	E	11	E11	Platinum Recliner	normal	1.60
540	9	E	12	E12	Platinum Recliner	normal	1.60
541	9	F	1	F1	Platinum Recliner	normal	1.60
542	9	F	2	F2	Platinum Recliner	normal	1.60
543	9	F	3	F3	Platinum Recliner	normal	1.60
544	9	F	4	F4	Platinum Recliner	normal	1.60
545	9	F	5	F5	Platinum Recliner	normal	1.60
546	9	F	6	F6	Platinum Recliner	normal	1.60
547	9	F	7	F7	Platinum Recliner	normal	1.60
548	9	F	8	F8	Platinum Recliner	normal	1.60
549	9	F	9	F9	Platinum Recliner	normal	1.60
550	9	F	10	F10	Platinum Recliner	normal	1.60
551	9	F	11	F11	Platinum Recliner	normal	1.60
552	9	F	12	F12	Platinum Recliner	normal	1.60
553	10	A	1	A1	Silver	normal	1.00
554	10	A	2	A2	Silver	normal	1.00
555	10	A	3	A3	Silver	normal	1.00
556	10	A	4	A4	Silver	normal	1.00
557	10	A	5	A5	Silver	normal	1.00
558	10	A	6	A6	Silver	normal	1.00
559	10	A	7	A7	Silver	normal	1.00
560	10	A	8	A8	Silver	normal	1.00
561	10	A	9	A9	Silver	normal	1.00
562	10	A	10	A10	Silver	normal	1.00
563	10	B	1	B1	Silver	normal	1.00
564	10	B	2	B2	Silver	normal	1.00
565	10	B	3	B3	Silver	normal	1.00
566	10	B	4	B4	Silver	normal	1.00
567	10	B	5	B5	Silver	normal	1.00
568	10	B	6	B6	Silver	normal	1.00
569	10	B	7	B7	Silver	normal	1.00
570	10	B	8	B8	Silver	normal	1.00
571	10	B	9	B9	Silver	normal	1.00
572	10	B	10	B10	Silver	normal	1.00
573	10	C	1	C1	Gold	normal	1.25
574	10	C	2	C2	Gold	normal	1.25
575	10	C	3	C3	Gold	normal	1.25
576	10	C	4	C4	Gold	normal	1.25
577	10	C	5	C5	Gold	normal	1.25
578	10	C	6	C6	Gold	normal	1.25
579	10	C	7	C7	Gold	normal	1.25
580	10	C	8	C8	Gold	normal	1.25
581	10	C	9	C9	Gold	normal	1.25
582	10	C	10	C10	Gold	normal	1.25
583	10	D	1	D1	Gold	normal	1.25
584	10	D	2	D2	Gold	normal	1.25
585	10	D	3	D3	Gold	normal	1.25
586	10	D	4	D4	Gold	normal	1.25
587	10	D	5	D5	Gold	normal	1.25
588	10	D	6	D6	Gold	normal	1.25
589	10	D	7	D7	Gold	normal	1.25
590	10	D	8	D8	Gold	normal	1.25
591	10	D	9	D9	Gold	normal	1.25
592	10	D	10	D10	Gold	normal	1.25
593	10	E	1	E1	Platinum Recliner	normal	1.60
594	10	E	2	E2	Platinum Recliner	normal	1.60
595	10	E	3	E3	Platinum Recliner	normal	1.60
596	10	E	4	E4	Platinum Recliner	normal	1.60
597	10	E	5	E5	Platinum Recliner	normal	1.60
598	10	E	6	E6	Platinum Recliner	normal	1.60
599	10	E	7	E7	Platinum Recliner	normal	1.60
600	10	E	8	E8	Platinum Recliner	normal	1.60
601	10	E	9	E9	Platinum Recliner	normal	1.60
602	10	E	10	E10	Platinum Recliner	normal	1.60
603	10	F	1	F1	Platinum Recliner	normal	1.60
604	10	F	2	F2	Platinum Recliner	normal	1.60
605	10	F	3	F3	Platinum Recliner	normal	1.60
606	10	F	4	F4	Platinum Recliner	normal	1.60
607	10	F	5	F5	Platinum Recliner	normal	1.60
608	10	F	6	F6	Platinum Recliner	normal	1.60
609	10	F	7	F7	Platinum Recliner	normal	1.60
610	10	F	8	F8	Platinum Recliner	normal	1.60
611	10	F	9	F9	Platinum Recliner	normal	1.60
612	10	F	10	F10	Platinum Recliner	normal	1.60
613	11	A	1	A1	Silver	normal	1.00
614	11	A	2	A2	Silver	normal	1.00
615	11	A	3	A3	Silver	normal	1.00
616	11	A	4	A4	Silver	normal	1.00
617	11	A	5	A5	Silver	normal	1.00
618	11	A	6	A6	Silver	normal	1.00
619	11	A	7	A7	Silver	normal	1.00
620	11	A	8	A8	Silver	normal	1.00
621	11	A	9	A9	Silver	normal	1.00
622	11	A	10	A10	Silver	normal	1.00
623	11	A	11	A11	Silver	normal	1.00
624	11	A	12	A12	Silver	normal	1.00
625	11	B	1	B1	Silver	normal	1.00
626	11	B	2	B2	Silver	normal	1.00
627	11	B	3	B3	Silver	normal	1.00
628	11	B	4	B4	Silver	normal	1.00
629	11	B	5	B5	Silver	normal	1.00
630	11	B	6	B6	Silver	normal	1.00
631	11	B	7	B7	Silver	normal	1.00
632	11	B	8	B8	Silver	normal	1.00
633	11	B	9	B9	Silver	normal	1.00
634	11	B	10	B10	Silver	normal	1.00
635	11	B	11	B11	Silver	normal	1.00
636	11	B	12	B12	Silver	normal	1.00
637	11	C	1	C1	Gold	normal	1.25
638	11	C	2	C2	Gold	normal	1.25
639	11	C	3	C3	Gold	normal	1.25
640	11	C	4	C4	Gold	normal	1.25
641	11	C	5	C5	Gold	normal	1.25
642	11	C	6	C6	Gold	normal	1.25
643	11	C	7	C7	Gold	normal	1.25
644	11	C	8	C8	Gold	normal	1.25
645	11	C	9	C9	Gold	normal	1.25
646	11	C	10	C10	Gold	normal	1.25
647	11	C	11	C11	Gold	normal	1.25
648	11	C	12	C12	Gold	normal	1.25
649	11	D	1	D1	Gold	normal	1.25
650	11	D	2	D2	Gold	normal	1.25
651	11	D	3	D3	Gold	normal	1.25
652	11	D	4	D4	Gold	normal	1.25
653	11	D	5	D5	Gold	normal	1.25
654	11	D	6	D6	Gold	normal	1.25
655	11	D	7	D7	Gold	normal	1.25
656	11	D	8	D8	Gold	normal	1.25
657	11	D	9	D9	Gold	normal	1.25
658	11	D	10	D10	Gold	normal	1.25
659	11	D	11	D11	Gold	normal	1.25
660	11	D	12	D12	Gold	normal	1.25
661	11	E	1	E1	Platinum Recliner	normal	1.60
662	11	E	2	E2	Platinum Recliner	normal	1.60
663	11	E	3	E3	Platinum Recliner	normal	1.60
664	11	E	4	E4	Platinum Recliner	normal	1.60
665	11	E	5	E5	Platinum Recliner	normal	1.60
666	11	E	6	E6	Platinum Recliner	normal	1.60
667	11	E	7	E7	Platinum Recliner	normal	1.60
668	11	E	8	E8	Platinum Recliner	normal	1.60
669	11	E	9	E9	Platinum Recliner	normal	1.60
670	11	E	10	E10	Platinum Recliner	normal	1.60
671	11	E	11	E11	Platinum Recliner	normal	1.60
672	11	E	12	E12	Platinum Recliner	normal	1.60
673	11	F	1	F1	Platinum Recliner	normal	1.60
674	11	F	2	F2	Platinum Recliner	normal	1.60
675	11	F	3	F3	Platinum Recliner	normal	1.60
676	11	F	4	F4	Platinum Recliner	normal	1.60
677	11	F	5	F5	Platinum Recliner	normal	1.60
678	11	F	6	F6	Platinum Recliner	normal	1.60
679	11	F	7	F7	Platinum Recliner	normal	1.60
680	11	F	8	F8	Platinum Recliner	normal	1.60
681	11	F	9	F9	Platinum Recliner	normal	1.60
682	11	F	10	F10	Platinum Recliner	normal	1.60
683	11	F	11	F11	Platinum Recliner	normal	1.60
684	11	F	12	F12	Platinum Recliner	normal	1.60
685	12	A	1	A1	Silver	normal	1.00
686	12	A	2	A2	Silver	normal	1.00
687	12	A	3	A3	Silver	normal	1.00
688	12	A	4	A4	Silver	normal	1.00
689	12	A	5	A5	Silver	normal	1.00
690	12	A	6	A6	Silver	normal	1.00
691	12	A	7	A7	Silver	normal	1.00
692	12	A	8	A8	Silver	normal	1.00
693	12	A	9	A9	Silver	normal	1.00
694	12	A	10	A10	Silver	normal	1.00
695	12	A	11	A11	Silver	normal	1.00
696	12	A	12	A12	Silver	normal	1.00
697	12	B	1	B1	Silver	normal	1.00
698	12	B	2	B2	Silver	normal	1.00
699	12	B	3	B3	Silver	normal	1.00
700	12	B	4	B4	Silver	normal	1.00
701	12	B	5	B5	Silver	normal	1.00
702	12	B	6	B6	Silver	normal	1.00
703	12	B	7	B7	Silver	normal	1.00
704	12	B	8	B8	Silver	normal	1.00
705	12	B	9	B9	Silver	normal	1.00
706	12	B	10	B10	Silver	normal	1.00
707	12	B	11	B11	Silver	normal	1.00
708	12	B	12	B12	Silver	normal	1.00
709	12	C	1	C1	Gold	normal	1.25
710	12	C	2	C2	Gold	normal	1.25
711	12	C	3	C3	Gold	normal	1.25
712	12	C	4	C4	Gold	normal	1.25
713	12	C	5	C5	Gold	normal	1.25
714	12	C	6	C6	Gold	normal	1.25
715	12	C	7	C7	Gold	normal	1.25
716	12	C	8	C8	Gold	normal	1.25
717	12	C	9	C9	Gold	normal	1.25
718	12	C	10	C10	Gold	normal	1.25
719	12	C	11	C11	Gold	normal	1.25
720	12	C	12	C12	Gold	normal	1.25
721	12	D	1	D1	Gold	normal	1.25
722	12	D	2	D2	Gold	normal	1.25
723	12	D	3	D3	Gold	normal	1.25
724	12	D	4	D4	Gold	normal	1.25
725	12	D	5	D5	Gold	normal	1.25
726	12	D	6	D6	Gold	normal	1.25
727	12	D	7	D7	Gold	normal	1.25
728	12	D	8	D8	Gold	normal	1.25
729	12	D	9	D9	Gold	normal	1.25
730	12	D	10	D10	Gold	normal	1.25
731	12	D	11	D11	Gold	normal	1.25
732	12	D	12	D12	Gold	normal	1.25
733	12	E	1	E1	Platinum Recliner	normal	1.60
734	12	E	2	E2	Platinum Recliner	normal	1.60
735	12	E	3	E3	Platinum Recliner	normal	1.60
736	12	E	4	E4	Platinum Recliner	normal	1.60
737	12	E	5	E5	Platinum Recliner	normal	1.60
738	12	E	6	E6	Platinum Recliner	normal	1.60
739	12	E	7	E7	Platinum Recliner	normal	1.60
740	12	E	8	E8	Platinum Recliner	normal	1.60
741	12	E	9	E9	Platinum Recliner	normal	1.60
742	12	E	10	E10	Platinum Recliner	normal	1.60
743	12	E	11	E11	Platinum Recliner	normal	1.60
744	12	E	12	E12	Platinum Recliner	normal	1.60
745	12	F	1	F1	Platinum Recliner	normal	1.60
746	12	F	2	F2	Platinum Recliner	normal	1.60
747	12	F	3	F3	Platinum Recliner	normal	1.60
748	12	F	4	F4	Platinum Recliner	normal	1.60
749	12	F	5	F5	Platinum Recliner	normal	1.60
750	12	F	6	F6	Platinum Recliner	normal	1.60
751	12	F	7	F7	Platinum Recliner	normal	1.60
752	12	F	8	F8	Platinum Recliner	normal	1.60
753	12	F	9	F9	Platinum Recliner	normal	1.60
754	12	F	10	F10	Platinum Recliner	normal	1.60
755	12	F	11	F11	Platinum Recliner	normal	1.60
756	12	F	12	F12	Platinum Recliner	normal	1.60
757	13	A	1	A1	Silver	normal	1.00
758	13	A	2	A2	Silver	normal	1.00
759	13	A	3	A3	Silver	normal	1.00
760	13	A	4	A4	Silver	normal	1.00
761	13	A	5	A5	Silver	normal	1.00
762	13	A	6	A6	Silver	normal	1.00
763	13	A	7	A7	Silver	normal	1.00
764	13	A	8	A8	Silver	normal	1.00
765	13	A	9	A9	Silver	normal	1.00
766	13	A	10	A10	Silver	normal	1.00
767	13	A	11	A11	Silver	normal	1.00
768	13	A	12	A12	Silver	normal	1.00
769	13	B	1	B1	Silver	normal	1.00
770	13	B	2	B2	Silver	normal	1.00
771	13	B	3	B3	Silver	normal	1.00
772	13	B	4	B4	Silver	normal	1.00
773	13	B	5	B5	Silver	normal	1.00
774	13	B	6	B6	Silver	normal	1.00
775	13	B	7	B7	Silver	normal	1.00
776	13	B	8	B8	Silver	normal	1.00
777	13	B	9	B9	Silver	normal	1.00
778	13	B	10	B10	Silver	normal	1.00
779	13	B	11	B11	Silver	normal	1.00
780	13	B	12	B12	Silver	normal	1.00
781	13	C	1	C1	Gold	normal	1.25
782	13	C	2	C2	Gold	normal	1.25
783	13	C	3	C3	Gold	normal	1.25
784	13	C	4	C4	Gold	normal	1.25
785	13	C	5	C5	Gold	normal	1.25
786	13	C	6	C6	Gold	normal	1.25
787	13	C	7	C7	Gold	normal	1.25
788	13	C	8	C8	Gold	normal	1.25
789	13	C	9	C9	Gold	normal	1.25
790	13	C	10	C10	Gold	normal	1.25
791	13	C	11	C11	Gold	normal	1.25
792	13	C	12	C12	Gold	normal	1.25
793	13	D	1	D1	Gold	normal	1.25
794	13	D	2	D2	Gold	normal	1.25
795	13	D	3	D3	Gold	normal	1.25
796	13	D	4	D4	Gold	normal	1.25
797	13	D	5	D5	Gold	normal	1.25
798	13	D	6	D6	Gold	normal	1.25
799	13	D	7	D7	Gold	normal	1.25
800	13	D	8	D8	Gold	normal	1.25
801	13	D	9	D9	Gold	normal	1.25
802	13	D	10	D10	Gold	normal	1.25
803	13	D	11	D11	Gold	normal	1.25
804	13	D	12	D12	Gold	normal	1.25
805	13	E	1	E1	Platinum Recliner	normal	1.60
806	13	E	2	E2	Platinum Recliner	normal	1.60
807	13	E	3	E3	Platinum Recliner	normal	1.60
808	13	E	4	E4	Platinum Recliner	normal	1.60
809	13	E	5	E5	Platinum Recliner	normal	1.60
810	13	E	6	E6	Platinum Recliner	normal	1.60
811	13	E	7	E7	Platinum Recliner	normal	1.60
812	13	E	8	E8	Platinum Recliner	normal	1.60
813	13	E	9	E9	Platinum Recliner	normal	1.60
814	13	E	10	E10	Platinum Recliner	normal	1.60
815	13	E	11	E11	Platinum Recliner	normal	1.60
816	13	E	12	E12	Platinum Recliner	normal	1.60
817	13	F	1	F1	Platinum Recliner	normal	1.60
818	13	F	2	F2	Platinum Recliner	normal	1.60
819	13	F	3	F3	Platinum Recliner	normal	1.60
820	13	F	4	F4	Platinum Recliner	normal	1.60
821	13	F	5	F5	Platinum Recliner	normal	1.60
822	13	F	6	F6	Platinum Recliner	normal	1.60
823	13	F	7	F7	Platinum Recliner	normal	1.60
824	13	F	8	F8	Platinum Recliner	normal	1.60
825	13	F	9	F9	Platinum Recliner	normal	1.60
826	13	F	10	F10	Platinum Recliner	normal	1.60
827	13	F	11	F11	Platinum Recliner	normal	1.60
828	13	F	12	F12	Platinum Recliner	normal	1.60
829	14	A	1	A1	Silver	normal	1.00
830	14	A	2	A2	Silver	normal	1.00
831	14	A	3	A3	Silver	normal	1.00
832	14	A	4	A4	Silver	normal	1.00
833	14	A	5	A5	Silver	normal	1.00
834	14	A	6	A6	Silver	normal	1.00
835	14	A	7	A7	Silver	normal	1.00
836	14	A	8	A8	Silver	normal	1.00
837	14	A	9	A9	Silver	normal	1.00
838	14	A	10	A10	Silver	normal	1.00
839	14	A	11	A11	Silver	normal	1.00
840	14	A	12	A12	Silver	normal	1.00
841	14	B	1	B1	Silver	normal	1.00
842	14	B	2	B2	Silver	normal	1.00
843	14	B	3	B3	Silver	normal	1.00
844	14	B	4	B4	Silver	normal	1.00
845	14	B	5	B5	Silver	normal	1.00
846	14	B	6	B6	Silver	normal	1.00
847	14	B	7	B7	Silver	normal	1.00
848	14	B	8	B8	Silver	normal	1.00
849	14	B	9	B9	Silver	normal	1.00
850	14	B	10	B10	Silver	normal	1.00
851	14	B	11	B11	Silver	normal	1.00
852	14	B	12	B12	Silver	normal	1.00
853	14	C	1	C1	Gold	normal	1.25
854	14	C	2	C2	Gold	normal	1.25
855	14	C	3	C3	Gold	normal	1.25
856	14	C	4	C4	Gold	normal	1.25
857	14	C	5	C5	Gold	normal	1.25
858	14	C	6	C6	Gold	normal	1.25
859	14	C	7	C7	Gold	normal	1.25
860	14	C	8	C8	Gold	normal	1.25
861	14	C	9	C9	Gold	normal	1.25
862	14	C	10	C10	Gold	normal	1.25
863	14	C	11	C11	Gold	normal	1.25
864	14	C	12	C12	Gold	normal	1.25
865	14	D	1	D1	Gold	normal	1.25
866	14	D	2	D2	Gold	normal	1.25
867	14	D	3	D3	Gold	normal	1.25
868	14	D	4	D4	Gold	normal	1.25
869	14	D	5	D5	Gold	normal	1.25
870	14	D	6	D6	Gold	normal	1.25
871	14	D	7	D7	Gold	normal	1.25
872	14	D	8	D8	Gold	normal	1.25
873	14	D	9	D9	Gold	normal	1.25
874	14	D	10	D10	Gold	normal	1.25
875	14	D	11	D11	Gold	normal	1.25
876	14	D	12	D12	Gold	normal	1.25
877	14	E	1	E1	Platinum Recliner	normal	1.60
878	14	E	2	E2	Platinum Recliner	normal	1.60
879	14	E	3	E3	Platinum Recliner	normal	1.60
880	14	E	4	E4	Platinum Recliner	normal	1.60
881	14	E	5	E5	Platinum Recliner	normal	1.60
882	14	E	6	E6	Platinum Recliner	normal	1.60
883	14	E	7	E7	Platinum Recliner	normal	1.60
884	14	E	8	E8	Platinum Recliner	normal	1.60
885	14	E	9	E9	Platinum Recliner	normal	1.60
886	14	E	10	E10	Platinum Recliner	normal	1.60
887	14	E	11	E11	Platinum Recliner	normal	1.60
888	14	E	12	E12	Platinum Recliner	normal	1.60
889	14	F	1	F1	Platinum Recliner	normal	1.60
890	14	F	2	F2	Platinum Recliner	normal	1.60
891	14	F	3	F3	Platinum Recliner	normal	1.60
892	14	F	4	F4	Platinum Recliner	normal	1.60
893	14	F	5	F5	Platinum Recliner	normal	1.60
894	14	F	6	F6	Platinum Recliner	normal	1.60
895	14	F	7	F7	Platinum Recliner	normal	1.60
896	14	F	8	F8	Platinum Recliner	normal	1.60
897	14	F	9	F9	Platinum Recliner	normal	1.60
898	14	F	10	F10	Platinum Recliner	normal	1.60
899	14	F	11	F11	Platinum Recliner	normal	1.60
900	14	F	12	F12	Platinum Recliner	normal	1.60
901	15	A	1	A1	Silver	normal	1.00
902	15	A	2	A2	Silver	normal	1.00
903	15	A	3	A3	Silver	normal	1.00
904	15	A	4	A4	Silver	normal	1.00
905	15	A	5	A5	Silver	normal	1.00
906	15	A	6	A6	Silver	normal	1.00
907	15	A	7	A7	Silver	normal	1.00
908	15	A	8	A8	Silver	normal	1.00
909	15	A	9	A9	Silver	normal	1.00
910	15	A	10	A10	Silver	normal	1.00
911	15	A	11	A11	Silver	normal	1.00
912	15	A	12	A12	Silver	normal	1.00
913	15	B	1	B1	Silver	normal	1.00
914	15	B	2	B2	Silver	normal	1.00
915	15	B	3	B3	Silver	normal	1.00
916	15	B	4	B4	Silver	normal	1.00
917	15	B	5	B5	Silver	normal	1.00
918	15	B	6	B6	Silver	normal	1.00
919	15	B	7	B7	Silver	normal	1.00
920	15	B	8	B8	Silver	normal	1.00
921	15	B	9	B9	Silver	normal	1.00
922	15	B	10	B10	Silver	normal	1.00
923	15	B	11	B11	Silver	normal	1.00
924	15	B	12	B12	Silver	normal	1.00
925	15	C	1	C1	Gold	normal	1.25
926	15	C	2	C2	Gold	normal	1.25
927	15	C	3	C3	Gold	normal	1.25
928	15	C	4	C4	Gold	normal	1.25
929	15	C	5	C5	Gold	normal	1.25
930	15	C	6	C6	Gold	normal	1.25
931	15	C	7	C7	Gold	normal	1.25
932	15	C	8	C8	Gold	normal	1.25
933	15	C	9	C9	Gold	normal	1.25
934	15	C	10	C10	Gold	normal	1.25
935	15	C	11	C11	Gold	normal	1.25
936	15	C	12	C12	Gold	normal	1.25
937	15	D	1	D1	Gold	normal	1.25
938	15	D	2	D2	Gold	normal	1.25
939	15	D	3	D3	Gold	normal	1.25
940	15	D	4	D4	Gold	normal	1.25
941	15	D	5	D5	Gold	normal	1.25
942	15	D	6	D6	Gold	normal	1.25
943	15	D	7	D7	Gold	normal	1.25
944	15	D	8	D8	Gold	normal	1.25
945	15	D	9	D9	Gold	normal	1.25
946	15	D	10	D10	Gold	normal	1.25
947	15	D	11	D11	Gold	normal	1.25
948	15	D	12	D12	Gold	normal	1.25
949	15	E	1	E1	Platinum Recliner	normal	1.60
950	15	E	2	E2	Platinum Recliner	normal	1.60
951	15	E	3	E3	Platinum Recliner	normal	1.60
952	15	E	4	E4	Platinum Recliner	normal	1.60
953	15	E	5	E5	Platinum Recliner	normal	1.60
954	15	E	6	E6	Platinum Recliner	normal	1.60
955	15	E	7	E7	Platinum Recliner	normal	1.60
956	15	E	8	E8	Platinum Recliner	normal	1.60
957	15	E	9	E9	Platinum Recliner	normal	1.60
958	15	E	10	E10	Platinum Recliner	normal	1.60
959	15	E	11	E11	Platinum Recliner	normal	1.60
960	15	E	12	E12	Platinum Recliner	normal	1.60
961	15	F	1	F1	Platinum Recliner	normal	1.60
962	15	F	2	F2	Platinum Recliner	normal	1.60
963	15	F	3	F3	Platinum Recliner	normal	1.60
964	15	F	4	F4	Platinum Recliner	normal	1.60
965	15	F	5	F5	Platinum Recliner	normal	1.60
966	15	F	6	F6	Platinum Recliner	normal	1.60
967	15	F	7	F7	Platinum Recliner	normal	1.60
968	15	F	8	F8	Platinum Recliner	normal	1.60
969	15	F	9	F9	Platinum Recliner	normal	1.60
970	15	F	10	F10	Platinum Recliner	normal	1.60
971	15	F	11	F11	Platinum Recliner	normal	1.60
972	15	F	12	F12	Platinum Recliner	normal	1.60
973	16	A	1	A1	Silver	normal	1.00
974	16	A	2	A2	Silver	normal	1.00
975	16	A	3	A3	Silver	normal	1.00
976	16	A	4	A4	Silver	normal	1.00
977	16	A	5	A5	Silver	normal	1.00
978	16	A	6	A6	Silver	normal	1.00
979	16	A	7	A7	Silver	normal	1.00
980	16	A	8	A8	Silver	normal	1.00
981	16	A	9	A9	Silver	normal	1.00
982	16	A	10	A10	Silver	normal	1.00
983	16	A	11	A11	Silver	normal	1.00
984	16	A	12	A12	Silver	normal	1.00
985	16	B	1	B1	Silver	normal	1.00
986	16	B	2	B2	Silver	normal	1.00
987	16	B	3	B3	Silver	normal	1.00
988	16	B	4	B4	Silver	normal	1.00
989	16	B	5	B5	Silver	normal	1.00
990	16	B	6	B6	Silver	normal	1.00
991	16	B	7	B7	Silver	normal	1.00
992	16	B	8	B8	Silver	normal	1.00
993	16	B	9	B9	Silver	normal	1.00
994	16	B	10	B10	Silver	normal	1.00
995	16	B	11	B11	Silver	normal	1.00
996	16	B	12	B12	Silver	normal	1.00
997	16	C	1	C1	Gold	normal	1.25
998	16	C	2	C2	Gold	normal	1.25
999	16	C	3	C3	Gold	normal	1.25
1000	16	C	4	C4	Gold	normal	1.25
1001	16	C	5	C5	Gold	normal	1.25
1002	16	C	6	C6	Gold	normal	1.25
1003	16	C	7	C7	Gold	normal	1.25
1004	16	C	8	C8	Gold	normal	1.25
1005	16	C	9	C9	Gold	normal	1.25
1006	16	C	10	C10	Gold	normal	1.25
1007	16	C	11	C11	Gold	normal	1.25
1008	16	C	12	C12	Gold	normal	1.25
1009	16	D	1	D1	Gold	normal	1.25
1010	16	D	2	D2	Gold	normal	1.25
1011	16	D	3	D3	Gold	normal	1.25
1012	16	D	4	D4	Gold	normal	1.25
1013	16	D	5	D5	Gold	normal	1.25
1014	16	D	6	D6	Gold	normal	1.25
1015	16	D	7	D7	Gold	normal	1.25
1016	16	D	8	D8	Gold	normal	1.25
1017	16	D	9	D9	Gold	normal	1.25
1018	16	D	10	D10	Gold	normal	1.25
1019	16	D	11	D11	Gold	normal	1.25
1020	16	D	12	D12	Gold	normal	1.25
1021	16	E	1	E1	Platinum Recliner	normal	1.60
1022	16	E	2	E2	Platinum Recliner	normal	1.60
1023	16	E	3	E3	Platinum Recliner	normal	1.60
1024	16	E	4	E4	Platinum Recliner	normal	1.60
1025	16	E	5	E5	Platinum Recliner	normal	1.60
1026	16	E	6	E6	Platinum Recliner	normal	1.60
1027	16	E	7	E7	Platinum Recliner	normal	1.60
1028	16	E	8	E8	Platinum Recliner	normal	1.60
1029	16	E	9	E9	Platinum Recliner	normal	1.60
1030	16	E	10	E10	Platinum Recliner	normal	1.60
1031	16	E	11	E11	Platinum Recliner	normal	1.60
1032	16	E	12	E12	Platinum Recliner	normal	1.60
1033	16	F	1	F1	Platinum Recliner	normal	1.60
1034	16	F	2	F2	Platinum Recliner	normal	1.60
1035	16	F	3	F3	Platinum Recliner	normal	1.60
1036	16	F	4	F4	Platinum Recliner	normal	1.60
1037	16	F	5	F5	Platinum Recliner	normal	1.60
1038	16	F	6	F6	Platinum Recliner	normal	1.60
1039	16	F	7	F7	Platinum Recliner	normal	1.60
1040	16	F	8	F8	Platinum Recliner	normal	1.60
1041	16	F	9	F9	Platinum Recliner	normal	1.60
1042	16	F	10	F10	Platinum Recliner	normal	1.60
1043	16	F	11	F11	Platinum Recliner	normal	1.60
1044	16	F	12	F12	Platinum Recliner	normal	1.60
1045	17	A	1	A1	Silver	normal	1.00
1046	17	A	2	A2	Silver	normal	1.00
1047	17	A	3	A3	Silver	normal	1.00
1048	17	A	4	A4	Silver	normal	1.00
1049	17	A	5	A5	Silver	normal	1.00
1050	17	A	6	A6	Silver	normal	1.00
1051	17	A	7	A7	Silver	normal	1.00
1052	17	A	8	A8	Silver	normal	1.00
1053	17	A	9	A9	Silver	normal	1.00
1054	17	A	10	A10	Silver	normal	1.00
1055	17	B	1	B1	Silver	normal	1.00
1056	17	B	2	B2	Silver	normal	1.00
1057	17	B	3	B3	Silver	normal	1.00
1058	17	B	4	B4	Silver	normal	1.00
1059	17	B	5	B5	Silver	normal	1.00
1060	17	B	6	B6	Silver	normal	1.00
1061	17	B	7	B7	Silver	normal	1.00
1062	17	B	8	B8	Silver	normal	1.00
1063	17	B	9	B9	Silver	normal	1.00
1064	17	B	10	B10	Silver	normal	1.00
1065	17	C	1	C1	Gold	normal	1.25
1066	17	C	2	C2	Gold	normal	1.25
1067	17	C	3	C3	Gold	normal	1.25
1068	17	C	4	C4	Gold	normal	1.25
1069	17	C	5	C5	Gold	normal	1.25
1070	17	C	6	C6	Gold	normal	1.25
1071	17	C	7	C7	Gold	normal	1.25
1072	17	C	8	C8	Gold	normal	1.25
1073	17	C	9	C9	Gold	normal	1.25
1074	17	C	10	C10	Gold	normal	1.25
1075	17	D	1	D1	Gold	normal	1.25
1076	17	D	2	D2	Gold	normal	1.25
1077	17	D	3	D3	Gold	normal	1.25
1078	17	D	4	D4	Gold	normal	1.25
1079	17	D	5	D5	Gold	normal	1.25
1080	17	D	6	D6	Gold	normal	1.25
1081	17	D	7	D7	Gold	normal	1.25
1082	17	D	8	D8	Gold	normal	1.25
1083	17	D	9	D9	Gold	normal	1.25
1084	17	D	10	D10	Gold	normal	1.25
1085	17	E	1	E1	Platinum Recliner	normal	1.60
1086	17	E	2	E2	Platinum Recliner	normal	1.60
1087	17	E	3	E3	Platinum Recliner	normal	1.60
1088	17	E	4	E4	Platinum Recliner	normal	1.60
1089	17	E	5	E5	Platinum Recliner	normal	1.60
1090	17	E	6	E6	Platinum Recliner	normal	1.60
1091	17	E	7	E7	Platinum Recliner	normal	1.60
1092	17	E	8	E8	Platinum Recliner	normal	1.60
1093	17	E	9	E9	Platinum Recliner	normal	1.60
1094	17	E	10	E10	Platinum Recliner	normal	1.60
1095	17	F	1	F1	Platinum Recliner	normal	1.60
1096	17	F	2	F2	Platinum Recliner	normal	1.60
1097	17	F	3	F3	Platinum Recliner	normal	1.60
1098	17	F	4	F4	Platinum Recliner	normal	1.60
1099	17	F	5	F5	Platinum Recliner	normal	1.60
1100	17	F	6	F6	Platinum Recliner	normal	1.60
1101	17	F	7	F7	Platinum Recliner	normal	1.60
1102	17	F	8	F8	Platinum Recliner	normal	1.60
1103	17	F	9	F9	Platinum Recliner	normal	1.60
1104	17	F	10	F10	Platinum Recliner	normal	1.60
1105	18	A	1	A1	Silver	normal	1.00
1106	18	A	2	A2	Silver	normal	1.00
1107	18	A	3	A3	Silver	normal	1.00
1108	18	A	4	A4	Silver	normal	1.00
1109	18	A	5	A5	Silver	normal	1.00
1110	18	A	6	A6	Silver	normal	1.00
1111	18	A	7	A7	Silver	normal	1.00
1112	18	A	8	A8	Silver	normal	1.00
1113	18	A	9	A9	Silver	normal	1.00
1114	18	A	10	A10	Silver	normal	1.00
1115	18	A	11	A11	Silver	normal	1.00
1116	18	A	12	A12	Silver	normal	1.00
1117	18	B	1	B1	Silver	normal	1.00
1118	18	B	2	B2	Silver	normal	1.00
1119	18	B	3	B3	Silver	normal	1.00
1120	18	B	4	B4	Silver	normal	1.00
1121	18	B	5	B5	Silver	normal	1.00
1122	18	B	6	B6	Silver	normal	1.00
1123	18	B	7	B7	Silver	normal	1.00
1124	18	B	8	B8	Silver	normal	1.00
1125	18	B	9	B9	Silver	normal	1.00
1126	18	B	10	B10	Silver	normal	1.00
1127	18	B	11	B11	Silver	normal	1.00
1128	18	B	12	B12	Silver	normal	1.00
1129	18	C	1	C1	Gold	normal	1.25
1130	18	C	2	C2	Gold	normal	1.25
1131	18	C	3	C3	Gold	normal	1.25
1132	18	C	4	C4	Gold	normal	1.25
1133	18	C	5	C5	Gold	normal	1.25
1134	18	C	6	C6	Gold	normal	1.25
1135	18	C	7	C7	Gold	normal	1.25
1136	18	C	8	C8	Gold	normal	1.25
1137	18	C	9	C9	Gold	normal	1.25
1138	18	C	10	C10	Gold	normal	1.25
1139	18	C	11	C11	Gold	normal	1.25
1140	18	C	12	C12	Gold	normal	1.25
1141	18	D	1	D1	Gold	normal	1.25
1142	18	D	2	D2	Gold	normal	1.25
1143	18	D	3	D3	Gold	normal	1.25
1144	18	D	4	D4	Gold	normal	1.25
1145	18	D	5	D5	Gold	normal	1.25
1146	18	D	6	D6	Gold	normal	1.25
1147	18	D	7	D7	Gold	normal	1.25
1148	18	D	8	D8	Gold	normal	1.25
1149	18	D	9	D9	Gold	normal	1.25
1150	18	D	10	D10	Gold	normal	1.25
1151	18	D	11	D11	Gold	normal	1.25
1152	18	D	12	D12	Gold	normal	1.25
1153	18	E	1	E1	Platinum Recliner	normal	1.60
1154	18	E	2	E2	Platinum Recliner	normal	1.60
1155	18	E	3	E3	Platinum Recliner	normal	1.60
1156	18	E	4	E4	Platinum Recliner	normal	1.60
1157	18	E	5	E5	Platinum Recliner	normal	1.60
1158	18	E	6	E6	Platinum Recliner	normal	1.60
1159	18	E	7	E7	Platinum Recliner	normal	1.60
1160	18	E	8	E8	Platinum Recliner	normal	1.60
1161	18	E	9	E9	Platinum Recliner	normal	1.60
1162	18	E	10	E10	Platinum Recliner	normal	1.60
1163	18	E	11	E11	Platinum Recliner	normal	1.60
1164	18	E	12	E12	Platinum Recliner	normal	1.60
1165	18	F	1	F1	Platinum Recliner	normal	1.60
1166	18	F	2	F2	Platinum Recliner	normal	1.60
1167	18	F	3	F3	Platinum Recliner	normal	1.60
1168	18	F	4	F4	Platinum Recliner	normal	1.60
1169	18	F	5	F5	Platinum Recliner	normal	1.60
1170	18	F	6	F6	Platinum Recliner	normal	1.60
1171	18	F	7	F7	Platinum Recliner	normal	1.60
1172	18	F	8	F8	Platinum Recliner	normal	1.60
1173	18	F	9	F9	Platinum Recliner	normal	1.60
1174	18	F	10	F10	Platinum Recliner	normal	1.60
1175	18	F	11	F11	Platinum Recliner	normal	1.60
1176	18	F	12	F12	Platinum Recliner	normal	1.60
1177	19	A	1	A1	Silver	normal	1.00
1178	19	A	2	A2	Silver	normal	1.00
1179	19	A	3	A3	Silver	normal	1.00
1180	19	A	4	A4	Silver	normal	1.00
1181	19	A	5	A5	Silver	normal	1.00
1182	19	A	6	A6	Silver	normal	1.00
1183	19	A	7	A7	Silver	normal	1.00
1184	19	A	8	A8	Silver	normal	1.00
1185	19	A	9	A9	Silver	normal	1.00
1186	19	A	10	A10	Silver	normal	1.00
1187	19	A	11	A11	Silver	normal	1.00
1188	19	A	12	A12	Silver	normal	1.00
1189	19	B	1	B1	Silver	normal	1.00
1190	19	B	2	B2	Silver	normal	1.00
1191	19	B	3	B3	Silver	normal	1.00
1192	19	B	4	B4	Silver	normal	1.00
1193	19	B	5	B5	Silver	normal	1.00
1194	19	B	6	B6	Silver	normal	1.00
1195	19	B	7	B7	Silver	normal	1.00
1196	19	B	8	B8	Silver	normal	1.00
1197	19	B	9	B9	Silver	normal	1.00
1198	19	B	10	B10	Silver	normal	1.00
1199	19	B	11	B11	Silver	normal	1.00
1200	19	B	12	B12	Silver	normal	1.00
1201	19	C	1	C1	Gold	normal	1.25
1202	19	C	2	C2	Gold	normal	1.25
1203	19	C	3	C3	Gold	normal	1.25
1204	19	C	4	C4	Gold	normal	1.25
1205	19	C	5	C5	Gold	normal	1.25
1206	19	C	6	C6	Gold	normal	1.25
1207	19	C	7	C7	Gold	normal	1.25
1208	19	C	8	C8	Gold	normal	1.25
1209	19	C	9	C9	Gold	normal	1.25
1210	19	C	10	C10	Gold	normal	1.25
1211	19	C	11	C11	Gold	normal	1.25
1212	19	C	12	C12	Gold	normal	1.25
1213	19	D	1	D1	Gold	normal	1.25
1214	19	D	2	D2	Gold	normal	1.25
1215	19	D	3	D3	Gold	normal	1.25
1216	19	D	4	D4	Gold	normal	1.25
1217	19	D	5	D5	Gold	normal	1.25
1218	19	D	6	D6	Gold	normal	1.25
1219	19	D	7	D7	Gold	normal	1.25
1220	19	D	8	D8	Gold	normal	1.25
1221	19	D	9	D9	Gold	normal	1.25
1222	19	D	10	D10	Gold	normal	1.25
1223	19	D	11	D11	Gold	normal	1.25
1224	19	D	12	D12	Gold	normal	1.25
1225	19	E	1	E1	Platinum Recliner	normal	1.60
1226	19	E	2	E2	Platinum Recliner	normal	1.60
1227	19	E	3	E3	Platinum Recliner	normal	1.60
1228	19	E	4	E4	Platinum Recliner	normal	1.60
1229	19	E	5	E5	Platinum Recliner	normal	1.60
1230	19	E	6	E6	Platinum Recliner	normal	1.60
1231	19	E	7	E7	Platinum Recliner	normal	1.60
1232	19	E	8	E8	Platinum Recliner	normal	1.60
1233	19	E	9	E9	Platinum Recliner	normal	1.60
1234	19	E	10	E10	Platinum Recliner	normal	1.60
1235	19	E	11	E11	Platinum Recliner	normal	1.60
1236	19	E	12	E12	Platinum Recliner	normal	1.60
1237	19	F	1	F1	Platinum Recliner	normal	1.60
1238	19	F	2	F2	Platinum Recliner	normal	1.60
1239	19	F	3	F3	Platinum Recliner	normal	1.60
1240	19	F	4	F4	Platinum Recliner	normal	1.60
1241	19	F	5	F5	Platinum Recliner	normal	1.60
1242	19	F	6	F6	Platinum Recliner	normal	1.60
1243	19	F	7	F7	Platinum Recliner	normal	1.60
1244	19	F	8	F8	Platinum Recliner	normal	1.60
1245	19	F	9	F9	Platinum Recliner	normal	1.60
1246	19	F	10	F10	Platinum Recliner	normal	1.60
1247	19	F	11	F11	Platinum Recliner	normal	1.60
1248	19	F	12	F12	Platinum Recliner	normal	1.60
1249	20	A	1	A1	Silver	normal	1.00
1250	20	A	2	A2	Silver	normal	1.00
1251	20	A	3	A3	Silver	normal	1.00
1252	20	A	4	A4	Silver	normal	1.00
1253	20	A	5	A5	Silver	normal	1.00
1254	20	A	6	A6	Silver	normal	1.00
1255	20	A	7	A7	Silver	normal	1.00
1256	20	A	8	A8	Silver	normal	1.00
1257	20	B	1	B1	Silver	normal	1.00
1258	20	B	2	B2	Silver	normal	1.00
1259	20	B	3	B3	Silver	normal	1.00
1260	20	B	4	B4	Silver	normal	1.00
1261	20	B	5	B5	Silver	normal	1.00
1262	20	B	6	B6	Silver	normal	1.00
1263	20	B	7	B7	Silver	normal	1.00
1264	20	B	8	B8	Silver	normal	1.00
1265	20	C	1	C1	Gold	normal	1.25
1266	20	C	2	C2	Gold	normal	1.25
1267	20	C	3	C3	Gold	normal	1.25
1268	20	C	4	C4	Gold	normal	1.25
1269	20	C	5	C5	Gold	normal	1.25
1270	20	C	6	C6	Gold	normal	1.25
1271	20	C	7	C7	Gold	normal	1.25
1272	20	C	8	C8	Gold	normal	1.25
1273	20	D	1	D1	Gold	normal	1.25
1274	20	D	2	D2	Gold	normal	1.25
1275	20	D	3	D3	Gold	normal	1.25
1276	20	D	4	D4	Gold	normal	1.25
1277	20	D	5	D5	Gold	normal	1.25
1278	20	D	6	D6	Gold	normal	1.25
1279	20	D	7	D7	Gold	normal	1.25
1280	20	D	8	D8	Gold	normal	1.25
1281	20	E	1	E1	Platinum Recliner	normal	1.60
1282	20	E	2	E2	Platinum Recliner	normal	1.60
1283	20	E	3	E3	Platinum Recliner	normal	1.60
1284	20	E	4	E4	Platinum Recliner	normal	1.60
1285	20	E	5	E5	Platinum Recliner	normal	1.60
1286	20	E	6	E6	Platinum Recliner	normal	1.60
1287	20	E	7	E7	Platinum Recliner	normal	1.60
1288	20	E	8	E8	Platinum Recliner	normal	1.60
1289	20	F	1	F1	Platinum Recliner	normal	1.60
1290	20	F	2	F2	Platinum Recliner	normal	1.60
1291	20	F	3	F3	Platinum Recliner	normal	1.60
1292	20	F	4	F4	Platinum Recliner	normal	1.60
1293	20	F	5	F5	Platinum Recliner	normal	1.60
1294	20	F	6	F6	Platinum Recliner	normal	1.60
1295	20	F	7	F7	Platinum Recliner	normal	1.60
1296	20	F	8	F8	Platinum Recliner	normal	1.60
1297	21	A	1	A1	Silver	normal	1.00
1298	21	A	2	A2	Silver	normal	1.00
1299	21	A	3	A3	Silver	normal	1.00
1300	21	A	4	A4	Silver	normal	1.00
1301	21	A	5	A5	Silver	normal	1.00
1302	21	A	6	A6	Silver	normal	1.00
1303	21	A	7	A7	Silver	normal	1.00
1304	21	A	8	A8	Silver	normal	1.00
1305	21	A	9	A9	Silver	normal	1.00
1306	21	A	10	A10	Silver	normal	1.00
1307	21	A	11	A11	Silver	normal	1.00
1308	21	A	12	A12	Silver	normal	1.00
1309	21	B	1	B1	Silver	normal	1.00
1310	21	B	2	B2	Silver	normal	1.00
1311	21	B	3	B3	Silver	normal	1.00
1312	21	B	4	B4	Silver	normal	1.00
1313	21	B	5	B5	Silver	normal	1.00
1314	21	B	6	B6	Silver	normal	1.00
1315	21	B	7	B7	Silver	normal	1.00
1316	21	B	8	B8	Silver	normal	1.00
1317	21	B	9	B9	Silver	normal	1.00
1318	21	B	10	B10	Silver	normal	1.00
1319	21	B	11	B11	Silver	normal	1.00
1320	21	B	12	B12	Silver	normal	1.00
1321	21	C	1	C1	Gold	normal	1.25
1322	21	C	2	C2	Gold	normal	1.25
1323	21	C	3	C3	Gold	normal	1.25
1324	21	C	4	C4	Gold	normal	1.25
1325	21	C	5	C5	Gold	normal	1.25
1326	21	C	6	C6	Gold	normal	1.25
1327	21	C	7	C7	Gold	normal	1.25
1328	21	C	8	C8	Gold	normal	1.25
1329	21	C	9	C9	Gold	normal	1.25
1330	21	C	10	C10	Gold	normal	1.25
1331	21	C	11	C11	Gold	normal	1.25
1332	21	C	12	C12	Gold	normal	1.25
1333	21	D	1	D1	Gold	normal	1.25
1334	21	D	2	D2	Gold	normal	1.25
1335	21	D	3	D3	Gold	normal	1.25
1336	21	D	4	D4	Gold	normal	1.25
1337	21	D	5	D5	Gold	normal	1.25
1338	21	D	6	D6	Gold	normal	1.25
1339	21	D	7	D7	Gold	normal	1.25
1340	21	D	8	D8	Gold	normal	1.25
1341	21	D	9	D9	Gold	normal	1.25
1342	21	D	10	D10	Gold	normal	1.25
1343	21	D	11	D11	Gold	normal	1.25
1344	21	D	12	D12	Gold	normal	1.25
1345	21	E	1	E1	Platinum Recliner	normal	1.60
1346	21	E	2	E2	Platinum Recliner	normal	1.60
1347	21	E	3	E3	Platinum Recliner	normal	1.60
1348	21	E	4	E4	Platinum Recliner	normal	1.60
1349	21	E	5	E5	Platinum Recliner	normal	1.60
1350	21	E	6	E6	Platinum Recliner	normal	1.60
1351	21	E	7	E7	Platinum Recliner	normal	1.60
1352	21	E	8	E8	Platinum Recliner	normal	1.60
1353	21	E	9	E9	Platinum Recliner	normal	1.60
1354	21	E	10	E10	Platinum Recliner	normal	1.60
1355	21	E	11	E11	Platinum Recliner	normal	1.60
1356	21	E	12	E12	Platinum Recliner	normal	1.60
1357	21	F	1	F1	Platinum Recliner	normal	1.60
1358	21	F	2	F2	Platinum Recliner	normal	1.60
1359	21	F	3	F3	Platinum Recliner	normal	1.60
1360	21	F	4	F4	Platinum Recliner	normal	1.60
1361	21	F	5	F5	Platinum Recliner	normal	1.60
1362	21	F	6	F6	Platinum Recliner	normal	1.60
1363	21	F	7	F7	Platinum Recliner	normal	1.60
1364	21	F	8	F8	Platinum Recliner	normal	1.60
1365	21	F	9	F9	Platinum Recliner	normal	1.60
1366	21	F	10	F10	Platinum Recliner	normal	1.60
1367	21	F	11	F11	Platinum Recliner	normal	1.60
1368	21	F	12	F12	Platinum Recliner	normal	1.60
1369	22	A	1	A1	Silver	normal	1.00
1370	22	A	2	A2	Silver	normal	1.00
1371	22	A	3	A3	Silver	normal	1.00
1372	22	A	4	A4	Silver	normal	1.00
1373	22	A	5	A5	Silver	normal	1.00
1374	22	A	6	A6	Silver	normal	1.00
1375	22	A	7	A7	Silver	normal	1.00
1376	22	A	8	A8	Silver	normal	1.00
1377	22	A	9	A9	Silver	normal	1.00
1378	22	A	10	A10	Silver	normal	1.00
1379	22	B	1	B1	Silver	normal	1.00
1380	22	B	2	B2	Silver	normal	1.00
1381	22	B	3	B3	Silver	normal	1.00
1382	22	B	4	B4	Silver	normal	1.00
1383	22	B	5	B5	Silver	normal	1.00
1384	22	B	6	B6	Silver	normal	1.00
1385	22	B	7	B7	Silver	normal	1.00
1386	22	B	8	B8	Silver	normal	1.00
1387	22	B	9	B9	Silver	normal	1.00
1388	22	B	10	B10	Silver	normal	1.00
1389	22	C	1	C1	Gold	normal	1.25
1390	22	C	2	C2	Gold	normal	1.25
1391	22	C	3	C3	Gold	normal	1.25
1392	22	C	4	C4	Gold	normal	1.25
1393	22	C	5	C5	Gold	normal	1.25
1394	22	C	6	C6	Gold	normal	1.25
1395	22	C	7	C7	Gold	normal	1.25
1396	22	C	8	C8	Gold	normal	1.25
1397	22	C	9	C9	Gold	normal	1.25
1398	22	C	10	C10	Gold	normal	1.25
1399	22	D	1	D1	Gold	normal	1.25
1400	22	D	2	D2	Gold	normal	1.25
1401	22	D	3	D3	Gold	normal	1.25
1402	22	D	4	D4	Gold	normal	1.25
1403	22	D	5	D5	Gold	normal	1.25
1404	22	D	6	D6	Gold	normal	1.25
1405	22	D	7	D7	Gold	normal	1.25
1406	22	D	8	D8	Gold	normal	1.25
1407	22	D	9	D9	Gold	normal	1.25
1408	22	D	10	D10	Gold	normal	1.25
1409	22	E	1	E1	Platinum Recliner	normal	1.60
1410	22	E	2	E2	Platinum Recliner	normal	1.60
1411	22	E	3	E3	Platinum Recliner	normal	1.60
1412	22	E	4	E4	Platinum Recliner	normal	1.60
1413	22	E	5	E5	Platinum Recliner	normal	1.60
1414	22	E	6	E6	Platinum Recliner	normal	1.60
1415	22	E	7	E7	Platinum Recliner	normal	1.60
1416	22	E	8	E8	Platinum Recliner	normal	1.60
1417	22	E	9	E9	Platinum Recliner	normal	1.60
1418	22	E	10	E10	Platinum Recliner	normal	1.60
1419	22	F	1	F1	Platinum Recliner	normal	1.60
1420	22	F	2	F2	Platinum Recliner	normal	1.60
1421	22	F	3	F3	Platinum Recliner	normal	1.60
1422	22	F	4	F4	Platinum Recliner	normal	1.60
1423	22	F	5	F5	Platinum Recliner	normal	1.60
1424	22	F	6	F6	Platinum Recliner	normal	1.60
1425	22	F	7	F7	Platinum Recliner	normal	1.60
1426	22	F	8	F8	Platinum Recliner	normal	1.60
1427	22	F	9	F9	Platinum Recliner	normal	1.60
1428	22	F	10	F10	Platinum Recliner	normal	1.60
1429	23	A	1	A1	Silver	normal	1.00
1430	23	A	2	A2	Silver	normal	1.00
1431	23	A	3	A3	Silver	normal	1.00
1432	23	A	4	A4	Silver	normal	1.00
1433	23	A	5	A5	Silver	normal	1.00
1434	23	A	6	A6	Silver	normal	1.00
1435	23	A	7	A7	Silver	normal	1.00
1436	23	A	8	A8	Silver	normal	1.00
1437	23	B	1	B1	Silver	normal	1.00
1438	23	B	2	B2	Silver	normal	1.00
1439	23	B	3	B3	Silver	normal	1.00
1440	23	B	4	B4	Silver	normal	1.00
1441	23	B	5	B5	Silver	normal	1.00
1442	23	B	6	B6	Silver	normal	1.00
1443	23	B	7	B7	Silver	normal	1.00
1444	23	B	8	B8	Silver	normal	1.00
1445	23	C	1	C1	Gold	normal	1.25
1446	23	C	2	C2	Gold	normal	1.25
1447	23	C	3	C3	Gold	normal	1.25
1448	23	C	4	C4	Gold	normal	1.25
1449	23	C	5	C5	Gold	normal	1.25
1450	23	C	6	C6	Gold	normal	1.25
1451	23	C	7	C7	Gold	normal	1.25
1452	23	C	8	C8	Gold	normal	1.25
1453	23	D	1	D1	Gold	normal	1.25
1454	23	D	2	D2	Gold	normal	1.25
1455	23	D	3	D3	Gold	normal	1.25
1456	23	D	4	D4	Gold	normal	1.25
1457	23	D	5	D5	Gold	normal	1.25
1458	23	D	6	D6	Gold	normal	1.25
1459	23	D	7	D7	Gold	normal	1.25
1460	23	D	8	D8	Gold	normal	1.25
1461	23	E	1	E1	Platinum Recliner	normal	1.60
1462	23	E	2	E2	Platinum Recliner	normal	1.60
1463	23	E	3	E3	Platinum Recliner	normal	1.60
1464	23	E	4	E4	Platinum Recliner	normal	1.60
1465	23	E	5	E5	Platinum Recliner	normal	1.60
1466	23	E	6	E6	Platinum Recliner	normal	1.60
1467	23	E	7	E7	Platinum Recliner	normal	1.60
1468	23	E	8	E8	Platinum Recliner	normal	1.60
1469	23	F	1	F1	Platinum Recliner	normal	1.60
1470	23	F	2	F2	Platinum Recliner	normal	1.60
1471	23	F	3	F3	Platinum Recliner	normal	1.60
1472	23	F	4	F4	Platinum Recliner	normal	1.60
1473	23	F	5	F5	Platinum Recliner	normal	1.60
1474	23	F	6	F6	Platinum Recliner	normal	1.60
1475	23	F	7	F7	Platinum Recliner	normal	1.60
1476	23	F	8	F8	Platinum Recliner	normal	1.60
1477	24	A	1	A1	Silver	normal	1.00
1478	24	A	2	A2	Silver	normal	1.00
1479	24	A	3	A3	Silver	normal	1.00
1480	24	A	4	A4	Silver	normal	1.00
1481	24	A	5	A5	Silver	normal	1.00
1482	24	A	6	A6	Silver	normal	1.00
1483	24	A	7	A7	Silver	normal	1.00
1484	24	A	8	A8	Silver	normal	1.00
1485	24	B	1	B1	Silver	normal	1.00
1486	24	B	2	B2	Silver	normal	1.00
1487	24	B	3	B3	Silver	normal	1.00
1488	24	B	4	B4	Silver	normal	1.00
1489	24	B	5	B5	Silver	normal	1.00
1490	24	B	6	B6	Silver	normal	1.00
1491	24	B	7	B7	Silver	normal	1.00
1492	24	B	8	B8	Silver	normal	1.00
1493	24	C	1	C1	Gold	normal	1.25
1494	24	C	2	C2	Gold	normal	1.25
1495	24	C	3	C3	Gold	normal	1.25
1496	24	C	4	C4	Gold	normal	1.25
1497	24	C	5	C5	Gold	normal	1.25
1498	24	C	6	C6	Gold	normal	1.25
1499	24	C	7	C7	Gold	normal	1.25
1500	24	C	8	C8	Gold	normal	1.25
1501	24	D	1	D1	Gold	normal	1.25
1502	24	D	2	D2	Gold	normal	1.25
1503	24	D	3	D3	Gold	normal	1.25
1504	24	D	4	D4	Gold	normal	1.25
1505	24	D	5	D5	Gold	normal	1.25
1506	24	D	6	D6	Gold	normal	1.25
1507	24	D	7	D7	Gold	normal	1.25
1508	24	D	8	D8	Gold	normal	1.25
1509	24	E	1	E1	Platinum Recliner	normal	1.60
1510	24	E	2	E2	Platinum Recliner	normal	1.60
1511	24	E	3	E3	Platinum Recliner	normal	1.60
1512	24	E	4	E4	Platinum Recliner	normal	1.60
1513	24	E	5	E5	Platinum Recliner	normal	1.60
1514	24	E	6	E6	Platinum Recliner	normal	1.60
1515	24	E	7	E7	Platinum Recliner	normal	1.60
1516	24	E	8	E8	Platinum Recliner	normal	1.60
1517	24	F	1	F1	Platinum Recliner	normal	1.60
1518	24	F	2	F2	Platinum Recliner	normal	1.60
1519	24	F	3	F3	Platinum Recliner	normal	1.60
1520	24	F	4	F4	Platinum Recliner	normal	1.60
1521	24	F	5	F5	Platinum Recliner	normal	1.60
1522	24	F	6	F6	Platinum Recliner	normal	1.60
1523	24	F	7	F7	Platinum Recliner	normal	1.60
1524	24	F	8	F8	Platinum Recliner	normal	1.60
1525	25	A	1	A1	Silver	normal	1.00
1526	25	A	2	A2	Silver	normal	1.00
1527	25	A	3	A3	Silver	normal	1.00
1528	25	A	4	A4	Silver	normal	1.00
1529	25	A	5	A5	Silver	normal	1.00
1530	25	A	6	A6	Silver	normal	1.00
1531	25	A	7	A7	Silver	normal	1.00
1532	25	A	8	A8	Silver	normal	1.00
1533	25	A	9	A9	Silver	normal	1.00
1534	25	A	10	A10	Silver	normal	1.00
1535	25	A	11	A11	Silver	normal	1.00
1536	25	A	12	A12	Silver	normal	1.00
1537	25	B	1	B1	Silver	normal	1.00
1538	25	B	2	B2	Silver	normal	1.00
1539	25	B	3	B3	Silver	normal	1.00
1540	25	B	4	B4	Silver	normal	1.00
1541	25	B	5	B5	Silver	normal	1.00
1542	25	B	6	B6	Silver	normal	1.00
1543	25	B	7	B7	Silver	normal	1.00
1544	25	B	8	B8	Silver	normal	1.00
1545	25	B	9	B9	Silver	normal	1.00
1546	25	B	10	B10	Silver	normal	1.00
1547	25	B	11	B11	Silver	normal	1.00
1548	25	B	12	B12	Silver	normal	1.00
1549	25	C	1	C1	Gold	normal	1.25
1550	25	C	2	C2	Gold	normal	1.25
1551	25	C	3	C3	Gold	normal	1.25
1552	25	C	4	C4	Gold	normal	1.25
1553	25	C	5	C5	Gold	normal	1.25
1554	25	C	6	C6	Gold	normal	1.25
1555	25	C	7	C7	Gold	normal	1.25
1556	25	C	8	C8	Gold	normal	1.25
1557	25	C	9	C9	Gold	normal	1.25
1558	25	C	10	C10	Gold	normal	1.25
1559	25	C	11	C11	Gold	normal	1.25
1560	25	C	12	C12	Gold	normal	1.25
1561	25	D	1	D1	Gold	normal	1.25
1562	25	D	2	D2	Gold	normal	1.25
1563	25	D	3	D3	Gold	normal	1.25
1564	25	D	4	D4	Gold	normal	1.25
1565	25	D	5	D5	Gold	normal	1.25
1566	25	D	6	D6	Gold	normal	1.25
1567	25	D	7	D7	Gold	normal	1.25
1568	25	D	8	D8	Gold	normal	1.25
1569	25	D	9	D9	Gold	normal	1.25
1570	25	D	10	D10	Gold	normal	1.25
1571	25	D	11	D11	Gold	normal	1.25
1572	25	D	12	D12	Gold	normal	1.25
1573	25	E	1	E1	Platinum Recliner	normal	1.60
1574	25	E	2	E2	Platinum Recliner	normal	1.60
1575	25	E	3	E3	Platinum Recliner	normal	1.60
1576	25	E	4	E4	Platinum Recliner	normal	1.60
1577	25	E	5	E5	Platinum Recliner	normal	1.60
1578	25	E	6	E6	Platinum Recliner	normal	1.60
1579	25	E	7	E7	Platinum Recliner	normal	1.60
1580	25	E	8	E8	Platinum Recliner	normal	1.60
1581	25	E	9	E9	Platinum Recliner	normal	1.60
1582	25	E	10	E10	Platinum Recliner	normal	1.60
1583	25	E	11	E11	Platinum Recliner	normal	1.60
1584	25	E	12	E12	Platinum Recliner	normal	1.60
1585	25	F	1	F1	Platinum Recliner	normal	1.60
1586	25	F	2	F2	Platinum Recliner	normal	1.60
1587	25	F	3	F3	Platinum Recliner	normal	1.60
1588	25	F	4	F4	Platinum Recliner	normal	1.60
1589	25	F	5	F5	Platinum Recliner	normal	1.60
1590	25	F	6	F6	Platinum Recliner	normal	1.60
1591	25	F	7	F7	Platinum Recliner	normal	1.60
1592	25	F	8	F8	Platinum Recliner	normal	1.60
1593	25	F	9	F9	Platinum Recliner	normal	1.60
1594	25	F	10	F10	Platinum Recliner	normal	1.60
1595	25	F	11	F11	Platinum Recliner	normal	1.60
1596	25	F	12	F12	Platinum Recliner	normal	1.60
1597	26	A	1	A1	Silver	normal	1.00
1598	26	A	2	A2	Silver	normal	1.00
1599	26	A	3	A3	Silver	normal	1.00
1600	26	A	4	A4	Silver	normal	1.00
1601	26	A	5	A5	Silver	normal	1.00
1602	26	A	6	A6	Silver	normal	1.00
1603	26	A	7	A7	Silver	normal	1.00
1604	26	A	8	A8	Silver	normal	1.00
1605	26	A	9	A9	Silver	normal	1.00
1606	26	A	10	A10	Silver	normal	1.00
1607	26	B	1	B1	Silver	normal	1.00
1608	26	B	2	B2	Silver	normal	1.00
1609	26	B	3	B3	Silver	normal	1.00
1610	26	B	4	B4	Silver	normal	1.00
1611	26	B	5	B5	Silver	normal	1.00
1612	26	B	6	B6	Silver	normal	1.00
1613	26	B	7	B7	Silver	normal	1.00
1614	26	B	8	B8	Silver	normal	1.00
1615	26	B	9	B9	Silver	normal	1.00
1616	26	B	10	B10	Silver	normal	1.00
1617	26	C	1	C1	Gold	normal	1.25
1618	26	C	2	C2	Gold	normal	1.25
1619	26	C	3	C3	Gold	normal	1.25
1620	26	C	4	C4	Gold	normal	1.25
1621	26	C	5	C5	Gold	normal	1.25
1622	26	C	6	C6	Gold	normal	1.25
1623	26	C	7	C7	Gold	normal	1.25
1624	26	C	8	C8	Gold	normal	1.25
1625	26	C	9	C9	Gold	normal	1.25
1626	26	C	10	C10	Gold	normal	1.25
1627	26	D	1	D1	Gold	normal	1.25
1628	26	D	2	D2	Gold	normal	1.25
1629	26	D	3	D3	Gold	normal	1.25
1630	26	D	4	D4	Gold	normal	1.25
1631	26	D	5	D5	Gold	normal	1.25
1632	26	D	6	D6	Gold	normal	1.25
1633	26	D	7	D7	Gold	normal	1.25
1634	26	D	8	D8	Gold	normal	1.25
1635	26	D	9	D9	Gold	normal	1.25
1636	26	D	10	D10	Gold	normal	1.25
1637	26	E	1	E1	Platinum Recliner	normal	1.60
1638	26	E	2	E2	Platinum Recliner	normal	1.60
1639	26	E	3	E3	Platinum Recliner	normal	1.60
1640	26	E	4	E4	Platinum Recliner	normal	1.60
1641	26	E	5	E5	Platinum Recliner	normal	1.60
1642	26	E	6	E6	Platinum Recliner	normal	1.60
1643	26	E	7	E7	Platinum Recliner	normal	1.60
1644	26	E	8	E8	Platinum Recliner	normal	1.60
1645	26	E	9	E9	Platinum Recliner	normal	1.60
1646	26	E	10	E10	Platinum Recliner	normal	1.60
1647	26	F	1	F1	Platinum Recliner	normal	1.60
1648	26	F	2	F2	Platinum Recliner	normal	1.60
1649	26	F	3	F3	Platinum Recliner	normal	1.60
1650	26	F	4	F4	Platinum Recliner	normal	1.60
1651	26	F	5	F5	Platinum Recliner	normal	1.60
1652	26	F	6	F6	Platinum Recliner	normal	1.60
1653	26	F	7	F7	Platinum Recliner	normal	1.60
1654	26	F	8	F8	Platinum Recliner	normal	1.60
1655	26	F	9	F9	Platinum Recliner	normal	1.60
1656	26	F	10	F10	Platinum Recliner	normal	1.60
1657	27	A	1	A1	Silver	normal	1.00
1658	27	A	2	A2	Silver	normal	1.00
1659	27	A	3	A3	Silver	normal	1.00
1660	27	A	4	A4	Silver	normal	1.00
1661	27	A	5	A5	Silver	normal	1.00
1662	27	A	6	A6	Silver	normal	1.00
1663	27	A	7	A7	Silver	normal	1.00
1664	27	A	8	A8	Silver	normal	1.00
1665	27	A	9	A9	Silver	normal	1.00
1666	27	A	10	A10	Silver	normal	1.00
1667	27	A	11	A11	Silver	normal	1.00
1668	27	A	12	A12	Silver	normal	1.00
1669	27	B	1	B1	Silver	normal	1.00
1670	27	B	2	B2	Silver	normal	1.00
1671	27	B	3	B3	Silver	normal	1.00
1672	27	B	4	B4	Silver	normal	1.00
1673	27	B	5	B5	Silver	normal	1.00
1674	27	B	6	B6	Silver	normal	1.00
1675	27	B	7	B7	Silver	normal	1.00
1676	27	B	8	B8	Silver	normal	1.00
1677	27	B	9	B9	Silver	normal	1.00
1678	27	B	10	B10	Silver	normal	1.00
1679	27	B	11	B11	Silver	normal	1.00
1680	27	B	12	B12	Silver	normal	1.00
1681	27	C	1	C1	Gold	normal	1.25
1682	27	C	2	C2	Gold	normal	1.25
1683	27	C	3	C3	Gold	normal	1.25
1684	27	C	4	C4	Gold	normal	1.25
1685	27	C	5	C5	Gold	normal	1.25
1686	27	C	6	C6	Gold	normal	1.25
1687	27	C	7	C7	Gold	normal	1.25
1688	27	C	8	C8	Gold	normal	1.25
1689	27	C	9	C9	Gold	normal	1.25
1690	27	C	10	C10	Gold	normal	1.25
1691	27	C	11	C11	Gold	normal	1.25
1692	27	C	12	C12	Gold	normal	1.25
1693	27	D	1	D1	Gold	normal	1.25
1694	27	D	2	D2	Gold	normal	1.25
1695	27	D	3	D3	Gold	normal	1.25
1696	27	D	4	D4	Gold	normal	1.25
1697	27	D	5	D5	Gold	normal	1.25
1698	27	D	6	D6	Gold	normal	1.25
1699	27	D	7	D7	Gold	normal	1.25
1700	27	D	8	D8	Gold	normal	1.25
1701	27	D	9	D9	Gold	normal	1.25
1702	27	D	10	D10	Gold	normal	1.25
1703	27	D	11	D11	Gold	normal	1.25
1704	27	D	12	D12	Gold	normal	1.25
1705	27	E	1	E1	Platinum Recliner	normal	1.60
1706	27	E	2	E2	Platinum Recliner	normal	1.60
1707	27	E	3	E3	Platinum Recliner	normal	1.60
1708	27	E	4	E4	Platinum Recliner	normal	1.60
1709	27	E	5	E5	Platinum Recliner	normal	1.60
1710	27	E	6	E6	Platinum Recliner	normal	1.60
1711	27	E	7	E7	Platinum Recliner	normal	1.60
1712	27	E	8	E8	Platinum Recliner	normal	1.60
1713	27	E	9	E9	Platinum Recliner	normal	1.60
1714	27	E	10	E10	Platinum Recliner	normal	1.60
1715	27	E	11	E11	Platinum Recliner	normal	1.60
1716	27	E	12	E12	Platinum Recliner	normal	1.60
1717	27	F	1	F1	Platinum Recliner	normal	1.60
1718	27	F	2	F2	Platinum Recliner	normal	1.60
1719	27	F	3	F3	Platinum Recliner	normal	1.60
1720	27	F	4	F4	Platinum Recliner	normal	1.60
1721	27	F	5	F5	Platinum Recliner	normal	1.60
1722	27	F	6	F6	Platinum Recliner	normal	1.60
1723	27	F	7	F7	Platinum Recliner	normal	1.60
1724	27	F	8	F8	Platinum Recliner	normal	1.60
1725	27	F	9	F9	Platinum Recliner	normal	1.60
1726	27	F	10	F10	Platinum Recliner	normal	1.60
1727	27	F	11	F11	Platinum Recliner	normal	1.60
1728	27	F	12	F12	Platinum Recliner	normal	1.60
1729	28	A	1	A1	Silver	normal	1.00
1730	28	A	2	A2	Silver	normal	1.00
1731	28	A	3	A3	Silver	normal	1.00
1732	28	A	4	A4	Silver	normal	1.00
1733	28	A	5	A5	Silver	normal	1.00
1734	28	A	6	A6	Silver	normal	1.00
1735	28	A	7	A7	Silver	normal	1.00
1736	28	A	8	A8	Silver	normal	1.00
1737	28	A	9	A9	Silver	normal	1.00
1738	28	A	10	A10	Silver	normal	1.00
1739	28	B	1	B1	Silver	normal	1.00
1740	28	B	2	B2	Silver	normal	1.00
1741	28	B	3	B3	Silver	normal	1.00
1742	28	B	4	B4	Silver	normal	1.00
1743	28	B	5	B5	Silver	normal	1.00
1744	28	B	6	B6	Silver	normal	1.00
1745	28	B	7	B7	Silver	normal	1.00
1746	28	B	8	B8	Silver	normal	1.00
1747	28	B	9	B9	Silver	normal	1.00
1748	28	B	10	B10	Silver	normal	1.00
1749	28	C	1	C1	Gold	normal	1.25
1750	28	C	2	C2	Gold	normal	1.25
1751	28	C	3	C3	Gold	normal	1.25
1752	28	C	4	C4	Gold	normal	1.25
1753	28	C	5	C5	Gold	normal	1.25
1754	28	C	6	C6	Gold	normal	1.25
1755	28	C	7	C7	Gold	normal	1.25
1756	28	C	8	C8	Gold	normal	1.25
1757	28	C	9	C9	Gold	normal	1.25
1758	28	C	10	C10	Gold	normal	1.25
1759	28	D	1	D1	Gold	normal	1.25
1760	28	D	2	D2	Gold	normal	1.25
1761	28	D	3	D3	Gold	normal	1.25
1762	28	D	4	D4	Gold	normal	1.25
1763	28	D	5	D5	Gold	normal	1.25
1764	28	D	6	D6	Gold	normal	1.25
1765	28	D	7	D7	Gold	normal	1.25
1766	28	D	8	D8	Gold	normal	1.25
1767	28	D	9	D9	Gold	normal	1.25
1768	28	D	10	D10	Gold	normal	1.25
1769	28	E	1	E1	Platinum Recliner	normal	1.60
1770	28	E	2	E2	Platinum Recliner	normal	1.60
1771	28	E	3	E3	Platinum Recliner	normal	1.60
1772	28	E	4	E4	Platinum Recliner	normal	1.60
1773	28	E	5	E5	Platinum Recliner	normal	1.60
1774	28	E	6	E6	Platinum Recliner	normal	1.60
1886	30	C	2	C2	Gold	normal	1.25
1775	28	E	7	E7	Platinum Recliner	normal	1.60
1776	28	E	8	E8	Platinum Recliner	normal	1.60
1777	28	E	9	E9	Platinum Recliner	normal	1.60
1778	28	E	10	E10	Platinum Recliner	normal	1.60
1779	28	F	1	F1	Platinum Recliner	normal	1.60
1780	28	F	2	F2	Platinum Recliner	normal	1.60
1781	28	F	3	F3	Platinum Recliner	normal	1.60
1782	28	F	4	F4	Platinum Recliner	normal	1.60
1783	28	F	5	F5	Platinum Recliner	normal	1.60
1784	28	F	6	F6	Platinum Recliner	normal	1.60
1785	28	F	7	F7	Platinum Recliner	normal	1.60
1786	28	F	8	F8	Platinum Recliner	normal	1.60
1787	28	F	9	F9	Platinum Recliner	normal	1.60
1788	28	F	10	F10	Platinum Recliner	normal	1.60
1789	29	A	1	A1	Silver	normal	1.00
1790	29	A	2	A2	Silver	normal	1.00
1791	29	A	3	A3	Silver	normal	1.00
1792	29	A	4	A4	Silver	normal	1.00
1793	29	A	5	A5	Silver	normal	1.00
1794	29	A	6	A6	Silver	normal	1.00
1795	29	A	7	A7	Silver	normal	1.00
1796	29	A	8	A8	Silver	normal	1.00
1797	29	A	9	A9	Silver	normal	1.00
1798	29	A	10	A10	Silver	normal	1.00
1799	29	A	11	A11	Silver	normal	1.00
1800	29	A	12	A12	Silver	normal	1.00
1801	29	B	1	B1	Silver	normal	1.00
1802	29	B	2	B2	Silver	normal	1.00
1803	29	B	3	B3	Silver	normal	1.00
1804	29	B	4	B4	Silver	normal	1.00
1805	29	B	5	B5	Silver	normal	1.00
1806	29	B	6	B6	Silver	normal	1.00
1807	29	B	7	B7	Silver	normal	1.00
1808	29	B	8	B8	Silver	normal	1.00
1809	29	B	9	B9	Silver	normal	1.00
1810	29	B	10	B10	Silver	normal	1.00
1811	29	B	11	B11	Silver	normal	1.00
1812	29	B	12	B12	Silver	normal	1.00
1813	29	C	1	C1	Gold	normal	1.25
1814	29	C	2	C2	Gold	normal	1.25
1815	29	C	3	C3	Gold	normal	1.25
1816	29	C	4	C4	Gold	normal	1.25
1817	29	C	5	C5	Gold	normal	1.25
1818	29	C	6	C6	Gold	normal	1.25
1819	29	C	7	C7	Gold	normal	1.25
1820	29	C	8	C8	Gold	normal	1.25
1821	29	C	9	C9	Gold	normal	1.25
1822	29	C	10	C10	Gold	normal	1.25
1823	29	C	11	C11	Gold	normal	1.25
1824	29	C	12	C12	Gold	normal	1.25
1825	29	D	1	D1	Gold	normal	1.25
1826	29	D	2	D2	Gold	normal	1.25
1827	29	D	3	D3	Gold	normal	1.25
1828	29	D	4	D4	Gold	normal	1.25
1829	29	D	5	D5	Gold	normal	1.25
1830	29	D	6	D6	Gold	normal	1.25
1831	29	D	7	D7	Gold	normal	1.25
1832	29	D	8	D8	Gold	normal	1.25
1833	29	D	9	D9	Gold	normal	1.25
1834	29	D	10	D10	Gold	normal	1.25
1835	29	D	11	D11	Gold	normal	1.25
1836	29	D	12	D12	Gold	normal	1.25
1837	29	E	1	E1	Platinum Recliner	normal	1.60
1838	29	E	2	E2	Platinum Recliner	normal	1.60
1839	29	E	3	E3	Platinum Recliner	normal	1.60
1840	29	E	4	E4	Platinum Recliner	normal	1.60
1841	29	E	5	E5	Platinum Recliner	normal	1.60
1842	29	E	6	E6	Platinum Recliner	normal	1.60
1843	29	E	7	E7	Platinum Recliner	normal	1.60
1844	29	E	8	E8	Platinum Recliner	normal	1.60
1845	29	E	9	E9	Platinum Recliner	normal	1.60
1846	29	E	10	E10	Platinum Recliner	normal	1.60
1847	29	E	11	E11	Platinum Recliner	normal	1.60
1848	29	E	12	E12	Platinum Recliner	normal	1.60
1849	29	F	1	F1	Platinum Recliner	normal	1.60
1850	29	F	2	F2	Platinum Recliner	normal	1.60
1851	29	F	3	F3	Platinum Recliner	normal	1.60
1852	29	F	4	F4	Platinum Recliner	normal	1.60
1853	29	F	5	F5	Platinum Recliner	normal	1.60
1854	29	F	6	F6	Platinum Recliner	normal	1.60
1855	29	F	7	F7	Platinum Recliner	normal	1.60
1856	29	F	8	F8	Platinum Recliner	normal	1.60
1857	29	F	9	F9	Platinum Recliner	normal	1.60
1858	29	F	10	F10	Platinum Recliner	normal	1.60
1859	29	F	11	F11	Platinum Recliner	normal	1.60
1860	29	F	12	F12	Platinum Recliner	normal	1.60
1861	30	A	1	A1	Silver	normal	1.00
1862	30	A	2	A2	Silver	normal	1.00
1863	30	A	3	A3	Silver	normal	1.00
1864	30	A	4	A4	Silver	normal	1.00
1865	30	A	5	A5	Silver	normal	1.00
1866	30	A	6	A6	Silver	normal	1.00
1867	30	A	7	A7	Silver	normal	1.00
1868	30	A	8	A8	Silver	normal	1.00
1869	30	A	9	A9	Silver	normal	1.00
1870	30	A	10	A10	Silver	normal	1.00
1871	30	A	11	A11	Silver	normal	1.00
1872	30	A	12	A12	Silver	normal	1.00
1873	30	B	1	B1	Silver	normal	1.00
1874	30	B	2	B2	Silver	normal	1.00
1875	30	B	3	B3	Silver	normal	1.00
1876	30	B	4	B4	Silver	normal	1.00
1877	30	B	5	B5	Silver	normal	1.00
1878	30	B	6	B6	Silver	normal	1.00
1879	30	B	7	B7	Silver	normal	1.00
1880	30	B	8	B8	Silver	normal	1.00
1881	30	B	9	B9	Silver	normal	1.00
1882	30	B	10	B10	Silver	normal	1.00
1883	30	B	11	B11	Silver	normal	1.00
1884	30	B	12	B12	Silver	normal	1.00
1885	30	C	1	C1	Gold	normal	1.25
1887	30	C	3	C3	Gold	normal	1.25
1888	30	C	4	C4	Gold	normal	1.25
1889	30	C	5	C5	Gold	normal	1.25
1890	30	C	6	C6	Gold	normal	1.25
1891	30	C	7	C7	Gold	normal	1.25
1892	30	C	8	C8	Gold	normal	1.25
1893	30	C	9	C9	Gold	normal	1.25
1894	30	C	10	C10	Gold	normal	1.25
1895	30	C	11	C11	Gold	normal	1.25
1896	30	C	12	C12	Gold	normal	1.25
1897	30	D	1	D1	Gold	normal	1.25
1898	30	D	2	D2	Gold	normal	1.25
1899	30	D	3	D3	Gold	normal	1.25
1900	30	D	4	D4	Gold	normal	1.25
1901	30	D	5	D5	Gold	normal	1.25
1902	30	D	6	D6	Gold	normal	1.25
1903	30	D	7	D7	Gold	normal	1.25
1904	30	D	8	D8	Gold	normal	1.25
1905	30	D	9	D9	Gold	normal	1.25
1906	30	D	10	D10	Gold	normal	1.25
1907	30	D	11	D11	Gold	normal	1.25
1908	30	D	12	D12	Gold	normal	1.25
1909	30	E	1	E1	Platinum Recliner	normal	1.60
1910	30	E	2	E2	Platinum Recliner	normal	1.60
1911	30	E	3	E3	Platinum Recliner	normal	1.60
1912	30	E	4	E4	Platinum Recliner	normal	1.60
1913	30	E	5	E5	Platinum Recliner	normal	1.60
1914	30	E	6	E6	Platinum Recliner	normal	1.60
1915	30	E	7	E7	Platinum Recliner	normal	1.60
1916	30	E	8	E8	Platinum Recliner	normal	1.60
1917	30	E	9	E9	Platinum Recliner	normal	1.60
1918	30	E	10	E10	Platinum Recliner	normal	1.60
1919	30	E	11	E11	Platinum Recliner	normal	1.60
1920	30	E	12	E12	Platinum Recliner	normal	1.60
1921	30	F	1	F1	Platinum Recliner	normal	1.60
1922	30	F	2	F2	Platinum Recliner	normal	1.60
1923	30	F	3	F3	Platinum Recliner	normal	1.60
1924	30	F	4	F4	Platinum Recliner	normal	1.60
1925	30	F	5	F5	Platinum Recliner	normal	1.60
1926	30	F	6	F6	Platinum Recliner	normal	1.60
1927	30	F	7	F7	Platinum Recliner	normal	1.60
1928	30	F	8	F8	Platinum Recliner	normal	1.60
1929	30	F	9	F9	Platinum Recliner	normal	1.60
1930	30	F	10	F10	Platinum Recliner	normal	1.60
1931	30	F	11	F11	Platinum Recliner	normal	1.60
1932	30	F	12	F12	Platinum Recliner	normal	1.60
1933	31	A	1	A1	Silver	normal	1.00
1934	31	A	2	A2	Silver	normal	1.00
1935	31	A	3	A3	Silver	normal	1.00
1936	31	A	4	A4	Silver	normal	1.00
1937	31	A	5	A5	Silver	normal	1.00
1938	31	A	6	A6	Silver	normal	1.00
1939	31	A	7	A7	Silver	normal	1.00
1940	31	A	8	A8	Silver	normal	1.00
1941	31	A	9	A9	Silver	normal	1.00
1942	31	A	10	A10	Silver	normal	1.00
1943	31	A	11	A11	Silver	normal	1.00
1944	31	A	12	A12	Silver	normal	1.00
1945	31	B	1	B1	Silver	normal	1.00
1946	31	B	2	B2	Silver	normal	1.00
1947	31	B	3	B3	Silver	normal	1.00
1948	31	B	4	B4	Silver	normal	1.00
1949	31	B	5	B5	Silver	normal	1.00
1950	31	B	6	B6	Silver	normal	1.00
1951	31	B	7	B7	Silver	normal	1.00
1952	31	B	8	B8	Silver	normal	1.00
1953	31	B	9	B9	Silver	normal	1.00
1954	31	B	10	B10	Silver	normal	1.00
1955	31	B	11	B11	Silver	normal	1.00
1956	31	B	12	B12	Silver	normal	1.00
1957	31	C	1	C1	Gold	normal	1.25
1958	31	C	2	C2	Gold	normal	1.25
1959	31	C	3	C3	Gold	normal	1.25
1960	31	C	4	C4	Gold	normal	1.25
1961	31	C	5	C5	Gold	normal	1.25
1962	31	C	6	C6	Gold	normal	1.25
1963	31	C	7	C7	Gold	normal	1.25
1964	31	C	8	C8	Gold	normal	1.25
1965	31	C	9	C9	Gold	normal	1.25
1966	31	C	10	C10	Gold	normal	1.25
1967	31	C	11	C11	Gold	normal	1.25
1968	31	C	12	C12	Gold	normal	1.25
1969	31	D	1	D1	Gold	normal	1.25
1970	31	D	2	D2	Gold	normal	1.25
1971	31	D	3	D3	Gold	normal	1.25
1972	31	D	4	D4	Gold	normal	1.25
1973	31	D	5	D5	Gold	normal	1.25
1974	31	D	6	D6	Gold	normal	1.25
1975	31	D	7	D7	Gold	normal	1.25
1976	31	D	8	D8	Gold	normal	1.25
1977	31	D	9	D9	Gold	normal	1.25
1978	31	D	10	D10	Gold	normal	1.25
1979	31	D	11	D11	Gold	normal	1.25
1980	31	D	12	D12	Gold	normal	1.25
1981	31	E	1	E1	Platinum Recliner	normal	1.60
1982	31	E	2	E2	Platinum Recliner	normal	1.60
1983	31	E	3	E3	Platinum Recliner	normal	1.60
1984	31	E	4	E4	Platinum Recliner	normal	1.60
1985	31	E	5	E5	Platinum Recliner	normal	1.60
1986	31	E	6	E6	Platinum Recliner	normal	1.60
1987	31	E	7	E7	Platinum Recliner	normal	1.60
1988	31	E	8	E8	Platinum Recliner	normal	1.60
1989	31	E	9	E9	Platinum Recliner	normal	1.60
1990	31	E	10	E10	Platinum Recliner	normal	1.60
1991	31	E	11	E11	Platinum Recliner	normal	1.60
1992	31	E	12	E12	Platinum Recliner	normal	1.60
1993	31	F	1	F1	Platinum Recliner	normal	1.60
1994	31	F	2	F2	Platinum Recliner	normal	1.60
1995	31	F	3	F3	Platinum Recliner	normal	1.60
1996	31	F	4	F4	Platinum Recliner	normal	1.60
1997	31	F	5	F5	Platinum Recliner	normal	1.60
1998	31	F	6	F6	Platinum Recliner	normal	1.60
1999	31	F	7	F7	Platinum Recliner	normal	1.60
2000	31	F	8	F8	Platinum Recliner	normal	1.60
2001	31	F	9	F9	Platinum Recliner	normal	1.60
2002	31	F	10	F10	Platinum Recliner	normal	1.60
2003	31	F	11	F11	Platinum Recliner	normal	1.60
2004	31	F	12	F12	Platinum Recliner	normal	1.60
2005	32	A	1	A1	Silver	normal	1.00
2006	32	A	2	A2	Silver	normal	1.00
2007	32	A	3	A3	Silver	normal	1.00
2008	32	A	4	A4	Silver	normal	1.00
2009	32	A	5	A5	Silver	normal	1.00
2010	32	A	6	A6	Silver	normal	1.00
2011	32	A	7	A7	Silver	normal	1.00
2012	32	A	8	A8	Silver	normal	1.00
2013	32	B	1	B1	Silver	normal	1.00
2014	32	B	2	B2	Silver	normal	1.00
2015	32	B	3	B3	Silver	normal	1.00
2016	32	B	4	B4	Silver	normal	1.00
2017	32	B	5	B5	Silver	normal	1.00
2018	32	B	6	B6	Silver	normal	1.00
2019	32	B	7	B7	Silver	normal	1.00
2020	32	B	8	B8	Silver	normal	1.00
2021	32	C	1	C1	Gold	normal	1.25
2022	32	C	2	C2	Gold	normal	1.25
2023	32	C	3	C3	Gold	normal	1.25
2024	32	C	4	C4	Gold	normal	1.25
2025	32	C	5	C5	Gold	normal	1.25
2026	32	C	6	C6	Gold	normal	1.25
2027	32	C	7	C7	Gold	normal	1.25
2028	32	C	8	C8	Gold	normal	1.25
2029	32	D	1	D1	Gold	normal	1.25
2030	32	D	2	D2	Gold	normal	1.25
2031	32	D	3	D3	Gold	normal	1.25
2032	32	D	4	D4	Gold	normal	1.25
2033	32	D	5	D5	Gold	normal	1.25
2034	32	D	6	D6	Gold	normal	1.25
2035	32	D	7	D7	Gold	normal	1.25
2036	32	D	8	D8	Gold	normal	1.25
2037	32	E	1	E1	Platinum Recliner	normal	1.60
2038	32	E	2	E2	Platinum Recliner	normal	1.60
2039	32	E	3	E3	Platinum Recliner	normal	1.60
2040	32	E	4	E4	Platinum Recliner	normal	1.60
2041	32	E	5	E5	Platinum Recliner	normal	1.60
2042	32	E	6	E6	Platinum Recliner	normal	1.60
2043	32	E	7	E7	Platinum Recliner	normal	1.60
2044	32	E	8	E8	Platinum Recliner	normal	1.60
2045	32	F	1	F1	Platinum Recliner	normal	1.60
2046	32	F	2	F2	Platinum Recliner	normal	1.60
2047	32	F	3	F3	Platinum Recliner	normal	1.60
2048	32	F	4	F4	Platinum Recliner	normal	1.60
2049	32	F	5	F5	Platinum Recliner	normal	1.60
2050	32	F	6	F6	Platinum Recliner	normal	1.60
2051	32	F	7	F7	Platinum Recliner	normal	1.60
2052	32	F	8	F8	Platinum Recliner	normal	1.60
2053	33	A	1	A1	Silver	normal	1.00
2054	33	A	2	A2	Silver	normal	1.00
2055	33	A	3	A3	Silver	normal	1.00
2056	33	A	4	A4	Silver	normal	1.00
2057	33	A	5	A5	Silver	normal	1.00
2058	33	A	6	A6	Silver	normal	1.00
2059	33	A	7	A7	Silver	normal	1.00
2060	33	A	8	A8	Silver	normal	1.00
2061	33	A	9	A9	Silver	normal	1.00
2062	33	A	10	A10	Silver	normal	1.00
2063	33	A	11	A11	Silver	normal	1.00
2064	33	A	12	A12	Silver	normal	1.00
2065	33	B	1	B1	Silver	normal	1.00
2066	33	B	2	B2	Silver	normal	1.00
2067	33	B	3	B3	Silver	normal	1.00
2068	33	B	4	B4	Silver	normal	1.00
2069	33	B	5	B5	Silver	normal	1.00
2070	33	B	6	B6	Silver	normal	1.00
2071	33	B	7	B7	Silver	normal	1.00
2072	33	B	8	B8	Silver	normal	1.00
2073	33	B	9	B9	Silver	normal	1.00
2074	33	B	10	B10	Silver	normal	1.00
2075	33	B	11	B11	Silver	normal	1.00
2076	33	B	12	B12	Silver	normal	1.00
2077	33	C	1	C1	Gold	normal	1.25
2078	33	C	2	C2	Gold	normal	1.25
2079	33	C	3	C3	Gold	normal	1.25
2080	33	C	4	C4	Gold	normal	1.25
2081	33	C	5	C5	Gold	normal	1.25
2082	33	C	6	C6	Gold	normal	1.25
2083	33	C	7	C7	Gold	normal	1.25
2084	33	C	8	C8	Gold	normal	1.25
2085	33	C	9	C9	Gold	normal	1.25
2086	33	C	10	C10	Gold	normal	1.25
2087	33	C	11	C11	Gold	normal	1.25
2088	33	C	12	C12	Gold	normal	1.25
2089	33	D	1	D1	Gold	normal	1.25
2090	33	D	2	D2	Gold	normal	1.25
2091	33	D	3	D3	Gold	normal	1.25
2092	33	D	4	D4	Gold	normal	1.25
2093	33	D	5	D5	Gold	normal	1.25
2094	33	D	6	D6	Gold	normal	1.25
2095	33	D	7	D7	Gold	normal	1.25
2096	33	D	8	D8	Gold	normal	1.25
2097	33	D	9	D9	Gold	normal	1.25
2098	33	D	10	D10	Gold	normal	1.25
2099	33	D	11	D11	Gold	normal	1.25
2100	33	D	12	D12	Gold	normal	1.25
2101	33	E	1	E1	Platinum Recliner	normal	1.60
2102	33	E	2	E2	Platinum Recliner	normal	1.60
2103	33	E	3	E3	Platinum Recliner	normal	1.60
2104	33	E	4	E4	Platinum Recliner	normal	1.60
2105	33	E	5	E5	Platinum Recliner	normal	1.60
2106	33	E	6	E6	Platinum Recliner	normal	1.60
2107	33	E	7	E7	Platinum Recliner	normal	1.60
2108	33	E	8	E8	Platinum Recliner	normal	1.60
2109	33	E	9	E9	Platinum Recliner	normal	1.60
2110	33	E	10	E10	Platinum Recliner	normal	1.60
2111	33	E	11	E11	Platinum Recliner	normal	1.60
2112	33	E	12	E12	Platinum Recliner	normal	1.60
2113	33	F	1	F1	Platinum Recliner	normal	1.60
2114	33	F	2	F2	Platinum Recliner	normal	1.60
2115	33	F	3	F3	Platinum Recliner	normal	1.60
2116	33	F	4	F4	Platinum Recliner	normal	1.60
2117	33	F	5	F5	Platinum Recliner	normal	1.60
2118	33	F	6	F6	Platinum Recliner	normal	1.60
2119	33	F	7	F7	Platinum Recliner	normal	1.60
2120	33	F	8	F8	Platinum Recliner	normal	1.60
2121	33	F	9	F9	Platinum Recliner	normal	1.60
2122	33	F	10	F10	Platinum Recliner	normal	1.60
2123	33	F	11	F11	Platinum Recliner	normal	1.60
2124	33	F	12	F12	Platinum Recliner	normal	1.60
2125	34	A	1	A1	Silver	normal	1.00
2126	34	A	2	A2	Silver	normal	1.00
2127	34	A	3	A3	Silver	normal	1.00
2128	34	A	4	A4	Silver	normal	1.00
2129	34	A	5	A5	Silver	normal	1.00
2130	34	A	6	A6	Silver	normal	1.00
2131	34	A	7	A7	Silver	normal	1.00
2132	34	A	8	A8	Silver	normal	1.00
2133	34	B	1	B1	Silver	normal	1.00
2134	34	B	2	B2	Silver	normal	1.00
2135	34	B	3	B3	Silver	normal	1.00
2136	34	B	4	B4	Silver	normal	1.00
2137	34	B	5	B5	Silver	normal	1.00
2138	34	B	6	B6	Silver	normal	1.00
2139	34	B	7	B7	Silver	normal	1.00
2140	34	B	8	B8	Silver	normal	1.00
2141	34	C	1	C1	Gold	normal	1.25
2142	34	C	2	C2	Gold	normal	1.25
2143	34	C	3	C3	Gold	normal	1.25
2144	34	C	4	C4	Gold	normal	1.25
2145	34	C	5	C5	Gold	normal	1.25
2146	34	C	6	C6	Gold	normal	1.25
2147	34	C	7	C7	Gold	normal	1.25
2148	34	C	8	C8	Gold	normal	1.25
2149	34	D	1	D1	Gold	normal	1.25
2150	34	D	2	D2	Gold	normal	1.25
2151	34	D	3	D3	Gold	normal	1.25
2152	34	D	4	D4	Gold	normal	1.25
2153	34	D	5	D5	Gold	normal	1.25
2154	34	D	6	D6	Gold	normal	1.25
2155	34	D	7	D7	Gold	normal	1.25
2156	34	D	8	D8	Gold	normal	1.25
2157	34	E	1	E1	Platinum Recliner	normal	1.60
2158	34	E	2	E2	Platinum Recliner	normal	1.60
2159	34	E	3	E3	Platinum Recliner	normal	1.60
2160	34	E	4	E4	Platinum Recliner	normal	1.60
2161	34	E	5	E5	Platinum Recliner	normal	1.60
2162	34	E	6	E6	Platinum Recliner	normal	1.60
2163	34	E	7	E7	Platinum Recliner	normal	1.60
2164	34	E	8	E8	Platinum Recliner	normal	1.60
2165	34	F	1	F1	Platinum Recliner	normal	1.60
2166	34	F	2	F2	Platinum Recliner	normal	1.60
2167	34	F	3	F3	Platinum Recliner	normal	1.60
2168	34	F	4	F4	Platinum Recliner	normal	1.60
2169	34	F	5	F5	Platinum Recliner	normal	1.60
2170	34	F	6	F6	Platinum Recliner	normal	1.60
2171	34	F	7	F7	Platinum Recliner	normal	1.60
2172	34	F	8	F8	Platinum Recliner	normal	1.60
2173	35	A	1	A1	Silver	normal	1.00
2174	35	A	2	A2	Silver	normal	1.00
2175	35	A	3	A3	Silver	normal	1.00
2176	35	A	4	A4	Silver	normal	1.00
2177	35	A	5	A5	Silver	normal	1.00
2178	35	A	6	A6	Silver	normal	1.00
2179	35	A	7	A7	Silver	normal	1.00
2180	35	A	8	A8	Silver	normal	1.00
2181	35	A	9	A9	Silver	normal	1.00
2182	35	A	10	A10	Silver	normal	1.00
2183	35	A	11	A11	Silver	normal	1.00
2184	35	A	12	A12	Silver	normal	1.00
2185	35	B	1	B1	Silver	normal	1.00
2186	35	B	2	B2	Silver	normal	1.00
2187	35	B	3	B3	Silver	normal	1.00
2188	35	B	4	B4	Silver	normal	1.00
2189	35	B	5	B5	Silver	normal	1.00
2190	35	B	6	B6	Silver	normal	1.00
2191	35	B	7	B7	Silver	normal	1.00
2192	35	B	8	B8	Silver	normal	1.00
2193	35	B	9	B9	Silver	normal	1.00
2194	35	B	10	B10	Silver	normal	1.00
2195	35	B	11	B11	Silver	normal	1.00
2196	35	B	12	B12	Silver	normal	1.00
2197	35	C	1	C1	Gold	normal	1.25
2198	35	C	2	C2	Gold	normal	1.25
2199	35	C	3	C3	Gold	normal	1.25
2200	35	C	4	C4	Gold	normal	1.25
2201	35	C	5	C5	Gold	normal	1.25
2202	35	C	6	C6	Gold	normal	1.25
2203	35	C	7	C7	Gold	normal	1.25
2204	35	C	8	C8	Gold	normal	1.25
2205	35	C	9	C9	Gold	normal	1.25
2206	35	C	10	C10	Gold	normal	1.25
2207	35	C	11	C11	Gold	normal	1.25
2208	35	C	12	C12	Gold	normal	1.25
2209	35	D	1	D1	Gold	normal	1.25
2210	35	D	2	D2	Gold	normal	1.25
2211	35	D	3	D3	Gold	normal	1.25
2212	35	D	4	D4	Gold	normal	1.25
2213	35	D	5	D5	Gold	normal	1.25
2214	35	D	6	D6	Gold	normal	1.25
2215	35	D	7	D7	Gold	normal	1.25
2216	35	D	8	D8	Gold	normal	1.25
2217	35	D	9	D9	Gold	normal	1.25
2218	35	D	10	D10	Gold	normal	1.25
2219	35	D	11	D11	Gold	normal	1.25
2220	35	D	12	D12	Gold	normal	1.25
2221	35	E	1	E1	Platinum Recliner	normal	1.60
2222	35	E	2	E2	Platinum Recliner	normal	1.60
2223	35	E	3	E3	Platinum Recliner	normal	1.60
2224	35	E	4	E4	Platinum Recliner	normal	1.60
2225	35	E	5	E5	Platinum Recliner	normal	1.60
2226	35	E	6	E6	Platinum Recliner	normal	1.60
2227	35	E	7	E7	Platinum Recliner	normal	1.60
2228	35	E	8	E8	Platinum Recliner	normal	1.60
2229	35	E	9	E9	Platinum Recliner	normal	1.60
2230	35	E	10	E10	Platinum Recliner	normal	1.60
2231	35	E	11	E11	Platinum Recliner	normal	1.60
2232	35	E	12	E12	Platinum Recliner	normal	1.60
2233	35	F	1	F1	Platinum Recliner	normal	1.60
2234	35	F	2	F2	Platinum Recliner	normal	1.60
2235	35	F	3	F3	Platinum Recliner	normal	1.60
2236	35	F	4	F4	Platinum Recliner	normal	1.60
2237	35	F	5	F5	Platinum Recliner	normal	1.60
2238	35	F	6	F6	Platinum Recliner	normal	1.60
2239	35	F	7	F7	Platinum Recliner	normal	1.60
2240	35	F	8	F8	Platinum Recliner	normal	1.60
2241	35	F	9	F9	Platinum Recliner	normal	1.60
2242	35	F	10	F10	Platinum Recliner	normal	1.60
2243	35	F	11	F11	Platinum Recliner	normal	1.60
2244	35	F	12	F12	Platinum Recliner	normal	1.60
2245	36	A	1	A1	Silver	normal	1.00
2246	36	A	2	A2	Silver	normal	1.00
2247	36	A	3	A3	Silver	normal	1.00
2248	36	A	4	A4	Silver	normal	1.00
2249	36	A	5	A5	Silver	normal	1.00
2250	36	A	6	A6	Silver	normal	1.00
2251	36	A	7	A7	Silver	normal	1.00
2252	36	A	8	A8	Silver	normal	1.00
2253	36	B	1	B1	Silver	normal	1.00
2254	36	B	2	B2	Silver	normal	1.00
2255	36	B	3	B3	Silver	normal	1.00
2256	36	B	4	B4	Silver	normal	1.00
2257	36	B	5	B5	Silver	normal	1.00
2258	36	B	6	B6	Silver	normal	1.00
2259	36	B	7	B7	Silver	normal	1.00
2260	36	B	8	B8	Silver	normal	1.00
2261	36	C	1	C1	Gold	normal	1.25
2262	36	C	2	C2	Gold	normal	1.25
2263	36	C	3	C3	Gold	normal	1.25
2264	36	C	4	C4	Gold	normal	1.25
2265	36	C	5	C5	Gold	normal	1.25
2266	36	C	6	C6	Gold	normal	1.25
2267	36	C	7	C7	Gold	normal	1.25
2268	36	C	8	C8	Gold	normal	1.25
2269	36	D	1	D1	Gold	normal	1.25
2270	36	D	2	D2	Gold	normal	1.25
2271	36	D	3	D3	Gold	normal	1.25
2272	36	D	4	D4	Gold	normal	1.25
2273	36	D	5	D5	Gold	normal	1.25
2274	36	D	6	D6	Gold	normal	1.25
2275	36	D	7	D7	Gold	normal	1.25
2276	36	D	8	D8	Gold	normal	1.25
2277	36	E	1	E1	Platinum Recliner	normal	1.60
2278	36	E	2	E2	Platinum Recliner	normal	1.60
2279	36	E	3	E3	Platinum Recliner	normal	1.60
2280	36	E	4	E4	Platinum Recliner	normal	1.60
2281	36	E	5	E5	Platinum Recliner	normal	1.60
2282	36	E	6	E6	Platinum Recliner	normal	1.60
2283	36	E	7	E7	Platinum Recliner	normal	1.60
2284	36	E	8	E8	Platinum Recliner	normal	1.60
2285	36	F	1	F1	Platinum Recliner	normal	1.60
2286	36	F	2	F2	Platinum Recliner	normal	1.60
2287	36	F	3	F3	Platinum Recliner	normal	1.60
2288	36	F	4	F4	Platinum Recliner	normal	1.60
2289	36	F	5	F5	Platinum Recliner	normal	1.60
2290	36	F	6	F6	Platinum Recliner	normal	1.60
2291	36	F	7	F7	Platinum Recliner	normal	1.60
2292	36	F	8	F8	Platinum Recliner	normal	1.60
2293	37	A	1	A1	Silver	normal	1.00
2294	37	A	2	A2	Silver	normal	1.00
2295	37	A	3	A3	Silver	normal	1.00
2296	37	A	4	A4	Silver	normal	1.00
2297	37	A	5	A5	Silver	normal	1.00
2298	37	A	6	A6	Silver	normal	1.00
2299	37	A	7	A7	Silver	normal	1.00
2300	37	A	8	A8	Silver	normal	1.00
2301	37	A	9	A9	Silver	normal	1.00
2302	37	A	10	A10	Silver	normal	1.00
2303	37	A	11	A11	Silver	normal	1.00
2304	37	A	12	A12	Silver	normal	1.00
2305	37	B	1	B1	Silver	normal	1.00
2306	37	B	2	B2	Silver	normal	1.00
2307	37	B	3	B3	Silver	normal	1.00
2308	37	B	4	B4	Silver	normal	1.00
2309	37	B	5	B5	Silver	normal	1.00
2310	37	B	6	B6	Silver	normal	1.00
2311	37	B	7	B7	Silver	normal	1.00
2312	37	B	8	B8	Silver	normal	1.00
2313	37	B	9	B9	Silver	normal	1.00
2314	37	B	10	B10	Silver	normal	1.00
2315	37	B	11	B11	Silver	normal	1.00
2316	37	B	12	B12	Silver	normal	1.00
2317	37	C	1	C1	Gold	normal	1.25
2318	37	C	2	C2	Gold	normal	1.25
2319	37	C	3	C3	Gold	normal	1.25
2320	37	C	4	C4	Gold	normal	1.25
2321	37	C	5	C5	Gold	normal	1.25
2322	37	C	6	C6	Gold	normal	1.25
2323	37	C	7	C7	Gold	normal	1.25
2324	37	C	8	C8	Gold	normal	1.25
2325	37	C	9	C9	Gold	normal	1.25
2326	37	C	10	C10	Gold	normal	1.25
2327	37	C	11	C11	Gold	normal	1.25
2328	37	C	12	C12	Gold	normal	1.25
2329	37	D	1	D1	Gold	normal	1.25
2330	37	D	2	D2	Gold	normal	1.25
2331	37	D	3	D3	Gold	normal	1.25
2332	37	D	4	D4	Gold	normal	1.25
2333	37	D	5	D5	Gold	normal	1.25
2334	37	D	6	D6	Gold	normal	1.25
2335	37	D	7	D7	Gold	normal	1.25
2336	37	D	8	D8	Gold	normal	1.25
2337	37	D	9	D9	Gold	normal	1.25
2338	37	D	10	D10	Gold	normal	1.25
2339	37	D	11	D11	Gold	normal	1.25
2340	37	D	12	D12	Gold	normal	1.25
2341	37	E	1	E1	Platinum Recliner	normal	1.60
2342	37	E	2	E2	Platinum Recliner	normal	1.60
2343	37	E	3	E3	Platinum Recliner	normal	1.60
2344	37	E	4	E4	Platinum Recliner	normal	1.60
2345	37	E	5	E5	Platinum Recliner	normal	1.60
2346	37	E	6	E6	Platinum Recliner	normal	1.60
2347	37	E	7	E7	Platinum Recliner	normal	1.60
2348	37	E	8	E8	Platinum Recliner	normal	1.60
2349	37	E	9	E9	Platinum Recliner	normal	1.60
2350	37	E	10	E10	Platinum Recliner	normal	1.60
2351	37	E	11	E11	Platinum Recliner	normal	1.60
2352	37	E	12	E12	Platinum Recliner	normal	1.60
2353	37	F	1	F1	Platinum Recliner	normal	1.60
2354	37	F	2	F2	Platinum Recliner	normal	1.60
2355	37	F	3	F3	Platinum Recliner	normal	1.60
2356	37	F	4	F4	Platinum Recliner	normal	1.60
2357	37	F	5	F5	Platinum Recliner	normal	1.60
2358	37	F	6	F6	Platinum Recliner	normal	1.60
2359	37	F	7	F7	Platinum Recliner	normal	1.60
2360	37	F	8	F8	Platinum Recliner	normal	1.60
2361	37	F	9	F9	Platinum Recliner	normal	1.60
2362	37	F	10	F10	Platinum Recliner	normal	1.60
2363	37	F	11	F11	Platinum Recliner	normal	1.60
2364	37	F	12	F12	Platinum Recliner	normal	1.60
2365	38	A	1	A1	Silver	normal	1.00
2366	38	A	2	A2	Silver	normal	1.00
2367	38	A	3	A3	Silver	normal	1.00
2368	38	A	4	A4	Silver	normal	1.00
2369	38	A	5	A5	Silver	normal	1.00
2370	38	A	6	A6	Silver	normal	1.00
2371	38	A	7	A7	Silver	normal	1.00
2372	38	A	8	A8	Silver	normal	1.00
2373	38	A	9	A9	Silver	normal	1.00
2374	38	A	10	A10	Silver	normal	1.00
2375	38	B	1	B1	Silver	normal	1.00
2376	38	B	2	B2	Silver	normal	1.00
2377	38	B	3	B3	Silver	normal	1.00
2378	38	B	4	B4	Silver	normal	1.00
2379	38	B	5	B5	Silver	normal	1.00
2380	38	B	6	B6	Silver	normal	1.00
2381	38	B	7	B7	Silver	normal	1.00
2382	38	B	8	B8	Silver	normal	1.00
2383	38	B	9	B9	Silver	normal	1.00
2384	38	B	10	B10	Silver	normal	1.00
2385	38	C	1	C1	Gold	normal	1.25
2386	38	C	2	C2	Gold	normal	1.25
2387	38	C	3	C3	Gold	normal	1.25
2388	38	C	4	C4	Gold	normal	1.25
2389	38	C	5	C5	Gold	normal	1.25
2390	38	C	6	C6	Gold	normal	1.25
2391	38	C	7	C7	Gold	normal	1.25
2392	38	C	8	C8	Gold	normal	1.25
2393	38	C	9	C9	Gold	normal	1.25
2394	38	C	10	C10	Gold	normal	1.25
2395	38	D	1	D1	Gold	normal	1.25
2396	38	D	2	D2	Gold	normal	1.25
2397	38	D	3	D3	Gold	normal	1.25
2398	38	D	4	D4	Gold	normal	1.25
2399	38	D	5	D5	Gold	normal	1.25
2400	38	D	6	D6	Gold	normal	1.25
2401	38	D	7	D7	Gold	normal	1.25
2402	38	D	8	D8	Gold	normal	1.25
2403	38	D	9	D9	Gold	normal	1.25
2404	38	D	10	D10	Gold	normal	1.25
2405	38	E	1	E1	Platinum Recliner	normal	1.60
2406	38	E	2	E2	Platinum Recliner	normal	1.60
2407	38	E	3	E3	Platinum Recliner	normal	1.60
2408	38	E	4	E4	Platinum Recliner	normal	1.60
2409	38	E	5	E5	Platinum Recliner	normal	1.60
2410	38	E	6	E6	Platinum Recliner	normal	1.60
2411	38	E	7	E7	Platinum Recliner	normal	1.60
2412	38	E	8	E8	Platinum Recliner	normal	1.60
2413	38	E	9	E9	Platinum Recliner	normal	1.60
2414	38	E	10	E10	Platinum Recliner	normal	1.60
2415	38	F	1	F1	Platinum Recliner	normal	1.60
2416	38	F	2	F2	Platinum Recliner	normal	1.60
2417	38	F	3	F3	Platinum Recliner	normal	1.60
2418	38	F	4	F4	Platinum Recliner	normal	1.60
2419	38	F	5	F5	Platinum Recliner	normal	1.60
2420	38	F	6	F6	Platinum Recliner	normal	1.60
2421	38	F	7	F7	Platinum Recliner	normal	1.60
2422	38	F	8	F8	Platinum Recliner	normal	1.60
2423	38	F	9	F9	Platinum Recliner	normal	1.60
2424	38	F	10	F10	Platinum Recliner	normal	1.60
2425	39	A	1	A1	Silver	normal	1.00
2426	39	A	2	A2	Silver	normal	1.00
2427	39	A	3	A3	Silver	normal	1.00
2428	39	A	4	A4	Silver	normal	1.00
2429	39	A	5	A5	Silver	normal	1.00
2430	39	A	6	A6	Silver	normal	1.00
2431	39	A	7	A7	Silver	normal	1.00
2432	39	A	8	A8	Silver	normal	1.00
2433	39	A	9	A9	Silver	normal	1.00
2434	39	A	10	A10	Silver	normal	1.00
2435	39	A	11	A11	Silver	normal	1.00
2436	39	A	12	A12	Silver	normal	1.00
2437	39	B	1	B1	Silver	normal	1.00
2438	39	B	2	B2	Silver	normal	1.00
2439	39	B	3	B3	Silver	normal	1.00
2440	39	B	4	B4	Silver	normal	1.00
2441	39	B	5	B5	Silver	normal	1.00
2442	39	B	6	B6	Silver	normal	1.00
2443	39	B	7	B7	Silver	normal	1.00
2444	39	B	8	B8	Silver	normal	1.00
2445	39	B	9	B9	Silver	normal	1.00
2446	39	B	10	B10	Silver	normal	1.00
2447	39	B	11	B11	Silver	normal	1.00
2448	39	B	12	B12	Silver	normal	1.00
2449	39	C	1	C1	Gold	normal	1.25
2450	39	C	2	C2	Gold	normal	1.25
2451	39	C	3	C3	Gold	normal	1.25
2452	39	C	4	C4	Gold	normal	1.25
2453	39	C	5	C5	Gold	normal	1.25
2454	39	C	6	C6	Gold	normal	1.25
2455	39	C	7	C7	Gold	normal	1.25
2456	39	C	8	C8	Gold	normal	1.25
2457	39	C	9	C9	Gold	normal	1.25
2458	39	C	10	C10	Gold	normal	1.25
2459	39	C	11	C11	Gold	normal	1.25
2460	39	C	12	C12	Gold	normal	1.25
2461	39	D	1	D1	Gold	normal	1.25
2462	39	D	2	D2	Gold	normal	1.25
2463	39	D	3	D3	Gold	normal	1.25
2464	39	D	4	D4	Gold	normal	1.25
2465	39	D	5	D5	Gold	normal	1.25
2466	39	D	6	D6	Gold	normal	1.25
2467	39	D	7	D7	Gold	normal	1.25
2468	39	D	8	D8	Gold	normal	1.25
2469	39	D	9	D9	Gold	normal	1.25
2470	39	D	10	D10	Gold	normal	1.25
2471	39	D	11	D11	Gold	normal	1.25
2472	39	D	12	D12	Gold	normal	1.25
2473	39	E	1	E1	Platinum Recliner	normal	1.60
2474	39	E	2	E2	Platinum Recliner	normal	1.60
2475	39	E	3	E3	Platinum Recliner	normal	1.60
2476	39	E	4	E4	Platinum Recliner	normal	1.60
2477	39	E	5	E5	Platinum Recliner	normal	1.60
2478	39	E	6	E6	Platinum Recliner	normal	1.60
2479	39	E	7	E7	Platinum Recliner	normal	1.60
2480	39	E	8	E8	Platinum Recliner	normal	1.60
2481	39	E	9	E9	Platinum Recliner	normal	1.60
2482	39	E	10	E10	Platinum Recliner	normal	1.60
2483	39	E	11	E11	Platinum Recliner	normal	1.60
2484	39	E	12	E12	Platinum Recliner	normal	1.60
2485	39	F	1	F1	Platinum Recliner	normal	1.60
2486	39	F	2	F2	Platinum Recliner	normal	1.60
2487	39	F	3	F3	Platinum Recliner	normal	1.60
2488	39	F	4	F4	Platinum Recliner	normal	1.60
2489	39	F	5	F5	Platinum Recliner	normal	1.60
2490	39	F	6	F6	Platinum Recliner	normal	1.60
2491	39	F	7	F7	Platinum Recliner	normal	1.60
2492	39	F	8	F8	Platinum Recliner	normal	1.60
2493	39	F	9	F9	Platinum Recliner	normal	1.60
2494	39	F	10	F10	Platinum Recliner	normal	1.60
2495	39	F	11	F11	Platinum Recliner	normal	1.60
2496	39	F	12	F12	Platinum Recliner	normal	1.60
2497	40	A	1	A1	Silver	normal	1.00
2498	40	A	2	A2	Silver	normal	1.00
2499	40	A	3	A3	Silver	normal	1.00
2500	40	A	4	A4	Silver	normal	1.00
2501	40	A	5	A5	Silver	normal	1.00
2502	40	A	6	A6	Silver	normal	1.00
2503	40	A	7	A7	Silver	normal	1.00
2504	40	A	8	A8	Silver	normal	1.00
2505	40	A	9	A9	Silver	normal	1.00
2506	40	A	10	A10	Silver	normal	1.00
2507	40	B	1	B1	Silver	normal	1.00
2508	40	B	2	B2	Silver	normal	1.00
2509	40	B	3	B3	Silver	normal	1.00
2510	40	B	4	B4	Silver	normal	1.00
2511	40	B	5	B5	Silver	normal	1.00
2512	40	B	6	B6	Silver	normal	1.00
2513	40	B	7	B7	Silver	normal	1.00
2514	40	B	8	B8	Silver	normal	1.00
2515	40	B	9	B9	Silver	normal	1.00
2516	40	B	10	B10	Silver	normal	1.00
2517	40	C	1	C1	Gold	normal	1.25
2518	40	C	2	C2	Gold	normal	1.25
2519	40	C	3	C3	Gold	normal	1.25
2520	40	C	4	C4	Gold	normal	1.25
2521	40	C	5	C5	Gold	normal	1.25
2522	40	C	6	C6	Gold	normal	1.25
2523	40	C	7	C7	Gold	normal	1.25
2524	40	C	8	C8	Gold	normal	1.25
2525	40	C	9	C9	Gold	normal	1.25
2526	40	C	10	C10	Gold	normal	1.25
2527	40	D	1	D1	Gold	normal	1.25
2528	40	D	2	D2	Gold	normal	1.25
2529	40	D	3	D3	Gold	normal	1.25
2530	40	D	4	D4	Gold	normal	1.25
2531	40	D	5	D5	Gold	normal	1.25
2532	40	D	6	D6	Gold	normal	1.25
2533	40	D	7	D7	Gold	normal	1.25
2534	40	D	8	D8	Gold	normal	1.25
2535	40	D	9	D9	Gold	normal	1.25
2536	40	D	10	D10	Gold	normal	1.25
2537	40	E	1	E1	Platinum Recliner	normal	1.60
2538	40	E	2	E2	Platinum Recliner	normal	1.60
2539	40	E	3	E3	Platinum Recliner	normal	1.60
2540	40	E	4	E4	Platinum Recliner	normal	1.60
2541	40	E	5	E5	Platinum Recliner	normal	1.60
2542	40	E	6	E6	Platinum Recliner	normal	1.60
2543	40	E	7	E7	Platinum Recliner	normal	1.60
2544	40	E	8	E8	Platinum Recliner	normal	1.60
2545	40	E	9	E9	Platinum Recliner	normal	1.60
2546	40	E	10	E10	Platinum Recliner	normal	1.60
2547	40	F	1	F1	Platinum Recliner	normal	1.60
2548	40	F	2	F2	Platinum Recliner	normal	1.60
2549	40	F	3	F3	Platinum Recliner	normal	1.60
2550	40	F	4	F4	Platinum Recliner	normal	1.60
2551	40	F	5	F5	Platinum Recliner	normal	1.60
2552	40	F	6	F6	Platinum Recliner	normal	1.60
2553	40	F	7	F7	Platinum Recliner	normal	1.60
2554	40	F	8	F8	Platinum Recliner	normal	1.60
2555	40	F	9	F9	Platinum Recliner	normal	1.60
2556	40	F	10	F10	Platinum Recliner	normal	1.60
2557	41	A	1	A1	Silver	normal	1.00
2558	41	A	2	A2	Silver	normal	1.00
2559	41	A	3	A3	Silver	normal	1.00
2560	41	A	4	A4	Silver	normal	1.00
2561	41	A	5	A5	Silver	normal	1.00
2562	41	A	6	A6	Silver	normal	1.00
2563	41	A	7	A7	Silver	normal	1.00
2564	41	A	8	A8	Silver	normal	1.00
2565	41	A	9	A9	Silver	normal	1.00
2566	41	A	10	A10	Silver	normal	1.00
2567	41	A	11	A11	Silver	normal	1.00
2568	41	A	12	A12	Silver	normal	1.00
2569	41	B	1	B1	Silver	normal	1.00
2570	41	B	2	B2	Silver	normal	1.00
2571	41	B	3	B3	Silver	normal	1.00
2572	41	B	4	B4	Silver	normal	1.00
2573	41	B	5	B5	Silver	normal	1.00
2574	41	B	6	B6	Silver	normal	1.00
2575	41	B	7	B7	Silver	normal	1.00
2576	41	B	8	B8	Silver	normal	1.00
2577	41	B	9	B9	Silver	normal	1.00
2578	41	B	10	B10	Silver	normal	1.00
2579	41	B	11	B11	Silver	normal	1.00
2580	41	B	12	B12	Silver	normal	1.00
2581	41	C	1	C1	Gold	normal	1.25
2582	41	C	2	C2	Gold	normal	1.25
2583	41	C	3	C3	Gold	normal	1.25
2584	41	C	4	C4	Gold	normal	1.25
2585	41	C	5	C5	Gold	normal	1.25
2586	41	C	6	C6	Gold	normal	1.25
2587	41	C	7	C7	Gold	normal	1.25
2588	41	C	8	C8	Gold	normal	1.25
2589	41	C	9	C9	Gold	normal	1.25
2590	41	C	10	C10	Gold	normal	1.25
2591	41	C	11	C11	Gold	normal	1.25
2592	41	C	12	C12	Gold	normal	1.25
2593	41	D	1	D1	Gold	normal	1.25
2594	41	D	2	D2	Gold	normal	1.25
2595	41	D	3	D3	Gold	normal	1.25
2596	41	D	4	D4	Gold	normal	1.25
2597	41	D	5	D5	Gold	normal	1.25
2598	41	D	6	D6	Gold	normal	1.25
2599	41	D	7	D7	Gold	normal	1.25
2600	41	D	8	D8	Gold	normal	1.25
2601	41	D	9	D9	Gold	normal	1.25
2602	41	D	10	D10	Gold	normal	1.25
2603	41	D	11	D11	Gold	normal	1.25
2604	41	D	12	D12	Gold	normal	1.25
2605	41	E	1	E1	Platinum Recliner	normal	1.60
2606	41	E	2	E2	Platinum Recliner	normal	1.60
2607	41	E	3	E3	Platinum Recliner	normal	1.60
2608	41	E	4	E4	Platinum Recliner	normal	1.60
2609	41	E	5	E5	Platinum Recliner	normal	1.60
2610	41	E	6	E6	Platinum Recliner	normal	1.60
2611	41	E	7	E7	Platinum Recliner	normal	1.60
2612	41	E	8	E8	Platinum Recliner	normal	1.60
2613	41	E	9	E9	Platinum Recliner	normal	1.60
2614	41	E	10	E10	Platinum Recliner	normal	1.60
2615	41	E	11	E11	Platinum Recliner	normal	1.60
2616	41	E	12	E12	Platinum Recliner	normal	1.60
2617	41	F	1	F1	Platinum Recliner	normal	1.60
2618	41	F	2	F2	Platinum Recliner	normal	1.60
2619	41	F	3	F3	Platinum Recliner	normal	1.60
2620	41	F	4	F4	Platinum Recliner	normal	1.60
2621	41	F	5	F5	Platinum Recliner	normal	1.60
2622	41	F	6	F6	Platinum Recliner	normal	1.60
2623	41	F	7	F7	Platinum Recliner	normal	1.60
2624	41	F	8	F8	Platinum Recliner	normal	1.60
2625	41	F	9	F9	Platinum Recliner	normal	1.60
2626	41	F	10	F10	Platinum Recliner	normal	1.60
2627	41	F	11	F11	Platinum Recliner	normal	1.60
2628	41	F	12	F12	Platinum Recliner	normal	1.60
2629	42	A	1	A1	Silver	normal	1.00
2630	42	A	2	A2	Silver	normal	1.00
2631	42	A	3	A3	Silver	normal	1.00
2632	42	A	4	A4	Silver	normal	1.00
2633	42	A	5	A5	Silver	normal	1.00
2634	42	A	6	A6	Silver	normal	1.00
2635	42	A	7	A7	Silver	normal	1.00
2636	42	A	8	A8	Silver	normal	1.00
2637	42	A	9	A9	Silver	normal	1.00
2638	42	A	10	A10	Silver	normal	1.00
2639	42	A	11	A11	Silver	normal	1.00
2640	42	A	12	A12	Silver	normal	1.00
2641	42	B	1	B1	Silver	normal	1.00
2642	42	B	2	B2	Silver	normal	1.00
2643	42	B	3	B3	Silver	normal	1.00
2644	42	B	4	B4	Silver	normal	1.00
2645	42	B	5	B5	Silver	normal	1.00
2646	42	B	6	B6	Silver	normal	1.00
2647	42	B	7	B7	Silver	normal	1.00
2648	42	B	8	B8	Silver	normal	1.00
2649	42	B	9	B9	Silver	normal	1.00
2650	42	B	10	B10	Silver	normal	1.00
2651	42	B	11	B11	Silver	normal	1.00
2652	42	B	12	B12	Silver	normal	1.00
2653	42	C	1	C1	Gold	normal	1.25
2654	42	C	2	C2	Gold	normal	1.25
2655	42	C	3	C3	Gold	normal	1.25
2656	42	C	4	C4	Gold	normal	1.25
2657	42	C	5	C5	Gold	normal	1.25
2658	42	C	6	C6	Gold	normal	1.25
2659	42	C	7	C7	Gold	normal	1.25
2660	42	C	8	C8	Gold	normal	1.25
2661	42	C	9	C9	Gold	normal	1.25
2662	42	C	10	C10	Gold	normal	1.25
2663	42	C	11	C11	Gold	normal	1.25
2664	42	C	12	C12	Gold	normal	1.25
2665	42	D	1	D1	Gold	normal	1.25
2666	42	D	2	D2	Gold	normal	1.25
2667	42	D	3	D3	Gold	normal	1.25
2668	42	D	4	D4	Gold	normal	1.25
2669	42	D	5	D5	Gold	normal	1.25
2670	42	D	6	D6	Gold	normal	1.25
2671	42	D	7	D7	Gold	normal	1.25
2672	42	D	8	D8	Gold	normal	1.25
2673	42	D	9	D9	Gold	normal	1.25
2674	42	D	10	D10	Gold	normal	1.25
2675	42	D	11	D11	Gold	normal	1.25
2676	42	D	12	D12	Gold	normal	1.25
2677	42	E	1	E1	Platinum Recliner	normal	1.60
2678	42	E	2	E2	Platinum Recliner	normal	1.60
2679	42	E	3	E3	Platinum Recliner	normal	1.60
2680	42	E	4	E4	Platinum Recliner	normal	1.60
2681	42	E	5	E5	Platinum Recliner	normal	1.60
2682	42	E	6	E6	Platinum Recliner	normal	1.60
2683	42	E	7	E7	Platinum Recliner	normal	1.60
2684	42	E	8	E8	Platinum Recliner	normal	1.60
2685	42	E	9	E9	Platinum Recliner	normal	1.60
2686	42	E	10	E10	Platinum Recliner	normal	1.60
2687	42	E	11	E11	Platinum Recliner	normal	1.60
2688	42	E	12	E12	Platinum Recliner	normal	1.60
2689	42	F	1	F1	Platinum Recliner	normal	1.60
2690	42	F	2	F2	Platinum Recliner	normal	1.60
2691	42	F	3	F3	Platinum Recliner	normal	1.60
2692	42	F	4	F4	Platinum Recliner	normal	1.60
2693	42	F	5	F5	Platinum Recliner	normal	1.60
2694	42	F	6	F6	Platinum Recliner	normal	1.60
2695	42	F	7	F7	Platinum Recliner	normal	1.60
2696	42	F	8	F8	Platinum Recliner	normal	1.60
2697	42	F	9	F9	Platinum Recliner	normal	1.60
2698	42	F	10	F10	Platinum Recliner	normal	1.60
2699	42	F	11	F11	Platinum Recliner	normal	1.60
2700	42	F	12	F12	Platinum Recliner	normal	1.60
2701	43	A	1	A1	Silver	normal	1.00
2702	43	A	2	A2	Silver	normal	1.00
2703	43	A	3	A3	Silver	normal	1.00
2704	43	A	4	A4	Silver	normal	1.00
2705	43	A	5	A5	Silver	normal	1.00
2706	43	A	6	A6	Silver	normal	1.00
2707	43	A	7	A7	Silver	normal	1.00
2708	43	A	8	A8	Silver	normal	1.00
2709	43	A	9	A9	Silver	normal	1.00
2710	43	A	10	A10	Silver	normal	1.00
2711	43	A	11	A11	Silver	normal	1.00
2712	43	A	12	A12	Silver	normal	1.00
2713	43	B	1	B1	Silver	normal	1.00
2714	43	B	2	B2	Silver	normal	1.00
2715	43	B	3	B3	Silver	normal	1.00
2716	43	B	4	B4	Silver	normal	1.00
2717	43	B	5	B5	Silver	normal	1.00
2718	43	B	6	B6	Silver	normal	1.00
2719	43	B	7	B7	Silver	normal	1.00
2720	43	B	8	B8	Silver	normal	1.00
2721	43	B	9	B9	Silver	normal	1.00
2722	43	B	10	B10	Silver	normal	1.00
2723	43	B	11	B11	Silver	normal	1.00
2724	43	B	12	B12	Silver	normal	1.00
2725	43	C	1	C1	Gold	normal	1.25
2726	43	C	2	C2	Gold	normal	1.25
2727	43	C	3	C3	Gold	normal	1.25
2728	43	C	4	C4	Gold	normal	1.25
2729	43	C	5	C5	Gold	normal	1.25
2730	43	C	6	C6	Gold	normal	1.25
2731	43	C	7	C7	Gold	normal	1.25
2732	43	C	8	C8	Gold	normal	1.25
2733	43	C	9	C9	Gold	normal	1.25
2734	43	C	10	C10	Gold	normal	1.25
2735	43	C	11	C11	Gold	normal	1.25
2736	43	C	12	C12	Gold	normal	1.25
2737	43	D	1	D1	Gold	normal	1.25
2738	43	D	2	D2	Gold	normal	1.25
2739	43	D	3	D3	Gold	normal	1.25
2740	43	D	4	D4	Gold	normal	1.25
2741	43	D	5	D5	Gold	normal	1.25
2742	43	D	6	D6	Gold	normal	1.25
2743	43	D	7	D7	Gold	normal	1.25
2744	43	D	8	D8	Gold	normal	1.25
2745	43	D	9	D9	Gold	normal	1.25
2746	43	D	10	D10	Gold	normal	1.25
2747	43	D	11	D11	Gold	normal	1.25
2748	43	D	12	D12	Gold	normal	1.25
2749	43	E	1	E1	Platinum Recliner	normal	1.60
2750	43	E	2	E2	Platinum Recliner	normal	1.60
2751	43	E	3	E3	Platinum Recliner	normal	1.60
2752	43	E	4	E4	Platinum Recliner	normal	1.60
2753	43	E	5	E5	Platinum Recliner	normal	1.60
2754	43	E	6	E6	Platinum Recliner	normal	1.60
2755	43	E	7	E7	Platinum Recliner	normal	1.60
2756	43	E	8	E8	Platinum Recliner	normal	1.60
2757	43	E	9	E9	Platinum Recliner	normal	1.60
2758	43	E	10	E10	Platinum Recliner	normal	1.60
2759	43	E	11	E11	Platinum Recliner	normal	1.60
2760	43	E	12	E12	Platinum Recliner	normal	1.60
2761	43	F	1	F1	Platinum Recliner	normal	1.60
2762	43	F	2	F2	Platinum Recliner	normal	1.60
2763	43	F	3	F3	Platinum Recliner	normal	1.60
2764	43	F	4	F4	Platinum Recliner	normal	1.60
2765	43	F	5	F5	Platinum Recliner	normal	1.60
2766	43	F	6	F6	Platinum Recliner	normal	1.60
2767	43	F	7	F7	Platinum Recliner	normal	1.60
2768	43	F	8	F8	Platinum Recliner	normal	1.60
2769	43	F	9	F9	Platinum Recliner	normal	1.60
2770	43	F	10	F10	Platinum Recliner	normal	1.60
2771	43	F	11	F11	Platinum Recliner	normal	1.60
2996	47	C	4	C4	Gold	normal	1.25
2772	43	F	12	F12	Platinum Recliner	normal	1.60
2773	44	A	1	A1	Silver	normal	1.00
2774	44	A	2	A2	Silver	normal	1.00
2775	44	A	3	A3	Silver	normal	1.00
2776	44	A	4	A4	Silver	normal	1.00
2777	44	A	5	A5	Silver	normal	1.00
2778	44	A	6	A6	Silver	normal	1.00
2779	44	A	7	A7	Silver	normal	1.00
2780	44	A	8	A8	Silver	normal	1.00
2781	44	A	9	A9	Silver	normal	1.00
2782	44	A	10	A10	Silver	normal	1.00
2783	44	A	11	A11	Silver	normal	1.00
2784	44	A	12	A12	Silver	normal	1.00
2785	44	B	1	B1	Silver	normal	1.00
2786	44	B	2	B2	Silver	normal	1.00
2787	44	B	3	B3	Silver	normal	1.00
2788	44	B	4	B4	Silver	normal	1.00
2789	44	B	5	B5	Silver	normal	1.00
2790	44	B	6	B6	Silver	normal	1.00
2791	44	B	7	B7	Silver	normal	1.00
2792	44	B	8	B8	Silver	normal	1.00
2793	44	B	9	B9	Silver	normal	1.00
2794	44	B	10	B10	Silver	normal	1.00
2795	44	B	11	B11	Silver	normal	1.00
2796	44	B	12	B12	Silver	normal	1.00
2797	44	C	1	C1	Gold	normal	1.25
2798	44	C	2	C2	Gold	normal	1.25
2799	44	C	3	C3	Gold	normal	1.25
2800	44	C	4	C4	Gold	normal	1.25
2801	44	C	5	C5	Gold	normal	1.25
2802	44	C	6	C6	Gold	normal	1.25
2803	44	C	7	C7	Gold	normal	1.25
2804	44	C	8	C8	Gold	normal	1.25
2805	44	C	9	C9	Gold	normal	1.25
2806	44	C	10	C10	Gold	normal	1.25
2807	44	C	11	C11	Gold	normal	1.25
2808	44	C	12	C12	Gold	normal	1.25
2809	44	D	1	D1	Gold	normal	1.25
2810	44	D	2	D2	Gold	normal	1.25
2811	44	D	3	D3	Gold	normal	1.25
2812	44	D	4	D4	Gold	normal	1.25
2813	44	D	5	D5	Gold	normal	1.25
2814	44	D	6	D6	Gold	normal	1.25
2815	44	D	7	D7	Gold	normal	1.25
2816	44	D	8	D8	Gold	normal	1.25
2817	44	D	9	D9	Gold	normal	1.25
2818	44	D	10	D10	Gold	normal	1.25
2819	44	D	11	D11	Gold	normal	1.25
2820	44	D	12	D12	Gold	normal	1.25
2821	44	E	1	E1	Platinum Recliner	normal	1.60
2822	44	E	2	E2	Platinum Recliner	normal	1.60
2823	44	E	3	E3	Platinum Recliner	normal	1.60
2824	44	E	4	E4	Platinum Recliner	normal	1.60
2825	44	E	5	E5	Platinum Recliner	normal	1.60
2826	44	E	6	E6	Platinum Recliner	normal	1.60
2827	44	E	7	E7	Platinum Recliner	normal	1.60
2828	44	E	8	E8	Platinum Recliner	normal	1.60
2829	44	E	9	E9	Platinum Recliner	normal	1.60
2830	44	E	10	E10	Platinum Recliner	normal	1.60
2831	44	E	11	E11	Platinum Recliner	normal	1.60
2832	44	E	12	E12	Platinum Recliner	normal	1.60
2833	44	F	1	F1	Platinum Recliner	normal	1.60
2834	44	F	2	F2	Platinum Recliner	normal	1.60
2835	44	F	3	F3	Platinum Recliner	normal	1.60
2836	44	F	4	F4	Platinum Recliner	normal	1.60
2837	44	F	5	F5	Platinum Recliner	normal	1.60
2838	44	F	6	F6	Platinum Recliner	normal	1.60
2839	44	F	7	F7	Platinum Recliner	normal	1.60
2840	44	F	8	F8	Platinum Recliner	normal	1.60
2841	44	F	9	F9	Platinum Recliner	normal	1.60
2842	44	F	10	F10	Platinum Recliner	normal	1.60
2843	44	F	11	F11	Platinum Recliner	normal	1.60
2844	44	F	12	F12	Platinum Recliner	normal	1.60
2845	45	A	1	A1	Silver	normal	1.00
2846	45	A	2	A2	Silver	normal	1.00
2847	45	A	3	A3	Silver	normal	1.00
2848	45	A	4	A4	Silver	normal	1.00
2849	45	A	5	A5	Silver	normal	1.00
2850	45	A	6	A6	Silver	normal	1.00
2851	45	A	7	A7	Silver	normal	1.00
2852	45	A	8	A8	Silver	normal	1.00
2853	45	A	9	A9	Silver	normal	1.00
2854	45	A	10	A10	Silver	normal	1.00
2855	45	B	1	B1	Silver	normal	1.00
2856	45	B	2	B2	Silver	normal	1.00
2857	45	B	3	B3	Silver	normal	1.00
2858	45	B	4	B4	Silver	normal	1.00
2859	45	B	5	B5	Silver	normal	1.00
2860	45	B	6	B6	Silver	normal	1.00
2861	45	B	7	B7	Silver	normal	1.00
2862	45	B	8	B8	Silver	normal	1.00
2863	45	B	9	B9	Silver	normal	1.00
2864	45	B	10	B10	Silver	normal	1.00
2865	45	C	1	C1	Gold	normal	1.25
2866	45	C	2	C2	Gold	normal	1.25
2867	45	C	3	C3	Gold	normal	1.25
2868	45	C	4	C4	Gold	normal	1.25
2869	45	C	5	C5	Gold	normal	1.25
2870	45	C	6	C6	Gold	normal	1.25
2871	45	C	7	C7	Gold	normal	1.25
2872	45	C	8	C8	Gold	normal	1.25
2873	45	C	9	C9	Gold	normal	1.25
2874	45	C	10	C10	Gold	normal	1.25
2875	45	D	1	D1	Gold	normal	1.25
2876	45	D	2	D2	Gold	normal	1.25
2877	45	D	3	D3	Gold	normal	1.25
2878	45	D	4	D4	Gold	normal	1.25
2879	45	D	5	D5	Gold	normal	1.25
2880	45	D	6	D6	Gold	normal	1.25
2881	45	D	7	D7	Gold	normal	1.25
2882	45	D	8	D8	Gold	normal	1.25
2883	45	D	9	D9	Gold	normal	1.25
2884	45	D	10	D10	Gold	normal	1.25
2885	45	E	1	E1	Platinum Recliner	normal	1.60
2886	45	E	2	E2	Platinum Recliner	normal	1.60
2887	45	E	3	E3	Platinum Recliner	normal	1.60
2888	45	E	4	E4	Platinum Recliner	normal	1.60
2889	45	E	5	E5	Platinum Recliner	normal	1.60
2890	45	E	6	E6	Platinum Recliner	normal	1.60
2891	45	E	7	E7	Platinum Recliner	normal	1.60
2892	45	E	8	E8	Platinum Recliner	normal	1.60
2893	45	E	9	E9	Platinum Recliner	normal	1.60
2894	45	E	10	E10	Platinum Recliner	normal	1.60
2895	45	F	1	F1	Platinum Recliner	normal	1.60
2896	45	F	2	F2	Platinum Recliner	normal	1.60
2897	45	F	3	F3	Platinum Recliner	normal	1.60
2898	45	F	4	F4	Platinum Recliner	normal	1.60
2899	45	F	5	F5	Platinum Recliner	normal	1.60
2900	45	F	6	F6	Platinum Recliner	normal	1.60
2901	45	F	7	F7	Platinum Recliner	normal	1.60
2902	45	F	8	F8	Platinum Recliner	normal	1.60
2903	45	F	9	F9	Platinum Recliner	normal	1.60
2904	45	F	10	F10	Platinum Recliner	normal	1.60
2905	46	A	1	A1	Silver	normal	1.00
2906	46	A	2	A2	Silver	normal	1.00
2907	46	A	3	A3	Silver	normal	1.00
2908	46	A	4	A4	Silver	normal	1.00
2909	46	A	5	A5	Silver	normal	1.00
2910	46	A	6	A6	Silver	normal	1.00
2911	46	A	7	A7	Silver	normal	1.00
2912	46	A	8	A8	Silver	normal	1.00
2913	46	A	9	A9	Silver	normal	1.00
2914	46	A	10	A10	Silver	normal	1.00
2915	46	A	11	A11	Silver	normal	1.00
2916	46	A	12	A12	Silver	normal	1.00
2917	46	B	1	B1	Silver	normal	1.00
2918	46	B	2	B2	Silver	normal	1.00
2919	46	B	3	B3	Silver	normal	1.00
2920	46	B	4	B4	Silver	normal	1.00
2921	46	B	5	B5	Silver	normal	1.00
2922	46	B	6	B6	Silver	normal	1.00
2923	46	B	7	B7	Silver	normal	1.00
2924	46	B	8	B8	Silver	normal	1.00
2925	46	B	9	B9	Silver	normal	1.00
2926	46	B	10	B10	Silver	normal	1.00
2927	46	B	11	B11	Silver	normal	1.00
2928	46	B	12	B12	Silver	normal	1.00
2929	46	C	1	C1	Gold	normal	1.25
2930	46	C	2	C2	Gold	normal	1.25
2931	46	C	3	C3	Gold	normal	1.25
2932	46	C	4	C4	Gold	normal	1.25
2933	46	C	5	C5	Gold	normal	1.25
2934	46	C	6	C6	Gold	normal	1.25
2935	46	C	7	C7	Gold	normal	1.25
2936	46	C	8	C8	Gold	normal	1.25
2937	46	C	9	C9	Gold	normal	1.25
2938	46	C	10	C10	Gold	normal	1.25
2939	46	C	11	C11	Gold	normal	1.25
2940	46	C	12	C12	Gold	normal	1.25
2941	46	D	1	D1	Gold	normal	1.25
2942	46	D	2	D2	Gold	normal	1.25
2943	46	D	3	D3	Gold	normal	1.25
2944	46	D	4	D4	Gold	normal	1.25
2945	46	D	5	D5	Gold	normal	1.25
2946	46	D	6	D6	Gold	normal	1.25
2947	46	D	7	D7	Gold	normal	1.25
2948	46	D	8	D8	Gold	normal	1.25
2949	46	D	9	D9	Gold	normal	1.25
2950	46	D	10	D10	Gold	normal	1.25
2951	46	D	11	D11	Gold	normal	1.25
2952	46	D	12	D12	Gold	normal	1.25
2953	46	E	1	E1	Platinum Recliner	normal	1.60
2954	46	E	2	E2	Platinum Recliner	normal	1.60
2955	46	E	3	E3	Platinum Recliner	normal	1.60
2956	46	E	4	E4	Platinum Recliner	normal	1.60
2957	46	E	5	E5	Platinum Recliner	normal	1.60
2958	46	E	6	E6	Platinum Recliner	normal	1.60
2959	46	E	7	E7	Platinum Recliner	normal	1.60
2960	46	E	8	E8	Platinum Recliner	normal	1.60
2961	46	E	9	E9	Platinum Recliner	normal	1.60
2962	46	E	10	E10	Platinum Recliner	normal	1.60
2963	46	E	11	E11	Platinum Recliner	normal	1.60
2964	46	E	12	E12	Platinum Recliner	normal	1.60
2965	46	F	1	F1	Platinum Recliner	normal	1.60
2966	46	F	2	F2	Platinum Recliner	normal	1.60
2967	46	F	3	F3	Platinum Recliner	normal	1.60
2968	46	F	4	F4	Platinum Recliner	normal	1.60
2969	46	F	5	F5	Platinum Recliner	normal	1.60
2970	46	F	6	F6	Platinum Recliner	normal	1.60
2971	46	F	7	F7	Platinum Recliner	normal	1.60
2972	46	F	8	F8	Platinum Recliner	normal	1.60
2973	46	F	9	F9	Platinum Recliner	normal	1.60
2974	46	F	10	F10	Platinum Recliner	normal	1.60
2975	46	F	11	F11	Platinum Recliner	normal	1.60
2976	46	F	12	F12	Platinum Recliner	normal	1.60
2977	47	A	1	A1	Silver	normal	1.00
2978	47	A	2	A2	Silver	normal	1.00
2979	47	A	3	A3	Silver	normal	1.00
2980	47	A	4	A4	Silver	normal	1.00
2981	47	A	5	A5	Silver	normal	1.00
2982	47	A	6	A6	Silver	normal	1.00
2983	47	A	7	A7	Silver	normal	1.00
2984	47	A	8	A8	Silver	normal	1.00
2985	47	B	1	B1	Silver	normal	1.00
2986	47	B	2	B2	Silver	normal	1.00
2987	47	B	3	B3	Silver	normal	1.00
2988	47	B	4	B4	Silver	normal	1.00
2989	47	B	5	B5	Silver	normal	1.00
2990	47	B	6	B6	Silver	normal	1.00
2991	47	B	7	B7	Silver	normal	1.00
2992	47	B	8	B8	Silver	normal	1.00
2993	47	C	1	C1	Gold	normal	1.25
2994	47	C	2	C2	Gold	normal	1.25
2995	47	C	3	C3	Gold	normal	1.25
2997	47	C	5	C5	Gold	normal	1.25
2998	47	C	6	C6	Gold	normal	1.25
2999	47	C	7	C7	Gold	normal	1.25
3000	47	C	8	C8	Gold	normal	1.25
3001	47	D	1	D1	Gold	normal	1.25
3002	47	D	2	D2	Gold	normal	1.25
3003	47	D	3	D3	Gold	normal	1.25
3004	47	D	4	D4	Gold	normal	1.25
3005	47	D	5	D5	Gold	normal	1.25
3006	47	D	6	D6	Gold	normal	1.25
3007	47	D	7	D7	Gold	normal	1.25
3008	47	D	8	D8	Gold	normal	1.25
3009	47	E	1	E1	Platinum Recliner	normal	1.60
3010	47	E	2	E2	Platinum Recliner	normal	1.60
3011	47	E	3	E3	Platinum Recliner	normal	1.60
3012	47	E	4	E4	Platinum Recliner	normal	1.60
3013	47	E	5	E5	Platinum Recliner	normal	1.60
3014	47	E	6	E6	Platinum Recliner	normal	1.60
3015	47	E	7	E7	Platinum Recliner	normal	1.60
3016	47	E	8	E8	Platinum Recliner	normal	1.60
3017	47	F	1	F1	Platinum Recliner	normal	1.60
3018	47	F	2	F2	Platinum Recliner	normal	1.60
3019	47	F	3	F3	Platinum Recliner	normal	1.60
3020	47	F	4	F4	Platinum Recliner	normal	1.60
3021	47	F	5	F5	Platinum Recliner	normal	1.60
3022	47	F	6	F6	Platinum Recliner	normal	1.60
3023	47	F	7	F7	Platinum Recliner	normal	1.60
3024	47	F	8	F8	Platinum Recliner	normal	1.60
3025	48	A	1	A1	Silver	normal	1.00
3026	48	A	2	A2	Silver	normal	1.00
3027	48	A	3	A3	Silver	normal	1.00
3028	48	A	4	A4	Silver	normal	1.00
3029	48	A	5	A5	Silver	normal	1.00
3030	48	A	6	A6	Silver	normal	1.00
3031	48	A	7	A7	Silver	normal	1.00
3032	48	A	8	A8	Silver	normal	1.00
3033	48	A	9	A9	Silver	normal	1.00
3034	48	A	10	A10	Silver	normal	1.00
3035	48	A	11	A11	Silver	normal	1.00
3036	48	A	12	A12	Silver	normal	1.00
3037	48	B	1	B1	Silver	normal	1.00
3038	48	B	2	B2	Silver	normal	1.00
3039	48	B	3	B3	Silver	normal	1.00
3040	48	B	4	B4	Silver	normal	1.00
3041	48	B	5	B5	Silver	normal	1.00
3042	48	B	6	B6	Silver	normal	1.00
3043	48	B	7	B7	Silver	normal	1.00
3044	48	B	8	B8	Silver	normal	1.00
3045	48	B	9	B9	Silver	normal	1.00
3046	48	B	10	B10	Silver	normal	1.00
3047	48	B	11	B11	Silver	normal	1.00
3048	48	B	12	B12	Silver	normal	1.00
3049	48	C	1	C1	Gold	normal	1.25
3050	48	C	2	C2	Gold	normal	1.25
3051	48	C	3	C3	Gold	normal	1.25
3052	48	C	4	C4	Gold	normal	1.25
3053	48	C	5	C5	Gold	normal	1.25
3054	48	C	6	C6	Gold	normal	1.25
3055	48	C	7	C7	Gold	normal	1.25
3056	48	C	8	C8	Gold	normal	1.25
3057	48	C	9	C9	Gold	normal	1.25
3058	48	C	10	C10	Gold	normal	1.25
3059	48	C	11	C11	Gold	normal	1.25
3060	48	C	12	C12	Gold	normal	1.25
3061	48	D	1	D1	Gold	normal	1.25
3062	48	D	2	D2	Gold	normal	1.25
3063	48	D	3	D3	Gold	normal	1.25
3064	48	D	4	D4	Gold	normal	1.25
3065	48	D	5	D5	Gold	normal	1.25
3066	48	D	6	D6	Gold	normal	1.25
3067	48	D	7	D7	Gold	normal	1.25
3068	48	D	8	D8	Gold	normal	1.25
3069	48	D	9	D9	Gold	normal	1.25
3070	48	D	10	D10	Gold	normal	1.25
3071	48	D	11	D11	Gold	normal	1.25
3072	48	D	12	D12	Gold	normal	1.25
3073	48	E	1	E1	Platinum Recliner	normal	1.60
3074	48	E	2	E2	Platinum Recliner	normal	1.60
3075	48	E	3	E3	Platinum Recliner	normal	1.60
3076	48	E	4	E4	Platinum Recliner	normal	1.60
3077	48	E	5	E5	Platinum Recliner	normal	1.60
3078	48	E	6	E6	Platinum Recliner	normal	1.60
3079	48	E	7	E7	Platinum Recliner	normal	1.60
3080	48	E	8	E8	Platinum Recliner	normal	1.60
3081	48	E	9	E9	Platinum Recliner	normal	1.60
3082	48	E	10	E10	Platinum Recliner	normal	1.60
3083	48	E	11	E11	Platinum Recliner	normal	1.60
3084	48	E	12	E12	Platinum Recliner	normal	1.60
3085	48	F	1	F1	Platinum Recliner	normal	1.60
3086	48	F	2	F2	Platinum Recliner	normal	1.60
3087	48	F	3	F3	Platinum Recliner	normal	1.60
3088	48	F	4	F4	Platinum Recliner	normal	1.60
3089	48	F	5	F5	Platinum Recliner	normal	1.60
3090	48	F	6	F6	Platinum Recliner	normal	1.60
3091	48	F	7	F7	Platinum Recliner	normal	1.60
3092	48	F	8	F8	Platinum Recliner	normal	1.60
3093	48	F	9	F9	Platinum Recliner	normal	1.60
3094	48	F	10	F10	Platinum Recliner	normal	1.60
3095	48	F	11	F11	Platinum Recliner	normal	1.60
3096	48	F	12	F12	Platinum Recliner	normal	1.60
3097	49	A	1	A1	Silver	normal	1.00
3098	49	A	2	A2	Silver	normal	1.00
3099	49	A	3	A3	Silver	normal	1.00
3100	49	A	4	A4	Silver	normal	1.00
3101	49	A	5	A5	Silver	normal	1.00
3102	49	A	6	A6	Silver	normal	1.00
3103	49	A	7	A7	Silver	normal	1.00
3104	49	A	8	A8	Silver	normal	1.00
3105	49	A	9	A9	Silver	normal	1.00
3106	49	A	10	A10	Silver	normal	1.00
3107	49	A	11	A11	Silver	normal	1.00
3108	49	A	12	A12	Silver	normal	1.00
3109	49	B	1	B1	Silver	normal	1.00
3110	49	B	2	B2	Silver	normal	1.00
3111	49	B	3	B3	Silver	normal	1.00
3112	49	B	4	B4	Silver	normal	1.00
3113	49	B	5	B5	Silver	normal	1.00
3114	49	B	6	B6	Silver	normal	1.00
3115	49	B	7	B7	Silver	normal	1.00
3116	49	B	8	B8	Silver	normal	1.00
3117	49	B	9	B9	Silver	normal	1.00
3118	49	B	10	B10	Silver	normal	1.00
3119	49	B	11	B11	Silver	normal	1.00
3120	49	B	12	B12	Silver	normal	1.00
3121	49	C	1	C1	Gold	normal	1.25
3122	49	C	2	C2	Gold	normal	1.25
3123	49	C	3	C3	Gold	normal	1.25
3124	49	C	4	C4	Gold	normal	1.25
3125	49	C	5	C5	Gold	normal	1.25
3126	49	C	6	C6	Gold	normal	1.25
3127	49	C	7	C7	Gold	normal	1.25
3128	49	C	8	C8	Gold	normal	1.25
3129	49	C	9	C9	Gold	normal	1.25
3130	49	C	10	C10	Gold	normal	1.25
3131	49	C	11	C11	Gold	normal	1.25
3132	49	C	12	C12	Gold	normal	1.25
3133	49	D	1	D1	Gold	normal	1.25
3134	49	D	2	D2	Gold	normal	1.25
3135	49	D	3	D3	Gold	normal	1.25
3136	49	D	4	D4	Gold	normal	1.25
3137	49	D	5	D5	Gold	normal	1.25
3138	49	D	6	D6	Gold	normal	1.25
3139	49	D	7	D7	Gold	normal	1.25
3140	49	D	8	D8	Gold	normal	1.25
3141	49	D	9	D9	Gold	normal	1.25
3142	49	D	10	D10	Gold	normal	1.25
3143	49	D	11	D11	Gold	normal	1.25
3144	49	D	12	D12	Gold	normal	1.25
3145	49	E	1	E1	Platinum Recliner	normal	1.60
3146	49	E	2	E2	Platinum Recliner	normal	1.60
3147	49	E	3	E3	Platinum Recliner	normal	1.60
3148	49	E	4	E4	Platinum Recliner	normal	1.60
3149	49	E	5	E5	Platinum Recliner	normal	1.60
3150	49	E	6	E6	Platinum Recliner	normal	1.60
3151	49	E	7	E7	Platinum Recliner	normal	1.60
3152	49	E	8	E8	Platinum Recliner	normal	1.60
3153	49	E	9	E9	Platinum Recliner	normal	1.60
3154	49	E	10	E10	Platinum Recliner	normal	1.60
3155	49	E	11	E11	Platinum Recliner	normal	1.60
3156	49	E	12	E12	Platinum Recliner	normal	1.60
3157	49	F	1	F1	Platinum Recliner	normal	1.60
3158	49	F	2	F2	Platinum Recliner	normal	1.60
3159	49	F	3	F3	Platinum Recliner	normal	1.60
3160	49	F	4	F4	Platinum Recliner	normal	1.60
3161	49	F	5	F5	Platinum Recliner	normal	1.60
3162	49	F	6	F6	Platinum Recliner	normal	1.60
3163	49	F	7	F7	Platinum Recliner	normal	1.60
3164	49	F	8	F8	Platinum Recliner	normal	1.60
3165	49	F	9	F9	Platinum Recliner	normal	1.60
3166	49	F	10	F10	Platinum Recliner	normal	1.60
3167	49	F	11	F11	Platinum Recliner	normal	1.60
3168	49	F	12	F12	Platinum Recliner	normal	1.60
3169	50	A	1	A1	Silver	normal	1.00
3170	50	A	2	A2	Silver	normal	1.00
3171	50	A	3	A3	Silver	normal	1.00
3172	50	A	4	A4	Silver	normal	1.00
3173	50	A	5	A5	Silver	normal	1.00
3174	50	A	6	A6	Silver	normal	1.00
3175	50	A	7	A7	Silver	normal	1.00
3176	50	A	8	A8	Silver	normal	1.00
3177	50	A	9	A9	Silver	normal	1.00
3178	50	A	10	A10	Silver	normal	1.00
3179	50	A	11	A11	Silver	normal	1.00
3180	50	A	12	A12	Silver	normal	1.00
3181	50	B	1	B1	Silver	normal	1.00
3182	50	B	2	B2	Silver	normal	1.00
3183	50	B	3	B3	Silver	normal	1.00
3184	50	B	4	B4	Silver	normal	1.00
3185	50	B	5	B5	Silver	normal	1.00
3186	50	B	6	B6	Silver	normal	1.00
3187	50	B	7	B7	Silver	normal	1.00
3188	50	B	8	B8	Silver	normal	1.00
3189	50	B	9	B9	Silver	normal	1.00
3190	50	B	10	B10	Silver	normal	1.00
3191	50	B	11	B11	Silver	normal	1.00
3192	50	B	12	B12	Silver	normal	1.00
3193	50	C	1	C1	Gold	normal	1.25
3194	50	C	2	C2	Gold	normal	1.25
3195	50	C	3	C3	Gold	normal	1.25
3196	50	C	4	C4	Gold	normal	1.25
3197	50	C	5	C5	Gold	normal	1.25
3198	50	C	6	C6	Gold	normal	1.25
3199	50	C	7	C7	Gold	normal	1.25
3200	50	C	8	C8	Gold	normal	1.25
3201	50	C	9	C9	Gold	normal	1.25
3202	50	C	10	C10	Gold	normal	1.25
3203	50	C	11	C11	Gold	normal	1.25
3204	50	C	12	C12	Gold	normal	1.25
3205	50	D	1	D1	Gold	normal	1.25
3206	50	D	2	D2	Gold	normal	1.25
3207	50	D	3	D3	Gold	normal	1.25
3208	50	D	4	D4	Gold	normal	1.25
3209	50	D	5	D5	Gold	normal	1.25
3210	50	D	6	D6	Gold	normal	1.25
3211	50	D	7	D7	Gold	normal	1.25
3212	50	D	8	D8	Gold	normal	1.25
3213	50	D	9	D9	Gold	normal	1.25
3214	50	D	10	D10	Gold	normal	1.25
3215	50	D	11	D11	Gold	normal	1.25
3216	50	D	12	D12	Gold	normal	1.25
3217	50	E	1	E1	Platinum Recliner	normal	1.60
3218	50	E	2	E2	Platinum Recliner	normal	1.60
3219	50	E	3	E3	Platinum Recliner	normal	1.60
3220	50	E	4	E4	Platinum Recliner	normal	1.60
3221	50	E	5	E5	Platinum Recliner	normal	1.60
3222	50	E	6	E6	Platinum Recliner	normal	1.60
3223	50	E	7	E7	Platinum Recliner	normal	1.60
3224	50	E	8	E8	Platinum Recliner	normal	1.60
3225	50	E	9	E9	Platinum Recliner	normal	1.60
3226	50	E	10	E10	Platinum Recliner	normal	1.60
3227	50	E	11	E11	Platinum Recliner	normal	1.60
3228	50	E	12	E12	Platinum Recliner	normal	1.60
3229	50	F	1	F1	Platinum Recliner	normal	1.60
3230	50	F	2	F2	Platinum Recliner	normal	1.60
3231	50	F	3	F3	Platinum Recliner	normal	1.60
3232	50	F	4	F4	Platinum Recliner	normal	1.60
3233	50	F	5	F5	Platinum Recliner	normal	1.60
3234	50	F	6	F6	Platinum Recliner	normal	1.60
3235	50	F	7	F7	Platinum Recliner	normal	1.60
3236	50	F	8	F8	Platinum Recliner	normal	1.60
3237	50	F	9	F9	Platinum Recliner	normal	1.60
3238	50	F	10	F10	Platinum Recliner	normal	1.60
3239	50	F	11	F11	Platinum Recliner	normal	1.60
3240	50	F	12	F12	Platinum Recliner	normal	1.60
3241	51	A	1	A1	Silver	normal	1.00
3242	51	A	2	A2	Silver	normal	1.00
3243	51	A	3	A3	Silver	normal	1.00
3244	51	A	4	A4	Silver	normal	1.00
3245	51	A	5	A5	Silver	normal	1.00
3246	51	A	6	A6	Silver	normal	1.00
3247	51	A	7	A7	Silver	normal	1.00
3248	51	A	8	A8	Silver	normal	1.00
3249	51	A	9	A9	Silver	normal	1.00
3250	51	A	10	A10	Silver	normal	1.00
3251	51	A	11	A11	Silver	normal	1.00
3252	51	A	12	A12	Silver	normal	1.00
3253	51	B	1	B1	Silver	normal	1.00
3254	51	B	2	B2	Silver	normal	1.00
3255	51	B	3	B3	Silver	normal	1.00
3256	51	B	4	B4	Silver	normal	1.00
3257	51	B	5	B5	Silver	normal	1.00
3258	51	B	6	B6	Silver	normal	1.00
3259	51	B	7	B7	Silver	normal	1.00
3260	51	B	8	B8	Silver	normal	1.00
3261	51	B	9	B9	Silver	normal	1.00
3262	51	B	10	B10	Silver	normal	1.00
3263	51	B	11	B11	Silver	normal	1.00
3264	51	B	12	B12	Silver	normal	1.00
3265	51	C	1	C1	Gold	normal	1.25
3266	51	C	2	C2	Gold	normal	1.25
3267	51	C	3	C3	Gold	normal	1.25
3268	51	C	4	C4	Gold	normal	1.25
3269	51	C	5	C5	Gold	normal	1.25
3270	51	C	6	C6	Gold	normal	1.25
3271	51	C	7	C7	Gold	normal	1.25
3272	51	C	8	C8	Gold	normal	1.25
3273	51	C	9	C9	Gold	normal	1.25
3274	51	C	10	C10	Gold	normal	1.25
3275	51	C	11	C11	Gold	normal	1.25
3276	51	C	12	C12	Gold	normal	1.25
3277	51	D	1	D1	Gold	normal	1.25
3278	51	D	2	D2	Gold	normal	1.25
3279	51	D	3	D3	Gold	normal	1.25
3280	51	D	4	D4	Gold	normal	1.25
3281	51	D	5	D5	Gold	normal	1.25
3282	51	D	6	D6	Gold	normal	1.25
3283	51	D	7	D7	Gold	normal	1.25
3284	51	D	8	D8	Gold	normal	1.25
3285	51	D	9	D9	Gold	normal	1.25
3286	51	D	10	D10	Gold	normal	1.25
3287	51	D	11	D11	Gold	normal	1.25
3288	51	D	12	D12	Gold	normal	1.25
3289	51	E	1	E1	Platinum Recliner	normal	1.60
3290	51	E	2	E2	Platinum Recliner	normal	1.60
3291	51	E	3	E3	Platinum Recliner	normal	1.60
3292	51	E	4	E4	Platinum Recliner	normal	1.60
3293	51	E	5	E5	Platinum Recliner	normal	1.60
3294	51	E	6	E6	Platinum Recliner	normal	1.60
3295	51	E	7	E7	Platinum Recliner	normal	1.60
3296	51	E	8	E8	Platinum Recliner	normal	1.60
3297	51	E	9	E9	Platinum Recliner	normal	1.60
3298	51	E	10	E10	Platinum Recliner	normal	1.60
3299	51	E	11	E11	Platinum Recliner	normal	1.60
3300	51	E	12	E12	Platinum Recliner	normal	1.60
3301	51	F	1	F1	Platinum Recliner	normal	1.60
3302	51	F	2	F2	Platinum Recliner	normal	1.60
3303	51	F	3	F3	Platinum Recliner	normal	1.60
3304	51	F	4	F4	Platinum Recliner	normal	1.60
3305	51	F	5	F5	Platinum Recliner	normal	1.60
3306	51	F	6	F6	Platinum Recliner	normal	1.60
3307	51	F	7	F7	Platinum Recliner	normal	1.60
3308	51	F	8	F8	Platinum Recliner	normal	1.60
3309	51	F	9	F9	Platinum Recliner	normal	1.60
3310	51	F	10	F10	Platinum Recliner	normal	1.60
3311	51	F	11	F11	Platinum Recliner	normal	1.60
3312	51	F	12	F12	Platinum Recliner	normal	1.60
3313	52	A	1	A1	Silver	normal	1.00
3314	52	A	2	A2	Silver	normal	1.00
3315	52	A	3	A3	Silver	normal	1.00
3316	52	A	4	A4	Silver	normal	1.00
3317	52	A	5	A5	Silver	normal	1.00
3318	52	A	6	A6	Silver	normal	1.00
3319	52	A	7	A7	Silver	normal	1.00
3320	52	A	8	A8	Silver	normal	1.00
3321	52	A	9	A9	Silver	normal	1.00
3322	52	A	10	A10	Silver	normal	1.00
3323	52	B	1	B1	Silver	normal	1.00
3324	52	B	2	B2	Silver	normal	1.00
3325	52	B	3	B3	Silver	normal	1.00
3326	52	B	4	B4	Silver	normal	1.00
3327	52	B	5	B5	Silver	normal	1.00
3328	52	B	6	B6	Silver	normal	1.00
3329	52	B	7	B7	Silver	normal	1.00
3330	52	B	8	B8	Silver	normal	1.00
3331	52	B	9	B9	Silver	normal	1.00
3332	52	B	10	B10	Silver	normal	1.00
3333	52	C	1	C1	Gold	normal	1.25
3334	52	C	2	C2	Gold	normal	1.25
3335	52	C	3	C3	Gold	normal	1.25
3336	52	C	4	C4	Gold	normal	1.25
3337	52	C	5	C5	Gold	normal	1.25
3338	52	C	6	C6	Gold	normal	1.25
3339	52	C	7	C7	Gold	normal	1.25
3340	52	C	8	C8	Gold	normal	1.25
3341	52	C	9	C9	Gold	normal	1.25
3342	52	C	10	C10	Gold	normal	1.25
3343	52	D	1	D1	Gold	normal	1.25
3344	52	D	2	D2	Gold	normal	1.25
3345	52	D	3	D3	Gold	normal	1.25
3346	52	D	4	D4	Gold	normal	1.25
3347	52	D	5	D5	Gold	normal	1.25
3348	52	D	6	D6	Gold	normal	1.25
3349	52	D	7	D7	Gold	normal	1.25
3350	52	D	8	D8	Gold	normal	1.25
3351	52	D	9	D9	Gold	normal	1.25
3352	52	D	10	D10	Gold	normal	1.25
3353	52	E	1	E1	Platinum Recliner	normal	1.60
3354	52	E	2	E2	Platinum Recliner	normal	1.60
3355	52	E	3	E3	Platinum Recliner	normal	1.60
3356	52	E	4	E4	Platinum Recliner	normal	1.60
3357	52	E	5	E5	Platinum Recliner	normal	1.60
3358	52	E	6	E6	Platinum Recliner	normal	1.60
3359	52	E	7	E7	Platinum Recliner	normal	1.60
3360	52	E	8	E8	Platinum Recliner	normal	1.60
3361	52	E	9	E9	Platinum Recliner	normal	1.60
3362	52	E	10	E10	Platinum Recliner	normal	1.60
3363	52	F	1	F1	Platinum Recliner	normal	1.60
3364	52	F	2	F2	Platinum Recliner	normal	1.60
3365	52	F	3	F3	Platinum Recliner	normal	1.60
3366	52	F	4	F4	Platinum Recliner	normal	1.60
3367	52	F	5	F5	Platinum Recliner	normal	1.60
3368	52	F	6	F6	Platinum Recliner	normal	1.60
3369	52	F	7	F7	Platinum Recliner	normal	1.60
3370	52	F	8	F8	Platinum Recliner	normal	1.60
3371	52	F	9	F9	Platinum Recliner	normal	1.60
3372	52	F	10	F10	Platinum Recliner	normal	1.60
3373	53	A	1	A1	Silver	normal	1.00
3374	53	A	2	A2	Silver	normal	1.00
3375	53	A	3	A3	Silver	normal	1.00
3376	53	A	4	A4	Silver	normal	1.00
3377	53	A	5	A5	Silver	normal	1.00
3378	53	A	6	A6	Silver	normal	1.00
3379	53	A	7	A7	Silver	normal	1.00
3380	53	A	8	A8	Silver	normal	1.00
3381	53	B	1	B1	Silver	normal	1.00
3382	53	B	2	B2	Silver	normal	1.00
3383	53	B	3	B3	Silver	normal	1.00
3384	53	B	4	B4	Silver	normal	1.00
3385	53	B	5	B5	Silver	normal	1.00
3386	53	B	6	B6	Silver	normal	1.00
3387	53	B	7	B7	Silver	normal	1.00
3388	53	B	8	B8	Silver	normal	1.00
3389	53	C	1	C1	Gold	normal	1.25
3390	53	C	2	C2	Gold	normal	1.25
3391	53	C	3	C3	Gold	normal	1.25
3392	53	C	4	C4	Gold	normal	1.25
3393	53	C	5	C5	Gold	normal	1.25
3394	53	C	6	C6	Gold	normal	1.25
3395	53	C	7	C7	Gold	normal	1.25
3396	53	C	8	C8	Gold	normal	1.25
3397	53	D	1	D1	Gold	normal	1.25
3398	53	D	2	D2	Gold	normal	1.25
3399	53	D	3	D3	Gold	normal	1.25
3400	53	D	4	D4	Gold	normal	1.25
3401	53	D	5	D5	Gold	normal	1.25
3402	53	D	6	D6	Gold	normal	1.25
3403	53	D	7	D7	Gold	normal	1.25
3404	53	D	8	D8	Gold	normal	1.25
3405	53	E	1	E1	Platinum Recliner	normal	1.60
3406	53	E	2	E2	Platinum Recliner	normal	1.60
3407	53	E	3	E3	Platinum Recliner	normal	1.60
3408	53	E	4	E4	Platinum Recliner	normal	1.60
3409	53	E	5	E5	Platinum Recliner	normal	1.60
3410	53	E	6	E6	Platinum Recliner	normal	1.60
3411	53	E	7	E7	Platinum Recliner	normal	1.60
3412	53	E	8	E8	Platinum Recliner	normal	1.60
3413	53	F	1	F1	Platinum Recliner	normal	1.60
3414	53	F	2	F2	Platinum Recliner	normal	1.60
3415	53	F	3	F3	Platinum Recliner	normal	1.60
3416	53	F	4	F4	Platinum Recliner	normal	1.60
3417	53	F	5	F5	Platinum Recliner	normal	1.60
3418	53	F	6	F6	Platinum Recliner	normal	1.60
3419	53	F	7	F7	Platinum Recliner	normal	1.60
3420	53	F	8	F8	Platinum Recliner	normal	1.60
3421	54	A	1	A1	Silver	normal	1.00
3422	54	A	2	A2	Silver	normal	1.00
3423	54	A	3	A3	Silver	normal	1.00
3424	54	A	4	A4	Silver	normal	1.00
3425	54	A	5	A5	Silver	normal	1.00
3426	54	A	6	A6	Silver	normal	1.00
3427	54	A	7	A7	Silver	normal	1.00
3428	54	A	8	A8	Silver	normal	1.00
3429	54	A	9	A9	Silver	normal	1.00
3430	54	A	10	A10	Silver	normal	1.00
3431	54	A	11	A11	Silver	normal	1.00
3432	54	A	12	A12	Silver	normal	1.00
3433	54	B	1	B1	Silver	normal	1.00
3434	54	B	2	B2	Silver	normal	1.00
3435	54	B	3	B3	Silver	normal	1.00
3436	54	B	4	B4	Silver	normal	1.00
3437	54	B	5	B5	Silver	normal	1.00
3438	54	B	6	B6	Silver	normal	1.00
3439	54	B	7	B7	Silver	normal	1.00
3440	54	B	8	B8	Silver	normal	1.00
3441	54	B	9	B9	Silver	normal	1.00
3442	54	B	10	B10	Silver	normal	1.00
3443	54	B	11	B11	Silver	normal	1.00
3444	54	B	12	B12	Silver	normal	1.00
3445	54	C	1	C1	Gold	normal	1.25
3446	54	C	2	C2	Gold	normal	1.25
3447	54	C	3	C3	Gold	normal	1.25
3448	54	C	4	C4	Gold	normal	1.25
3449	54	C	5	C5	Gold	normal	1.25
3450	54	C	6	C6	Gold	normal	1.25
3451	54	C	7	C7	Gold	normal	1.25
3452	54	C	8	C8	Gold	normal	1.25
3453	54	C	9	C9	Gold	normal	1.25
3454	54	C	10	C10	Gold	normal	1.25
3455	54	C	11	C11	Gold	normal	1.25
3456	54	C	12	C12	Gold	normal	1.25
3457	54	D	1	D1	Gold	normal	1.25
3458	54	D	2	D2	Gold	normal	1.25
3459	54	D	3	D3	Gold	normal	1.25
3460	54	D	4	D4	Gold	normal	1.25
3461	54	D	5	D5	Gold	normal	1.25
3462	54	D	6	D6	Gold	normal	1.25
3463	54	D	7	D7	Gold	normal	1.25
3464	54	D	8	D8	Gold	normal	1.25
3465	54	D	9	D9	Gold	normal	1.25
3466	54	D	10	D10	Gold	normal	1.25
3467	54	D	11	D11	Gold	normal	1.25
3468	54	D	12	D12	Gold	normal	1.25
3469	54	E	1	E1	Platinum Recliner	normal	1.60
3470	54	E	2	E2	Platinum Recliner	normal	1.60
3471	54	E	3	E3	Platinum Recliner	normal	1.60
3472	54	E	4	E4	Platinum Recliner	normal	1.60
3473	54	E	5	E5	Platinum Recliner	normal	1.60
3474	54	E	6	E6	Platinum Recliner	normal	1.60
3475	54	E	7	E7	Platinum Recliner	normal	1.60
3476	54	E	8	E8	Platinum Recliner	normal	1.60
3477	54	E	9	E9	Platinum Recliner	normal	1.60
3478	54	E	10	E10	Platinum Recliner	normal	1.60
3479	54	E	11	E11	Platinum Recliner	normal	1.60
3480	54	E	12	E12	Platinum Recliner	normal	1.60
3481	54	F	1	F1	Platinum Recliner	normal	1.60
3482	54	F	2	F2	Platinum Recliner	normal	1.60
3483	54	F	3	F3	Platinum Recliner	normal	1.60
3484	54	F	4	F4	Platinum Recliner	normal	1.60
3485	54	F	5	F5	Platinum Recliner	normal	1.60
3486	54	F	6	F6	Platinum Recliner	normal	1.60
3487	54	F	7	F7	Platinum Recliner	normal	1.60
3488	54	F	8	F8	Platinum Recliner	normal	1.60
3489	54	F	9	F9	Platinum Recliner	normal	1.60
3490	54	F	10	F10	Platinum Recliner	normal	1.60
3491	54	F	11	F11	Platinum Recliner	normal	1.60
3492	54	F	12	F12	Platinum Recliner	normal	1.60
3493	55	A	1	A1	Silver	normal	1.00
3494	55	A	2	A2	Silver	normal	1.00
3495	55	A	3	A3	Silver	normal	1.00
3496	55	A	4	A4	Silver	normal	1.00
3497	55	A	5	A5	Silver	normal	1.00
3498	55	A	6	A6	Silver	normal	1.00
3499	55	A	7	A7	Silver	normal	1.00
3500	55	A	8	A8	Silver	normal	1.00
3501	55	A	9	A9	Silver	normal	1.00
3502	55	A	10	A10	Silver	normal	1.00
3503	55	A	11	A11	Silver	normal	1.00
3504	55	A	12	A12	Silver	normal	1.00
3505	55	B	1	B1	Silver	normal	1.00
3506	55	B	2	B2	Silver	normal	1.00
3507	55	B	3	B3	Silver	normal	1.00
3508	55	B	4	B4	Silver	normal	1.00
3509	55	B	5	B5	Silver	normal	1.00
3510	55	B	6	B6	Silver	normal	1.00
3511	55	B	7	B7	Silver	normal	1.00
3512	55	B	8	B8	Silver	normal	1.00
3513	55	B	9	B9	Silver	normal	1.00
3514	55	B	10	B10	Silver	normal	1.00
3515	55	B	11	B11	Silver	normal	1.00
3516	55	B	12	B12	Silver	normal	1.00
3517	55	C	1	C1	Gold	normal	1.25
3518	55	C	2	C2	Gold	normal	1.25
3519	55	C	3	C3	Gold	normal	1.25
3520	55	C	4	C4	Gold	normal	1.25
3521	55	C	5	C5	Gold	normal	1.25
3522	55	C	6	C6	Gold	normal	1.25
3523	55	C	7	C7	Gold	normal	1.25
3524	55	C	8	C8	Gold	normal	1.25
3525	55	C	9	C9	Gold	normal	1.25
3526	55	C	10	C10	Gold	normal	1.25
3527	55	C	11	C11	Gold	normal	1.25
3528	55	C	12	C12	Gold	normal	1.25
3529	55	D	1	D1	Gold	normal	1.25
3530	55	D	2	D2	Gold	normal	1.25
3531	55	D	3	D3	Gold	normal	1.25
3532	55	D	4	D4	Gold	normal	1.25
3533	55	D	5	D5	Gold	normal	1.25
3534	55	D	6	D6	Gold	normal	1.25
3535	55	D	7	D7	Gold	normal	1.25
3536	55	D	8	D8	Gold	normal	1.25
3537	55	D	9	D9	Gold	normal	1.25
3538	55	D	10	D10	Gold	normal	1.25
3539	55	D	11	D11	Gold	normal	1.25
3540	55	D	12	D12	Gold	normal	1.25
3541	55	E	1	E1	Platinum Recliner	normal	1.60
3542	55	E	2	E2	Platinum Recliner	normal	1.60
3543	55	E	3	E3	Platinum Recliner	normal	1.60
3544	55	E	4	E4	Platinum Recliner	normal	1.60
3545	55	E	5	E5	Platinum Recliner	normal	1.60
3546	55	E	6	E6	Platinum Recliner	normal	1.60
3547	55	E	7	E7	Platinum Recliner	normal	1.60
3548	55	E	8	E8	Platinum Recliner	normal	1.60
3549	55	E	9	E9	Platinum Recliner	normal	1.60
3550	55	E	10	E10	Platinum Recliner	normal	1.60
3663	57	D	3	D3	Gold	normal	1.25
3551	55	E	11	E11	Platinum Recliner	normal	1.60
3552	55	E	12	E12	Platinum Recliner	normal	1.60
3553	55	F	1	F1	Platinum Recliner	normal	1.60
3554	55	F	2	F2	Platinum Recliner	normal	1.60
3555	55	F	3	F3	Platinum Recliner	normal	1.60
3556	55	F	4	F4	Platinum Recliner	normal	1.60
3557	55	F	5	F5	Platinum Recliner	normal	1.60
3558	55	F	6	F6	Platinum Recliner	normal	1.60
3559	55	F	7	F7	Platinum Recliner	normal	1.60
3560	55	F	8	F8	Platinum Recliner	normal	1.60
3561	55	F	9	F9	Platinum Recliner	normal	1.60
3562	55	F	10	F10	Platinum Recliner	normal	1.60
3563	55	F	11	F11	Platinum Recliner	normal	1.60
3564	55	F	12	F12	Platinum Recliner	normal	1.60
3565	56	A	1	A1	Silver	normal	1.00
3566	56	A	2	A2	Silver	normal	1.00
3567	56	A	3	A3	Silver	normal	1.00
3568	56	A	4	A4	Silver	normal	1.00
3569	56	A	5	A5	Silver	normal	1.00
3570	56	A	6	A6	Silver	normal	1.00
3571	56	A	7	A7	Silver	normal	1.00
3572	56	A	8	A8	Silver	normal	1.00
3573	56	A	9	A9	Silver	normal	1.00
3574	56	A	10	A10	Silver	normal	1.00
3575	56	B	1	B1	Silver	normal	1.00
3576	56	B	2	B2	Silver	normal	1.00
3577	56	B	3	B3	Silver	normal	1.00
3578	56	B	4	B4	Silver	normal	1.00
3579	56	B	5	B5	Silver	normal	1.00
3580	56	B	6	B6	Silver	normal	1.00
3581	56	B	7	B7	Silver	normal	1.00
3582	56	B	8	B8	Silver	normal	1.00
3583	56	B	9	B9	Silver	normal	1.00
3584	56	B	10	B10	Silver	normal	1.00
3585	56	C	1	C1	Gold	normal	1.25
3586	56	C	2	C2	Gold	normal	1.25
3587	56	C	3	C3	Gold	normal	1.25
3588	56	C	4	C4	Gold	normal	1.25
3589	56	C	5	C5	Gold	normal	1.25
3590	56	C	6	C6	Gold	normal	1.25
3591	56	C	7	C7	Gold	normal	1.25
3592	56	C	8	C8	Gold	normal	1.25
3593	56	C	9	C9	Gold	normal	1.25
3594	56	C	10	C10	Gold	normal	1.25
3595	56	D	1	D1	Gold	normal	1.25
3596	56	D	2	D2	Gold	normal	1.25
3597	56	D	3	D3	Gold	normal	1.25
3598	56	D	4	D4	Gold	normal	1.25
3599	56	D	5	D5	Gold	normal	1.25
3600	56	D	6	D6	Gold	normal	1.25
3601	56	D	7	D7	Gold	normal	1.25
3602	56	D	8	D8	Gold	normal	1.25
3603	56	D	9	D9	Gold	normal	1.25
3604	56	D	10	D10	Gold	normal	1.25
3605	56	E	1	E1	Platinum Recliner	normal	1.60
3606	56	E	2	E2	Platinum Recliner	normal	1.60
3607	56	E	3	E3	Platinum Recliner	normal	1.60
3608	56	E	4	E4	Platinum Recliner	normal	1.60
3609	56	E	5	E5	Platinum Recliner	normal	1.60
3610	56	E	6	E6	Platinum Recliner	normal	1.60
3611	56	E	7	E7	Platinum Recliner	normal	1.60
3612	56	E	8	E8	Platinum Recliner	normal	1.60
3613	56	E	9	E9	Platinum Recliner	normal	1.60
3614	56	E	10	E10	Platinum Recliner	normal	1.60
3615	56	F	1	F1	Platinum Recliner	normal	1.60
3616	56	F	2	F2	Platinum Recliner	normal	1.60
3617	56	F	3	F3	Platinum Recliner	normal	1.60
3618	56	F	4	F4	Platinum Recliner	normal	1.60
3619	56	F	5	F5	Platinum Recliner	normal	1.60
3620	56	F	6	F6	Platinum Recliner	normal	1.60
3621	56	F	7	F7	Platinum Recliner	normal	1.60
3622	56	F	8	F8	Platinum Recliner	normal	1.60
3623	56	F	9	F9	Platinum Recliner	normal	1.60
3624	56	F	10	F10	Platinum Recliner	normal	1.60
3625	57	A	1	A1	Silver	normal	1.00
3626	57	A	2	A2	Silver	normal	1.00
3627	57	A	3	A3	Silver	normal	1.00
3628	57	A	4	A4	Silver	normal	1.00
3629	57	A	5	A5	Silver	normal	1.00
3630	57	A	6	A6	Silver	normal	1.00
3631	57	A	7	A7	Silver	normal	1.00
3632	57	A	8	A8	Silver	normal	1.00
3633	57	A	9	A9	Silver	normal	1.00
3634	57	A	10	A10	Silver	normal	1.00
3635	57	A	11	A11	Silver	normal	1.00
3636	57	A	12	A12	Silver	normal	1.00
3637	57	B	1	B1	Silver	normal	1.00
3638	57	B	2	B2	Silver	normal	1.00
3639	57	B	3	B3	Silver	normal	1.00
3640	57	B	4	B4	Silver	normal	1.00
3641	57	B	5	B5	Silver	normal	1.00
3642	57	B	6	B6	Silver	normal	1.00
3643	57	B	7	B7	Silver	normal	1.00
3644	57	B	8	B8	Silver	normal	1.00
3645	57	B	9	B9	Silver	normal	1.00
3646	57	B	10	B10	Silver	normal	1.00
3647	57	B	11	B11	Silver	normal	1.00
3648	57	B	12	B12	Silver	normal	1.00
3649	57	C	1	C1	Gold	normal	1.25
3650	57	C	2	C2	Gold	normal	1.25
3651	57	C	3	C3	Gold	normal	1.25
3652	57	C	4	C4	Gold	normal	1.25
3653	57	C	5	C5	Gold	normal	1.25
3654	57	C	6	C6	Gold	normal	1.25
3655	57	C	7	C7	Gold	normal	1.25
3656	57	C	8	C8	Gold	normal	1.25
3657	57	C	9	C9	Gold	normal	1.25
3658	57	C	10	C10	Gold	normal	1.25
3659	57	C	11	C11	Gold	normal	1.25
3660	57	C	12	C12	Gold	normal	1.25
3661	57	D	1	D1	Gold	normal	1.25
3662	57	D	2	D2	Gold	normal	1.25
3664	57	D	4	D4	Gold	normal	1.25
3665	57	D	5	D5	Gold	normal	1.25
3666	57	D	6	D6	Gold	normal	1.25
3667	57	D	7	D7	Gold	normal	1.25
3668	57	D	8	D8	Gold	normal	1.25
3669	57	D	9	D9	Gold	normal	1.25
3670	57	D	10	D10	Gold	normal	1.25
3671	57	D	11	D11	Gold	normal	1.25
3672	57	D	12	D12	Gold	normal	1.25
3673	57	E	1	E1	Platinum Recliner	normal	1.60
3674	57	E	2	E2	Platinum Recliner	normal	1.60
3675	57	E	3	E3	Platinum Recliner	normal	1.60
3676	57	E	4	E4	Platinum Recliner	normal	1.60
3677	57	E	5	E5	Platinum Recliner	normal	1.60
3678	57	E	6	E6	Platinum Recliner	normal	1.60
3679	57	E	7	E7	Platinum Recliner	normal	1.60
3680	57	E	8	E8	Platinum Recliner	normal	1.60
3681	57	E	9	E9	Platinum Recliner	normal	1.60
3682	57	E	10	E10	Platinum Recliner	normal	1.60
3683	57	E	11	E11	Platinum Recliner	normal	1.60
3684	57	E	12	E12	Platinum Recliner	normal	1.60
3685	57	F	1	F1	Platinum Recliner	normal	1.60
3686	57	F	2	F2	Platinum Recliner	normal	1.60
3687	57	F	3	F3	Platinum Recliner	normal	1.60
3688	57	F	4	F4	Platinum Recliner	normal	1.60
3689	57	F	5	F5	Platinum Recliner	normal	1.60
3690	57	F	6	F6	Platinum Recliner	normal	1.60
3691	57	F	7	F7	Platinum Recliner	normal	1.60
3692	57	F	8	F8	Platinum Recliner	normal	1.60
3693	57	F	9	F9	Platinum Recliner	normal	1.60
3694	57	F	10	F10	Platinum Recliner	normal	1.60
3695	57	F	11	F11	Platinum Recliner	normal	1.60
3696	57	F	12	F12	Platinum Recliner	normal	1.60
3697	58	A	1	A1	Silver	normal	1.00
3698	58	A	2	A2	Silver	normal	1.00
3699	58	A	3	A3	Silver	normal	1.00
3700	58	A	4	A4	Silver	normal	1.00
3701	58	A	5	A5	Silver	normal	1.00
3702	58	A	6	A6	Silver	normal	1.00
3703	58	A	7	A7	Silver	normal	1.00
3704	58	A	8	A8	Silver	normal	1.00
3705	58	A	9	A9	Silver	normal	1.00
3706	58	A	10	A10	Silver	normal	1.00
3707	58	B	1	B1	Silver	normal	1.00
3708	58	B	2	B2	Silver	normal	1.00
3709	58	B	3	B3	Silver	normal	1.00
3710	58	B	4	B4	Silver	normal	1.00
3711	58	B	5	B5	Silver	normal	1.00
3712	58	B	6	B6	Silver	normal	1.00
3713	58	B	7	B7	Silver	normal	1.00
3714	58	B	8	B8	Silver	normal	1.00
3715	58	B	9	B9	Silver	normal	1.00
3716	58	B	10	B10	Silver	normal	1.00
3717	58	C	1	C1	Gold	normal	1.25
3718	58	C	2	C2	Gold	normal	1.25
3719	58	C	3	C3	Gold	normal	1.25
3720	58	C	4	C4	Gold	normal	1.25
3721	58	C	5	C5	Gold	normal	1.25
3722	58	C	6	C6	Gold	normal	1.25
3723	58	C	7	C7	Gold	normal	1.25
3724	58	C	8	C8	Gold	normal	1.25
3725	58	C	9	C9	Gold	normal	1.25
3726	58	C	10	C10	Gold	normal	1.25
3727	58	D	1	D1	Gold	normal	1.25
3728	58	D	2	D2	Gold	normal	1.25
3729	58	D	3	D3	Gold	normal	1.25
3730	58	D	4	D4	Gold	normal	1.25
3731	58	D	5	D5	Gold	normal	1.25
3732	58	D	6	D6	Gold	normal	1.25
3733	58	D	7	D7	Gold	normal	1.25
3734	58	D	8	D8	Gold	normal	1.25
3735	58	D	9	D9	Gold	normal	1.25
3736	58	D	10	D10	Gold	normal	1.25
3737	58	E	1	E1	Platinum Recliner	normal	1.60
3738	58	E	2	E2	Platinum Recliner	normal	1.60
3739	58	E	3	E3	Platinum Recliner	normal	1.60
3740	58	E	4	E4	Platinum Recliner	normal	1.60
3741	58	E	5	E5	Platinum Recliner	normal	1.60
3742	58	E	6	E6	Platinum Recliner	normal	1.60
3743	58	E	7	E7	Platinum Recliner	normal	1.60
3744	58	E	8	E8	Platinum Recliner	normal	1.60
3745	58	E	9	E9	Platinum Recliner	normal	1.60
3746	58	E	10	E10	Platinum Recliner	normal	1.60
3747	58	F	1	F1	Platinum Recliner	normal	1.60
3748	58	F	2	F2	Platinum Recliner	normal	1.60
3749	58	F	3	F3	Platinum Recliner	normal	1.60
3750	58	F	4	F4	Platinum Recliner	normal	1.60
3751	58	F	5	F5	Platinum Recliner	normal	1.60
3752	58	F	6	F6	Platinum Recliner	normal	1.60
3753	58	F	7	F7	Platinum Recliner	normal	1.60
3754	58	F	8	F8	Platinum Recliner	normal	1.60
3755	58	F	9	F9	Platinum Recliner	normal	1.60
3756	58	F	10	F10	Platinum Recliner	normal	1.60
3757	59	A	1	A1	Silver	normal	1.00
3758	59	A	2	A2	Silver	normal	1.00
3759	59	A	3	A3	Silver	normal	1.00
3760	59	A	4	A4	Silver	normal	1.00
3761	59	A	5	A5	Silver	normal	1.00
3762	59	A	6	A6	Silver	normal	1.00
3763	59	A	7	A7	Silver	normal	1.00
3764	59	A	8	A8	Silver	normal	1.00
3765	59	A	9	A9	Silver	normal	1.00
3766	59	A	10	A10	Silver	normal	1.00
3767	59	A	11	A11	Silver	normal	1.00
3768	59	A	12	A12	Silver	normal	1.00
3769	59	B	1	B1	Silver	normal	1.00
3770	59	B	2	B2	Silver	normal	1.00
3771	59	B	3	B3	Silver	normal	1.00
3772	59	B	4	B4	Silver	normal	1.00
3773	59	B	5	B5	Silver	normal	1.00
3774	59	B	6	B6	Silver	normal	1.00
3775	59	B	7	B7	Silver	normal	1.00
3776	59	B	8	B8	Silver	normal	1.00
3777	59	B	9	B9	Silver	normal	1.00
3778	59	B	10	B10	Silver	normal	1.00
3779	59	B	11	B11	Silver	normal	1.00
3780	59	B	12	B12	Silver	normal	1.00
3781	59	C	1	C1	Gold	normal	1.25
3782	59	C	2	C2	Gold	normal	1.25
3783	59	C	3	C3	Gold	normal	1.25
3784	59	C	4	C4	Gold	normal	1.25
3785	59	C	5	C5	Gold	normal	1.25
3786	59	C	6	C6	Gold	normal	1.25
3787	59	C	7	C7	Gold	normal	1.25
3788	59	C	8	C8	Gold	normal	1.25
3789	59	C	9	C9	Gold	normal	1.25
3790	59	C	10	C10	Gold	normal	1.25
3791	59	C	11	C11	Gold	normal	1.25
3792	59	C	12	C12	Gold	normal	1.25
3793	59	D	1	D1	Gold	normal	1.25
3794	59	D	2	D2	Gold	normal	1.25
3795	59	D	3	D3	Gold	normal	1.25
3796	59	D	4	D4	Gold	normal	1.25
3797	59	D	5	D5	Gold	normal	1.25
3798	59	D	6	D6	Gold	normal	1.25
3799	59	D	7	D7	Gold	normal	1.25
3800	59	D	8	D8	Gold	normal	1.25
3801	59	D	9	D9	Gold	normal	1.25
3802	59	D	10	D10	Gold	normal	1.25
3803	59	D	11	D11	Gold	normal	1.25
3804	59	D	12	D12	Gold	normal	1.25
3805	59	E	1	E1	Platinum Recliner	normal	1.60
3806	59	E	2	E2	Platinum Recliner	normal	1.60
3807	59	E	3	E3	Platinum Recliner	normal	1.60
3808	59	E	4	E4	Platinum Recliner	normal	1.60
3809	59	E	5	E5	Platinum Recliner	normal	1.60
3810	59	E	6	E6	Platinum Recliner	normal	1.60
3811	59	E	7	E7	Platinum Recliner	normal	1.60
3812	59	E	8	E8	Platinum Recliner	normal	1.60
3813	59	E	9	E9	Platinum Recliner	normal	1.60
3814	59	E	10	E10	Platinum Recliner	normal	1.60
3815	59	E	11	E11	Platinum Recliner	normal	1.60
3816	59	E	12	E12	Platinum Recliner	normal	1.60
3817	59	F	1	F1	Platinum Recliner	normal	1.60
3818	59	F	2	F2	Platinum Recliner	normal	1.60
3819	59	F	3	F3	Platinum Recliner	normal	1.60
3820	59	F	4	F4	Platinum Recliner	normal	1.60
3821	59	F	5	F5	Platinum Recliner	normal	1.60
3822	59	F	6	F6	Platinum Recliner	normal	1.60
3823	59	F	7	F7	Platinum Recliner	normal	1.60
3824	59	F	8	F8	Platinum Recliner	normal	1.60
3825	59	F	9	F9	Platinum Recliner	normal	1.60
3826	59	F	10	F10	Platinum Recliner	normal	1.60
3827	59	F	11	F11	Platinum Recliner	normal	1.60
3828	59	F	12	F12	Platinum Recliner	normal	1.60
3829	60	A	1	A1	Silver	normal	1.00
3830	60	A	2	A2	Silver	normal	1.00
3831	60	A	3	A3	Silver	normal	1.00
3832	60	A	4	A4	Silver	normal	1.00
3833	60	A	5	A5	Silver	normal	1.00
3834	60	A	6	A6	Silver	normal	1.00
3835	60	A	7	A7	Silver	normal	1.00
3836	60	A	8	A8	Silver	normal	1.00
3837	60	A	9	A9	Silver	normal	1.00
3838	60	A	10	A10	Silver	normal	1.00
3839	60	A	11	A11	Silver	normal	1.00
3840	60	A	12	A12	Silver	normal	1.00
3841	60	B	1	B1	Silver	normal	1.00
3842	60	B	2	B2	Silver	normal	1.00
3843	60	B	3	B3	Silver	normal	1.00
3844	60	B	4	B4	Silver	normal	1.00
3845	60	B	5	B5	Silver	normal	1.00
3846	60	B	6	B6	Silver	normal	1.00
3847	60	B	7	B7	Silver	normal	1.00
3848	60	B	8	B8	Silver	normal	1.00
3849	60	B	9	B9	Silver	normal	1.00
3850	60	B	10	B10	Silver	normal	1.00
3851	60	B	11	B11	Silver	normal	1.00
3852	60	B	12	B12	Silver	normal	1.00
3853	60	C	1	C1	Gold	normal	1.25
3854	60	C	2	C2	Gold	normal	1.25
3855	60	C	3	C3	Gold	normal	1.25
3856	60	C	4	C4	Gold	normal	1.25
3857	60	C	5	C5	Gold	normal	1.25
3858	60	C	6	C6	Gold	normal	1.25
3859	60	C	7	C7	Gold	normal	1.25
3860	60	C	8	C8	Gold	normal	1.25
3861	60	C	9	C9	Gold	normal	1.25
3862	60	C	10	C10	Gold	normal	1.25
3863	60	C	11	C11	Gold	normal	1.25
3864	60	C	12	C12	Gold	normal	1.25
3865	60	D	1	D1	Gold	normal	1.25
3866	60	D	2	D2	Gold	normal	1.25
3867	60	D	3	D3	Gold	normal	1.25
3868	60	D	4	D4	Gold	normal	1.25
3869	60	D	5	D5	Gold	normal	1.25
3870	60	D	6	D6	Gold	normal	1.25
3871	60	D	7	D7	Gold	normal	1.25
3872	60	D	8	D8	Gold	normal	1.25
3873	60	D	9	D9	Gold	normal	1.25
3874	60	D	10	D10	Gold	normal	1.25
3875	60	D	11	D11	Gold	normal	1.25
3876	60	D	12	D12	Gold	normal	1.25
3877	60	E	1	E1	Platinum Recliner	normal	1.60
3878	60	E	2	E2	Platinum Recliner	normal	1.60
3879	60	E	3	E3	Platinum Recliner	normal	1.60
3880	60	E	4	E4	Platinum Recliner	normal	1.60
3881	60	E	5	E5	Platinum Recliner	normal	1.60
3882	60	E	6	E6	Platinum Recliner	normal	1.60
3883	60	E	7	E7	Platinum Recliner	normal	1.60
3884	60	E	8	E8	Platinum Recliner	normal	1.60
3885	60	E	9	E9	Platinum Recliner	normal	1.60
3886	60	E	10	E10	Platinum Recliner	normal	1.60
3887	60	E	11	E11	Platinum Recliner	normal	1.60
3888	60	E	12	E12	Platinum Recliner	normal	1.60
3889	60	F	1	F1	Platinum Recliner	normal	1.60
3890	60	F	2	F2	Platinum Recliner	normal	1.60
3891	60	F	3	F3	Platinum Recliner	normal	1.60
3892	60	F	4	F4	Platinum Recliner	normal	1.60
3893	60	F	5	F5	Platinum Recliner	normal	1.60
3894	60	F	6	F6	Platinum Recliner	normal	1.60
3895	60	F	7	F7	Platinum Recliner	normal	1.60
3896	60	F	8	F8	Platinum Recliner	normal	1.60
3897	60	F	9	F9	Platinum Recliner	normal	1.60
3898	60	F	10	F10	Platinum Recliner	normal	1.60
3899	60	F	11	F11	Platinum Recliner	normal	1.60
3900	60	F	12	F12	Platinum Recliner	normal	1.60
3901	61	A	1	A1	Silver	normal	1.00
3902	61	A	2	A2	Silver	normal	1.00
3903	61	A	3	A3	Silver	normal	1.00
3904	61	A	4	A4	Silver	normal	1.00
3905	61	A	5	A5	Silver	normal	1.00
3906	61	A	6	A6	Silver	normal	1.00
3907	61	A	7	A7	Silver	normal	1.00
3908	61	A	8	A8	Silver	normal	1.00
3909	61	B	1	B1	Silver	normal	1.00
3910	61	B	2	B2	Silver	normal	1.00
3911	61	B	3	B3	Silver	normal	1.00
3912	61	B	4	B4	Silver	normal	1.00
3913	61	B	5	B5	Silver	normal	1.00
3914	61	B	6	B6	Silver	normal	1.00
3915	61	B	7	B7	Silver	normal	1.00
3916	61	B	8	B8	Silver	normal	1.00
3917	61	C	1	C1	Gold	normal	1.25
3918	61	C	2	C2	Gold	normal	1.25
3919	61	C	3	C3	Gold	normal	1.25
3920	61	C	4	C4	Gold	normal	1.25
3921	61	C	5	C5	Gold	normal	1.25
3922	61	C	6	C6	Gold	normal	1.25
3923	61	C	7	C7	Gold	normal	1.25
3924	61	C	8	C8	Gold	normal	1.25
3925	61	D	1	D1	Gold	normal	1.25
3926	61	D	2	D2	Gold	normal	1.25
3927	61	D	3	D3	Gold	normal	1.25
3928	61	D	4	D4	Gold	normal	1.25
3929	61	D	5	D5	Gold	normal	1.25
3930	61	D	6	D6	Gold	normal	1.25
3931	61	D	7	D7	Gold	normal	1.25
3932	61	D	8	D8	Gold	normal	1.25
3933	61	E	1	E1	Platinum Recliner	normal	1.60
3934	61	E	2	E2	Platinum Recliner	normal	1.60
3935	61	E	3	E3	Platinum Recliner	normal	1.60
3936	61	E	4	E4	Platinum Recliner	normal	1.60
3937	61	E	5	E5	Platinum Recliner	normal	1.60
3938	61	E	6	E6	Platinum Recliner	normal	1.60
3939	61	E	7	E7	Platinum Recliner	normal	1.60
3940	61	E	8	E8	Platinum Recliner	normal	1.60
3941	61	F	1	F1	Platinum Recliner	normal	1.60
3942	61	F	2	F2	Platinum Recliner	normal	1.60
3943	61	F	3	F3	Platinum Recliner	normal	1.60
3944	61	F	4	F4	Platinum Recliner	normal	1.60
3945	61	F	5	F5	Platinum Recliner	normal	1.60
3946	61	F	6	F6	Platinum Recliner	normal	1.60
3947	61	F	7	F7	Platinum Recliner	normal	1.60
3948	61	F	8	F8	Platinum Recliner	normal	1.60
3949	62	A	1	A1	Silver	normal	1.00
3950	62	A	2	A2	Silver	normal	1.00
3951	62	A	3	A3	Silver	normal	1.00
3952	62	A	4	A4	Silver	normal	1.00
3953	62	A	5	A5	Silver	normal	1.00
3954	62	A	6	A6	Silver	normal	1.00
3955	62	A	7	A7	Silver	normal	1.00
3956	62	A	8	A8	Silver	normal	1.00
3957	62	A	9	A9	Silver	normal	1.00
3958	62	A	10	A10	Silver	normal	1.00
3959	62	A	11	A11	Silver	normal	1.00
3960	62	A	12	A12	Silver	normal	1.00
3961	62	B	1	B1	Silver	normal	1.00
3962	62	B	2	B2	Silver	normal	1.00
3963	62	B	3	B3	Silver	normal	1.00
3964	62	B	4	B4	Silver	normal	1.00
3965	62	B	5	B5	Silver	normal	1.00
3966	62	B	6	B6	Silver	normal	1.00
3967	62	B	7	B7	Silver	normal	1.00
3968	62	B	8	B8	Silver	normal	1.00
3969	62	B	9	B9	Silver	normal	1.00
3970	62	B	10	B10	Silver	normal	1.00
3971	62	B	11	B11	Silver	normal	1.00
3972	62	B	12	B12	Silver	normal	1.00
3973	62	C	1	C1	Gold	normal	1.25
3974	62	C	2	C2	Gold	normal	1.25
3975	62	C	3	C3	Gold	normal	1.25
3976	62	C	4	C4	Gold	normal	1.25
3977	62	C	5	C5	Gold	normal	1.25
3978	62	C	6	C6	Gold	normal	1.25
3979	62	C	7	C7	Gold	normal	1.25
3980	62	C	8	C8	Gold	normal	1.25
3981	62	C	9	C9	Gold	normal	1.25
3982	62	C	10	C10	Gold	normal	1.25
3983	62	C	11	C11	Gold	normal	1.25
3984	62	C	12	C12	Gold	normal	1.25
3985	62	D	1	D1	Gold	normal	1.25
3986	62	D	2	D2	Gold	normal	1.25
3987	62	D	3	D3	Gold	normal	1.25
3988	62	D	4	D4	Gold	normal	1.25
3989	62	D	5	D5	Gold	normal	1.25
3990	62	D	6	D6	Gold	normal	1.25
3991	62	D	7	D7	Gold	normal	1.25
3992	62	D	8	D8	Gold	normal	1.25
3993	62	D	9	D9	Gold	normal	1.25
3994	62	D	10	D10	Gold	normal	1.25
3995	62	D	11	D11	Gold	normal	1.25
3996	62	D	12	D12	Gold	normal	1.25
3997	62	E	1	E1	Platinum Recliner	normal	1.60
3998	62	E	2	E2	Platinum Recliner	normal	1.60
3999	62	E	3	E3	Platinum Recliner	normal	1.60
4000	62	E	4	E4	Platinum Recliner	normal	1.60
4001	62	E	5	E5	Platinum Recliner	normal	1.60
4002	62	E	6	E6	Platinum Recliner	normal	1.60
4003	62	E	7	E7	Platinum Recliner	normal	1.60
4004	62	E	8	E8	Platinum Recliner	normal	1.60
4005	62	E	9	E9	Platinum Recliner	normal	1.60
4006	62	E	10	E10	Platinum Recliner	normal	1.60
4007	62	E	11	E11	Platinum Recliner	normal	1.60
4008	62	E	12	E12	Platinum Recliner	normal	1.60
4009	62	F	1	F1	Platinum Recliner	normal	1.60
4010	62	F	2	F2	Platinum Recliner	normal	1.60
4011	62	F	3	F3	Platinum Recliner	normal	1.60
4012	62	F	4	F4	Platinum Recliner	normal	1.60
4013	62	F	5	F5	Platinum Recliner	normal	1.60
4014	62	F	6	F6	Platinum Recliner	normal	1.60
4015	62	F	7	F7	Platinum Recliner	normal	1.60
4016	62	F	8	F8	Platinum Recliner	normal	1.60
4017	62	F	9	F9	Platinum Recliner	normal	1.60
4018	62	F	10	F10	Platinum Recliner	normal	1.60
4019	62	F	11	F11	Platinum Recliner	normal	1.60
4020	62	F	12	F12	Platinum Recliner	normal	1.60
4021	63	A	1	A1	Silver	normal	1.00
4022	63	A	2	A2	Silver	normal	1.00
4023	63	A	3	A3	Silver	normal	1.00
4024	63	A	4	A4	Silver	normal	1.00
4025	63	A	5	A5	Silver	normal	1.00
4026	63	A	6	A6	Silver	normal	1.00
4027	63	A	7	A7	Silver	normal	1.00
4028	63	A	8	A8	Silver	normal	1.00
4029	63	A	9	A9	Silver	normal	1.00
4030	63	A	10	A10	Silver	normal	1.00
4031	63	A	11	A11	Silver	normal	1.00
4032	63	A	12	A12	Silver	normal	1.00
4033	63	B	1	B1	Silver	normal	1.00
4034	63	B	2	B2	Silver	normal	1.00
4035	63	B	3	B3	Silver	normal	1.00
4036	63	B	4	B4	Silver	normal	1.00
4037	63	B	5	B5	Silver	normal	1.00
4038	63	B	6	B6	Silver	normal	1.00
4039	63	B	7	B7	Silver	normal	1.00
4040	63	B	8	B8	Silver	normal	1.00
4041	63	B	9	B9	Silver	normal	1.00
4042	63	B	10	B10	Silver	normal	1.00
4043	63	B	11	B11	Silver	normal	1.00
4044	63	B	12	B12	Silver	normal	1.00
4045	63	C	1	C1	Gold	normal	1.25
4046	63	C	2	C2	Gold	normal	1.25
4047	63	C	3	C3	Gold	normal	1.25
4048	63	C	4	C4	Gold	normal	1.25
4049	63	C	5	C5	Gold	normal	1.25
4050	63	C	6	C6	Gold	normal	1.25
4051	63	C	7	C7	Gold	normal	1.25
4052	63	C	8	C8	Gold	normal	1.25
4053	63	C	9	C9	Gold	normal	1.25
4054	63	C	10	C10	Gold	normal	1.25
4055	63	C	11	C11	Gold	normal	1.25
4056	63	C	12	C12	Gold	normal	1.25
4057	63	D	1	D1	Gold	normal	1.25
4058	63	D	2	D2	Gold	normal	1.25
4059	63	D	3	D3	Gold	normal	1.25
4060	63	D	4	D4	Gold	normal	1.25
4061	63	D	5	D5	Gold	normal	1.25
4062	63	D	6	D6	Gold	normal	1.25
4063	63	D	7	D7	Gold	normal	1.25
4064	63	D	8	D8	Gold	normal	1.25
4065	63	D	9	D9	Gold	normal	1.25
4066	63	D	10	D10	Gold	normal	1.25
4067	63	D	11	D11	Gold	normal	1.25
4068	63	D	12	D12	Gold	normal	1.25
4069	63	E	1	E1	Platinum Recliner	normal	1.60
4070	63	E	2	E2	Platinum Recliner	normal	1.60
4071	63	E	3	E3	Platinum Recliner	normal	1.60
4072	63	E	4	E4	Platinum Recliner	normal	1.60
4073	63	E	5	E5	Platinum Recliner	normal	1.60
4074	63	E	6	E6	Platinum Recliner	normal	1.60
4075	63	E	7	E7	Platinum Recliner	normal	1.60
4076	63	E	8	E8	Platinum Recliner	normal	1.60
4077	63	E	9	E9	Platinum Recliner	normal	1.60
4078	63	E	10	E10	Platinum Recliner	normal	1.60
4079	63	E	11	E11	Platinum Recliner	normal	1.60
4080	63	E	12	E12	Platinum Recliner	normal	1.60
4081	63	F	1	F1	Platinum Recliner	normal	1.60
4082	63	F	2	F2	Platinum Recliner	normal	1.60
4083	63	F	3	F3	Platinum Recliner	normal	1.60
4084	63	F	4	F4	Platinum Recliner	normal	1.60
4085	63	F	5	F5	Platinum Recliner	normal	1.60
4086	63	F	6	F6	Platinum Recliner	normal	1.60
4087	63	F	7	F7	Platinum Recliner	normal	1.60
4088	63	F	8	F8	Platinum Recliner	normal	1.60
4089	63	F	9	F9	Platinum Recliner	normal	1.60
4090	63	F	10	F10	Platinum Recliner	normal	1.60
4091	63	F	11	F11	Platinum Recliner	normal	1.60
4092	63	F	12	F12	Platinum Recliner	normal	1.60
4093	64	A	1	A1	Silver	normal	1.00
4094	64	A	2	A2	Silver	normal	1.00
4095	64	A	3	A3	Silver	normal	1.00
4096	64	A	4	A4	Silver	normal	1.00
4097	64	A	5	A5	Silver	normal	1.00
4098	64	A	6	A6	Silver	normal	1.00
4099	64	A	7	A7	Silver	normal	1.00
4100	64	A	8	A8	Silver	normal	1.00
4101	64	A	9	A9	Silver	normal	1.00
4102	64	A	10	A10	Silver	normal	1.00
4103	64	A	11	A11	Silver	normal	1.00
4104	64	A	12	A12	Silver	normal	1.00
4105	64	B	1	B1	Silver	normal	1.00
4106	64	B	2	B2	Silver	normal	1.00
4107	64	B	3	B3	Silver	normal	1.00
4108	64	B	4	B4	Silver	normal	1.00
4109	64	B	5	B5	Silver	normal	1.00
4110	64	B	6	B6	Silver	normal	1.00
4111	64	B	7	B7	Silver	normal	1.00
4112	64	B	8	B8	Silver	normal	1.00
4113	64	B	9	B9	Silver	normal	1.00
4114	64	B	10	B10	Silver	normal	1.00
4115	64	B	11	B11	Silver	normal	1.00
4116	64	B	12	B12	Silver	normal	1.00
4117	64	C	1	C1	Gold	normal	1.25
4118	64	C	2	C2	Gold	normal	1.25
4119	64	C	3	C3	Gold	normal	1.25
4120	64	C	4	C4	Gold	normal	1.25
4121	64	C	5	C5	Gold	normal	1.25
4122	64	C	6	C6	Gold	normal	1.25
4123	64	C	7	C7	Gold	normal	1.25
4124	64	C	8	C8	Gold	normal	1.25
4125	64	C	9	C9	Gold	normal	1.25
4126	64	C	10	C10	Gold	normal	1.25
4127	64	C	11	C11	Gold	normal	1.25
4128	64	C	12	C12	Gold	normal	1.25
4129	64	D	1	D1	Gold	normal	1.25
4130	64	D	2	D2	Gold	normal	1.25
4131	64	D	3	D3	Gold	normal	1.25
4132	64	D	4	D4	Gold	normal	1.25
4133	64	D	5	D5	Gold	normal	1.25
4134	64	D	6	D6	Gold	normal	1.25
4135	64	D	7	D7	Gold	normal	1.25
4136	64	D	8	D8	Gold	normal	1.25
4137	64	D	9	D9	Gold	normal	1.25
4138	64	D	10	D10	Gold	normal	1.25
4139	64	D	11	D11	Gold	normal	1.25
4140	64	D	12	D12	Gold	normal	1.25
4141	64	E	1	E1	Platinum Recliner	normal	1.60
4142	64	E	2	E2	Platinum Recliner	normal	1.60
4143	64	E	3	E3	Platinum Recliner	normal	1.60
4144	64	E	4	E4	Platinum Recliner	normal	1.60
4145	64	E	5	E5	Platinum Recliner	normal	1.60
4146	64	E	6	E6	Platinum Recliner	normal	1.60
4147	64	E	7	E7	Platinum Recliner	normal	1.60
4148	64	E	8	E8	Platinum Recliner	normal	1.60
4149	64	E	9	E9	Platinum Recliner	normal	1.60
4150	64	E	10	E10	Platinum Recliner	normal	1.60
4151	64	E	11	E11	Platinum Recliner	normal	1.60
4152	64	E	12	E12	Platinum Recliner	normal	1.60
4153	64	F	1	F1	Platinum Recliner	normal	1.60
4154	64	F	2	F2	Platinum Recliner	normal	1.60
4155	64	F	3	F3	Platinum Recliner	normal	1.60
4156	64	F	4	F4	Platinum Recliner	normal	1.60
4157	64	F	5	F5	Platinum Recliner	normal	1.60
4158	64	F	6	F6	Platinum Recliner	normal	1.60
4159	64	F	7	F7	Platinum Recliner	normal	1.60
4160	64	F	8	F8	Platinum Recliner	normal	1.60
4161	64	F	9	F9	Platinum Recliner	normal	1.60
4162	64	F	10	F10	Platinum Recliner	normal	1.60
4163	64	F	11	F11	Platinum Recliner	normal	1.60
4164	64	F	12	F12	Platinum Recliner	normal	1.60
4165	65	A	1	A1	Silver	normal	1.00
4166	65	A	2	A2	Silver	normal	1.00
4167	65	A	3	A3	Silver	normal	1.00
4168	65	A	4	A4	Silver	normal	1.00
4169	65	A	5	A5	Silver	normal	1.00
4170	65	A	6	A6	Silver	normal	1.00
4171	65	A	7	A7	Silver	normal	1.00
4172	65	A	8	A8	Silver	normal	1.00
4173	65	A	9	A9	Silver	normal	1.00
4174	65	A	10	A10	Silver	normal	1.00
4175	65	B	1	B1	Silver	normal	1.00
4176	65	B	2	B2	Silver	normal	1.00
4177	65	B	3	B3	Silver	normal	1.00
4178	65	B	4	B4	Silver	normal	1.00
4179	65	B	5	B5	Silver	normal	1.00
4180	65	B	6	B6	Silver	normal	1.00
4181	65	B	7	B7	Silver	normal	1.00
4182	65	B	8	B8	Silver	normal	1.00
4183	65	B	9	B9	Silver	normal	1.00
4184	65	B	10	B10	Silver	normal	1.00
4185	65	C	1	C1	Gold	normal	1.25
4186	65	C	2	C2	Gold	normal	1.25
4187	65	C	3	C3	Gold	normal	1.25
4188	65	C	4	C4	Gold	normal	1.25
4189	65	C	5	C5	Gold	normal	1.25
4190	65	C	6	C6	Gold	normal	1.25
4191	65	C	7	C7	Gold	normal	1.25
4192	65	C	8	C8	Gold	normal	1.25
4193	65	C	9	C9	Gold	normal	1.25
4194	65	C	10	C10	Gold	normal	1.25
4195	65	D	1	D1	Gold	normal	1.25
4196	65	D	2	D2	Gold	normal	1.25
4197	65	D	3	D3	Gold	normal	1.25
4198	65	D	4	D4	Gold	normal	1.25
4199	65	D	5	D5	Gold	normal	1.25
4200	65	D	6	D6	Gold	normal	1.25
4201	65	D	7	D7	Gold	normal	1.25
4202	65	D	8	D8	Gold	normal	1.25
4203	65	D	9	D9	Gold	normal	1.25
4204	65	D	10	D10	Gold	normal	1.25
4205	65	E	1	E1	Platinum Recliner	normal	1.60
4206	65	E	2	E2	Platinum Recliner	normal	1.60
4207	65	E	3	E3	Platinum Recliner	normal	1.60
4208	65	E	4	E4	Platinum Recliner	normal	1.60
4209	65	E	5	E5	Platinum Recliner	normal	1.60
4210	65	E	6	E6	Platinum Recliner	normal	1.60
4211	65	E	7	E7	Platinum Recliner	normal	1.60
4212	65	E	8	E8	Platinum Recliner	normal	1.60
4213	65	E	9	E9	Platinum Recliner	normal	1.60
4214	65	E	10	E10	Platinum Recliner	normal	1.60
4215	65	F	1	F1	Platinum Recliner	normal	1.60
4216	65	F	2	F2	Platinum Recliner	normal	1.60
4217	65	F	3	F3	Platinum Recliner	normal	1.60
4218	65	F	4	F4	Platinum Recliner	normal	1.60
4219	65	F	5	F5	Platinum Recliner	normal	1.60
4220	65	F	6	F6	Platinum Recliner	normal	1.60
4221	65	F	7	F7	Platinum Recliner	normal	1.60
4222	65	F	8	F8	Platinum Recliner	normal	1.60
4223	65	F	9	F9	Platinum Recliner	normal	1.60
4224	65	F	10	F10	Platinum Recliner	normal	1.60
4225	66	A	1	A1	Silver	normal	1.00
4226	66	A	2	A2	Silver	normal	1.00
4227	66	A	3	A3	Silver	normal	1.00
4228	66	A	4	A4	Silver	normal	1.00
4229	66	A	5	A5	Silver	normal	1.00
4230	66	A	6	A6	Silver	normal	1.00
4231	66	A	7	A7	Silver	normal	1.00
4232	66	A	8	A8	Silver	normal	1.00
4233	66	A	9	A9	Silver	normal	1.00
4234	66	A	10	A10	Silver	normal	1.00
4235	66	A	11	A11	Silver	normal	1.00
4236	66	A	12	A12	Silver	normal	1.00
4237	66	B	1	B1	Silver	normal	1.00
4238	66	B	2	B2	Silver	normal	1.00
4239	66	B	3	B3	Silver	normal	1.00
4240	66	B	4	B4	Silver	normal	1.00
4241	66	B	5	B5	Silver	normal	1.00
4242	66	B	6	B6	Silver	normal	1.00
4243	66	B	7	B7	Silver	normal	1.00
4244	66	B	8	B8	Silver	normal	1.00
4245	66	B	9	B9	Silver	normal	1.00
4246	66	B	10	B10	Silver	normal	1.00
4247	66	B	11	B11	Silver	normal	1.00
4248	66	B	12	B12	Silver	normal	1.00
4249	66	C	1	C1	Gold	normal	1.25
4250	66	C	2	C2	Gold	normal	1.25
4251	66	C	3	C3	Gold	normal	1.25
4252	66	C	4	C4	Gold	normal	1.25
4253	66	C	5	C5	Gold	normal	1.25
4254	66	C	6	C6	Gold	normal	1.25
4255	66	C	7	C7	Gold	normal	1.25
4256	66	C	8	C8	Gold	normal	1.25
4257	66	C	9	C9	Gold	normal	1.25
4258	66	C	10	C10	Gold	normal	1.25
4259	66	C	11	C11	Gold	normal	1.25
4260	66	C	12	C12	Gold	normal	1.25
4261	66	D	1	D1	Gold	normal	1.25
4262	66	D	2	D2	Gold	normal	1.25
4263	66	D	3	D3	Gold	normal	1.25
4264	66	D	4	D4	Gold	normal	1.25
4265	66	D	5	D5	Gold	normal	1.25
4266	66	D	6	D6	Gold	normal	1.25
4267	66	D	7	D7	Gold	normal	1.25
4268	66	D	8	D8	Gold	normal	1.25
4269	66	D	9	D9	Gold	normal	1.25
4270	66	D	10	D10	Gold	normal	1.25
4271	66	D	11	D11	Gold	normal	1.25
4272	66	D	12	D12	Gold	normal	1.25
4273	66	E	1	E1	Platinum Recliner	normal	1.60
4274	66	E	2	E2	Platinum Recliner	normal	1.60
4275	66	E	3	E3	Platinum Recliner	normal	1.60
4276	66	E	4	E4	Platinum Recliner	normal	1.60
4277	66	E	5	E5	Platinum Recliner	normal	1.60
4278	66	E	6	E6	Platinum Recliner	normal	1.60
4279	66	E	7	E7	Platinum Recliner	normal	1.60
4280	66	E	8	E8	Platinum Recliner	normal	1.60
4281	66	E	9	E9	Platinum Recliner	normal	1.60
4282	66	E	10	E10	Platinum Recliner	normal	1.60
4283	66	E	11	E11	Platinum Recliner	normal	1.60
4284	66	E	12	E12	Platinum Recliner	normal	1.60
4285	66	F	1	F1	Platinum Recliner	normal	1.60
4286	66	F	2	F2	Platinum Recliner	normal	1.60
4287	66	F	3	F3	Platinum Recliner	normal	1.60
4288	66	F	4	F4	Platinum Recliner	normal	1.60
4289	66	F	5	F5	Platinum Recliner	normal	1.60
4290	66	F	6	F6	Platinum Recliner	normal	1.60
4291	66	F	7	F7	Platinum Recliner	normal	1.60
4292	66	F	8	F8	Platinum Recliner	normal	1.60
4293	66	F	9	F9	Platinum Recliner	normal	1.60
4294	66	F	10	F10	Platinum Recliner	normal	1.60
4295	66	F	11	F11	Platinum Recliner	normal	1.60
4296	66	F	12	F12	Platinum Recliner	normal	1.60
4297	67	A	1	A1	Silver	normal	1.00
4298	67	A	2	A2	Silver	normal	1.00
4299	67	A	3	A3	Silver	normal	1.00
4300	67	A	4	A4	Silver	normal	1.00
4301	67	A	5	A5	Silver	normal	1.00
4302	67	A	6	A6	Silver	normal	1.00
4303	67	A	7	A7	Silver	normal	1.00
4304	67	A	8	A8	Silver	normal	1.00
4305	67	B	1	B1	Silver	normal	1.00
4306	67	B	2	B2	Silver	normal	1.00
4307	67	B	3	B3	Silver	normal	1.00
4308	67	B	4	B4	Silver	normal	1.00
4309	67	B	5	B5	Silver	normal	1.00
4310	67	B	6	B6	Silver	normal	1.00
4311	67	B	7	B7	Silver	normal	1.00
4312	67	B	8	B8	Silver	normal	1.00
4313	67	C	1	C1	Gold	normal	1.25
4314	67	C	2	C2	Gold	normal	1.25
4315	67	C	3	C3	Gold	normal	1.25
4316	67	C	4	C4	Gold	normal	1.25
4317	67	C	5	C5	Gold	normal	1.25
4318	67	C	6	C6	Gold	normal	1.25
4319	67	C	7	C7	Gold	normal	1.25
4320	67	C	8	C8	Gold	normal	1.25
4321	67	D	1	D1	Gold	normal	1.25
4322	67	D	2	D2	Gold	normal	1.25
4323	67	D	3	D3	Gold	normal	1.25
4324	67	D	4	D4	Gold	normal	1.25
4325	67	D	5	D5	Gold	normal	1.25
4326	67	D	6	D6	Gold	normal	1.25
4327	67	D	7	D7	Gold	normal	1.25
4328	67	D	8	D8	Gold	normal	1.25
4329	67	E	1	E1	Platinum Recliner	normal	1.60
4330	67	E	2	E2	Platinum Recliner	normal	1.60
4331	67	E	3	E3	Platinum Recliner	normal	1.60
4332	67	E	4	E4	Platinum Recliner	normal	1.60
4333	67	E	5	E5	Platinum Recliner	normal	1.60
4334	67	E	6	E6	Platinum Recliner	normal	1.60
4335	67	E	7	E7	Platinum Recliner	normal	1.60
4336	67	E	8	E8	Platinum Recliner	normal	1.60
4337	67	F	1	F1	Platinum Recliner	normal	1.60
4338	67	F	2	F2	Platinum Recliner	normal	1.60
4339	67	F	3	F3	Platinum Recliner	normal	1.60
4340	67	F	4	F4	Platinum Recliner	normal	1.60
4341	67	F	5	F5	Platinum Recliner	normal	1.60
4342	67	F	6	F6	Platinum Recliner	normal	1.60
4343	67	F	7	F7	Platinum Recliner	normal	1.60
4344	67	F	8	F8	Platinum Recliner	normal	1.60
4345	68	A	1	A1	Silver	normal	1.00
4346	68	A	2	A2	Silver	normal	1.00
4347	68	A	3	A3	Silver	normal	1.00
4348	68	A	4	A4	Silver	normal	1.00
4349	68	A	5	A5	Silver	normal	1.00
4350	68	A	6	A6	Silver	normal	1.00
4351	68	A	7	A7	Silver	normal	1.00
4352	68	A	8	A8	Silver	normal	1.00
4353	68	A	9	A9	Silver	normal	1.00
4354	68	A	10	A10	Silver	normal	1.00
4355	68	A	11	A11	Silver	normal	1.00
4356	68	A	12	A12	Silver	normal	1.00
4357	68	B	1	B1	Silver	normal	1.00
4358	68	B	2	B2	Silver	normal	1.00
4359	68	B	3	B3	Silver	normal	1.00
4360	68	B	4	B4	Silver	normal	1.00
4361	68	B	5	B5	Silver	normal	1.00
4362	68	B	6	B6	Silver	normal	1.00
4363	68	B	7	B7	Silver	normal	1.00
4364	68	B	8	B8	Silver	normal	1.00
4365	68	B	9	B9	Silver	normal	1.00
4366	68	B	10	B10	Silver	normal	1.00
4367	68	B	11	B11	Silver	normal	1.00
4368	68	B	12	B12	Silver	normal	1.00
4369	68	C	1	C1	Gold	normal	1.25
4370	68	C	2	C2	Gold	normal	1.25
4371	68	C	3	C3	Gold	normal	1.25
4372	68	C	4	C4	Gold	normal	1.25
4373	68	C	5	C5	Gold	normal	1.25
4374	68	C	6	C6	Gold	normal	1.25
4375	68	C	7	C7	Gold	normal	1.25
4376	68	C	8	C8	Gold	normal	1.25
4377	68	C	9	C9	Gold	normal	1.25
4378	68	C	10	C10	Gold	normal	1.25
4379	68	C	11	C11	Gold	normal	1.25
4380	68	C	12	C12	Gold	normal	1.25
4381	68	D	1	D1	Gold	normal	1.25
4382	68	D	2	D2	Gold	normal	1.25
4383	68	D	3	D3	Gold	normal	1.25
4384	68	D	4	D4	Gold	normal	1.25
4385	68	D	5	D5	Gold	normal	1.25
4386	68	D	6	D6	Gold	normal	1.25
4387	68	D	7	D7	Gold	normal	1.25
4388	68	D	8	D8	Gold	normal	1.25
4389	68	D	9	D9	Gold	normal	1.25
4390	68	D	10	D10	Gold	normal	1.25
4391	68	D	11	D11	Gold	normal	1.25
4392	68	D	12	D12	Gold	normal	1.25
4393	68	E	1	E1	Platinum Recliner	normal	1.60
4394	68	E	2	E2	Platinum Recliner	normal	1.60
4395	68	E	3	E3	Platinum Recliner	normal	1.60
4396	68	E	4	E4	Platinum Recliner	normal	1.60
4397	68	E	5	E5	Platinum Recliner	normal	1.60
4398	68	E	6	E6	Platinum Recliner	normal	1.60
4399	68	E	7	E7	Platinum Recliner	normal	1.60
4400	68	E	8	E8	Platinum Recliner	normal	1.60
4401	68	E	9	E9	Platinum Recliner	normal	1.60
4402	68	E	10	E10	Platinum Recliner	normal	1.60
4403	68	E	11	E11	Platinum Recliner	normal	1.60
4404	68	E	12	E12	Platinum Recliner	normal	1.60
4405	68	F	1	F1	Platinum Recliner	normal	1.60
4406	68	F	2	F2	Platinum Recliner	normal	1.60
4407	68	F	3	F3	Platinum Recliner	normal	1.60
4408	68	F	4	F4	Platinum Recliner	normal	1.60
4409	68	F	5	F5	Platinum Recliner	normal	1.60
4410	68	F	6	F6	Platinum Recliner	normal	1.60
4411	68	F	7	F7	Platinum Recliner	normal	1.60
4412	68	F	8	F8	Platinum Recliner	normal	1.60
4413	68	F	9	F9	Platinum Recliner	normal	1.60
4414	68	F	10	F10	Platinum Recliner	normal	1.60
4415	68	F	11	F11	Platinum Recliner	normal	1.60
4416	68	F	12	F12	Platinum Recliner	normal	1.60
4417	69	A	1	A1	Silver	normal	1.00
4418	69	A	2	A2	Silver	normal	1.00
4419	69	A	3	A3	Silver	normal	1.00
4420	69	A	4	A4	Silver	normal	1.00
4421	69	A	5	A5	Silver	normal	1.00
4422	69	A	6	A6	Silver	normal	1.00
4423	69	A	7	A7	Silver	normal	1.00
4424	69	A	8	A8	Silver	normal	1.00
4425	69	A	9	A9	Silver	normal	1.00
4426	69	A	10	A10	Silver	normal	1.00
4427	69	B	1	B1	Silver	normal	1.00
4428	69	B	2	B2	Silver	normal	1.00
4429	69	B	3	B3	Silver	normal	1.00
4430	69	B	4	B4	Silver	normal	1.00
4431	69	B	5	B5	Silver	normal	1.00
4432	69	B	6	B6	Silver	normal	1.00
4433	69	B	7	B7	Silver	normal	1.00
4434	69	B	8	B8	Silver	normal	1.00
4435	69	B	9	B9	Silver	normal	1.00
4436	69	B	10	B10	Silver	normal	1.00
4437	69	C	1	C1	Gold	normal	1.25
4438	69	C	2	C2	Gold	normal	1.25
4439	69	C	3	C3	Gold	normal	1.25
4440	69	C	4	C4	Gold	normal	1.25
4441	69	C	5	C5	Gold	normal	1.25
4442	69	C	6	C6	Gold	normal	1.25
4443	69	C	7	C7	Gold	normal	1.25
4444	69	C	8	C8	Gold	normal	1.25
4445	69	C	9	C9	Gold	normal	1.25
4446	69	C	10	C10	Gold	normal	1.25
4447	69	D	1	D1	Gold	normal	1.25
4448	69	D	2	D2	Gold	normal	1.25
4449	69	D	3	D3	Gold	normal	1.25
4450	69	D	4	D4	Gold	normal	1.25
4451	69	D	5	D5	Gold	normal	1.25
4452	69	D	6	D6	Gold	normal	1.25
4453	69	D	7	D7	Gold	normal	1.25
4454	69	D	8	D8	Gold	normal	1.25
4455	69	D	9	D9	Gold	normal	1.25
4456	69	D	10	D10	Gold	normal	1.25
4457	69	E	1	E1	Platinum Recliner	normal	1.60
4458	69	E	2	E2	Platinum Recliner	normal	1.60
4459	69	E	3	E3	Platinum Recliner	normal	1.60
4460	69	E	4	E4	Platinum Recliner	normal	1.60
4461	69	E	5	E5	Platinum Recliner	normal	1.60
4462	69	E	6	E6	Platinum Recliner	normal	1.60
4463	69	E	7	E7	Platinum Recliner	normal	1.60
4464	69	E	8	E8	Platinum Recliner	normal	1.60
4465	69	E	9	E9	Platinum Recliner	normal	1.60
4466	69	E	10	E10	Platinum Recliner	normal	1.60
4467	69	F	1	F1	Platinum Recliner	normal	1.60
4468	69	F	2	F2	Platinum Recliner	normal	1.60
4469	69	F	3	F3	Platinum Recliner	normal	1.60
4470	69	F	4	F4	Platinum Recliner	normal	1.60
4471	69	F	5	F5	Platinum Recliner	normal	1.60
4472	69	F	6	F6	Platinum Recliner	normal	1.60
4473	69	F	7	F7	Platinum Recliner	normal	1.60
4474	69	F	8	F8	Platinum Recliner	normal	1.60
4475	69	F	9	F9	Platinum Recliner	normal	1.60
4476	69	F	10	F10	Platinum Recliner	normal	1.60
4477	70	A	1	A1	Silver	normal	1.00
4478	70	A	2	A2	Silver	normal	1.00
4479	70	A	3	A3	Silver	normal	1.00
4480	70	A	4	A4	Silver	normal	1.00
4481	70	A	5	A5	Silver	normal	1.00
4482	70	A	6	A6	Silver	normal	1.00
4483	70	A	7	A7	Silver	normal	1.00
4484	70	A	8	A8	Silver	normal	1.00
4485	70	A	9	A9	Silver	normal	1.00
4486	70	A	10	A10	Silver	normal	1.00
4487	70	A	11	A11	Silver	normal	1.00
4488	70	A	12	A12	Silver	normal	1.00
4489	70	B	1	B1	Silver	normal	1.00
4490	70	B	2	B2	Silver	normal	1.00
4491	70	B	3	B3	Silver	normal	1.00
4492	70	B	4	B4	Silver	normal	1.00
4493	70	B	5	B5	Silver	normal	1.00
4494	70	B	6	B6	Silver	normal	1.00
4495	70	B	7	B7	Silver	normal	1.00
4496	70	B	8	B8	Silver	normal	1.00
4497	70	B	9	B9	Silver	normal	1.00
4498	70	B	10	B10	Silver	normal	1.00
4499	70	B	11	B11	Silver	normal	1.00
4500	70	B	12	B12	Silver	normal	1.00
4501	70	C	1	C1	Gold	normal	1.25
4502	70	C	2	C2	Gold	normal	1.25
4503	70	C	3	C3	Gold	normal	1.25
4504	70	C	4	C4	Gold	normal	1.25
4505	70	C	5	C5	Gold	normal	1.25
4506	70	C	6	C6	Gold	normal	1.25
4507	70	C	7	C7	Gold	normal	1.25
4508	70	C	8	C8	Gold	normal	1.25
4509	70	C	9	C9	Gold	normal	1.25
4510	70	C	10	C10	Gold	normal	1.25
4511	70	C	11	C11	Gold	normal	1.25
4512	70	C	12	C12	Gold	normal	1.25
4513	70	D	1	D1	Gold	normal	1.25
4514	70	D	2	D2	Gold	normal	1.25
4515	70	D	3	D3	Gold	normal	1.25
4516	70	D	4	D4	Gold	normal	1.25
4517	70	D	5	D5	Gold	normal	1.25
4518	70	D	6	D6	Gold	normal	1.25
4519	70	D	7	D7	Gold	normal	1.25
4520	70	D	8	D8	Gold	normal	1.25
4521	70	D	9	D9	Gold	normal	1.25
4522	70	D	10	D10	Gold	normal	1.25
4523	70	D	11	D11	Gold	normal	1.25
4524	70	D	12	D12	Gold	normal	1.25
4525	70	E	1	E1	Platinum Recliner	normal	1.60
4526	70	E	2	E2	Platinum Recliner	normal	1.60
4527	70	E	3	E3	Platinum Recliner	normal	1.60
4528	70	E	4	E4	Platinum Recliner	normal	1.60
4529	70	E	5	E5	Platinum Recliner	normal	1.60
4530	70	E	6	E6	Platinum Recliner	normal	1.60
4531	70	E	7	E7	Platinum Recliner	normal	1.60
4532	70	E	8	E8	Platinum Recliner	normal	1.60
4533	70	E	9	E9	Platinum Recliner	normal	1.60
4534	70	E	10	E10	Platinum Recliner	normal	1.60
4535	70	E	11	E11	Platinum Recliner	normal	1.60
4536	70	E	12	E12	Platinum Recliner	normal	1.60
4537	70	F	1	F1	Platinum Recliner	normal	1.60
4538	70	F	2	F2	Platinum Recliner	normal	1.60
4539	70	F	3	F3	Platinum Recliner	normal	1.60
4540	70	F	4	F4	Platinum Recliner	normal	1.60
4541	70	F	5	F5	Platinum Recliner	normal	1.60
4542	70	F	6	F6	Platinum Recliner	normal	1.60
4543	70	F	7	F7	Platinum Recliner	normal	1.60
4544	70	F	8	F8	Platinum Recliner	normal	1.60
4545	70	F	9	F9	Platinum Recliner	normal	1.60
4546	70	F	10	F10	Platinum Recliner	normal	1.60
4547	70	F	11	F11	Platinum Recliner	normal	1.60
4548	70	F	12	F12	Platinum Recliner	normal	1.60
4549	71	A	1	A1	Silver	normal	1.00
4550	71	A	2	A2	Silver	normal	1.00
4551	71	A	3	A3	Silver	normal	1.00
4552	71	A	4	A4	Silver	normal	1.00
4553	71	A	5	A5	Silver	normal	1.00
4554	71	A	6	A6	Silver	normal	1.00
4555	71	A	7	A7	Silver	normal	1.00
4556	71	A	8	A8	Silver	normal	1.00
4557	71	B	1	B1	Silver	normal	1.00
4558	71	B	2	B2	Silver	normal	1.00
4559	71	B	3	B3	Silver	normal	1.00
4560	71	B	4	B4	Silver	normal	1.00
4561	71	B	5	B5	Silver	normal	1.00
4562	71	B	6	B6	Silver	normal	1.00
4563	71	B	7	B7	Silver	normal	1.00
4564	71	B	8	B8	Silver	normal	1.00
4565	71	C	1	C1	Gold	normal	1.25
4566	71	C	2	C2	Gold	normal	1.25
4567	71	C	3	C3	Gold	normal	1.25
4568	71	C	4	C4	Gold	normal	1.25
4569	71	C	5	C5	Gold	normal	1.25
4570	71	C	6	C6	Gold	normal	1.25
4571	71	C	7	C7	Gold	normal	1.25
4572	71	C	8	C8	Gold	normal	1.25
4573	71	D	1	D1	Gold	normal	1.25
4574	71	D	2	D2	Gold	normal	1.25
4575	71	D	3	D3	Gold	normal	1.25
4576	71	D	4	D4	Gold	normal	1.25
4577	71	D	5	D5	Gold	normal	1.25
4578	71	D	6	D6	Gold	normal	1.25
4579	71	D	7	D7	Gold	normal	1.25
4580	71	D	8	D8	Gold	normal	1.25
4581	71	E	1	E1	Platinum Recliner	normal	1.60
4582	71	E	2	E2	Platinum Recliner	normal	1.60
4583	71	E	3	E3	Platinum Recliner	normal	1.60
4584	71	E	4	E4	Platinum Recliner	normal	1.60
4585	71	E	5	E5	Platinum Recliner	normal	1.60
4586	71	E	6	E6	Platinum Recliner	normal	1.60
4587	71	E	7	E7	Platinum Recliner	normal	1.60
4588	71	E	8	E8	Platinum Recliner	normal	1.60
4589	71	F	1	F1	Platinum Recliner	normal	1.60
4590	71	F	2	F2	Platinum Recliner	normal	1.60
4591	71	F	3	F3	Platinum Recliner	normal	1.60
4592	71	F	4	F4	Platinum Recliner	normal	1.60
4593	71	F	5	F5	Platinum Recliner	normal	1.60
4594	71	F	6	F6	Platinum Recliner	normal	1.60
4595	71	F	7	F7	Platinum Recliner	normal	1.60
4596	71	F	8	F8	Platinum Recliner	normal	1.60
4597	72	A	1	A1	Silver	normal	1.00
4598	72	A	2	A2	Silver	normal	1.00
4599	72	A	3	A3	Silver	normal	1.00
4600	72	A	4	A4	Silver	normal	1.00
4601	72	A	5	A5	Silver	normal	1.00
4602	72	A	6	A6	Silver	normal	1.00
4603	72	A	7	A7	Silver	normal	1.00
4604	72	A	8	A8	Silver	normal	1.00
4605	72	A	9	A9	Silver	normal	1.00
4606	72	A	10	A10	Silver	normal	1.00
4607	72	A	11	A11	Silver	normal	1.00
4608	72	A	12	A12	Silver	normal	1.00
4609	72	B	1	B1	Silver	normal	1.00
4610	72	B	2	B2	Silver	normal	1.00
4611	72	B	3	B3	Silver	normal	1.00
4612	72	B	4	B4	Silver	normal	1.00
4613	72	B	5	B5	Silver	normal	1.00
4614	72	B	6	B6	Silver	normal	1.00
4615	72	B	7	B7	Silver	normal	1.00
4616	72	B	8	B8	Silver	normal	1.00
4617	72	B	9	B9	Silver	normal	1.00
4618	72	B	10	B10	Silver	normal	1.00
4619	72	B	11	B11	Silver	normal	1.00
4620	72	B	12	B12	Silver	normal	1.00
4621	72	C	1	C1	Gold	normal	1.25
4622	72	C	2	C2	Gold	normal	1.25
4623	72	C	3	C3	Gold	normal	1.25
4624	72	C	4	C4	Gold	normal	1.25
4625	72	C	5	C5	Gold	normal	1.25
4626	72	C	6	C6	Gold	normal	1.25
4627	72	C	7	C7	Gold	normal	1.25
4628	72	C	8	C8	Gold	normal	1.25
4629	72	C	9	C9	Gold	normal	1.25
4630	72	C	10	C10	Gold	normal	1.25
4631	72	C	11	C11	Gold	normal	1.25
4632	72	C	12	C12	Gold	normal	1.25
4633	72	D	1	D1	Gold	normal	1.25
4634	72	D	2	D2	Gold	normal	1.25
4635	72	D	3	D3	Gold	normal	1.25
4636	72	D	4	D4	Gold	normal	1.25
4637	72	D	5	D5	Gold	normal	1.25
4638	72	D	6	D6	Gold	normal	1.25
4639	72	D	7	D7	Gold	normal	1.25
4640	72	D	8	D8	Gold	normal	1.25
4641	72	D	9	D9	Gold	normal	1.25
4642	72	D	10	D10	Gold	normal	1.25
4643	72	D	11	D11	Gold	normal	1.25
4644	72	D	12	D12	Gold	normal	1.25
4645	72	E	1	E1	Platinum Recliner	normal	1.60
4646	72	E	2	E2	Platinum Recliner	normal	1.60
4647	72	E	3	E3	Platinum Recliner	normal	1.60
4648	72	E	4	E4	Platinum Recliner	normal	1.60
4649	72	E	5	E5	Platinum Recliner	normal	1.60
4650	72	E	6	E6	Platinum Recliner	normal	1.60
4651	72	E	7	E7	Platinum Recliner	normal	1.60
4652	72	E	8	E8	Platinum Recliner	normal	1.60
4653	72	E	9	E9	Platinum Recliner	normal	1.60
4654	72	E	10	E10	Platinum Recliner	normal	1.60
4655	72	E	11	E11	Platinum Recliner	normal	1.60
4656	72	E	12	E12	Platinum Recliner	normal	1.60
4657	72	F	1	F1	Platinum Recliner	normal	1.60
4658	72	F	2	F2	Platinum Recliner	normal	1.60
4659	72	F	3	F3	Platinum Recliner	normal	1.60
4660	72	F	4	F4	Platinum Recliner	normal	1.60
4661	72	F	5	F5	Platinum Recliner	normal	1.60
4662	72	F	6	F6	Platinum Recliner	normal	1.60
4663	72	F	7	F7	Platinum Recliner	normal	1.60
4664	72	F	8	F8	Platinum Recliner	normal	1.60
4665	72	F	9	F9	Platinum Recliner	normal	1.60
4666	72	F	10	F10	Platinum Recliner	normal	1.60
4667	72	F	11	F11	Platinum Recliner	normal	1.60
4668	72	F	12	F12	Platinum Recliner	normal	1.60
4669	73	A	1	A1	Silver	normal	1.00
4670	73	A	2	A2	Silver	normal	1.00
4671	73	A	3	A3	Silver	normal	1.00
4672	73	A	4	A4	Silver	normal	1.00
4673	73	A	5	A5	Silver	normal	1.00
4674	73	A	6	A6	Silver	normal	1.00
4675	73	A	7	A7	Silver	normal	1.00
4676	73	A	8	A8	Silver	normal	1.00
4677	73	A	9	A9	Silver	normal	1.00
4678	73	A	10	A10	Silver	normal	1.00
4679	73	A	11	A11	Silver	normal	1.00
4680	73	A	12	A12	Silver	normal	1.00
4681	73	B	1	B1	Silver	normal	1.00
4682	73	B	2	B2	Silver	normal	1.00
4683	73	B	3	B3	Silver	normal	1.00
4684	73	B	4	B4	Silver	normal	1.00
4685	73	B	5	B5	Silver	normal	1.00
4686	73	B	6	B6	Silver	normal	1.00
4687	73	B	7	B7	Silver	normal	1.00
4688	73	B	8	B8	Silver	normal	1.00
4689	73	B	9	B9	Silver	normal	1.00
4690	73	B	10	B10	Silver	normal	1.00
4691	73	B	11	B11	Silver	normal	1.00
4692	73	B	12	B12	Silver	normal	1.00
4693	73	C	1	C1	Gold	normal	1.25
4694	73	C	2	C2	Gold	normal	1.25
4695	73	C	3	C3	Gold	normal	1.25
4696	73	C	4	C4	Gold	normal	1.25
4697	73	C	5	C5	Gold	normal	1.25
4698	73	C	6	C6	Gold	normal	1.25
4699	73	C	7	C7	Gold	normal	1.25
4700	73	C	8	C8	Gold	normal	1.25
4701	73	C	9	C9	Gold	normal	1.25
4702	73	C	10	C10	Gold	normal	1.25
4703	73	C	11	C11	Gold	normal	1.25
4704	73	C	12	C12	Gold	normal	1.25
4705	73	D	1	D1	Gold	normal	1.25
4706	73	D	2	D2	Gold	normal	1.25
4707	73	D	3	D3	Gold	normal	1.25
4708	73	D	4	D4	Gold	normal	1.25
4709	73	D	5	D5	Gold	normal	1.25
4710	73	D	6	D6	Gold	normal	1.25
4711	73	D	7	D7	Gold	normal	1.25
4712	73	D	8	D8	Gold	normal	1.25
4713	73	D	9	D9	Gold	normal	1.25
4714	73	D	10	D10	Gold	normal	1.25
4715	73	D	11	D11	Gold	normal	1.25
4716	73	D	12	D12	Gold	normal	1.25
4717	73	E	1	E1	Platinum Recliner	normal	1.60
4718	73	E	2	E2	Platinum Recliner	normal	1.60
4719	73	E	3	E3	Platinum Recliner	normal	1.60
4720	73	E	4	E4	Platinum Recliner	normal	1.60
4721	73	E	5	E5	Platinum Recliner	normal	1.60
4722	73	E	6	E6	Platinum Recliner	normal	1.60
4723	73	E	7	E7	Platinum Recliner	normal	1.60
4724	73	E	8	E8	Platinum Recliner	normal	1.60
4725	73	E	9	E9	Platinum Recliner	normal	1.60
4726	73	E	10	E10	Platinum Recliner	normal	1.60
4727	73	E	11	E11	Platinum Recliner	normal	1.60
4728	73	E	12	E12	Platinum Recliner	normal	1.60
4729	73	F	1	F1	Platinum Recliner	normal	1.60
4730	73	F	2	F2	Platinum Recliner	normal	1.60
4731	73	F	3	F3	Platinum Recliner	normal	1.60
4732	73	F	4	F4	Platinum Recliner	normal	1.60
4733	73	F	5	F5	Platinum Recliner	normal	1.60
4734	73	F	6	F6	Platinum Recliner	normal	1.60
4735	73	F	7	F7	Platinum Recliner	normal	1.60
4736	73	F	8	F8	Platinum Recliner	normal	1.60
4737	73	F	9	F9	Platinum Recliner	normal	1.60
4738	73	F	10	F10	Platinum Recliner	normal	1.60
4739	73	F	11	F11	Platinum Recliner	normal	1.60
4740	73	F	12	F12	Platinum Recliner	normal	1.60
4741	74	A	1	A1	Silver	normal	1.00
4742	74	A	2	A2	Silver	normal	1.00
4743	74	A	3	A3	Silver	normal	1.00
4744	74	A	4	A4	Silver	normal	1.00
4745	74	A	5	A5	Silver	normal	1.00
4746	74	A	6	A6	Silver	normal	1.00
4747	74	A	7	A7	Silver	normal	1.00
4748	74	A	8	A8	Silver	normal	1.00
4749	74	A	9	A9	Silver	normal	1.00
4750	74	A	10	A10	Silver	normal	1.00
4751	74	B	1	B1	Silver	normal	1.00
4752	74	B	2	B2	Silver	normal	1.00
4753	74	B	3	B3	Silver	normal	1.00
4754	74	B	4	B4	Silver	normal	1.00
4755	74	B	5	B5	Silver	normal	1.00
4756	74	B	6	B6	Silver	normal	1.00
4757	74	B	7	B7	Silver	normal	1.00
4758	74	B	8	B8	Silver	normal	1.00
4759	74	B	9	B9	Silver	normal	1.00
4760	74	B	10	B10	Silver	normal	1.00
4761	74	C	1	C1	Gold	normal	1.25
4762	74	C	2	C2	Gold	normal	1.25
4763	74	C	3	C3	Gold	normal	1.25
4764	74	C	4	C4	Gold	normal	1.25
4765	74	C	5	C5	Gold	normal	1.25
4766	74	C	6	C6	Gold	normal	1.25
4767	74	C	7	C7	Gold	normal	1.25
4768	74	C	8	C8	Gold	normal	1.25
4769	74	C	9	C9	Gold	normal	1.25
4770	74	C	10	C10	Gold	normal	1.25
4771	74	D	1	D1	Gold	normal	1.25
4772	74	D	2	D2	Gold	normal	1.25
4773	74	D	3	D3	Gold	normal	1.25
4774	74	D	4	D4	Gold	normal	1.25
4775	74	D	5	D5	Gold	normal	1.25
4776	74	D	6	D6	Gold	normal	1.25
4777	74	D	7	D7	Gold	normal	1.25
4778	74	D	8	D8	Gold	normal	1.25
4779	74	D	9	D9	Gold	normal	1.25
4780	74	D	10	D10	Gold	normal	1.25
4781	74	E	1	E1	Platinum Recliner	normal	1.60
4782	74	E	2	E2	Platinum Recliner	normal	1.60
4783	74	E	3	E3	Platinum Recliner	normal	1.60
4784	74	E	4	E4	Platinum Recliner	normal	1.60
4785	74	E	5	E5	Platinum Recliner	normal	1.60
4786	74	E	6	E6	Platinum Recliner	normal	1.60
4787	74	E	7	E7	Platinum Recliner	normal	1.60
4788	74	E	8	E8	Platinum Recliner	normal	1.60
4789	74	E	9	E9	Platinum Recliner	normal	1.60
4790	74	E	10	E10	Platinum Recliner	normal	1.60
4791	74	F	1	F1	Platinum Recliner	normal	1.60
4792	74	F	2	F2	Platinum Recliner	normal	1.60
4793	74	F	3	F3	Platinum Recliner	normal	1.60
4794	74	F	4	F4	Platinum Recliner	normal	1.60
4795	74	F	5	F5	Platinum Recliner	normal	1.60
4796	74	F	6	F6	Platinum Recliner	normal	1.60
4797	74	F	7	F7	Platinum Recliner	normal	1.60
4798	74	F	8	F8	Platinum Recliner	normal	1.60
4799	74	F	9	F9	Platinum Recliner	normal	1.60
4800	74	F	10	F10	Platinum Recliner	normal	1.60
4801	75	A	1	A1	Silver	normal	1.00
4802	75	A	2	A2	Silver	normal	1.00
4803	75	A	3	A3	Silver	normal	1.00
4804	75	A	4	A4	Silver	normal	1.00
4805	75	A	5	A5	Silver	normal	1.00
4806	75	A	6	A6	Silver	normal	1.00
4807	75	A	7	A7	Silver	normal	1.00
4808	75	A	8	A8	Silver	normal	1.00
4809	75	A	9	A9	Silver	normal	1.00
4810	75	A	10	A10	Silver	normal	1.00
4811	75	A	11	A11	Silver	normal	1.00
4812	75	A	12	A12	Silver	normal	1.00
4813	75	B	1	B1	Silver	normal	1.00
4814	75	B	2	B2	Silver	normal	1.00
4815	75	B	3	B3	Silver	normal	1.00
4816	75	B	4	B4	Silver	normal	1.00
4817	75	B	5	B5	Silver	normal	1.00
4818	75	B	6	B6	Silver	normal	1.00
4819	75	B	7	B7	Silver	normal	1.00
4820	75	B	8	B8	Silver	normal	1.00
4821	75	B	9	B9	Silver	normal	1.00
4822	75	B	10	B10	Silver	normal	1.00
4823	75	B	11	B11	Silver	normal	1.00
4824	75	B	12	B12	Silver	normal	1.00
4825	75	C	1	C1	Gold	normal	1.25
4826	75	C	2	C2	Gold	normal	1.25
4827	75	C	3	C3	Gold	normal	1.25
4828	75	C	4	C4	Gold	normal	1.25
4829	75	C	5	C5	Gold	normal	1.25
4830	75	C	6	C6	Gold	normal	1.25
4831	75	C	7	C7	Gold	normal	1.25
4832	75	C	8	C8	Gold	normal	1.25
4833	75	C	9	C9	Gold	normal	1.25
4834	75	C	10	C10	Gold	normal	1.25
4835	75	C	11	C11	Gold	normal	1.25
4836	75	C	12	C12	Gold	normal	1.25
4837	75	D	1	D1	Gold	normal	1.25
4838	75	D	2	D2	Gold	normal	1.25
4839	75	D	3	D3	Gold	normal	1.25
4840	75	D	4	D4	Gold	normal	1.25
4841	75	D	5	D5	Gold	normal	1.25
4842	75	D	6	D6	Gold	normal	1.25
4843	75	D	7	D7	Gold	normal	1.25
4844	75	D	8	D8	Gold	normal	1.25
4845	75	D	9	D9	Gold	normal	1.25
4846	75	D	10	D10	Gold	normal	1.25
4847	75	D	11	D11	Gold	normal	1.25
4848	75	D	12	D12	Gold	normal	1.25
4849	75	E	1	E1	Platinum Recliner	normal	1.60
4850	75	E	2	E2	Platinum Recliner	normal	1.60
4851	75	E	3	E3	Platinum Recliner	normal	1.60
4852	75	E	4	E4	Platinum Recliner	normal	1.60
4853	75	E	5	E5	Platinum Recliner	normal	1.60
4854	75	E	6	E6	Platinum Recliner	normal	1.60
4855	75	E	7	E7	Platinum Recliner	normal	1.60
4856	75	E	8	E8	Platinum Recliner	normal	1.60
4857	75	E	9	E9	Platinum Recliner	normal	1.60
4858	75	E	10	E10	Platinum Recliner	normal	1.60
4859	75	E	11	E11	Platinum Recliner	normal	1.60
4860	75	E	12	E12	Platinum Recliner	normal	1.60
4861	75	F	1	F1	Platinum Recliner	normal	1.60
4862	75	F	2	F2	Platinum Recliner	normal	1.60
4863	75	F	3	F3	Platinum Recliner	normal	1.60
4864	75	F	4	F4	Platinum Recliner	normal	1.60
4865	75	F	5	F5	Platinum Recliner	normal	1.60
4866	75	F	6	F6	Platinum Recliner	normal	1.60
4867	75	F	7	F7	Platinum Recliner	normal	1.60
4868	75	F	8	F8	Platinum Recliner	normal	1.60
4869	75	F	9	F9	Platinum Recliner	normal	1.60
4870	75	F	10	F10	Platinum Recliner	normal	1.60
4871	75	F	11	F11	Platinum Recliner	normal	1.60
4872	75	F	12	F12	Platinum Recliner	normal	1.60
4873	76	A	1	A1	Silver	normal	1.00
4874	76	A	2	A2	Silver	normal	1.00
4875	76	A	3	A3	Silver	normal	1.00
4876	76	A	4	A4	Silver	normal	1.00
4877	76	A	5	A5	Silver	normal	1.00
4878	76	A	6	A6	Silver	normal	1.00
4879	76	A	7	A7	Silver	normal	1.00
4880	76	A	8	A8	Silver	normal	1.00
4881	76	A	9	A9	Silver	normal	1.00
4882	76	A	10	A10	Silver	normal	1.00
4883	76	B	1	B1	Silver	normal	1.00
4884	76	B	2	B2	Silver	normal	1.00
4885	76	B	3	B3	Silver	normal	1.00
4886	76	B	4	B4	Silver	normal	1.00
4887	76	B	5	B5	Silver	normal	1.00
4888	76	B	6	B6	Silver	normal	1.00
4889	76	B	7	B7	Silver	normal	1.00
4890	76	B	8	B8	Silver	normal	1.00
4891	76	B	9	B9	Silver	normal	1.00
4892	76	B	10	B10	Silver	normal	1.00
4893	76	C	1	C1	Gold	normal	1.25
4894	76	C	2	C2	Gold	normal	1.25
4895	76	C	3	C3	Gold	normal	1.25
4896	76	C	4	C4	Gold	normal	1.25
4897	76	C	5	C5	Gold	normal	1.25
4898	76	C	6	C6	Gold	normal	1.25
4899	76	C	7	C7	Gold	normal	1.25
4900	76	C	8	C8	Gold	normal	1.25
4901	76	C	9	C9	Gold	normal	1.25
4902	76	C	10	C10	Gold	normal	1.25
4903	76	D	1	D1	Gold	normal	1.25
4904	76	D	2	D2	Gold	normal	1.25
4905	76	D	3	D3	Gold	normal	1.25
4906	76	D	4	D4	Gold	normal	1.25
4907	76	D	5	D5	Gold	normal	1.25
4908	76	D	6	D6	Gold	normal	1.25
4909	76	D	7	D7	Gold	normal	1.25
4910	76	D	8	D8	Gold	normal	1.25
4911	76	D	9	D9	Gold	normal	1.25
4912	76	D	10	D10	Gold	normal	1.25
4913	76	E	1	E1	Platinum Recliner	normal	1.60
4914	76	E	2	E2	Platinum Recliner	normal	1.60
4915	76	E	3	E3	Platinum Recliner	normal	1.60
4916	76	E	4	E4	Platinum Recliner	normal	1.60
4917	76	E	5	E5	Platinum Recliner	normal	1.60
4918	76	E	6	E6	Platinum Recliner	normal	1.60
4919	76	E	7	E7	Platinum Recliner	normal	1.60
4920	76	E	8	E8	Platinum Recliner	normal	1.60
4921	76	E	9	E9	Platinum Recliner	normal	1.60
4922	76	E	10	E10	Platinum Recliner	normal	1.60
4923	76	F	1	F1	Platinum Recliner	normal	1.60
4924	76	F	2	F2	Platinum Recliner	normal	1.60
4925	76	F	3	F3	Platinum Recliner	normal	1.60
4926	76	F	4	F4	Platinum Recliner	normal	1.60
4927	76	F	5	F5	Platinum Recliner	normal	1.60
4928	76	F	6	F6	Platinum Recliner	normal	1.60
4929	76	F	7	F7	Platinum Recliner	normal	1.60
4930	76	F	8	F8	Platinum Recliner	normal	1.60
4931	76	F	9	F9	Platinum Recliner	normal	1.60
4932	76	F	10	F10	Platinum Recliner	normal	1.60
4933	77	A	1	A1	Silver	normal	1.00
4934	77	A	2	A2	Silver	normal	1.00
4935	77	A	3	A3	Silver	normal	1.00
4936	77	A	4	A4	Silver	normal	1.00
4937	77	A	5	A5	Silver	normal	1.00
4938	77	A	6	A6	Silver	normal	1.00
4939	77	A	7	A7	Silver	normal	1.00
4940	77	A	8	A8	Silver	normal	1.00
4941	77	A	9	A9	Silver	normal	1.00
4942	77	A	10	A10	Silver	normal	1.00
4943	77	A	11	A11	Silver	normal	1.00
4944	77	A	12	A12	Silver	normal	1.00
4945	77	B	1	B1	Silver	normal	1.00
4946	77	B	2	B2	Silver	normal	1.00
4947	77	B	3	B3	Silver	normal	1.00
4948	77	B	4	B4	Silver	normal	1.00
4949	77	B	5	B5	Silver	normal	1.00
4950	77	B	6	B6	Silver	normal	1.00
4951	77	B	7	B7	Silver	normal	1.00
4952	77	B	8	B8	Silver	normal	1.00
4953	77	B	9	B9	Silver	normal	1.00
4954	77	B	10	B10	Silver	normal	1.00
4955	77	B	11	B11	Silver	normal	1.00
4956	77	B	12	B12	Silver	normal	1.00
4957	77	C	1	C1	Gold	normal	1.25
4958	77	C	2	C2	Gold	normal	1.25
4959	77	C	3	C3	Gold	normal	1.25
4960	77	C	4	C4	Gold	normal	1.25
4961	77	C	5	C5	Gold	normal	1.25
4962	77	C	6	C6	Gold	normal	1.25
4963	77	C	7	C7	Gold	normal	1.25
4964	77	C	8	C8	Gold	normal	1.25
4965	77	C	9	C9	Gold	normal	1.25
4966	77	C	10	C10	Gold	normal	1.25
4967	77	C	11	C11	Gold	normal	1.25
4968	77	C	12	C12	Gold	normal	1.25
4969	77	D	1	D1	Gold	normal	1.25
4970	77	D	2	D2	Gold	normal	1.25
4971	77	D	3	D3	Gold	normal	1.25
4972	77	D	4	D4	Gold	normal	1.25
4973	77	D	5	D5	Gold	normal	1.25
4974	77	D	6	D6	Gold	normal	1.25
4975	77	D	7	D7	Gold	normal	1.25
4976	77	D	8	D8	Gold	normal	1.25
4977	77	D	9	D9	Gold	normal	1.25
4978	77	D	10	D10	Gold	normal	1.25
4979	77	D	11	D11	Gold	normal	1.25
4980	77	D	12	D12	Gold	normal	1.25
4981	77	E	1	E1	Platinum Recliner	normal	1.60
4982	77	E	2	E2	Platinum Recliner	normal	1.60
4983	77	E	3	E3	Platinum Recliner	normal	1.60
4984	77	E	4	E4	Platinum Recliner	normal	1.60
4985	77	E	5	E5	Platinum Recliner	normal	1.60
4986	77	E	6	E6	Platinum Recliner	normal	1.60
4987	77	E	7	E7	Platinum Recliner	normal	1.60
4988	77	E	8	E8	Platinum Recliner	normal	1.60
4989	77	E	9	E9	Platinum Recliner	normal	1.60
4990	77	E	10	E10	Platinum Recliner	normal	1.60
4991	77	E	11	E11	Platinum Recliner	normal	1.60
4992	77	E	12	E12	Platinum Recliner	normal	1.60
4993	77	F	1	F1	Platinum Recliner	normal	1.60
4994	77	F	2	F2	Platinum Recliner	normal	1.60
4995	77	F	3	F3	Platinum Recliner	normal	1.60
4996	77	F	4	F4	Platinum Recliner	normal	1.60
4997	77	F	5	F5	Platinum Recliner	normal	1.60
4998	77	F	6	F6	Platinum Recliner	normal	1.60
4999	77	F	7	F7	Platinum Recliner	normal	1.60
5000	77	F	8	F8	Platinum Recliner	normal	1.60
5001	77	F	9	F9	Platinum Recliner	normal	1.60
5002	77	F	10	F10	Platinum Recliner	normal	1.60
5003	77	F	11	F11	Platinum Recliner	normal	1.60
5004	77	F	12	F12	Platinum Recliner	normal	1.60
5005	78	A	1	A1	Silver	normal	1.00
5006	78	A	2	A2	Silver	normal	1.00
5007	78	A	3	A3	Silver	normal	1.00
5008	78	A	4	A4	Silver	normal	1.00
5009	78	A	5	A5	Silver	normal	1.00
5010	78	A	6	A6	Silver	normal	1.00
5011	78	A	7	A7	Silver	normal	1.00
5012	78	A	8	A8	Silver	normal	1.00
5013	78	A	9	A9	Silver	normal	1.00
5014	78	A	10	A10	Silver	normal	1.00
5015	78	B	1	B1	Silver	normal	1.00
5016	78	B	2	B2	Silver	normal	1.00
5017	78	B	3	B3	Silver	normal	1.00
5018	78	B	4	B4	Silver	normal	1.00
5019	78	B	5	B5	Silver	normal	1.00
5020	78	B	6	B6	Silver	normal	1.00
5021	78	B	7	B7	Silver	normal	1.00
5022	78	B	8	B8	Silver	normal	1.00
5023	78	B	9	B9	Silver	normal	1.00
5024	78	B	10	B10	Silver	normal	1.00
5025	78	C	1	C1	Gold	normal	1.25
5026	78	C	2	C2	Gold	normal	1.25
5027	78	C	3	C3	Gold	normal	1.25
5028	78	C	4	C4	Gold	normal	1.25
5029	78	C	5	C5	Gold	normal	1.25
5030	78	C	6	C6	Gold	normal	1.25
5031	78	C	7	C7	Gold	normal	1.25
5032	78	C	8	C8	Gold	normal	1.25
5033	78	C	9	C9	Gold	normal	1.25
5034	78	C	10	C10	Gold	normal	1.25
5035	78	D	1	D1	Gold	normal	1.25
5036	78	D	2	D2	Gold	normal	1.25
5037	78	D	3	D3	Gold	normal	1.25
5038	78	D	4	D4	Gold	normal	1.25
5039	78	D	5	D5	Gold	normal	1.25
5040	78	D	6	D6	Gold	normal	1.25
5041	78	D	7	D7	Gold	normal	1.25
5042	78	D	8	D8	Gold	normal	1.25
5043	78	D	9	D9	Gold	normal	1.25
5044	78	D	10	D10	Gold	normal	1.25
5045	78	E	1	E1	Platinum Recliner	normal	1.60
5046	78	E	2	E2	Platinum Recliner	normal	1.60
5047	78	E	3	E3	Platinum Recliner	normal	1.60
5048	78	E	4	E4	Platinum Recliner	normal	1.60
5049	78	E	5	E5	Platinum Recliner	normal	1.60
5050	78	E	6	E6	Platinum Recliner	normal	1.60
5051	78	E	7	E7	Platinum Recliner	normal	1.60
5052	78	E	8	E8	Platinum Recliner	normal	1.60
5053	78	E	9	E9	Platinum Recliner	normal	1.60
5054	78	E	10	E10	Platinum Recliner	normal	1.60
5055	78	F	1	F1	Platinum Recliner	normal	1.60
5056	78	F	2	F2	Platinum Recliner	normal	1.60
5057	78	F	3	F3	Platinum Recliner	normal	1.60
5058	78	F	4	F4	Platinum Recliner	normal	1.60
5059	78	F	5	F5	Platinum Recliner	normal	1.60
5060	78	F	6	F6	Platinum Recliner	normal	1.60
5061	78	F	7	F7	Platinum Recliner	normal	1.60
5062	78	F	8	F8	Platinum Recliner	normal	1.60
5063	78	F	9	F9	Platinum Recliner	normal	1.60
5064	78	F	10	F10	Platinum Recliner	normal	1.60
5065	79	A	1	A1	Silver	normal	1.00
5066	79	A	2	A2	Silver	normal	1.00
5067	79	A	3	A3	Silver	normal	1.00
5068	79	A	4	A4	Silver	normal	1.00
5069	79	A	5	A5	Silver	normal	1.00
5070	79	A	6	A6	Silver	normal	1.00
5071	79	A	7	A7	Silver	normal	1.00
5072	79	A	8	A8	Silver	normal	1.00
5073	79	B	1	B1	Silver	normal	1.00
5074	79	B	2	B2	Silver	normal	1.00
5075	79	B	3	B3	Silver	normal	1.00
5076	79	B	4	B4	Silver	normal	1.00
5077	79	B	5	B5	Silver	normal	1.00
5078	79	B	6	B6	Silver	normal	1.00
5079	79	B	7	B7	Silver	normal	1.00
5080	79	B	8	B8	Silver	normal	1.00
5081	79	C	1	C1	Gold	normal	1.25
5082	79	C	2	C2	Gold	normal	1.25
5083	79	C	3	C3	Gold	normal	1.25
5084	79	C	4	C4	Gold	normal	1.25
5085	79	C	5	C5	Gold	normal	1.25
5086	79	C	6	C6	Gold	normal	1.25
5087	79	C	7	C7	Gold	normal	1.25
5088	79	C	8	C8	Gold	normal	1.25
5089	79	D	1	D1	Gold	normal	1.25
5090	79	D	2	D2	Gold	normal	1.25
5091	79	D	3	D3	Gold	normal	1.25
5092	79	D	4	D4	Gold	normal	1.25
5093	79	D	5	D5	Gold	normal	1.25
5094	79	D	6	D6	Gold	normal	1.25
5095	79	D	7	D7	Gold	normal	1.25
5096	79	D	8	D8	Gold	normal	1.25
5097	79	E	1	E1	Platinum Recliner	normal	1.60
5098	79	E	2	E2	Platinum Recliner	normal	1.60
5099	79	E	3	E3	Platinum Recliner	normal	1.60
5100	79	E	4	E4	Platinum Recliner	normal	1.60
5101	79	E	5	E5	Platinum Recliner	normal	1.60
5102	79	E	6	E6	Platinum Recliner	normal	1.60
5215	81	C	7	C7	Gold	normal	1.25
5103	79	E	7	E7	Platinum Recliner	normal	1.60
5104	79	E	8	E8	Platinum Recliner	normal	1.60
5105	79	F	1	F1	Platinum Recliner	normal	1.60
5106	79	F	2	F2	Platinum Recliner	normal	1.60
5107	79	F	3	F3	Platinum Recliner	normal	1.60
5108	79	F	4	F4	Platinum Recliner	normal	1.60
5109	79	F	5	F5	Platinum Recliner	normal	1.60
5110	79	F	6	F6	Platinum Recliner	normal	1.60
5111	79	F	7	F7	Platinum Recliner	normal	1.60
5112	79	F	8	F8	Platinum Recliner	normal	1.60
5113	80	A	1	A1	Silver	normal	1.00
5114	80	A	2	A2	Silver	normal	1.00
5115	80	A	3	A3	Silver	normal	1.00
5116	80	A	4	A4	Silver	normal	1.00
5117	80	A	5	A5	Silver	normal	1.00
5118	80	A	6	A6	Silver	normal	1.00
5119	80	A	7	A7	Silver	normal	1.00
5120	80	A	8	A8	Silver	normal	1.00
5121	80	A	9	A9	Silver	normal	1.00
5122	80	A	10	A10	Silver	normal	1.00
5123	80	A	11	A11	Silver	normal	1.00
5124	80	A	12	A12	Silver	normal	1.00
5125	80	B	1	B1	Silver	normal	1.00
5126	80	B	2	B2	Silver	normal	1.00
5127	80	B	3	B3	Silver	normal	1.00
5128	80	B	4	B4	Silver	normal	1.00
5129	80	B	5	B5	Silver	normal	1.00
5130	80	B	6	B6	Silver	normal	1.00
5131	80	B	7	B7	Silver	normal	1.00
5132	80	B	8	B8	Silver	normal	1.00
5133	80	B	9	B9	Silver	normal	1.00
5134	80	B	10	B10	Silver	normal	1.00
5135	80	B	11	B11	Silver	normal	1.00
5136	80	B	12	B12	Silver	normal	1.00
5137	80	C	1	C1	Gold	normal	1.25
5138	80	C	2	C2	Gold	normal	1.25
5139	80	C	3	C3	Gold	normal	1.25
5140	80	C	4	C4	Gold	normal	1.25
5141	80	C	5	C5	Gold	normal	1.25
5142	80	C	6	C6	Gold	normal	1.25
5143	80	C	7	C7	Gold	normal	1.25
5144	80	C	8	C8	Gold	normal	1.25
5145	80	C	9	C9	Gold	normal	1.25
5146	80	C	10	C10	Gold	normal	1.25
5147	80	C	11	C11	Gold	normal	1.25
5148	80	C	12	C12	Gold	normal	1.25
5149	80	D	1	D1	Gold	normal	1.25
5150	80	D	2	D2	Gold	normal	1.25
5151	80	D	3	D3	Gold	normal	1.25
5152	80	D	4	D4	Gold	normal	1.25
5153	80	D	5	D5	Gold	normal	1.25
5154	80	D	6	D6	Gold	normal	1.25
5155	80	D	7	D7	Gold	normal	1.25
5156	80	D	8	D8	Gold	normal	1.25
5157	80	D	9	D9	Gold	normal	1.25
5158	80	D	10	D10	Gold	normal	1.25
5159	80	D	11	D11	Gold	normal	1.25
5160	80	D	12	D12	Gold	normal	1.25
5161	80	E	1	E1	Platinum Recliner	normal	1.60
5162	80	E	2	E2	Platinum Recliner	normal	1.60
5163	80	E	3	E3	Platinum Recliner	normal	1.60
5164	80	E	4	E4	Platinum Recliner	normal	1.60
5165	80	E	5	E5	Platinum Recliner	normal	1.60
5166	80	E	6	E6	Platinum Recliner	normal	1.60
5167	80	E	7	E7	Platinum Recliner	normal	1.60
5168	80	E	8	E8	Platinum Recliner	normal	1.60
5169	80	E	9	E9	Platinum Recliner	normal	1.60
5170	80	E	10	E10	Platinum Recliner	normal	1.60
5171	80	E	11	E11	Platinum Recliner	normal	1.60
5172	80	E	12	E12	Platinum Recliner	normal	1.60
5173	80	F	1	F1	Platinum Recliner	normal	1.60
5174	80	F	2	F2	Platinum Recliner	normal	1.60
5175	80	F	3	F3	Platinum Recliner	normal	1.60
5176	80	F	4	F4	Platinum Recliner	normal	1.60
5177	80	F	5	F5	Platinum Recliner	normal	1.60
5178	80	F	6	F6	Platinum Recliner	normal	1.60
5179	80	F	7	F7	Platinum Recliner	normal	1.60
5180	80	F	8	F8	Platinum Recliner	normal	1.60
5181	80	F	9	F9	Platinum Recliner	normal	1.60
5182	80	F	10	F10	Platinum Recliner	normal	1.60
5183	80	F	11	F11	Platinum Recliner	normal	1.60
5184	80	F	12	F12	Platinum Recliner	normal	1.60
5185	81	A	1	A1	Silver	normal	1.00
5186	81	A	2	A2	Silver	normal	1.00
5187	81	A	3	A3	Silver	normal	1.00
5188	81	A	4	A4	Silver	normal	1.00
5189	81	A	5	A5	Silver	normal	1.00
5190	81	A	6	A6	Silver	normal	1.00
5191	81	A	7	A7	Silver	normal	1.00
5192	81	A	8	A8	Silver	normal	1.00
5193	81	A	9	A9	Silver	normal	1.00
5194	81	A	10	A10	Silver	normal	1.00
5195	81	A	11	A11	Silver	normal	1.00
5196	81	A	12	A12	Silver	normal	1.00
5197	81	B	1	B1	Silver	normal	1.00
5198	81	B	2	B2	Silver	normal	1.00
5199	81	B	3	B3	Silver	normal	1.00
5200	81	B	4	B4	Silver	normal	1.00
5201	81	B	5	B5	Silver	normal	1.00
5202	81	B	6	B6	Silver	normal	1.00
5203	81	B	7	B7	Silver	normal	1.00
5204	81	B	8	B8	Silver	normal	1.00
5205	81	B	9	B9	Silver	normal	1.00
5206	81	B	10	B10	Silver	normal	1.00
5207	81	B	11	B11	Silver	normal	1.00
5208	81	B	12	B12	Silver	normal	1.00
5209	81	C	1	C1	Gold	normal	1.25
5210	81	C	2	C2	Gold	normal	1.25
5211	81	C	3	C3	Gold	normal	1.25
5212	81	C	4	C4	Gold	normal	1.25
5213	81	C	5	C5	Gold	normal	1.25
5214	81	C	6	C6	Gold	normal	1.25
5216	81	C	8	C8	Gold	normal	1.25
5217	81	C	9	C9	Gold	normal	1.25
5218	81	C	10	C10	Gold	normal	1.25
5219	81	C	11	C11	Gold	normal	1.25
5220	81	C	12	C12	Gold	normal	1.25
5221	81	D	1	D1	Gold	normal	1.25
5222	81	D	2	D2	Gold	normal	1.25
5223	81	D	3	D3	Gold	normal	1.25
5224	81	D	4	D4	Gold	normal	1.25
5225	81	D	5	D5	Gold	normal	1.25
5226	81	D	6	D6	Gold	normal	1.25
5227	81	D	7	D7	Gold	normal	1.25
5228	81	D	8	D8	Gold	normal	1.25
5229	81	D	9	D9	Gold	normal	1.25
5230	81	D	10	D10	Gold	normal	1.25
5231	81	D	11	D11	Gold	normal	1.25
5232	81	D	12	D12	Gold	normal	1.25
5233	81	E	1	E1	Platinum Recliner	normal	1.60
5234	81	E	2	E2	Platinum Recliner	normal	1.60
5235	81	E	3	E3	Platinum Recliner	normal	1.60
5236	81	E	4	E4	Platinum Recliner	normal	1.60
5237	81	E	5	E5	Platinum Recliner	normal	1.60
5238	81	E	6	E6	Platinum Recliner	normal	1.60
5239	81	E	7	E7	Platinum Recliner	normal	1.60
5240	81	E	8	E8	Platinum Recliner	normal	1.60
5241	81	E	9	E9	Platinum Recliner	normal	1.60
5242	81	E	10	E10	Platinum Recliner	normal	1.60
5243	81	E	11	E11	Platinum Recliner	normal	1.60
5244	81	E	12	E12	Platinum Recliner	normal	1.60
5245	81	F	1	F1	Platinum Recliner	normal	1.60
5246	81	F	2	F2	Platinum Recliner	normal	1.60
5247	81	F	3	F3	Platinum Recliner	normal	1.60
5248	81	F	4	F4	Platinum Recliner	normal	1.60
5249	81	F	5	F5	Platinum Recliner	normal	1.60
5250	81	F	6	F6	Platinum Recliner	normal	1.60
5251	81	F	7	F7	Platinum Recliner	normal	1.60
5252	81	F	8	F8	Platinum Recliner	normal	1.60
5253	81	F	9	F9	Platinum Recliner	normal	1.60
5254	81	F	10	F10	Platinum Recliner	normal	1.60
5255	81	F	11	F11	Platinum Recliner	normal	1.60
5256	81	F	12	F12	Platinum Recliner	normal	1.60
5257	82	A	1	A1	Silver	normal	1.00
5258	82	A	2	A2	Silver	normal	1.00
5259	82	A	3	A3	Silver	normal	1.00
5260	82	A	4	A4	Silver	normal	1.00
5261	82	A	5	A5	Silver	normal	1.00
5262	82	A	6	A6	Silver	normal	1.00
5263	82	A	7	A7	Silver	normal	1.00
5264	82	A	8	A8	Silver	normal	1.00
5265	82	A	9	A9	Silver	normal	1.00
5266	82	A	10	A10	Silver	normal	1.00
5267	82	A	11	A11	Silver	normal	1.00
5268	82	A	12	A12	Silver	normal	1.00
5269	82	B	1	B1	Silver	normal	1.00
5270	82	B	2	B2	Silver	normal	1.00
5271	82	B	3	B3	Silver	normal	1.00
5272	82	B	4	B4	Silver	normal	1.00
5273	82	B	5	B5	Silver	normal	1.00
5274	82	B	6	B6	Silver	normal	1.00
5275	82	B	7	B7	Silver	normal	1.00
5276	82	B	8	B8	Silver	normal	1.00
5277	82	B	9	B9	Silver	normal	1.00
5278	82	B	10	B10	Silver	normal	1.00
5279	82	B	11	B11	Silver	normal	1.00
5280	82	B	12	B12	Silver	normal	1.00
5281	82	C	1	C1	Gold	normal	1.25
5282	82	C	2	C2	Gold	normal	1.25
5283	82	C	3	C3	Gold	normal	1.25
5284	82	C	4	C4	Gold	normal	1.25
5285	82	C	5	C5	Gold	normal	1.25
5286	82	C	6	C6	Gold	normal	1.25
5287	82	C	7	C7	Gold	normal	1.25
5288	82	C	8	C8	Gold	normal	1.25
5289	82	C	9	C9	Gold	normal	1.25
5290	82	C	10	C10	Gold	normal	1.25
5291	82	C	11	C11	Gold	normal	1.25
5292	82	C	12	C12	Gold	normal	1.25
5293	82	D	1	D1	Gold	normal	1.25
5294	82	D	2	D2	Gold	normal	1.25
5295	82	D	3	D3	Gold	normal	1.25
5296	82	D	4	D4	Gold	normal	1.25
5297	82	D	5	D5	Gold	normal	1.25
5298	82	D	6	D6	Gold	normal	1.25
5299	82	D	7	D7	Gold	normal	1.25
5300	82	D	8	D8	Gold	normal	1.25
5301	82	D	9	D9	Gold	normal	1.25
5302	82	D	10	D10	Gold	normal	1.25
5303	82	D	11	D11	Gold	normal	1.25
5304	82	D	12	D12	Gold	normal	1.25
5305	82	E	1	E1	Platinum Recliner	normal	1.60
5306	82	E	2	E2	Platinum Recliner	normal	1.60
5307	82	E	3	E3	Platinum Recliner	normal	1.60
5308	82	E	4	E4	Platinum Recliner	normal	1.60
5309	82	E	5	E5	Platinum Recliner	normal	1.60
5310	82	E	6	E6	Platinum Recliner	normal	1.60
5311	82	E	7	E7	Platinum Recliner	normal	1.60
5312	82	E	8	E8	Platinum Recliner	normal	1.60
5313	82	E	9	E9	Platinum Recliner	normal	1.60
5314	82	E	10	E10	Platinum Recliner	normal	1.60
5315	82	E	11	E11	Platinum Recliner	normal	1.60
5316	82	E	12	E12	Platinum Recliner	normal	1.60
5317	82	F	1	F1	Platinum Recliner	normal	1.60
5318	82	F	2	F2	Platinum Recliner	normal	1.60
5319	82	F	3	F3	Platinum Recliner	normal	1.60
5320	82	F	4	F4	Platinum Recliner	normal	1.60
5321	82	F	5	F5	Platinum Recliner	normal	1.60
5322	82	F	6	F6	Platinum Recliner	normal	1.60
5323	82	F	7	F7	Platinum Recliner	normal	1.60
5324	82	F	8	F8	Platinum Recliner	normal	1.60
5325	82	F	9	F9	Platinum Recliner	normal	1.60
5326	82	F	10	F10	Platinum Recliner	normal	1.60
5327	82	F	11	F11	Platinum Recliner	normal	1.60
5328	82	F	12	F12	Platinum Recliner	normal	1.60
5329	83	A	1	A1	Silver	normal	1.00
5330	83	A	2	A2	Silver	normal	1.00
5331	83	A	3	A3	Silver	normal	1.00
5332	83	A	4	A4	Silver	normal	1.00
5333	83	A	5	A5	Silver	normal	1.00
5334	83	A	6	A6	Silver	normal	1.00
5335	83	A	7	A7	Silver	normal	1.00
5336	83	A	8	A8	Silver	normal	1.00
5337	83	A	9	A9	Silver	normal	1.00
5338	83	A	10	A10	Silver	normal	1.00
5339	83	A	11	A11	Silver	normal	1.00
5340	83	A	12	A12	Silver	normal	1.00
5341	83	B	1	B1	Silver	normal	1.00
5342	83	B	2	B2	Silver	normal	1.00
5343	83	B	3	B3	Silver	normal	1.00
5344	83	B	4	B4	Silver	normal	1.00
5345	83	B	5	B5	Silver	normal	1.00
5346	83	B	6	B6	Silver	normal	1.00
5347	83	B	7	B7	Silver	normal	1.00
5348	83	B	8	B8	Silver	normal	1.00
5349	83	B	9	B9	Silver	normal	1.00
5350	83	B	10	B10	Silver	normal	1.00
5351	83	B	11	B11	Silver	normal	1.00
5352	83	B	12	B12	Silver	normal	1.00
5353	83	C	1	C1	Gold	normal	1.25
5354	83	C	2	C2	Gold	normal	1.25
5355	83	C	3	C3	Gold	normal	1.25
5356	83	C	4	C4	Gold	normal	1.25
5357	83	C	5	C5	Gold	normal	1.25
5358	83	C	6	C6	Gold	normal	1.25
5359	83	C	7	C7	Gold	normal	1.25
5360	83	C	8	C8	Gold	normal	1.25
5361	83	C	9	C9	Gold	normal	1.25
5362	83	C	10	C10	Gold	normal	1.25
5363	83	C	11	C11	Gold	normal	1.25
5364	83	C	12	C12	Gold	normal	1.25
5365	83	D	1	D1	Gold	normal	1.25
5366	83	D	2	D2	Gold	normal	1.25
5367	83	D	3	D3	Gold	normal	1.25
5368	83	D	4	D4	Gold	normal	1.25
5369	83	D	5	D5	Gold	normal	1.25
5370	83	D	6	D6	Gold	normal	1.25
5371	83	D	7	D7	Gold	normal	1.25
5372	83	D	8	D8	Gold	normal	1.25
5373	83	D	9	D9	Gold	normal	1.25
5374	83	D	10	D10	Gold	normal	1.25
5375	83	D	11	D11	Gold	normal	1.25
5376	83	D	12	D12	Gold	normal	1.25
5377	83	E	1	E1	Platinum Recliner	normal	1.60
5378	83	E	2	E2	Platinum Recliner	normal	1.60
5379	83	E	3	E3	Platinum Recliner	normal	1.60
5380	83	E	4	E4	Platinum Recliner	normal	1.60
5381	83	E	5	E5	Platinum Recliner	normal	1.60
5382	83	E	6	E6	Platinum Recliner	normal	1.60
5383	83	E	7	E7	Platinum Recliner	normal	1.60
5384	83	E	8	E8	Platinum Recliner	normal	1.60
5385	83	E	9	E9	Platinum Recliner	normal	1.60
5386	83	E	10	E10	Platinum Recliner	normal	1.60
5387	83	E	11	E11	Platinum Recliner	normal	1.60
5388	83	E	12	E12	Platinum Recliner	normal	1.60
5389	83	F	1	F1	Platinum Recliner	normal	1.60
5390	83	F	2	F2	Platinum Recliner	normal	1.60
5391	83	F	3	F3	Platinum Recliner	normal	1.60
5392	83	F	4	F4	Platinum Recliner	normal	1.60
5393	83	F	5	F5	Platinum Recliner	normal	1.60
5394	83	F	6	F6	Platinum Recliner	normal	1.60
5395	83	F	7	F7	Platinum Recliner	normal	1.60
5396	83	F	8	F8	Platinum Recliner	normal	1.60
5397	83	F	9	F9	Platinum Recliner	normal	1.60
5398	83	F	10	F10	Platinum Recliner	normal	1.60
5399	83	F	11	F11	Platinum Recliner	normal	1.60
5400	83	F	12	F12	Platinum Recliner	normal	1.60
5401	84	A	1	A1	Silver	normal	1.00
5402	84	A	2	A2	Silver	normal	1.00
5403	84	A	3	A3	Silver	normal	1.00
5404	84	A	4	A4	Silver	normal	1.00
5405	84	A	5	A5	Silver	normal	1.00
5406	84	A	6	A6	Silver	normal	1.00
5407	84	A	7	A7	Silver	normal	1.00
5408	84	A	8	A8	Silver	normal	1.00
5409	84	A	9	A9	Silver	normal	1.00
5410	84	A	10	A10	Silver	normal	1.00
5411	84	A	11	A11	Silver	normal	1.00
5412	84	A	12	A12	Silver	normal	1.00
5413	84	B	1	B1	Silver	normal	1.00
5414	84	B	2	B2	Silver	normal	1.00
5415	84	B	3	B3	Silver	normal	1.00
5416	84	B	4	B4	Silver	normal	1.00
5417	84	B	5	B5	Silver	normal	1.00
5418	84	B	6	B6	Silver	normal	1.00
5419	84	B	7	B7	Silver	normal	1.00
5420	84	B	8	B8	Silver	normal	1.00
5421	84	B	9	B9	Silver	normal	1.00
5422	84	B	10	B10	Silver	normal	1.00
5423	84	B	11	B11	Silver	normal	1.00
5424	84	B	12	B12	Silver	normal	1.00
5425	84	C	1	C1	Gold	normal	1.25
5426	84	C	2	C2	Gold	normal	1.25
5427	84	C	3	C3	Gold	normal	1.25
5428	84	C	4	C4	Gold	normal	1.25
5429	84	C	5	C5	Gold	normal	1.25
5430	84	C	6	C6	Gold	normal	1.25
5431	84	C	7	C7	Gold	normal	1.25
5432	84	C	8	C8	Gold	normal	1.25
5433	84	C	9	C9	Gold	normal	1.25
5434	84	C	10	C10	Gold	normal	1.25
5435	84	C	11	C11	Gold	normal	1.25
5436	84	C	12	C12	Gold	normal	1.25
5437	84	D	1	D1	Gold	normal	1.25
5438	84	D	2	D2	Gold	normal	1.25
5439	84	D	3	D3	Gold	normal	1.25
5440	84	D	4	D4	Gold	normal	1.25
5441	84	D	5	D5	Gold	normal	1.25
5442	84	D	6	D6	Gold	normal	1.25
5443	84	D	7	D7	Gold	normal	1.25
5444	84	D	8	D8	Gold	normal	1.25
5445	84	D	9	D9	Gold	normal	1.25
5446	84	D	10	D10	Gold	normal	1.25
5447	84	D	11	D11	Gold	normal	1.25
5448	84	D	12	D12	Gold	normal	1.25
5449	84	E	1	E1	Platinum Recliner	normal	1.60
5450	84	E	2	E2	Platinum Recliner	normal	1.60
5451	84	E	3	E3	Platinum Recliner	normal	1.60
5452	84	E	4	E4	Platinum Recliner	normal	1.60
5453	84	E	5	E5	Platinum Recliner	normal	1.60
5454	84	E	6	E6	Platinum Recliner	normal	1.60
5455	84	E	7	E7	Platinum Recliner	normal	1.60
5456	84	E	8	E8	Platinum Recliner	normal	1.60
5457	84	E	9	E9	Platinum Recliner	normal	1.60
5458	84	E	10	E10	Platinum Recliner	normal	1.60
5459	84	E	11	E11	Platinum Recliner	normal	1.60
5460	84	E	12	E12	Platinum Recliner	normal	1.60
5461	84	F	1	F1	Platinum Recliner	normal	1.60
5462	84	F	2	F2	Platinum Recliner	normal	1.60
5463	84	F	3	F3	Platinum Recliner	normal	1.60
5464	84	F	4	F4	Platinum Recliner	normal	1.60
5465	84	F	5	F5	Platinum Recliner	normal	1.60
5466	84	F	6	F6	Platinum Recliner	normal	1.60
5467	84	F	7	F7	Platinum Recliner	normal	1.60
5468	84	F	8	F8	Platinum Recliner	normal	1.60
5469	84	F	9	F9	Platinum Recliner	normal	1.60
5470	84	F	10	F10	Platinum Recliner	normal	1.60
5471	84	F	11	F11	Platinum Recliner	normal	1.60
5472	84	F	12	F12	Platinum Recliner	normal	1.60
5473	85	A	1	A1	Silver	normal	1.00
5474	85	A	2	A2	Silver	normal	1.00
5475	85	A	3	A3	Silver	normal	1.00
5476	85	A	4	A4	Silver	normal	1.00
5477	85	A	5	A5	Silver	normal	1.00
5478	85	A	6	A6	Silver	normal	1.00
5479	85	A	7	A7	Silver	normal	1.00
5480	85	A	8	A8	Silver	normal	1.00
5481	85	A	9	A9	Silver	normal	1.00
5482	85	A	10	A10	Silver	normal	1.00
5483	85	A	11	A11	Silver	normal	1.00
5484	85	A	12	A12	Silver	normal	1.00
5485	85	B	1	B1	Silver	normal	1.00
5486	85	B	2	B2	Silver	normal	1.00
5487	85	B	3	B3	Silver	normal	1.00
5488	85	B	4	B4	Silver	normal	1.00
5489	85	B	5	B5	Silver	normal	1.00
5490	85	B	6	B6	Silver	normal	1.00
5491	85	B	7	B7	Silver	normal	1.00
5492	85	B	8	B8	Silver	normal	1.00
5493	85	B	9	B9	Silver	normal	1.00
5494	85	B	10	B10	Silver	normal	1.00
5495	85	B	11	B11	Silver	normal	1.00
5496	85	B	12	B12	Silver	normal	1.00
5497	85	C	1	C1	Gold	normal	1.25
5498	85	C	2	C2	Gold	normal	1.25
5499	85	C	3	C3	Gold	normal	1.25
5500	85	C	4	C4	Gold	normal	1.25
5501	85	C	5	C5	Gold	normal	1.25
5502	85	C	6	C6	Gold	normal	1.25
5503	85	C	7	C7	Gold	normal	1.25
5504	85	C	8	C8	Gold	normal	1.25
5505	85	C	9	C9	Gold	normal	1.25
5506	85	C	10	C10	Gold	normal	1.25
5507	85	C	11	C11	Gold	normal	1.25
5508	85	C	12	C12	Gold	normal	1.25
5509	85	D	1	D1	Gold	normal	1.25
5510	85	D	2	D2	Gold	normal	1.25
5511	85	D	3	D3	Gold	normal	1.25
5512	85	D	4	D4	Gold	normal	1.25
5513	85	D	5	D5	Gold	normal	1.25
5514	85	D	6	D6	Gold	normal	1.25
5515	85	D	7	D7	Gold	normal	1.25
5516	85	D	8	D8	Gold	normal	1.25
5517	85	D	9	D9	Gold	normal	1.25
5518	85	D	10	D10	Gold	normal	1.25
5519	85	D	11	D11	Gold	normal	1.25
5520	85	D	12	D12	Gold	normal	1.25
5521	85	E	1	E1	Platinum Recliner	normal	1.60
5522	85	E	2	E2	Platinum Recliner	normal	1.60
5523	85	E	3	E3	Platinum Recliner	normal	1.60
5524	85	E	4	E4	Platinum Recliner	normal	1.60
5525	85	E	5	E5	Platinum Recliner	normal	1.60
5526	85	E	6	E6	Platinum Recliner	normal	1.60
5527	85	E	7	E7	Platinum Recliner	normal	1.60
5528	85	E	8	E8	Platinum Recliner	normal	1.60
5529	85	E	9	E9	Platinum Recliner	normal	1.60
5530	85	E	10	E10	Platinum Recliner	normal	1.60
5531	85	E	11	E11	Platinum Recliner	normal	1.60
5532	85	E	12	E12	Platinum Recliner	normal	1.60
5533	85	F	1	F1	Platinum Recliner	normal	1.60
5534	85	F	2	F2	Platinum Recliner	normal	1.60
5535	85	F	3	F3	Platinum Recliner	normal	1.60
5536	85	F	4	F4	Platinum Recliner	normal	1.60
5537	85	F	5	F5	Platinum Recliner	normal	1.60
5538	85	F	6	F6	Platinum Recliner	normal	1.60
5539	85	F	7	F7	Platinum Recliner	normal	1.60
5540	85	F	8	F8	Platinum Recliner	normal	1.60
5541	85	F	9	F9	Platinum Recliner	normal	1.60
5542	85	F	10	F10	Platinum Recliner	normal	1.60
5543	85	F	11	F11	Platinum Recliner	normal	1.60
5544	85	F	12	F12	Platinum Recliner	normal	1.60
5545	86	A	1	A1	Silver	normal	1.00
5546	86	A	2	A2	Silver	normal	1.00
5547	86	A	3	A3	Silver	normal	1.00
5548	86	A	4	A4	Silver	normal	1.00
5549	86	A	5	A5	Silver	normal	1.00
5550	86	A	6	A6	Silver	normal	1.00
5551	86	A	7	A7	Silver	normal	1.00
5552	86	A	8	A8	Silver	normal	1.00
5553	86	A	9	A9	Silver	normal	1.00
5554	86	A	10	A10	Silver	normal	1.00
5555	86	A	11	A11	Silver	normal	1.00
5556	86	A	12	A12	Silver	normal	1.00
5557	86	B	1	B1	Silver	normal	1.00
5558	86	B	2	B2	Silver	normal	1.00
5559	86	B	3	B3	Silver	normal	1.00
5560	86	B	4	B4	Silver	normal	1.00
5561	86	B	5	B5	Silver	normal	1.00
5562	86	B	6	B6	Silver	normal	1.00
5563	86	B	7	B7	Silver	normal	1.00
5564	86	B	8	B8	Silver	normal	1.00
5565	86	B	9	B9	Silver	normal	1.00
5566	86	B	10	B10	Silver	normal	1.00
5567	86	B	11	B11	Silver	normal	1.00
5568	86	B	12	B12	Silver	normal	1.00
5569	86	C	1	C1	Gold	normal	1.25
5570	86	C	2	C2	Gold	normal	1.25
5571	86	C	3	C3	Gold	normal	1.25
5572	86	C	4	C4	Gold	normal	1.25
5573	86	C	5	C5	Gold	normal	1.25
5574	86	C	6	C6	Gold	normal	1.25
5575	86	C	7	C7	Gold	normal	1.25
5576	86	C	8	C8	Gold	normal	1.25
5577	86	C	9	C9	Gold	normal	1.25
5578	86	C	10	C10	Gold	normal	1.25
5579	86	C	11	C11	Gold	normal	1.25
5580	86	C	12	C12	Gold	normal	1.25
5581	86	D	1	D1	Gold	normal	1.25
5582	86	D	2	D2	Gold	normal	1.25
5583	86	D	3	D3	Gold	normal	1.25
5584	86	D	4	D4	Gold	normal	1.25
5585	86	D	5	D5	Gold	normal	1.25
5586	86	D	6	D6	Gold	normal	1.25
5587	86	D	7	D7	Gold	normal	1.25
5588	86	D	8	D8	Gold	normal	1.25
5589	86	D	9	D9	Gold	normal	1.25
5590	86	D	10	D10	Gold	normal	1.25
5591	86	D	11	D11	Gold	normal	1.25
5592	86	D	12	D12	Gold	normal	1.25
5593	86	E	1	E1	Platinum Recliner	normal	1.60
5594	86	E	2	E2	Platinum Recliner	normal	1.60
5595	86	E	3	E3	Platinum Recliner	normal	1.60
5596	86	E	4	E4	Platinum Recliner	normal	1.60
5597	86	E	5	E5	Platinum Recliner	normal	1.60
5598	86	E	6	E6	Platinum Recliner	normal	1.60
5599	86	E	7	E7	Platinum Recliner	normal	1.60
5600	86	E	8	E8	Platinum Recliner	normal	1.60
5601	86	E	9	E9	Platinum Recliner	normal	1.60
5602	86	E	10	E10	Platinum Recliner	normal	1.60
5603	86	E	11	E11	Platinum Recliner	normal	1.60
5604	86	E	12	E12	Platinum Recliner	normal	1.60
5605	86	F	1	F1	Platinum Recliner	normal	1.60
5606	86	F	2	F2	Platinum Recliner	normal	1.60
5607	86	F	3	F3	Platinum Recliner	normal	1.60
5608	86	F	4	F4	Platinum Recliner	normal	1.60
5609	86	F	5	F5	Platinum Recliner	normal	1.60
5610	86	F	6	F6	Platinum Recliner	normal	1.60
5611	86	F	7	F7	Platinum Recliner	normal	1.60
5612	86	F	8	F8	Platinum Recliner	normal	1.60
5613	86	F	9	F9	Platinum Recliner	normal	1.60
5614	86	F	10	F10	Platinum Recliner	normal	1.60
5615	86	F	11	F11	Platinum Recliner	normal	1.60
5616	86	F	12	F12	Platinum Recliner	normal	1.60
5617	87	A	1	A1	Silver	normal	1.00
5618	87	A	2	A2	Silver	normal	1.00
5619	87	A	3	A3	Silver	normal	1.00
5620	87	A	4	A4	Silver	normal	1.00
5621	87	A	5	A5	Silver	normal	1.00
5622	87	A	6	A6	Silver	normal	1.00
5623	87	A	7	A7	Silver	normal	1.00
5624	87	A	8	A8	Silver	normal	1.00
5625	87	A	9	A9	Silver	normal	1.00
5626	87	A	10	A10	Silver	normal	1.00
5627	87	A	11	A11	Silver	normal	1.00
5628	87	A	12	A12	Silver	normal	1.00
5629	87	B	1	B1	Silver	normal	1.00
5630	87	B	2	B2	Silver	normal	1.00
5631	87	B	3	B3	Silver	normal	1.00
5632	87	B	4	B4	Silver	normal	1.00
5633	87	B	5	B5	Silver	normal	1.00
5634	87	B	6	B6	Silver	normal	1.00
5635	87	B	7	B7	Silver	normal	1.00
5636	87	B	8	B8	Silver	normal	1.00
5637	87	B	9	B9	Silver	normal	1.00
5638	87	B	10	B10	Silver	normal	1.00
5639	87	B	11	B11	Silver	normal	1.00
5640	87	B	12	B12	Silver	normal	1.00
5641	87	C	1	C1	Gold	normal	1.25
5642	87	C	2	C2	Gold	normal	1.25
5643	87	C	3	C3	Gold	normal	1.25
5644	87	C	4	C4	Gold	normal	1.25
5645	87	C	5	C5	Gold	normal	1.25
5646	87	C	6	C6	Gold	normal	1.25
5647	87	C	7	C7	Gold	normal	1.25
5648	87	C	8	C8	Gold	normal	1.25
5649	87	C	9	C9	Gold	normal	1.25
5650	87	C	10	C10	Gold	normal	1.25
5651	87	C	11	C11	Gold	normal	1.25
5652	87	C	12	C12	Gold	normal	1.25
5653	87	D	1	D1	Gold	normal	1.25
5654	87	D	2	D2	Gold	normal	1.25
5655	87	D	3	D3	Gold	normal	1.25
5656	87	D	4	D4	Gold	normal	1.25
5657	87	D	5	D5	Gold	normal	1.25
5658	87	D	6	D6	Gold	normal	1.25
5659	87	D	7	D7	Gold	normal	1.25
5660	87	D	8	D8	Gold	normal	1.25
5661	87	D	9	D9	Gold	normal	1.25
5662	87	D	10	D10	Gold	normal	1.25
5663	87	D	11	D11	Gold	normal	1.25
5664	87	D	12	D12	Gold	normal	1.25
5665	87	E	1	E1	Platinum Recliner	normal	1.60
5666	87	E	2	E2	Platinum Recliner	normal	1.60
5667	87	E	3	E3	Platinum Recliner	normal	1.60
5668	87	E	4	E4	Platinum Recliner	normal	1.60
5669	87	E	5	E5	Platinum Recliner	normal	1.60
5670	87	E	6	E6	Platinum Recliner	normal	1.60
5671	87	E	7	E7	Platinum Recliner	normal	1.60
5672	87	E	8	E8	Platinum Recliner	normal	1.60
5673	87	E	9	E9	Platinum Recliner	normal	1.60
5674	87	E	10	E10	Platinum Recliner	normal	1.60
5675	87	E	11	E11	Platinum Recliner	normal	1.60
5676	87	E	12	E12	Platinum Recliner	normal	1.60
5677	87	F	1	F1	Platinum Recliner	normal	1.60
5678	87	F	2	F2	Platinum Recliner	normal	1.60
5679	87	F	3	F3	Platinum Recliner	normal	1.60
5680	87	F	4	F4	Platinum Recliner	normal	1.60
5681	87	F	5	F5	Platinum Recliner	normal	1.60
5682	87	F	6	F6	Platinum Recliner	normal	1.60
5683	87	F	7	F7	Platinum Recliner	normal	1.60
5684	87	F	8	F8	Platinum Recliner	normal	1.60
5685	87	F	9	F9	Platinum Recliner	normal	1.60
5686	87	F	10	F10	Platinum Recliner	normal	1.60
5687	87	F	11	F11	Platinum Recliner	normal	1.60
5688	87	F	12	F12	Platinum Recliner	normal	1.60
\.


--
-- TOC entry 5228 (class 0 OID 16648)
-- Dependencies: 240
-- Data for Name: shows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shows (id, movie_id, screen_id, show_time, show_time_formatted, language, format, base_price, status, is_fast_filling, created_at) FROM stdin;
1	1	1	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
2	1	2	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
3	1	3	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
4	1	4	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
5	1	5	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
6	1	6	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
7	1	7	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
8	1	8	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
9	1	9	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
10	1	10	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
11	1	11	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
12	1	12	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
13	1	13	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
14	1	14	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
15	1	15	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
16	1	16	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
17	1	17	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
18	1	18	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
19	1	19	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
20	1	20	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
21	1	21	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
22	1	22	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
23	1	23	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
24	1	24	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
25	1	25	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
26	1	26	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
27	1	27	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
28	1	28	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
29	1	29	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
30	1	30	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
31	1	31	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
32	1	32	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
33	1	33	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
34	1	34	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
35	1	35	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
36	1	36	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
37	1	37	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
38	1	38	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
39	1	39	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
40	1	40	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
41	1	41	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
42	1	42	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
43	1	43	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
44	1	44	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
45	1	45	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
46	1	46	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
47	1	47	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
48	1	48	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
49	1	49	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
50	1	50	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
51	1	51	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
52	1	52	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
53	1	53	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
54	1	54	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
55	1	55	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
56	1	56	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
57	1	57	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
58	1	58	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
59	1	59	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
60	1	60	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
61	1	61	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
62	1	62	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
63	1	63	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
64	1	64	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
65	1	65	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
66	1	66	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
67	1	67	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
68	1	68	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
69	1	69	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
70	1	70	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
71	1	71	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
72	1	72	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
73	1	73	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
74	1	74	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
75	1	75	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
76	1	76	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
77	1	77	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
78	1	78	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
79	1	79	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
80	1	80	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
81	1	81	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
82	1	82	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
83	1	83	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
84	1	84	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
85	1	85	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
86	1	86	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
87	1	87	2026-10-01 19:50:24.477488+05:30	01:15 PM	English	IMAX 3D Laser	350.00	active	t	2026-10-01 17:50:24.477488+05:30
88	1	1	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
89	1	2	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
90	1	3	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
91	1	4	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
92	1	5	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
93	1	6	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
94	1	7	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
95	1	8	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
96	1	9	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
97	1	10	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
98	1	11	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
99	1	12	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
100	1	13	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
101	1	14	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
102	1	15	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
103	1	16	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
104	1	17	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
105	1	18	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
106	1	19	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
107	1	20	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
108	1	21	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
109	1	22	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
110	1	23	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
111	1	24	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
112	1	25	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
113	1	26	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
114	1	27	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
115	1	28	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
116	1	29	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
117	1	30	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
118	1	31	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
119	1	32	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
120	1	33	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
121	1	34	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
122	1	35	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
123	1	36	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
124	1	37	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
125	1	38	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
126	1	39	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
127	1	40	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
128	1	41	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
129	1	42	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
130	1	43	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
131	1	44	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
132	1	45	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
133	1	46	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
134	1	47	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
135	1	48	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
136	1	49	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
137	1	50	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
138	1	51	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
139	1	52	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
140	1	53	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
141	1	54	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
142	1	55	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
143	1	56	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
144	1	57	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
145	1	58	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
146	1	59	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
147	1	60	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
148	1	61	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
149	1	62	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
150	1	63	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
151	1	64	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
152	1	65	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
153	1	66	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
154	1	67	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
155	1	68	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
156	1	69	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
157	1	70	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
158	1	71	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
159	1	72	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
160	1	73	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
161	1	74	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
162	1	75	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
163	1	76	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
164	1	77	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
165	1	78	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
166	1	79	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
167	1	80	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
168	1	81	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
169	1	82	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
170	1	83	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
171	1	84	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
172	1	85	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
173	1	86	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
174	1	87	2026-10-01 22:50:24.482191+05:30	04:30 PM	English	Dolby Atmos 7.1	380.00	active	t	2026-10-01 17:50:24.482191+05:30
175	1	1	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
176	1	2	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
177	1	3	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
178	1	4	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
179	1	5	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
180	1	6	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
181	1	7	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
182	1	8	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
183	1	9	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
184	1	10	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
185	1	11	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
186	1	12	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
187	1	13	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
188	1	14	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
189	1	15	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
190	1	16	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
191	1	17	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
192	1	18	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
193	1	19	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
194	1	20	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
195	1	21	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
196	1	22	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
197	1	23	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
198	1	24	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
199	1	25	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
200	1	26	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
201	1	27	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
202	1	28	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
203	1	29	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
204	1	30	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
205	1	31	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
206	1	32	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
207	1	33	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
208	1	34	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
209	1	35	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
210	1	36	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
211	1	37	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
212	1	38	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
213	1	39	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
214	1	40	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
215	1	41	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
216	1	42	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
217	1	43	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
218	1	44	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
219	1	45	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
220	1	46	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
221	1	47	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
222	1	48	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
223	1	49	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
224	1	50	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
225	1	51	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
226	1	52	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
227	1	53	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
228	1	54	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
229	1	55	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
230	1	56	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
231	1	57	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
232	1	58	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
233	1	59	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
234	1	60	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
235	1	61	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
236	1	62	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
237	1	63	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
238	1	64	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
239	1	65	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
240	1	66	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
241	1	67	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
242	1	68	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
243	1	69	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
244	1	70	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
245	1	71	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
246	1	72	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
247	1	73	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
248	1	74	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
249	1	75	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
250	1	76	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
251	1	77	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
252	1	78	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
253	1	79	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
254	1	80	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
255	1	81	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
256	1	82	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
257	1	83	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
258	1	84	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
259	1	85	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
260	1	86	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
261	1	87	2026-10-02 01:50:24.484238+05:30	08:00 PM	English	VIP Recliner Luxe	420.00	active	t	2026-10-01 17:50:24.484238+05:30
262	2	1	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
263	2	2	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
264	2	3	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
265	2	4	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
266	2	5	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
267	2	6	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
268	2	7	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
269	2	8	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
270	2	9	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
271	2	10	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
272	2	11	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
273	2	12	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
274	2	13	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
275	2	14	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
276	2	15	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
277	2	16	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
278	2	17	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
279	2	18	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
280	2	19	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
281	2	20	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
282	2	21	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
283	2	22	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
284	2	23	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
285	2	24	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
286	2	25	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
287	2	26	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
288	2	27	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
289	2	28	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
290	2	29	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
291	2	30	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
292	2	31	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
293	2	32	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
294	2	33	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
295	2	34	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
296	2	35	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
297	2	36	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
298	2	37	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
299	2	38	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
300	2	39	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
301	2	40	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
302	2	41	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
303	2	42	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
304	2	43	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
305	2	44	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
306	2	45	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
307	2	46	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
308	2	47	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
309	2	48	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
310	2	49	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
311	2	50	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
312	2	51	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
313	2	52	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
314	2	53	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
315	2	54	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
316	2	55	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
317	2	56	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
318	2	57	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
319	2	58	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
320	2	59	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
321	2	60	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
322	2	61	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
323	2	62	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
324	2	63	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
325	2	64	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
326	2	65	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
327	2	66	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
328	2	67	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
329	2	68	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
330	2	69	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
331	2	70	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
332	2	71	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
333	2	72	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
334	2	73	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
335	2	74	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
336	2	75	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
337	2	76	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
338	2	77	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
339	2	78	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
340	2	79	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
341	2	80	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
342	2	81	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
343	2	82	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
344	2	83	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
345	2	84	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
346	2	85	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
347	2	86	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
348	2	87	2026-10-02 04:50:24.486144+05:30	10:45 PM	English	Dolby Atmos 7.1	350.00	active	f	2026-10-01 17:50:24.486144+05:30
\.


--
-- TOC entry 5222 (class 0 OID 16585)
-- Dependencies: 234
-- Data for Name: theaters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.theaters (id, theater_code, city_id, name, distance_info, landmark, address, formats, latitude, longitude, is_fast_filling, created_at) FROM stdin;
1	TH_001	1	PVR INOX Palladium	2.4 km away	High Street Phoenix	Senapati Bapat Marg, Lower Parel	IMAX Laser, Luxe	\N	\N	t	2026-10-01 11:44:52.733672+05:30
2	TH_002	1	Cinepolis Nexus Seawoods	5.1 km away	Seawoods Grand Central	Sector 40, Nerul, Navi Mumbai	4DX, VIP Atmos	\N	\N	f	2026-10-01 11:44:52.733672+05:30
3	TH_003	1	Maison PVR Living Room	3.6 km away	Jio World Drive	Bandra Kurla Complex (BKC)	Luxe Recliner, Dolby Vision	\N	\N	t	2026-10-01 11:44:52.733672+05:30
4	TH_004	1	Carnival Cinemas Broadway	1.2 km away	Linking Road Junction	Khar West	2D, 3D, Dolby 7.1	\N	\N	f	2026-10-01 11:44:52.733672+05:30
5	TH_005	1	PVR Oberoi Mall	6.0 km away	Western Express Highway	Goregaon East	IMAX 3D, P[XL]	\N	\N	t	2026-10-01 11:44:52.733672+05:30
6	TH_006	1	INOX R-City Mall	4.3 km away	Amrut Nagar Circle	LBS Marg, Ghatkopar West	Laser IMAX, Dolby Atmos	\N	\N	f	2026-10-01 11:44:52.733672+05:30
7	TH_007	2	PVR Superplex Forum South	2.8 km away	Konanakunte Cross	Kanakapura Main Road	IMAX Laser, 4DX, ICE	\N	\N	t	2026-10-01 11:44:52.733672+05:30
8	TH_008	2	Cinepolis Orion Mall	4.1 km away	Brigade Gateway	Dr. Rajkumar Road, Rajajinagar	Dolby Atmos, VIP Class	\N	\N	t	2026-10-01 11:44:52.733672+05:30
9	TH_009	2	INOX Nexus Koramangala	1.5 km away	Dairy Circle	Hosur Main Road, Koramangala	Dolby Atmos, 3D	\N	\N	f	2026-10-01 11:44:52.733672+05:30
10	TH_010	2	PVR Director Cut Nexus	5.3 km away	Sony World Signal	80 Feet Road, Koramangala 4th Block	Ultra Luxury, Recliner	\N	\N	f	2026-10-01 11:44:52.733672+05:30
11	TH_011	2	Urvashi Digital 4K Cinema	3.0 km away	Lalbagh Botanical Main Gate	Siddaiah Road, Sudhama Nagar	Laser 4K RGB, Dolby Atmos	\N	\N	t	2026-10-01 11:44:52.733672+05:30
12	TH_012	2	PVR Phoenix Marketcity	7.2 km away	ITPL Main Road	Mahadevapura, Whitefield	IMAX 3D, 4DX	\N	\N	t	2026-10-01 11:44:52.733672+05:30
13	TH_013	3	Sathyam Cinemas (SPI)	2.2 km away	Royapettah Flyover	8 Thiru Vi Ka Road, Royapettah	Dolby Atmos, RDX 4K	\N	\N	t	2026-10-01 11:44:52.733672+05:30
14	TH_014	3	PVR INOX Luxe Phoenix	4.8 km away	Velachery Road	142 Velachery Main Rd, Velachery	IMAX Laser, Luxe	\N	\N	t	2026-10-01 11:44:52.733672+05:30
15	TH_015	3	Palazzo Cinemas Nexus Vijaya	3.5 km away	Vadapalani Metro	100 Feet Road, Vadapalani	Dolby Atmos, VIP	\N	\N	f	2026-10-01 11:44:52.733672+05:30
16	TH_016	3	Escape Cinemas Express Avenue	1.7 km away	Royapettah Clock Tower	Whites Road, Royapettah	Blind Velvet 2D, Atmos	\N	\N	f	2026-10-01 11:44:52.733672+05:30
17	TH_017	3	PVR VR Mall EPIQ	6.1 km away	Anna Nagar Roundtana	Jawaharlal Nehru Road, Anna Nagar	EPIQ Premium Large, 4DX	\N	\N	t	2026-10-01 11:44:52.733672+05:30
18	TH_018	3	AGS Cinemas T Nagar	2.9 km away	Panagal Park	Gopathy Narayanaswamy Chetty Rd	4K Laser, Dolby Atmos	\N	\N	f	2026-10-01 11:44:52.733672+05:30
19	TH_019	4	Prasad Multiplex & Large Screen	1.9 km away	Hussain Sagar Lake	NTR Gardens, Khairatabad	Large Screen PCX, 4K 3D	\N	\N	t	2026-10-01 11:44:52.733672+05:30
20	TH_020	4	AMB Cinemas Gachibowli	5.4 km away	Kondapur Junction	Sarath City Capital Mall, Gachibowli	Dolby Atmos, VIP Lounge	\N	\N	t	2026-10-01 11:44:52.733672+05:30
21	TH_021	4	PVR Inorbit Mall Cyberabad	4.7 km away	Durgam Cheruvu View	Mindspace, HITEC City	IMAX Laser, 3D	\N	\N	f	2026-10-01 11:44:52.733672+05:30
22	TH_022	4	Cinepolis Lulu Mall Kukatpally	6.8 km away	JNTU Metro Station	NH 65, Kukatpally Housing Board	4DX, Macro XE	\N	\N	t	2026-10-01 11:44:52.733672+05:30
23	TH_023	4	INOX GVK One Mall	2.6 km away	Banjara Hills Rd No. 1	Balapur Basheerbagh Rd, Banjara Hills	Insignia 7.1, 4K	\N	\N	f	2026-10-01 11:44:52.733672+05:30
24	TH_024	5	PVR Phoenix Marketcity Viman Nagar	3.4 km away	Viman Nagar Flyover	Viman Nagar Main Road	IMAX 3D, 4DX	\N	\N	t	2026-10-01 11:44:52.733672+05:30
25	TH_025	5	Cinepolis Seasons Mall Magarpatta	4.9 km away	Magarpatta Cybercity	Hadapsar, Magarpatta Road	VIP Dolby Atmos, 3D	\N	\N	f	2026-10-01 11:44:52.733672+05:30
26	TH_026	5	INOX Bund Garden	1.6 km away	Pune Railway Station	Bund Garden Road, Camp	Laser 4K, Recliner	\N	\N	f	2026-10-01 11:44:52.733672+05:30
27	TH_027	5	PVR The Pavillion Mall	2.7 km away	University Circle	Senapati Bapat Road, Shivaji Nagar	P[XL], 4K Dolby Atmos	\N	\N	t	2026-10-01 11:44:52.733672+05:30
28	TH_028	5	Cinepolis Westend Mall Aundh	5.2 km away	D-Mart Aundh	Harmony Society, Ward No. 8, Aundh	RealD 3D, Dolby Atmos	\N	\N	f	2026-10-01 11:44:52.733672+05:30
29	TH_029	6	INOX South City Mall	2.9 km away	Prince Anwar Shah Road	Jadavpur, South City Complex	IMAX Laser, Insignia	\N	\N	t	2026-10-01 11:44:52.733672+05:30
30	TH_030	6	PVR Mani Square Mall	3.8 km away	Apollo Hospital EM Bypass	164/1 Maniktala Main Road	4DX, Dolby Atmos	\N	\N	f	2026-10-01 11:44:52.733672+05:30
31	TH_031	6	INOX Quest Mall	1.4 km away	Park Circus 7-Point	33 Syed Amir Ali Avenue, Ballygunge	Insignia Luxe, 4K	\N	\N	t	2026-10-01 11:44:52.733672+05:30
32	TH_032	6	Cinepolis Acropolis Mall	4.2 km away	Ruby Hospital Crossing	1858 Rajdanga Main Road, Kasba	3D, Dolby 7.1	\N	\N	f	2026-10-01 11:44:52.733672+05:30
33	TH_033	6	Navina Cinema Tollygunge	2.5 km away	Mahanayak Uttam Kumar Metro	85 Prince Anwar Shah Road	Dolby Atmos 4K Laser	\N	\N	t	2026-10-01 11:44:52.733672+05:30
34	TH_034	7	PVR Superplex Lulu Mall	3.1 km away	Edappally Metro Station	NH 544, Edappally	IMAX 3D, 4DX, Luxe	\N	\N	t	2026-10-01 11:44:52.733672+05:30
35	TH_035	7	Cinepolis Centre Square Mall	1.2 km away	Maharajas College Ground	MG Road, Shenoys, Ernakulam	RealD 3D, Dolby Atmos	\N	\N	f	2026-10-01 11:44:52.733672+05:30
36	TH_036	7	Shenoys Theatre	1.0 km away	Shenoys Junction	Mahatma Gandhi Rd, Shenoys	4K Dolby Atmos, RGB Laser	\N	\N	t	2026-10-01 11:44:52.733672+05:30
37	TH_037	7	PVR Forum Mall Maradu	5.6 km away	Kundannoor Junction	NH 66, Maradu, Ernakulam	P[XL], 4K Laser	\N	\N	t	2026-10-01 11:44:52.733672+05:30
38	TH_038	7	Kavitha Theatre	1.5 km away	Jos Junction	MG Road, Ernakulam South	Dolby 7.1, 2D	\N	\N	f	2026-10-01 11:44:52.733672+05:30
\.


--
-- TOC entry 5220 (class 0 OID 16560)
-- Dependencies: 232
-- Data for Name: trailers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trailers (id, trailer_code, movie_id, title, subtitle, image_url, video_url, duration, tag_label, display_order, is_active, created_at) FROM stdin;
1	TRL_001	\N	Spider-Man: Into the Spider-Verse	Official Trailer	https://img.youtube.com/vi/tg52up16eq0/maxresdefault.jpg	https://www.youtube.com/watch?v=tg52up16eq0	02:40	Trailer	1	t	2026-10-01 15:57:06.216866+05:30
2	TRL_002	\N	Day Drinker	Official Trailer	https://img.youtube.com/vi/bhKKR5He_Fo/maxresdefault.jpg	https://www.youtube.com/watch?v=bhKKR5He_Fo	02:15	Trailer	2	t	2026-10-01 15:57:06.216866+05:30
3	TRL_003	\N	Fall 2	Official Teaser	https://img.youtube.com/vi/Rsztt5qDj_A/maxresdefault.jpg	https://www.youtube.com/watch?v=Rsztt5qDj_A	01:45	Teaser	3	t	2026-10-01 15:57:06.216866+05:30
\.


--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 229
-- Name: banners_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.banners_id_seq', 6, true);


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 245
-- Name: booking_seats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.booking_seats_id_seq', 16, true);


--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 243
-- Name: bookings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bookings_id_seq', 6, true);


--
-- TOC entry 5257 (class 0 OID 0)
-- Dependencies: 225
-- Name: cities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cities_id_seq', 8, false);


--
-- TOC entry 5258 (class 0 OID 0)
-- Dependencies: 227
-- Name: movies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.movies_id_seq', 31, true);


--
-- TOC entry 5259 (class 0 OID 0)
-- Dependencies: 223
-- Name: password_reset_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.password_reset_tokens_id_seq', 3, true);


--
-- TOC entry 5260 (class 0 OID 0)
-- Dependencies: 221
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.refresh_tokens_id_seq', 56, true);


--
-- TOC entry 5261 (class 0 OID 0)
-- Dependencies: 235
-- Name: screens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.screens_id_seq', 87, true);


--
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 241
-- Name: seat_locks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seat_locks_id_seq', 16, true);


--
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 237
-- Name: seats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seats_id_seq', 5688, true);


--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 239
-- Name: shows_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shows_id_seq', 348, true);


--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 233
-- Name: theaters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.theaters_id_seq', 39, false);


--
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 231
-- Name: trailers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.trailers_id_seq', 3, true);


--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 25, true);


--
-- TOC entry 5009 (class 2606 OID 16553)
-- Name: banners banners_banner_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.banners
    ADD CONSTRAINT banners_banner_code_key UNIQUE (banner_code);


--
-- TOC entry 5011 (class 2606 OID 16551)
-- Name: banners banners_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.banners
    ADD CONSTRAINT banners_pkey PRIMARY KEY (id);


--
-- TOC entry 5043 (class 2606 OID 16750)
-- Name: booking_seats booking_seats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_seats
    ADD CONSTRAINT booking_seats_pkey PRIMARY KEY (id);


--
-- TOC entry 5037 (class 2606 OID 16727)
-- Name: bookings bookings_booking_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_booking_code_key UNIQUE (booking_code);


--
-- TOC entry 5039 (class 2606 OID 16725)
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- TOC entry 4997 (class 2606 OID 16503)
-- Name: cities cities_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_name_key UNIQUE (name);


--
-- TOC entry 4999 (class 2606 OID 16501)
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- TOC entry 4981 (class 2606 OID 16490)
-- Name: login_auth login_auth_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_auth
    ADD CONSTRAINT login_auth_phone_key UNIQUE (phone);


--
-- TOC entry 5003 (class 2606 OID 16532)
-- Name: movies movies_movie_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT movies_movie_code_key UNIQUE (movie_code);


--
-- TOC entry 5005 (class 2606 OID 16530)
-- Name: movies movies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT movies_pkey PRIMARY KEY (id);


--
-- TOC entry 5007 (class 2606 OID 16534)
-- Name: movies movies_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT movies_slug_key UNIQUE (slug);


--
-- TOC entry 4993 (class 2606 OID 16467)
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4995 (class 2606 OID 16469)
-- Name: password_reset_tokens password_reset_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_token_hash_key UNIQUE (token_hash);


--
-- TOC entry 4988 (class 2606 OID 16445)
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4990 (class 2606 OID 16447)
-- Name: refresh_tokens refresh_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_hash_key UNIQUE (token_hash);


--
-- TOC entry 5022 (class 2606 OID 16619)
-- Name: screens screens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.screens
    ADD CONSTRAINT screens_pkey PRIMARY KEY (id);


--
-- TOC entry 5033 (class 2606 OID 16687)
-- Name: seat_locks seat_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seat_locks
    ADD CONSTRAINT seat_locks_pkey PRIMARY KEY (id);


--
-- TOC entry 5035 (class 2606 OID 16689)
-- Name: seat_locks seat_locks_show_id_seat_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seat_locks
    ADD CONSTRAINT seat_locks_show_id_seat_id_key UNIQUE (show_id, seat_id);


--
-- TOC entry 5024 (class 2606 OID 16639)
-- Name: seats seats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seats
    ADD CONSTRAINT seats_pkey PRIMARY KEY (id);


--
-- TOC entry 5026 (class 2606 OID 16641)
-- Name: seats seats_screen_id_row_label_seat_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seats
    ADD CONSTRAINT seats_screen_id_row_label_seat_number_key UNIQUE (screen_id, row_label, seat_number);


--
-- TOC entry 5030 (class 2606 OID 16664)
-- Name: shows shows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shows
    ADD CONSTRAINT shows_pkey PRIMARY KEY (id);


--
-- TOC entry 5018 (class 2606 OID 16600)
-- Name: theaters theaters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theaters
    ADD CONSTRAINT theaters_pkey PRIMARY KEY (id);


--
-- TOC entry 5020 (class 2606 OID 16602)
-- Name: theaters theaters_theater_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theaters
    ADD CONSTRAINT theaters_theater_code_key UNIQUE (theater_code);


--
-- TOC entry 5013 (class 2606 OID 16576)
-- Name: trailers trailers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trailers
    ADD CONSTRAINT trailers_pkey PRIMARY KEY (id);


--
-- TOC entry 5015 (class 2606 OID 16578)
-- Name: trailers trailers_trailer_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trailers
    ADD CONSTRAINT trailers_trailer_code_key UNIQUE (trailer_code);


--
-- TOC entry 4983 (class 2606 OID 16430)
-- Name: login_auth users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_auth
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4985 (class 2606 OID 16428)
-- Name: login_auth users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_auth
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5040 (class 1259 OID 16768)
-- Name: idx_bookings_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bookings_code ON public.bookings USING btree (booking_code);


--
-- TOC entry 5041 (class 1259 OID 16767)
-- Name: idx_bookings_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bookings_user_id ON public.bookings USING btree (user_id);


--
-- TOC entry 5000 (class 1259 OID 16762)
-- Name: idx_movies_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_movies_slug ON public.movies USING btree (slug);


--
-- TOC entry 5001 (class 1259 OID 16761)
-- Name: idx_movies_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_movies_status ON public.movies USING btree (status);


--
-- TOC entry 4991 (class 1259 OID 16476)
-- Name: idx_password_reset_tokens_token_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_password_reset_tokens_token_hash ON public.password_reset_tokens USING btree (token_hash);


--
-- TOC entry 4986 (class 1259 OID 16475)
-- Name: idx_refresh_tokens_token_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_tokens_token_hash ON public.refresh_tokens USING btree (token_hash);


--
-- TOC entry 5031 (class 1259 OID 16766)
-- Name: idx_seat_locks_expiry; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_seat_locks_expiry ON public.seat_locks USING btree (expires_at);


--
-- TOC entry 5027 (class 1259 OID 16763)
-- Name: idx_shows_movie_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shows_movie_id ON public.shows USING btree (movie_id);


--
-- TOC entry 5028 (class 1259 OID 16764)
-- Name: idx_shows_screen_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shows_screen_id ON public.shows USING btree (screen_id);


--
-- TOC entry 5016 (class 1259 OID 16765)
-- Name: idx_theaters_city_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_theaters_city_id ON public.theaters USING btree (city_id);


--
-- TOC entry 5046 (class 2606 OID 16554)
-- Name: banners banners_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.banners
    ADD CONSTRAINT banners_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movies(id) ON DELETE SET NULL;


--
-- TOC entry 5058 (class 2606 OID 16751)
-- Name: booking_seats booking_seats_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_seats
    ADD CONSTRAINT booking_seats_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- TOC entry 5059 (class 2606 OID 16756)
-- Name: booking_seats booking_seats_seat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_seats
    ADD CONSTRAINT booking_seats_seat_id_fkey FOREIGN KEY (seat_id) REFERENCES public.seats(id) ON DELETE CASCADE;


--
-- TOC entry 5056 (class 2606 OID 16733)
-- Name: bookings bookings_show_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_show_id_fkey FOREIGN KEY (show_id) REFERENCES public.shows(id) ON DELETE CASCADE;


--
-- TOC entry 5057 (class 2606 OID 16728)
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.login_auth(id) ON DELETE CASCADE;


--
-- TOC entry 5045 (class 2606 OID 16470)
-- Name: password_reset_tokens password_reset_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.login_auth(id) ON DELETE CASCADE;


--
-- TOC entry 5044 (class 2606 OID 16448)
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.login_auth(id) ON DELETE CASCADE;


--
-- TOC entry 5049 (class 2606 OID 16620)
-- Name: screens screens_theater_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.screens
    ADD CONSTRAINT screens_theater_id_fkey FOREIGN KEY (theater_id) REFERENCES public.theaters(id) ON DELETE CASCADE;


--
-- TOC entry 5053 (class 2606 OID 16695)
-- Name: seat_locks seat_locks_seat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seat_locks
    ADD CONSTRAINT seat_locks_seat_id_fkey FOREIGN KEY (seat_id) REFERENCES public.seats(id) ON DELETE CASCADE;


--
-- TOC entry 5054 (class 2606 OID 16690)
-- Name: seat_locks seat_locks_show_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seat_locks
    ADD CONSTRAINT seat_locks_show_id_fkey FOREIGN KEY (show_id) REFERENCES public.shows(id) ON DELETE CASCADE;


--
-- TOC entry 5055 (class 2606 OID 16700)
-- Name: seat_locks seat_locks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seat_locks
    ADD CONSTRAINT seat_locks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.login_auth(id) ON DELETE CASCADE;


--
-- TOC entry 5050 (class 2606 OID 16642)
-- Name: seats seats_screen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seats
    ADD CONSTRAINT seats_screen_id_fkey FOREIGN KEY (screen_id) REFERENCES public.screens(id) ON DELETE CASCADE;


--
-- TOC entry 5051 (class 2606 OID 16665)
-- Name: shows shows_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shows
    ADD CONSTRAINT shows_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movies(id) ON DELETE CASCADE;


--
-- TOC entry 5052 (class 2606 OID 16670)
-- Name: shows shows_screen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shows
    ADD CONSTRAINT shows_screen_id_fkey FOREIGN KEY (screen_id) REFERENCES public.screens(id) ON DELETE CASCADE;


--
-- TOC entry 5048 (class 2606 OID 16603)
-- Name: theaters theaters_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theaters
    ADD CONSTRAINT theaters_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(id) ON DELETE CASCADE;


--
-- TOC entry 5047 (class 2606 OID 16579)
-- Name: trailers trailers_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trailers
    ADD CONSTRAINT trailers_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movies(id) ON DELETE SET NULL;


-- Completed on 2026-10-03 10:24:10

--
-- PostgreSQL database dump complete
--

\unrestrict hATSpFsTt2l6v4Yqrobroc5OFGUmbEHhrj0yAlMV8nWnamQL8Nm8lyCF5sBshq9

