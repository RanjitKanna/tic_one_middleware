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

  // 2. Get Movie Details by Slug or Movie Code
  static Future<Response> getMovieBySlug(RequestContext context, String slug) async {
    final connection = await openDatabaseConnection();

    try {
      final result = await connection.execute(
        Sql.named('''
          SELECT
            id, movie_code, slug, title, subtitle, synopsis, genre, language,
            duration_mins, certificate, rating, rating_count, image_url, banner_url,
            trailer_url, status, release_date, format, badge_text, match_percent,
            is_trending, is_filling_fast, is_advance_booking_open
          FROM movies
          WHERE LOWER(slug) = LOWER(@slug) OR LOWER(movie_code) = LOWER(@slug)
          LIMIT 1
        '''),
        parameters: {'slug': slug.trim()},
      );

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
    final city = queryParams['city'] ?? 'Downtown';
    final date = queryParams['date']; // Optional date filter YYYY-MM-DD

    final connection = await openDatabaseConnection();

    try {
      final movieRes = await connection.execute(
        Sql.named('''
          SELECT id, movie_code, title, format, duration_mins, certificate
          FROM movies
          WHERE LOWER(slug) = LOWER(@slug)
             OR LOWER(movie_code) = LOWER(@slug)
             OR CAST(id AS TEXT) = @slug
          LIMIT 1
        '''),
        parameters: {'slug': movieIdOrSlug.trim()},
      );

      if (movieRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Movie not found'},
        );
      }

      final movie = movieRes.first;
      final movieId = movie[0] as int;

      final parameters = <String, dynamic>{
        'movieId': movieId,
        'city': city,
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
          AND LOWER(c.name) = LOWER(@city)
      ''';

      if (date != null && date.isNotEmpty) {
        showsSql += ' AND DATE(s.show_time) = @date::DATE';
        parameters['date'] = date;
      }
      showsSql += ' ORDER BY t.name ASC, s.show_time ASC';

      final result = await connection.execute(
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
            'landmark': landmark,
            'address': address,
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

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'data': {
            'movie': {
              'id': movie[0],
              'movieCode': movie[1],
              'title': movie[2],
              'format': movie[3],
              'durationMins': movie[4],
              'certificate': movie[5],
            },
            'city': city,
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
    return {
      'id': row[0],
      'movieId': row[1],
      'slug': row[2],
      'title': row[3],
      'subtitle': row[4],
      'synopsis': row[5],
      'genre': row[6],
      'language': row[7],
      'durationMins': row[8],
      'certificate': row[9],
      'rating': _toDouble(row[10]),
      'ratingCount': row[11]?.toString() ?? '0',
      'imageUrl': row[12],
      'bannerUrl': row[13],
      'trailerUrl': row[14],
      'status': row[15],
      'releaseDate': (row[16] as DateTime?)?.toIso8601String(),
      'format': row[17],
      'badgeText': row[18],
      'matchPercent': row[19],
      'isTrending': row[20] ?? false,
      'isFillingFast': row[21] ?? false,
      'isAdvanceBookingOpen': row[22] ?? false,
    };
  }
}
