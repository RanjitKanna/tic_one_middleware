-- ==============================================================================
-- SEED DATA FOR MOVIE BOOKING APP
-- ==============================================================================

-- 1. Cities
INSERT INTO public.cities (id, name, is_popular) VALUES
(1, 'Mumbai', true),
(2, 'Bengaluru', true),
(3, 'Chennai', true),
(4, 'Hyderabad', true),
(5, 'Pune', true),
(6, 'Kolkata', true),
(7, 'Kochi', true)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, is_popular = EXCLUDED.is_popular;

-- 2. Movies
INSERT INTO public.movies (
    movie_code, slug, title, subtitle, synopsis, genre, language, duration_mins,
    certificate, rating, rating_count, image_url, banner_url, status, release_date,
    format, badge_text, match_percent, is_trending, is_filling_fast, is_advance_booking_open
) VALUES
(
    'MOV_CYBER_2026',
    'cyberpunk-odyssey-2026',
    'CYBERPUNK: ODYSSEY',
    'Sci-Fi • 2h 48m • Rated R • Directed by Denis Villeneuve',
    'In a neo-futuristic metropolis, an augmented detective uncovers a conspiracy that threatens the fragile boundary between synthetic intelligence and human consciousness.',
    'Sci-Fi / Action',
    'English',
    168,
    'Rated R',
    9.6,
    '120K',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBGkHApAjlxaiOuTN0L4bMbZVg_UsXzeviYQSoOQgaIUYb5TOB4lX2CNK9mPiu6KPQmBFqoXOQvvZc2Sj7vMs1o6nSJY-LD1fH1DIw4imYRlbpiQtm7azLTOTyrygTD0PfkxMTP27YBFdN02GDKT9wdcbhzmeg-OiHrMhwhO0iw8exlZUWXmIxE6DNFSF8HmSuqyAOJmuDXROIaweU54gav7VX5ZvzYozD4ZD36tf8kF0fP8LFpcbY',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBGkHApAjlxaiOuTN0L4bMbZVg_UsXzeviYQSoOQgaIUYb5TOB4lX2CNK9mPiu6KPQmBFqoXOQvvZc2Sj7vMs1o6nSJY-LD1fH1DIw4imYRlbpiQtm7azLTOTyrygTD0PfkxMTP27YBFdN02GDKT9wdcbhzmeg-OiHrMhwhO0iw8exlZUWXmIxE6DNFSF8HmSuqyAOJmuDXROIaweU54gav7VX5ZvzYozD4ZD36tf8kF0fP8LFpcbY',
    'now_showing',
    '2026-09-15',
    'IMAX 70MM',
    'Trending #1',
    '99% Match',
    true,
    true,
    false
),
(
    'MOV_DUNE3_2026',
    'dune-part-three-2026',
    'DUNE: PART THREE',
    'Sci-Fi • 3h 02m • Rated PG-13 • Directed by Denis Villeneuve',
    'Paul Atreides confronts the galactic jihad unleashed across the cosmos as prophecy and reality clash on Arrakis.',
    'Sci-Fi / Adventure',
    'English',
    182,
    'PG-13',
    9.4,
    '85K',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBaHX4H0QA72R5wqiDSV2k_Po7b6V4Cz_PAtIHJ0F4tmsaC7UWP2MIYIGRr2tyRWXs4eJ9fnk46Jh__VV7d3d7lal-FHCK0KBo8WDG2qApnAcCfNKeOsll80uAoP2Gmh50eAzy19rlgJkMnhXcri3CRUe3u6kJNFcrSMlqp6TyknjKd27o-2Q-C2_DAi6cW6SRfFUmPGrcqoWossWEDoU3EXy-nmqzqdwHgfBqlHf6UQDWab0ALpsk',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBaHX4H0QA72R5wqiDSV2k_Po7b6V4Cz_PAtIHJ0F4tmsaC7UWP2MIYIGRr2tyRWXs4eJ9fnk46Jh__VV7d3d7lal-FHCK0KBo8WDG2qApnAcCfNKeOsll80uAoP2Gmh50eAzy19rlgJkMnhXcri3CRUe3u6kJNFcrSMlqp6TyknjKd27o-2Q-C2_DAi6cW6SRfFUmPGrcqoWossWEDoU3EXy-nmqzqdwHgfBqlHf6UQDWab0ALpsk',
    'now_showing',
    '2026-09-20',
    'DOLBY ATMOS',
    'Critically Acclaimed',
    '96% Match',
    true,
    false,
    false
),
(
    'MOV_SINGULARITY_2026',
    'singularity-horizon',
    'Singularity Horizon',
    'Action / Sci-Fi • 2h 15m • Rated UA16+',
    'An elite deep-space salvage crew discovers a derelict vessel trapped at the edge of an artificial event horizon.',
    'Action / Sci-Fi',
    'English',
    135,
    'UA16+',
    9.2,
    '45K',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBGkHApAjlxaiOuTN0L4bMbZVg_UsXzeviYQSoOQgaIUYb5TOB4lX2CNK9mPiu6KPQmBFqoXOQvvZc2Sj7vMs1o6nSJY-LD1fH1DIw4imYRlbpiQtm7azLTOTyrygTD0PfkxMTP27YBFdN02GDKT9wdcbhzmeg-OiHrMhwhO0iw8exlZUWXmIxE6DNFSF8HmSuqyAOJmuDXROIaweU54gav7VX5ZvzYozD4ZD36tf8kF0fP8LFpcbY',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBGkHApAjlxaiOuTN0L4bMbZVg_UsXzeviYQSoOQgaIUYb5TOB4lX2CNK9mPiu6KPQmBFqoXOQvvZc2Sj7vMs1o6nSJY-LD1fH1DIw4imYRlbpiQtm7azLTOTyrygTD0PfkxMTP27YBFdN02GDKT9wdcbhzmeg-OiHrMhwhO0iw8exlZUWXmIxE6DNFSF8HmSuqyAOJmuDXROIaweU54gav7VX5ZvzYozD4ZD36tf8kF0fP8LFpcbY',
    'now_showing',
    '2026-09-28',
    'IMAX 3D',
    'Filling Fast',
    '98% Match',
    false,
    true,
    false
),
(
    'MOV_SHADOWS_PRAGUE_2026',
    'shadows-of-prague',
    'Shadows of Prague',
    'Mystery / Thriller • 2h 05m • Rated A',
    'A noir mystery tracing international espionage across the foggy cobblestone bridges of historic Prague.',
    'Mystery / Thriller',
    'English',
    125,
    'A',
    8.8,
    '28K',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDCQd5U6h8dK_J_sA4iWf8Hl4q64a8vQj_FkM8kPqS0j7oK-XgNqV12N8-L9e-K3pW4sF5t7u6vY8rZ_9xW12019-3829104-9218204-9812401',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDCQd5U6h8dK_J_sA4iWf8Hl4q64a8vQj_FkM8kPqS0j7oK-XgNqV12N8-L9e-K3pW4sF5t7u6vY8rZ_9xW12019-3829104-9218204-9812401',
    'now_showing',
    '2026-09-25',
    'Dolby Vision',
    'Dolby Vision',
    '92% Match',
    false,
    false,
    false
),
(
    'MOV_AVATAR3_2026',
    'avatar-fire-and-ash',
    'AVATAR: FIRE & ASH',
    'Sci-Fi • Adventure • Directed by James Cameron',
    'Jake Sully and Neytiri travel to unexplored volcanic domains of Pandora, meeting the fiery Ash People tribe.',
    'Sci-Fi • Adventure',
    'English',
    195,
    'UA16+',
    9.8,
    '500K',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBGkHApAjlxaiOuTN0L4bMbZVg_UsXzeviYQSoOQgaIUYb5TOB4lX2CNK9mPiu6KPQmBFqoXOQvvZc2Sj7vMs1o6nSJY-LD1fH1DIw4imYRlbpiQtm7azLTOTyrygTD0PfkxMTP27YBFdN02GDKT9wdcbhzmeg-OiHrMhwhO0iw8exlZUWXmIxE6DNFSF8HmSuqyAOJmuDXROIaweU54gav7VX5ZvzYozD4ZD36tf8kF0fP8LFpcbY',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBGkHApAjlxaiOuTN0L4bMbZVg_UsXzeviYQSoOQgaIUYb5TOB4lX2CNK9mPiu6KPQmBFqoXOQvvZc2Sj7vMs1o6nSJY-LD1fH1DIw4imYRlbpiQtm7azLTOTyrygTD0PfkxMTP27YBFdN02GDKT9wdcbhzmeg-OiHrMhwhO0iw8exlZUWXmIxE6DNFSF8HmSuqyAOJmuDXROIaweU54gav7VX5ZvzYozD4ZD36tf8kF0fP8LFpcbY',
    'upcoming',
    '2026-12-19',
    'IMAX 3D Laser',
    'Advance Open',
    '99% Anticipation',
    true,
    false,
    true
)
ON CONFLICT (movie_code) DO NOTHING;

-- 3. Banners
INSERT INTO public.banners (
    banner_code, movie_id, slug, title, subtitle, image_url, rating, rating_count, format, is_trending, display_order
) VALUES
(
    'BAN_001',
    (SELECT id FROM public.movies WHERE movie_code = 'MOV_CYBER_2026'),
    'cyberpunk-odyssey-2026',
    'CYBERPUNK: ODYSSEY',
    'Sci-Fi • 2h 48m • Rated R • Directed by Denis Villeneuve',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBGkHApAjlxaiOuTN0L4bMbZVg_UsXzeviYQSoOQgaIUYb5TOB4lX2CNK9mPiu6KPQmBFqoXOQvvZc2Sj7vMs1o6nSJY-LD1fH1DIw4imYRlbpiQtm7azLTOTyrygTD0PfkxMTP27YBFdN02GDKT9wdcbhzmeg-OiHrMhwhO0iw8exlZUWXmIxE6DNFSF8HmSuqyAOJmuDXROIaweU54gav7VX5ZvzYozD4ZD36tf8kF0fP8LFpcbY',
    9.6,
    '120K',
    'IMAX 70MM',
    true,
    1
),
(
    'BAN_002',
    (SELECT id FROM public.movies WHERE movie_code = 'MOV_DUNE3_2026'),
    'dune-part-three-2026',
    'DUNE: PART THREE',
    'Sci-Fi • 3h 02m • Rated PG-13 • Directed by Denis Villeneuve',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBaHX4H0QA72R5wqiDSV2k_Po7b6V4Cz_PAtIHJ0F4tmsaC7UWP2MIYIGRr2tyRWXs4eJ9fnk46Jh__VV7d3d7lal-FHCK0KBo8WDG2qApnAcCfNKeOsll80uAoP2Gmh50eAzy19rlgJkMnhXcri3CRUe3u6kJNFcrSMlqp6TyknjKd27o-2Q-C2_DAi6cW6SRfFUmPGrcqoWossWEDoU3EXy-nmqzqdwHgfBqlHf6UQDWab0ALpsk',
    9.4,
    '85K',
    'DOLBY ATMOS',
    true,
    2
)
ON CONFLICT (banner_code) DO NOTHING;

-- 4. Trailers
INSERT INTO public.trailers (
    trailer_code, movie_id, title, subtitle, image_url, video_url, duration, tag_label, display_order
) VALUES
(
    'TRL_001',
    NULL,
    'Spider-Man: Into the Spider-Verse',
    'Official Trailer',
    'https://img.youtube.com/vi/tg52up16eq0/maxresdefault.jpg',
    'https://www.youtube.com/watch?v=tg52up16eq0',
    '02:40',
    'Trailer',
    1
),
(
    'TRL_002',
    NULL,
    'Day Drinker',
    'Official Trailer',
    'https://img.youtube.com/vi/bhKKR5He_Fo/maxresdefault.jpg',
    'https://www.youtube.com/watch?v=bhKKR5He_Fo',
    '02:15',
    'Trailer',
    2
),
(
    'TRL_003',
    NULL,
    'Fall 2',
    'Official Teaser',
    'https://img.youtube.com/vi/Rsztt5qDj_A/maxresdefault.jpg',
    'https://www.youtube.com/watch?v=Rsztt5qDj_A',
    '01:45',
    'Teaser',
    3
)
ON CONFLICT (trailer_code) DO NOTHING;

-- 5. Theaters
INSERT INTO public.theaters (
  id, theater_code, city_id, name, distance_info, landmark, address, formats, latitude, longitude, is_fast_filling, created_at
) VALUES
-- ============================================================
-- CITY 1: Mumbai
-- ============================================================
(1, 'TH_001', 1, 'PVR INOX Palladium', '2.4 km away', 'High Street Phoenix', 'Senapati Bapat Marg, Lower Parel', 'IMAX Laser, Luxe', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(2, 'TH_002', 1, 'Cinepolis Nexus Seawoods', '5.1 km away', 'Seawoods Grand Central', 'Sector 40, Nerul, Navi Mumbai', '4DX, VIP Atmos', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),
(3, 'TH_003', 1, 'Maison PVR Living Room', '3.6 km away', 'Jio World Drive', 'Bandra Kurla Complex (BKC)', 'Luxe Recliner, Dolby Vision', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(4, 'TH_004', 1, 'Carnival Cinemas Broadway', '1.2 km away', 'Linking Road Junction', 'Khar West', '2D, 3D, Dolby 7.1', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),
(5, 'TH_005', 1, 'PVR Oberoi Mall', '6.0 km away', 'Western Express Highway', 'Goregaon East', 'IMAX 3D, P[XL]', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(6, 'TH_006', 1, 'INOX R-City Mall', '4.3 km away', 'Amrut Nagar Circle', 'LBS Marg, Ghatkopar West', 'Laser IMAX, Dolby Atmos', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),

-- ============================================================
-- CITY 2: Bengaluru
-- ============================================================
(7, 'TH_007', 2, 'PVR Superplex Forum South', '2.8 km away', 'Konanakunte Cross', 'Kanakapura Main Road', 'IMAX Laser, 4DX, ICE', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(8, 'TH_008', 2, 'Cinepolis Orion Mall', '4.1 km away', 'Brigade Gateway', 'Dr. Rajkumar Road, Rajajinagar', 'Dolby Atmos, VIP Class', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(9, 'TH_009', 2, 'INOX Nexus Koramangala', '1.5 km away', 'Dairy Circle', 'Hosur Main Road, Koramangala', 'Dolby Atmos, 3D', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),
(10, 'TH_010', 2, 'PVR Director Cut Nexus', '5.3 km away', 'Sony World Signal', '80 Feet Road, Koramangala 4th Block', 'Ultra Luxury, Recliner', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),
(11, 'TH_011', 2, 'Urvashi Digital 4K Cinema', '3.0 km away', 'Lalbagh Botanical Main Gate', 'Siddaiah Road, Sudhama Nagar', 'Laser 4K RGB, Dolby Atmos', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(12, 'TH_012', 2, 'PVR Phoenix Marketcity', '7.2 km away', 'ITPL Main Road', 'Mahadevapura, Whitefield', 'IMAX 3D, 4DX', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),

-- ============================================================
-- CITY 3: Chennai
-- ============================================================
(13, 'TH_013', 3, 'Sathyam Cinemas (SPI)', '2.2 km away', 'Royapettah Flyover', '8 Thiru Vi Ka Road, Royapettah', 'Dolby Atmos, RDX 4K', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(14, 'TH_014', 3, 'PVR INOX Luxe Phoenix', '4.8 km away', 'Velachery Road', '142 Velachery Main Rd, Velachery', 'IMAX Laser, Luxe', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(15, 'TH_015', 3, 'Palazzo Cinemas Nexus Vijaya', '3.5 km away', 'Vadapalani Metro', '100 Feet Road, Vadapalani', 'Dolby Atmos, VIP', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),
(16, 'TH_016', 3, 'Escape Cinemas Express Avenue', '1.7 km away', 'Royapettah Clock Tower', 'Whites Road, Royapettah', 'Blind Velvet 2D, Atmos', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),
(17, 'TH_017', 3, 'PVR VR Mall EPIQ', '6.1 km away', 'Anna Nagar Roundtana', 'Jawaharlal Nehru Road, Anna Nagar', 'EPIQ Premium Large, 4DX', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(18, 'TH_018', 3, 'AGS Cinemas T Nagar', '2.9 km away', 'Panagal Park', 'Gopathy Narayanaswamy Chetty Rd', '4K Laser, Dolby Atmos', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),

-- ============================================================
-- CITY 4: Hyderabad
-- ============================================================
(19, 'TH_019', 4, 'Prasad Multiplex & Large Screen', '1.9 km away', 'Hussain Sagar Lake', 'NTR Gardens, Khairatabad', 'Large Screen PCX, 4K 3D', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(20, 'TH_020', 4, 'AMB Cinemas Gachibowli', '5.4 km away', 'Kondapur Junction', 'Sarath City Capital Mall, Gachibowli', 'Dolby Atmos, VIP Lounge', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(21, 'TH_021', 4, 'PVR Inorbit Mall Cyberabad', '4.7 km away', 'Durgam Cheruvu View', 'Mindspace, HITEC City', 'IMAX Laser, 3D', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),
(22, 'TH_022', 4, 'Cinepolis Lulu Mall Kukatpally', '6.8 km away', 'JNTU Metro Station', 'NH 65, Kukatpally Housing Board', '4DX, Macro XE', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(23, 'TH_023', 4, 'INOX GVK One Mall', '2.6 km away', 'Banjara Hills Rd No. 1', 'Balapur Basheerbagh Rd, Banjara Hills', 'Insignia 7.1, 4K', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),

-- ============================================================
-- CITY 5: Pune
-- ============================================================
(24, 'TH_024', 5, 'PVR Phoenix Marketcity Viman Nagar', '3.4 km away', 'Viman Nagar Flyover', 'Viman Nagar Main Road', 'IMAX 3D, 4DX', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(25, 'TH_025', 5, 'Cinepolis Seasons Mall Magarpatta', '4.9 km away', 'Magarpatta Cybercity', 'Hadapsar, Magarpatta Road', 'VIP Dolby Atmos, 3D', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),
(26, 'TH_026', 5, 'INOX Bund Garden', '1.6 km away', 'Pune Railway Station', 'Bund Garden Road, Camp', 'Laser 4K, Recliner', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),
(27, 'TH_027', 5, 'PVR The Pavillion Mall', '2.7 km away', 'University Circle', 'Senapati Bapat Road, Shivaji Nagar', 'P[XL], 4K Dolby Atmos', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(28, 'TH_028', 5, 'Cinepolis Westend Mall Aundh', '5.2 km away', 'D-Mart Aundh', 'Harmony Society, Ward No. 8, Aundh', 'RealD 3D, Dolby Atmos', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),

-- ============================================================
-- CITY 6: Kolkata
-- ============================================================
(29, 'TH_029', 6, 'INOX South City Mall', '2.9 km away', 'Prince Anwar Shah Road', 'Jadavpur, South City Complex', 'IMAX Laser, Insignia', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(30, 'TH_030', 6, 'PVR Mani Square Mall', '3.8 km away', 'Apollo Hospital EM Bypass', '164/1 Maniktala Main Road', '4DX, Dolby Atmos', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),
(31, 'TH_031', 6, 'INOX Quest Mall', '1.4 km away', 'Park Circus 7-Point', '33 Syed Amir Ali Avenue, Ballygunge', 'Insignia Luxe, 4K', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(32, 'TH_032', 6, 'Cinepolis Acropolis Mall', '4.2 km away', 'Ruby Hospital Crossing', '1858 Rajdanga Main Road, Kasba', '3D, Dolby 7.1', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),
(33, 'TH_033', 6, 'Navina Cinema Tollygunge', '2.5 km away', 'Mahanayak Uttam Kumar Metro', '85 Prince Anwar Shah Road', 'Dolby Atmos 4K Laser', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),

-- ============================================================
-- CITY 7: Kochi
-- ============================================================
(34, 'TH_034', 7, 'PVR Superplex Lulu Mall', '3.1 km away', 'Edappally Metro Station', 'NH 544, Edappally', 'IMAX 3D, 4DX, Luxe', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(35, 'TH_035', 7, 'Cinepolis Centre Square Mall', '1.2 km away', 'Maharajas College Ground', 'MG Road, Shenoys, Ernakulam', 'RealD 3D, Dolby Atmos', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30'),
(36, 'TH_036', 7, 'Shenoys Theatre', '1.0 km away', 'Shenoys Junction', 'Mahatma Gandhi Rd, Shenoys', '4K Dolby Atmos, RGB Laser', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(37, 'TH_037', 7, 'PVR Forum Mall Maradu', '5.6 km away', 'Kundannoor Junction', 'NH 66, Maradu, Ernakulam', 'P[XL], 4K Laser', NULL, NULL, TRUE, '2026-10-01 11:44:52.733672+05:30'),
(38, 'TH_038', 7, 'Kavitha Theatre', '1.5 km away', 'Jos Junction', 'MG Road, Ernakulam South', 'Dolby 7.1, 2D', NULL, NULL, FALSE, '2026-10-01 11:44:52.733672+05:30')
ON CONFLICT (id) DO NOTHING;

-- 6. Screens
INSERT INTO public.screens (theater_id, screen_name, total_seats) VALUES
-- CITY 1: Mumbai (Theaters 1 - 6)
(1, 'Audi 1 - IMAX Laser', 140),
(1, 'Audi 2 - LUXE Suite Recliner', 60),
(1, 'Audi 3 - Dolby Atmos Premiere', 120),
(2, 'Audi 1 - 4DX Dynamic Motion', 96),
(2, 'Audi 2 - VIP Dolby Atmos', 72),
(2, 'Audi 3 - RealD 3D Laser', 120),
(3, 'Living Room 1 - Dolby Vision', 48),
(3, 'Living Room 2 - Private Luxe', 40),
(4, 'Screen 1 - 3D Dolby 7.1', 120),
(4, 'Screen 2 - Digital 2D Classic', 96),
(5, 'Audi 1 - IMAX 3D Laser', 130),
(5, 'Audi 2 - P[XL] Giant Screen', 150),
(5, 'Audi 3 - Dolby Atmos Prime', 100),
(6, 'Audi 1 - Laser IMAX Large Screen', 140),
(6, 'Audi 2 - Dolby Atmos 7.1.4', 110),
-- CITY 2: Bengaluru (Theaters 7 - 12)
(7, 'Audi 1 - IMAX Laser 70mm', 150),
(7, 'Audi 2 - 4DX Sensory Screen', 96),
(7, 'Audi 3 - ICE Immersive Theatre', 100),
(8, 'Audi 1 - Dolby Atmos Macro XE', 130),
(8, 'Audi 2 - VIP Recliner Class', 60),
(9, 'Audi 1 - Dolby Atmos 3D', 120),
(9, 'Audi 2 - 4K Laser Digital', 96),
(10, 'Audi 1 - Director Cut Ultra Luxury', 48),
(10, 'Audi 2 - Platinum Gold Class', 40),
(11, 'Main Screen - Laser 4K RGB Giant', 180),
(11, 'Balcony Screen - Dolby Atmos VIP', 90),
(12, 'Audi 1 - IMAX 3D with Laser', 140),
(12, 'Audi 2 - 4DX Interactive', 88),
(12, 'Audi 3 - Dolby Atmos Premiere', 110),
-- CITY 3: Chennai (Theaters 13 - 18)
(13, 'Sathyam - RDX 4K Laser & Atmos', 160),
(13, 'Santham - Dolby Atmos 7.1.4', 120),
(13, 'Studio 5 - VIP Recliner', 60),
(14, 'Audi 1 - IMAX Laser Commercial', 140),
(14, 'Audi 2 - Luxe Recliner Lounge', 56),
(15, 'Audi 1 - Palazzo Dolby Atmos Grand', 150),
(15, 'Audi 2 - Italian VIP Suite', 60),
(16, 'Screen 1 - Blind Velvet Atmos', 110),
(16, 'Screen 2 - Velvet 2D Laser', 90),
(17, 'Audi 1 - EPIQ Premium Large Format', 170),
(17, 'Audi 2 - 4DX Motion Theatre', 96),
(18, 'Screen 1 - 4K Laser Dolby Atmos', 130),
(18, 'Screen 2 - Digital 3D Surround', 100),
-- CITY 4: Hyderabad (Theaters 19 - 23)
(19, 'Screen 6 - Large Screen PCX 4K Giant', 200),
(19, 'Screen 1 - 4K 3D Dolby Atmos', 130),
(19, 'Screen 2 - Digital Laser Luxe', 90),
(20, 'Audi 1 - Superplex Laser Dolby Atmos', 160),
(20, 'Audi 2 - VIP M-Lounge Recliner', 60),
(20, 'Audi 3 - 4K Barco Laser', 120),
(21, 'Audi 1 - IMAX Laser 3D', 140),
(21, 'Audi 2 - Dolby Atmos Prime', 110),
(22, 'Audi 1 - Macro XE Giant Screen', 150),
(22, 'Audi 2 - 4DX Sensory Experience', 96),
(23, 'Audi 1 - Insignia Luxury Recliner', 60),
(23, 'Audi 2 - 4K Dolby Atmos', 120),
-- CITY 5: Pune (Theaters 24 - 28)
(24, 'Audi 1 - IMAX 3D Laser', 140),
(24, 'Audi 2 - 4DX Motion Effects', 96),
(24, 'Audi 3 - Dolby Atmos Premiere', 110),
(25, 'Audi 1 - VIP Dolby Atmos Recliner', 64),
(25, 'Audi 2 - RealD 3D Laser', 120),
(26, 'Audi 1 - Laser 4K Dolby 7.1', 110),
(26, 'Audi 2 - Executive Recliner', 56),
(27, 'Audi 1 - P[XL] Premium Giant Screen', 160),
(27, 'Audi 2 - 4K Dolby Atmos Laser', 120),
(28, 'Audi 1 - RealD 3D Dolby Atmos', 130),
(28, 'Audi 2 - Digital 2D Surround', 96),
-- CITY 6: Kolkata (Theaters 29 - 33)
(29, 'Audi 1 - IMAX Laser Commercial', 150),
(29, 'Audi 2 - Insignia Gold Recliner', 56),
(29, 'Audi 3 - Dolby Atmos Prime', 120),
(30, 'Audi 1 - 4DX Sensory Theatre', 96),
(30, 'Audi 2 - Dolby Atmos 7.1', 120),
(31, 'Audi 1 - Insignia Luxe Recliner', 56),
(31, 'Audi 2 - 4K Laser Dolby Atmos', 120),
(32, 'Audi 1 - RealD 3D Dolby 7.1', 120),
(32, 'Audi 2 - Digital 2D Laser', 96),
(33, 'Main Audi - Dolby Atmos 4K Laser', 170),
(33, 'Mini Audi - Digital 2D Classic', 80),
-- CITY 7: Kochi (Theaters 34 - 38)
(34, 'Audi 1 - IMAX 3D Laser', 150),
(34, 'Audi 2 - 4DX Motion Experience', 96),
(34, 'Audi 3 - Luxe Recliner Suite', 56),
(34, 'Audi 4 - Dolby Atmos 7.1.4', 120),
(35, 'Audi 1 - Dolby Atmos Macro XE', 130),
(35, 'Audi 2 - RealD 3D Laser', 100),
(36, 'Screen 1 - 4K Dolby Atmos RGB Laser', 160),
(36, 'Screen 2 - Christie Laser 4K 3D', 120),
(37, 'Audi 1 - P[XL] Giant Screen 4K', 160),
(37, 'Audi 2 - Dolby Atmos Prime', 120),
(38, 'Main Screen - Dolby 7.1 2D Classic', 140)
ON CONFLICT DO NOTHING;

-- 7. Populate Seats for Screens
DO \$\$
DECLARE
    sc_rec RECORD;
    r_label TEXT;
    s_num INTEGER;
    t_name TEXT;
    mult NUMERIC(3,2);
    seats_per_row INTEGER;
BEGIN
    FOR sc_rec IN SELECT id, total_seats FROM public.screens LOOP
        seats_per_row := 12;
        IF sc_rec.total_seats <= 60 THEN
            seats_per_row := 8;
        ELSIF sc_rec.total_seats <= 96 THEN
            seats_per_row := 10;
        END IF;

        FOREACH r_label IN ARRAY ARRAY['A', 'B', 'C', 'D', 'E', 'F']
        LOOP
            IF r_label IN ('A', 'B') THEN
                t_name := 'Silver';
                mult := 1.00;
            ELSIF r_label IN ('C', 'D') THEN
                t_name := 'Gold';
                mult := 1.25;
            ELSE
                t_name := 'Platinum Recliner';
                mult := 1.60;
            END IF;

            FOR s_num IN 1..seats_per_row LOOP
                INSERT INTO public.seats (screen_id, row_label, seat_number, seat_identifier, tier_name, seat_type, multiplier)
                VALUES (sc_rec.id, r_label, s_num, r_label || s_num, t_name, 'normal', mult)
                ON CONFLICT (screen_id, row_label, seat_number) DO NOTHING;
            END LOOP;
        END LOOP;
    END LOOP;
END \$\$;

-- 8. Shows for Today / Upcoming
INSERT INTO public.shows (
    movie_id, screen_id, show_time, show_time_formatted, language, format, base_price, status, is_fast_filling
)
SELECT 
    (SELECT id FROM public.movies WHERE status = 'now_showing' ORDER BY is_trending DESC, rating DESC LIMIT 1),
    sc.id,
    CURRENT_TIMESTAMP + INTERVAL '2 hours',
    '01:15 PM',
    'English',
    'IMAX 3D Laser',
    350.00,
    'active',
    true
FROM public.screens sc;

INSERT INTO public.shows (
    movie_id, screen_id, show_time, show_time_formatted, language, format, base_price, status, is_fast_filling
)
SELECT 
    (SELECT id FROM public.movies WHERE status = 'now_showing' ORDER BY is_trending DESC, rating DESC LIMIT 1),
    sc.id,
    CURRENT_TIMESTAMP + INTERVAL '5 hours',
    '04:30 PM',
    'English',
    'Dolby Atmos 7.1',
    380.00,
    'active',
    true
FROM public.screens sc;

INSERT INTO public.shows (
    movie_id, screen_id, show_time, show_time_formatted, language, format, base_price, status, is_fast_filling
)
SELECT 
    (SELECT id FROM public.movies WHERE status = 'now_showing' ORDER BY is_trending DESC, rating DESC LIMIT 1),
    sc.id,
    CURRENT_TIMESTAMP + INTERVAL '8 hours',
    '08:00 PM',
    'English',
    'VIP Recliner Luxe',
    420.00,
    'active',
    true
FROM public.screens sc;

INSERT INTO public.shows (
    movie_id, screen_id, show_time, show_time_formatted, language, format, base_price, status, is_fast_filling
)
SELECT 
    (SELECT id FROM public.movies WHERE status = 'now_showing' ORDER BY is_trending DESC, rating DESC OFFSET 1 LIMIT 1),
    sc.id,
    CURRENT_TIMESTAMP + INTERVAL '11 hours',
    '10:45 PM',
    'English',
    'Dolby Atmos 7.1',
    350.00,
    'active',
    false
FROM public.screens sc;

