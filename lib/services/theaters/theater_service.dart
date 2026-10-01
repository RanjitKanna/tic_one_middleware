import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

class TheaterService {
  static Future<Response> listTheaters(RequestContext context) async {
    final queryParams = context.request.uri.queryParameters;
    final requestedCity = queryParams['city'];

    final connection = await openDatabaseConnection();

    try {
      var city = requestedCity?.trim();
      if (city == null || city.isEmpty) {
        final defaultCityRes = await connection.execute(
          Sql.named('SELECT name FROM cities ORDER BY is_popular DESC, id ASC LIMIT 1'),
        );
        city = defaultCityRes.isNotEmpty ? (defaultCityRes.first[0] as String) : 'Mumbai';
      }
      final result = await connection.execute(
        Sql.named('''
          SELECT
            t.id,
            t.theater_code,
            t.name,
            t.distance_info,
            t.landmark,
            t.address,
            t.formats,
            t.latitude,
            t.longitude,
            t.is_fast_filling,
            c.name as city_name,
            COALESCE(
              JSON_AGG(
                JSON_BUILD_OBJECT(
                  'screenId', sc.id,
                  'screenName', sc.screen_name,
                  'totalSeats', sc.total_seats
                )
              ) FILTER (WHERE sc.id IS NOT NULL),
              '[]'::json
            ) as screens
          FROM theaters t
          JOIN cities c ON t.city_id = c.id
          LEFT JOIN screens sc ON sc.theater_id = t.id
          WHERE LOWER(c.name) = LOWER(@city)
          GROUP BY t.id, t.theater_code, t.name, t.distance_info, t.landmark,
                   t.address, t.formats, t.latitude, t.longitude, t.is_fast_filling, c.name
          ORDER BY t.name ASC
        '''),
        parameters: {'city': city},
      );

      final theaters = result.map((row) {
        return {
          'id': row[0],
          'theaterCode': row[1],
          'name': row[2],
          'distance': row[3] ?? 'Nearby',
          'landmark': row[4],
          'address': row[5],
          'formats': row[6],
          'latitude': (row[7] as num?)?.toDouble(),
          'longitude': (row[8] as num?)?.toDouble(),
          'isFastFilling': row[9] ?? false,
          'cityName': row[10],
          'screens': row[11],
        };
      }).toList();

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'city': city,
          'count': theaters.length,
          'data': theaters,
        },
      );
    } catch (e, st) {
      AppLogger.error('TheaterService', 'Error listing theaters', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': e.toString()},
      );
    } finally {
      await connection.close();
    }
  }
}
