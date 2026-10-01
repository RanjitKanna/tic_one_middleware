import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

class HomeService {
  static double _toDouble(dynamic val, [double def = 0.0]) {
    if (val == null) return def;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? def;
    return def;
  }

  static Future<Response> getHomeData(RequestContext context) async {
    final queryParams = context.request.uri.queryParameters;
    final requestedCity = queryParams['city'];
    final language = queryParams['language'] ?? 'All';

    final connection = await openDatabaseConnection();

    try {
      // 1. Fetch Popular Cities from DB
      final citiesResult = await connection.execute(
        Sql.named('SELECT name, is_popular FROM cities ORDER BY is_popular DESC, id ASC'),
      );
      final popularCities = <String>[];
      for (final row in citiesResult) {
        popularCities.add(row[0]! as String);
      }

      // Determine active city: use query parameter if provided, otherwise default to first city from DB
      final city = (requestedCity != null && requestedCity.trim().isNotEmpty)
          ? requestedCity.trim()
          : (popularCities.isNotEmpty ? popularCities.first : 'Mumbai');

      // 2. Fetch Active Banners / Hero Carousel
      final bannersResult = await connection.execute(
        Sql.named('''
          SELECT
            b.banner_code,
            COALESCE(m.movie_code, ''),
            COALESCE(b.slug, m.slug, ''),
            b.title,
            b.subtitle,
            b.image_url,
            COALESCE(b.rating, m.rating, 0.0),
            COALESCE(b.rating_count, m.rating_count, '0'),
            COALESCE(b.format, m.format, '2D'),
            b.is_trending
          FROM banners b
          LEFT JOIN movies m ON b.movie_id = m.id
          WHERE b.is_active = true
          ORDER BY b.display_order ASC
        '''),
      );

      final heroCarousel = bannersResult.map((row) {
        return {
          'id': row[0],
          'movieId': row[1],
          'slug': row[2],
          'title': row[3],
          'subtitle': row[4],
          'imageUrl': row[5],
          'rating': _toDouble(row[6]),
          'ratingCount': row[7]?.toString() ?? '0',
          'format': row[8],
          'isTrending': row[9] ?? false,
        };
      }).toList();

      // 3. Fetch Now Showing Movies (Filter by language if not 'All')
      final nowShowingParams = <String, dynamic>{};
      var nowShowingSql = '''
        SELECT
          id, movie_code, slug, title, genre, image_url,
          rating, badge_text, match_percent, is_filling_fast, language
        FROM movies
        WHERE status = 'now_showing'
      ''';

      if (language != 'All') {
        nowShowingSql += ' AND language = @language';
        nowShowingParams['language'] = language;
      }
      nowShowingSql += ' ORDER BY is_trending DESC, rating DESC';

      final nowShowingResult = await connection.execute(
        Sql.named(nowShowingSql),
        parameters: nowShowingParams,
      );

      final nowShowingMovies = nowShowingResult.map((row) {
        return {
          'id': 'mov_ns_${row[0]}',
          'movieId': row[1],
          'slug': row[2],
          'title': row[3],
          'genre': row[4],
          'imageUrl': row[5],
          'rating': _toDouble(row[6]),
          'badgeText': row[7] ?? 'Filling Fast',
          'matchPercent': row[8] ?? '95% Match',
          'isFillingFast': row[9] ?? false,
          'language': row[10],
        };
      }).toList();

      // 4. Fetch Upcoming Movies
      final upcomingResult = await connection.execute(
        Sql.named('''
          SELECT
            id, movie_code, slug, title, genre, image_url,
            release_date, certificate, is_advance_booking_open
          FROM movies
          WHERE status = 'upcoming'
          ORDER BY release_date ASC
        '''),
      );

      final upcomingMovies = upcomingResult.map((row) {
        final relDate = row[6] as DateTime?;
        final formattedDate = relDate != null
            ? '${_getMonthName(relDate.month)} ${relDate.day}'
            : 'Coming Soon';

        return {
          'id': 'mov_up_${row[0]}',
          'movieId': row[1],
          'slug': row[2],
          'title': row[3],
          'genre': row[4],
          'imageUrl': row[5],
          'releaseDate': formattedDate,
          'certificate': row[7] ?? 'UA',
          'isAdvanceBookingOpen': row[8] ?? false,
        };
      }).toList();

      // 5. Fetch Theaters in Selected City with Live Showtimes
      final theatersResult = await connection.execute(
        Sql.named('''
          SELECT
            t.id,
            t.theater_code,
            t.name,
            t.distance_info,
            t.formats,
            t.is_fast_filling,
            COALESCE(
              ARRAY_AGG(s.show_time_formatted ORDER BY s.show_time ASC) FILTER (WHERE s.id IS NOT NULL),
              ARRAY[]::VARCHAR[]
            ) as showtimes
          FROM theaters t
          JOIN cities c ON t.city_id = c.id
          LEFT JOIN screens sc ON sc.theater_id = t.id
          LEFT JOIN shows s ON s.screen_id = sc.id AND s.status = 'active'
          WHERE LOWER(c.name) = LOWER(@city)
          GROUP BY t.id, t.theater_code, t.name, t.distance_info, t.formats, t.is_fast_filling
        '''),
        parameters: {'city': city},
      );

      final nearbyTheaters = theatersResult.map((row) {
        final rawShowtimes = row[6] as List?;
        final showtimes = (rawShowtimes != null && rawShowtimes.isNotEmpty)
            ? rawShowtimes.map((e) => e.toString()).toList()
            : ['01:15 PM', '04:30 PM', '08:00 PM', '10:45 PM'];

        return {
          'id': row[1],
          'name': row[2],
          'distance': row[3],
          'format': row[4],
          'showtimes': showtimes,
          'isFastFilling': row[5] ?? false,
        };
      }).toList();

      // 6. Fetch Trailers
      final trailersResult = await connection.execute(
        Sql.named('''
          SELECT
            trailer_code, title, subtitle, image_url, video_url, duration, tag_label
          FROM trailers
          WHERE is_active = true
          ORDER BY display_order ASC
        '''),
      );

      final trailers = trailersResult.map((row) {
        return {
          'id': row[0],
          'title': row[1],
          'subtitle': row[2],
          'imageUrl': row[3],
          'videoUrl': row[4],
          'duration': row[5],
          'tagLabel': row[6],
        };
      }).toList();

      final responseData = {
        'location': {
          'popularCities': popularCities,
        },
        'languages': [
          'All',
          'English',
          'Hindi',
          'Tamil',
          'Telugu',
          'Malayalam',
          'Kannada',
        ],
        'heroCarousel': heroCarousel,
        'nowShowingMovies': nowShowingMovies,
        'upcomingMovies': upcomingMovies,
        'nearbyTheaters': nearbyTheaters,
        'trailers': trailers,
      };

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'data': responseData,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e, st) {
      AppLogger.error('HomeService', 'Error getting home data', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'status': 'error',
          'message': 'Failed to retrieve home feed: ${e.toString()}',
        },
      );
    } finally {
      await connection.close();
    }
  }

  static String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
