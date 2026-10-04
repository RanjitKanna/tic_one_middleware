import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

class MovieService {
  static double _toDouble(dynamic val, [double def = 0.0]) {
    if (val == null) return def;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? def;
    return def;
  }

  // 1. List Movies (with filters: status, genre, language, search)
  static Future<Response> listMovies(RequestContext context) async {
    final queryParams = context.request.uri.queryParameters;
    final status = queryParams['status']; // 'now_showing', 'upcoming', null for all
    final genre = queryParams['genre'];
    final language = queryParams['language'];
    final search = queryParams['q']?.trim();

    final connection = await openDatabaseConnection();

    try {
      final whereClauses = <String>[];
      final parameters = <String, dynamic>{};

      if (status != null && status.isNotEmpty) {
        whereClauses.add('status = @status');
        parameters['status'] = status;
      }
      if (genre != null && genre.isNotEmpty) {
        whereClauses.add('LOWER(genre) LIKE @genre');
        parameters['genre'] = '%${genre.toLowerCase()}%';
      }
      if (language != null && language.isNotEmpty && language != 'All') {
        whereClauses.add('LOWER(language) = LOWER(@language)');
        parameters['language'] = language;
      }
      if (search != null && search.isNotEmpty) {
        whereClauses.add('(LOWER(title) LIKE @search OR LOWER(subtitle) LIKE @search OR LOWER(genre) LIKE @search)');
        parameters['search'] = '%${search.toLowerCase()}%';
      }

      var sql = '''
        SELECT
          id, movie_code, slug, title, subtitle, synopsis, genre, language,
          duration_mins, certificate, rating, rating_count, image_url, banner_url,
          trailer_url, status, release_date, format, badge_text, match_percent,
          is_trending, is_filling_fast, is_advance_booking_open
        FROM movies
      ''';

      if (whereClauses.isNotEmpty) {
        sql += ' WHERE ${whereClauses.join(' AND ')}';
      }
      sql += ' ORDER BY is_trending DESC, rating DESC, release_date ASC';

      final result = await connection.execute(
        Sql.named(sql),
        parameters: parameters,
      );

      final movies = result.map((row) {
        return _formatMovieRow(row);
      }).toList();

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'count': movies.length,
          'data': movies,
        },
      );
    } catch (e, st) {
      AppLogger.error('MovieService', 'Error listing movies', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': e.toString()},
      );
    } finally {
      await connection.close();
    }
  }

  // 2. Get Movie Details by Slug, Title, Movie Code, or ID
  static Future<Response> getMovieBySlug(RequestContext context, String slug) async {
    final connection = await openDatabaseConnection();

    try {
      final decoded = Uri.decodeComponent(slug);
    final clean = decoded.trim().toLowerCase();
      // Remove ID prefixes like 'mov_ns_' or 'mov_up_' if present
      final cleanId = clean.replaceAll(RegExp(r'^mov_(ns|up|hero)_'), '');

      // 1. First attempt: exact match on slug, movie_code, ID, or exact title
      var result = await connection.execute(
        Sql.named('''
          SELECT
            id, movie_code, slug, title, subtitle, synopsis, genre, language,
            duration_mins, certificate, rating, rating_count, image_url, banner_url,
            trailer_url, status, release_date, format, badge_text, match_percent,
            is_trending, is_filling_fast, is_advance_booking_open
          FROM movies
          WHERE LOWER(slug) = @clean 
             OR LOWER(movie_code) = @clean 
             OR LOWER(title) = @clean
             OR CAST(id AS TEXT) = @clean
             OR CAST(id AS TEXT) = @cleanId
             OR LOWER(slug) = @cleanId
          LIMIT 1
        '''),
        parameters: {
          'clean': clean,
          'cleanId': cleanId,
        },
      );

      // 2. Second attempt: full substring match on title or slug
      if (result.isEmpty && clean.length >= 3) {
        result = await connection.execute(
          Sql.named('''
            SELECT
              id, movie_code, slug, title, subtitle, synopsis, genre, language,
              duration_mins, certificate, rating, rating_count, image_url, banner_url,
              trailer_url, status, release_date, format, badge_text, match_percent,
              is_trending, is_filling_fast, is_advance_booking_open
            FROM movies
            WHERE LOWER(title) LIKE @searchPattern 
               OR LOWER(slug) LIKE @searchPattern
            ORDER BY 
              CASE WHEN LOWER(title) LIKE @exactStart THEN 1 ELSE 2 END,
              rating DESC
            LIMIT 1
          '''),
          parameters: {
            'searchPattern': '%$clean%',
            'exactStart': '$clean%',
          },
        );
      }

      // 3. Third attempt if still empty: match normalized alphanumeric title
      if (result.isEmpty) {
        final alphaOnly = clean.replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (alphaOnly.isNotEmpty) {
          result = await connection.execute(
            Sql.named('''
              SELECT
                id, movie_code, slug, title, subtitle, synopsis, genre, language,
                duration_mins, certificate, rating, rating_count, image_url, banner_url,
                trailer_url, status, release_date, format, badge_text, match_percent,
                is_trending, is_filling_fast, is_advance_booking_open
              FROM movies
              WHERE LOWER(REGEXP_REPLACE(title, '[^a-zA-Z0-9]', '', 'g')) = @alpha
                 OR LOWER(REGEXP_REPLACE(slug, '[^a-zA-Z0-9]', '', 'g')) = @alpha
              LIMIT 1
            '''),
            parameters: {'alpha': alphaOnly},
          );
        }
      }

      if (result.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Movie not found'},
        );
      }

      final movie = _formatMovieRow(result.first);

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'data': movie,
        },
      );
    } catch (e, st) {
      AppLogger.error('MovieService', 'Error fetching movie $slug', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': e.toString()},
      );
    } finally {
      await connection.close();
    }
  }

  // 3. Get Theaters & Shows for a Movie
  static Future<Response> getMovieShows(RequestContext context, String movieIdOrSlug) async {
    final queryParams = context.request.uri.queryParameters;
    final city = queryParams['city'] ?? 'Chennai';
    final date = queryParams['date'] ?? DateTime.now().toIso8601String().split('T').first;

    final connection = await openDatabaseConnection();

    try {
      final decoded = Uri.decodeComponent(movieIdOrSlug);
    final clean = decoded.trim().toLowerCase();
      final cleanId = clean.replaceAll(RegExp(r'^mov_(ns|up|hero)_'), '');

      // 1. Resolve movie by exact match
      var movieRes = await connection.execute(
        Sql.named('''
          SELECT id, movie_code, title, format, duration_mins, certificate, language, genre, slug
          FROM movies
          WHERE LOWER(slug) = @clean
             OR LOWER(movie_code) = @clean
             OR LOWER(title) = @clean
             OR CAST(id AS TEXT) = @clean
             OR CAST(id AS TEXT) = @cleanId
             OR LOWER(slug) = @cleanId
          LIMIT 1
        '''),
        parameters: {
          'clean': clean,
          'cleanId': cleanId,
        },
      );

      // 2. Substring match if needed
      if (movieRes.isEmpty && clean.length >= 3) {
        movieRes = await connection.execute(
          Sql.named('''
            SELECT id, movie_code, title, format, duration_mins, certificate, language, genre, slug
            FROM movies
            WHERE LOWER(title) LIKE @searchPattern
               OR LOWER(slug) LIKE @searchPattern
            ORDER BY 
              CASE WHEN LOWER(title) LIKE @exactStart THEN 1 ELSE 2 END,
              rating DESC
            LIMIT 1
          '''),
          parameters: {
            'searchPattern': '%$clean%',
            'exactStart': '$clean%',
          },
        );
      }

      // 3. Normalized alphanumeric match
      if (movieRes.isEmpty) {
        final alphaOnly = clean.replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (alphaOnly.isNotEmpty) {
          movieRes = await connection.execute(
            Sql.named('''
              SELECT id, movie_code, title, format, duration_mins, certificate, language, genre, slug
              FROM movies
              WHERE LOWER(REGEXP_REPLACE(title, '[^a-zA-Z0-9]', '', 'g')) = @alpha
                 OR LOWER(REGEXP_REPLACE(slug, '[^a-zA-Z0-9]', '', 'g')) = @alpha
              LIMIT 1
            '''),
            parameters: {'alpha': alphaOnly},
          );
        }
      }

      if (movieRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Movie not found'},
        );
      }

      final movie = movieRes.first;
      final movieId = movie[0] as int;
      final movieTitle = movie[2] as String;
      final movieFormat = movie[3] as String? ?? '2D / 3D / IMAX';
      final movieSlug = movie[8] as String? ?? '';

      final parameters = <String, dynamic>{
        'movieId': movieId,
        'city': city,
        'date': date,
      };

      var showsSql = '''
        SELECT
          t.id AS theater_id,
          t.theater_code,
          t.name AS theater_name,
          t.distance_info,
          t.landmark,
          t.address,
          sc.id AS screen_id,
          sc.screen_name,
          s.id AS show_id,
          s.show_time,
          s.show_time_formatted,
          s.language,
          s.format,
          s.base_price,
          s.status,
          s.is_fast_filling
        FROM shows s
        JOIN screens sc ON s.screen_id = sc.id
        JOIN theaters t ON sc.theater_id = t.id
        JOIN cities c ON t.city_id = c.id
        WHERE s.movie_id = @movieId
          AND (LOWER(c.name) = LOWER(@city) OR LOWER(@city) = 'all')
          AND DATE(s.show_time) = @date::DATE
        ORDER BY t.name ASC, s.show_time ASC
      ''';

      var result = await connection.execute(
        Sql.named(showsSql),
        parameters: parameters,
      );

      // Group shows by theater
      final theaterMap = <int, Map<String, dynamic>>{};

      for (final row in result) {
        final theaterId = row[0] as int;
        final theaterCode = row[1] as String;
        final theaterName = row[2] as String;
        final distance = row[3] as String?;
        final landmark = row[4] as String?;
        final address = row[5] as String?;

        if (!theaterMap.containsKey(theaterId)) {
          theaterMap[theaterId] = {
            'theaterId': theaterId,
            'theaterCode': theaterCode,
            'name': theaterName,
            'distance': distance ?? 'Nearby',
            'landmark': landmark ?? '',
            'address': address ?? '',
            'shows': <Map<String, dynamic>>[],
          };
        }

        final showObj = {
          'showId': row[8],
          'screenId': row[6],
          'screenName': row[7],
          'showTime': (row[9] as DateTime).toIso8601String(),
          'timeFormatted': row[10],
          'language': row[11],
          'format': row[12],
          'basePrice': _toDouble(row[13], 250.0),
          'status': row[14],
          'isFastFilling': row[15] ?? false,
        };

        (theaterMap[theaterId]!['shows'] as List).add(showObj);
      }

      // If no explicit shows found, generate dynamic schedule from city theaters
      if (theaterMap.isEmpty) {
        final cityTheaters = await connection.execute(
          Sql.named('''
            SELECT t.id, t.theater_code, t.name, t.distance_info, t.landmark, t.address, sc.id, sc.screen_name
            FROM theaters t
            JOIN cities c ON t.city_id = c.id
            JOIN screens sc ON sc.theater_id = t.id
            WHERE LOWER(c.name) = LOWER(@city)
            ORDER BY t.id, sc.id
          '''),
          parameters: {'city': city},
        );

        final sampleSlots = [
          ['10:15 AM', '01:45 PM', '05:30 PM', '09:15 PM'],
          ['11:00 AM', '02:30 PM', '06:15 PM', '09:45 PM'],
          ['09:30 AM', '01:00 PM', '04:30 PM', '08:00 PM'],
          ['10:45 AM', '02:15 PM', '06:00 PM', '10:00 PM'],
        ];

        int thCount = 0;
        for (final row in cityTheaters) {
          final tId = row[0] as int;
          if (!theaterMap.containsKey(tId) && thCount < 4) {
            thCount++;
            final slots = sampleSlots[(tId + movieId) % sampleSlots.length];
            final generatedShows = <Map<String, dynamic>>[];

            for (int sIdx = 0; sIdx < slots.length; sIdx++) {
              final slotTime = slots[sIdx];
              generatedShows.add({
                'showId': tId * 100 + sIdx + 1,
                'screenId': row[6],
                'screenName': row[7],
                'showTime': '${date}T${slotTime.contains('PM') ? '18:00:00.000Z' : '10:00:00.000Z'}',
                'timeFormatted': slotTime,
                'language': movie[6] ?? 'English',
                'format': movieFormat.contains('IMAX') ? 'IMAX 3D Laser' : 'Dolby Atmos 7.1',
                'basePrice': movieFormat.contains('IMAX') ? 350.0 : 250.0,
                'status': 'active',
                'isFastFilling': sIdx == 1 || sIdx == 3,
              });
            }

            theaterMap[tId] = {
              'theaterId': tId,
              'theaterCode': row[1] ?? 'TH_$tId',
              'name': row[2],
              'distance': row[3] ?? '2.5 km away',
              'landmark': row[4] ?? '',
              'address': row[5] ?? '',
              'shows': generatedShows,
            };
          }
        }
      }

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'data': {
            'movie': {
              'id': movie[0],
              'movieCode': movie[1],
              'title': movieTitle,
              'format': movie[3],
              'durationMins': movie[4],
              'certificate': movie[5],
              'slug': movieSlug,
            },
            'city': city,
            'date': date,
            'theaters': theaterMap.values.toList(),
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('MovieService', 'Error getting shows for movie $movieIdOrSlug', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': e.toString()},
      );
    } finally {
      await connection.close();
    }
  }

  static Map<String, dynamic> _formatMovieRow(List<dynamic> row) {
    final title = (row[3] as String?) ?? 'Movie';
    final slug = (row[2] as String?) ?? '';
    final durationMins = (row[8] as int?) ?? 120;
    final hours = durationMins ~/ 60;
    final mins = durationMins % 60;
    final durationFormatted = '${hours}h ${mins.toString().padLeft(2, '0')}m';

    final castCrew = _resolveCastAndCrew(slug, title);

    return {
      'id': row[0],
      'movieId': row[1],
      'slug': slug,
      'title': title,
      'subtitle': row[4],
      'synopsis': row[5] ?? 'Experience $title in cinemas with stunning sound and visuals.',
      'genre': row[6] ?? 'Action',
      'genres': (row[6] as String?)?.split(RegExp(r'[/•,]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? ['Action'],
      'language': row[7] ?? 'English',
      'durationMins': durationMins,
      'durationFormatted': durationFormatted,
      'certificate': row[9] ?? 'UA',
      'rating': _toDouble(row[10], 8.5),
      'ratingCount': row[11]?.toString() ?? '10K',
      'imageUrl': row[12],
      'bannerUrl': row[13] ?? row[12],
      'trailerUrl': row[14],
      'status': row[15] ?? 'now_showing',
      'releaseDate': (row[16] as DateTime?)?.toIso8601String(),
      'format': row[17] ?? '2D / 3D / IMAX',
      'formats': (row[17] as String?)?.split(RegExp(r'[/,]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? ['IMAX 70MM', 'Dolby Atmos', '2D'],
      'badgeText': row[18],
      'matchPercent': row[19] ?? '95% Match',
      'isTrending': row[20] ?? false,
      'isFillingFast': row[21] ?? false,
      'isAdvanceBookingOpen': row[22] ?? false,
      'startingPrice': 250.0,
      'cast': castCrew['cast'],
      'crew': castCrew['crew'],
    };
  }

  static Map<String, dynamic> _resolveCastAndCrew(String slug, String title) {
    final lower = (slug + ' ' + title).toLowerCase();

    if (lower.contains('the-goat') || lower.contains('greatest of all time')) {
      return {
        'cast': [
          {'name': 'Vijay', 'character': 'Gandhi / Jeevan', 'imageUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Prashanth', 'character': 'Sunil', 'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Prabhu Deva', 'character': 'Kalyan', 'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Sneha', 'character': 'Anuradha', 'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Mohan', 'character': 'Rajeev Menon', 'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop'},
        ],
        'crew': [
          {'name': 'Venkat Prabhu', 'role': 'Director', 'imageUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Yuvan Shankar Raja', 'role': 'Music Composer', 'imageUrl': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=300&auto=format&fit=crop'},
        ],
      };
    }

    if (lower.contains('aadujeevitham') || lower.contains('goat life')) {
      return {
        'cast': [
          {'name': 'Prithviraj Sukumaran', 'character': 'Najeeb Muhammad', 'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Amala Paul', 'character': 'Sainu', 'imageUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Jimmy Jean-Louis', 'character': 'Ibrahim Khadiri', 'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop'},
          {'name': 'K.R. Gokul', 'character': 'Hakeem', 'imageUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=300&auto=format&fit=crop'},
        ],
        'crew': [
          {'name': 'Blessy', 'role': 'Director & Screenplay', 'imageUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop'},
          {'name': 'A. R. Rahman', 'role': 'Music Composer', 'imageUrl': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=300&auto=format&fit=crop'},
        ],
      };
    }

    if (lower.contains('leo')) {
      return {
        'cast': [
          {'name': 'Vijay', 'character': 'Parthiban / Leo Das', 'imageUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Trisha Krishnan', 'character': 'Sathya Parthiban', 'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Sanjay Dutt', 'character': 'Antony Das', 'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Arjun Sarja', 'character': 'Harold Das', 'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Gautham Menon', 'character': 'Joshy Andrews', 'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Mysskin', 'character': 'Shanmugam', 'imageUrl': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?q=80&w=300&auto=format&fit=crop'},
        ],
        'crew': [
          {'name': 'Lokesh Kanagaraj', 'role': 'Director & Writer', 'imageUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Anirudh Ravichander', 'role': 'Music Composer', 'imageUrl': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Manoj Paramahamsa', 'role': 'Cinematographer', 'imageUrl': 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=300&auto=format&fit=crop'},
        ],
      };
    }

    if (lower.contains('jailer')) {
      return {
        'cast': [
          {'name': 'Rajinikanth', 'character': 'Tiger Muthuvel Pandian', 'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Vinayakan', 'character': 'Varman', 'imageUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Ramya Krishnan', 'character': 'Vijaya Pandian', 'imageUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Mohanlal', 'character': 'Mathew (Cameo)', 'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Shiva Rajkumar', 'character': 'Narasimha (Cameo)', 'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=300&auto=format&fit=crop'},
        ],
        'crew': [
          {'name': 'Nelson Dilipkumar', 'role': 'Director', 'imageUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Anirudh Ravichander', 'role': 'Music Composer', 'imageUrl': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=300&auto=format&fit=crop'},
        ],
      };
    }

    if (lower.contains('bramayugam')) {
      return {
        'cast': [
          {'name': 'Mammootty', 'character': 'Kodumon Potti', 'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Arjun Ashokan', 'character': 'Thevan', 'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Sidharth Bharathan', 'character': 'Court Cook', 'imageUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=300&auto=format&fit=crop'},
        ],
        'crew': [
          {'name': 'Rahul Sadasivan', 'role': 'Director', 'imageUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Christo Xavier', 'role': 'Music Composer', 'imageUrl': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=300&auto=format&fit=crop'},
        ],
      };
    }

    if (lower.contains('dune')) {
      return {
        'cast': [
          {'name': 'Timothée Chalamet', 'character': 'Paul Atreides', 'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Zendaya', 'character': 'Chani', 'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Rebecca Ferguson', 'character': 'Lady Jessica', 'imageUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Javier Bardem', 'character': 'Stilgar', 'imageUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Florence Pugh', 'character': 'Princess Irulan', 'imageUrl': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=300&auto=format&fit=crop'},
        ],
        'crew': [
          {'name': 'Denis Villeneuve', 'role': 'Director', 'imageUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Hans Zimmer', 'role': 'Music Composer', 'imageUrl': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=300&auto=format&fit=crop'},
        ],
      };
    }

    if (lower.contains('aavesham')) {
      return {
        'cast': [
          {'name': 'Fahadh Faasil', 'character': 'Ranga', 'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Hipzster', 'character': 'Aju', 'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Mithun Jai Shankar', 'character': 'Bibi', 'imageUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Roshan Shanavas', 'character': 'Shantha', 'imageUrl': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Sajin Gopu', 'character': 'Amban', 'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=300&auto=format&fit=crop'},
        ],
        'crew': [
          {'name': 'Jithu Madhavan', 'role': 'Director & Writer', 'imageUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Sushin Shyam', 'role': 'Music Composer', 'imageUrl': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=300&auto=format&fit=crop'},
        ],
      };
    }

    if (lower.contains('manjummel') || lower.contains('boys')) {
      return {
        'cast': [
          {'name': 'Soubin Shahir', 'character': 'Kuttan', 'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Sreenath Bhasi', 'character': 'Subhash', 'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Balu Varghese', 'character': 'Sixen', 'imageUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Ganapathi', 'character': 'Sudhi', 'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=300&auto=format&fit=crop'},
        ],
        'crew': [
          {'name': 'Chidambaram', 'role': 'Director', 'imageUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Sushin Shyam', 'role': 'Music Composer', 'imageUrl': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=300&auto=format&fit=crop'},
        ],
      };
    }

    if (lower.contains('cyberpunk')) {
      return {
        'cast': [
          {'name': 'Alex Mercer', 'character': 'V / Cyber Agent', 'imageUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Elena Rostova', 'character': 'Nyx / Netrunner', 'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Marcus Vance', 'character': 'Commander Kage', 'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop'},
        ],
        'crew': [
          {'name': 'Kenji Sato', 'role': 'Director', 'imageUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Synthwave Collective', 'role': 'Original Score', 'imageUrl': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=300&auto=format&fit=crop'},
        ],
      };
    }

    if (lower.contains('avatar')) {
      return {
        'cast': [
          {'name': 'Sam Worthington', 'character': 'Jake Sully', 'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Zoe Saldana', 'character': 'Neytiri', 'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Sigourney Weaver', 'character': 'Kiri', 'imageUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Stephen Lang', 'character': 'Colonel Quaritch', 'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop'},
        ],
        'crew': [
          {'name': 'James Cameron', 'role': 'Director', 'imageUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop'},
          {'name': 'Simon Franglen', 'role': 'Composer', 'imageUrl': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=300&auto=format&fit=crop'},
        ],
      };
    }

    // Default dynamic cast
    return {
      'cast': [
        {'name': 'Lead Protagonist', 'character': 'Main Character', 'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop'},
        {'name': 'Co-Star', 'character': 'Key Ally', 'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop'},
        {'name': 'Antagonist', 'character': 'Primary Nemesis', 'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop'},
      ],
      'crew': [
        {'name': 'Film Director', 'role': 'Director', 'imageUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop'},
      ],
    };
  }
}
