import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

import '../../database.dart';
import 'auth_utils.dart';

class ProfileService {
  static Future<Response> execute(
    RequestContext context,
  ) async {
    AppLogger.info(
      'PROFILE',
      '[01] Profile request received',
    );

    AppLogger.info(
      'PROFILE',
      '[02] Reading Bearer token',
    );

    final token = AuthUtils.getBearerToken(context);

    if (token == null) {
      AppLogger.warning(
        'PROFILE',
        '[03] Access token missing',
      );

      return Response.json(
        statusCode: 401,
        body: {
          'error': 'Authorization token is required',
        },
      );
    }

    AppLogger.info(
      'PROFILE',
      '[03] Access token extracted',
    );

    final int userId;

    try {
      AppLogger.info(
        'PROFILE',
        '[04] Verifying JWT',
      );

      userId = AuthUtils.verifyAccessToken(token);

      AppLogger.info(
        'PROFILE',
        '[05] JWT verified userId=$userId',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'PROFILE',
        '[05] JWT verification failed',
        error: error,
        stackTrace: stackTrace,
      );

      return Response.json(
        statusCode: 401,
        body: {
          'error': 'Invalid or expired access token',
        },
      );
    }

    AppLogger.info(
      'PROFILE',
      '[06] Connecting to database',
    );

    final connection = await openDatabaseConnection();

    try {
      AppLogger.info(
        'PROFILE',
        '[07] Database connected',
      );

      AppLogger.info(
        'PROFILE',
        '[08] Querying login_auth for userId=$userId',
      );

      final result = await connection.execute(
        Sql.named('''
          SELECT
            id,
            name,
            email,
            created_at
          FROM login_auth
          WHERE id = @userId
          LIMIT 1
        '''),
        parameters: {
          'userId': userId,
        },
      );

      AppLogger.info(
        'PROFILE',
        '[09] Profile query completed',
      );

      if (result.isEmpty) {
        AppLogger.warning(
          'PROFILE',
          '[10] User not found id=$userId',
        );

        return Response.json(
          statusCode: 404,
          body: {
            'error': 'User not found',
          },
        );
      }

      final row = result.first;

      AppLogger.info(
        'PROFILE',
        '[11] User found id=${row[0]}',
      );

      AppLogger.info(
        'PROFILE',
        '[12] Profile response created',
      );

      return Response.json(
        statusCode: 200,
        body: {
          'message': 'Profile fetched successfully',
          'user': {
            'id': row[0],
            'name': row[1],
            'email': row[2],
            'createdAt': row[3].toString(),
          },
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'PROFILE',
        'Profile request failed',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      AppLogger.info(
        'PROFILE',
        'Closing database connection',
      );

      await connection.close();

      AppLogger.info(
        'PROFILE',
        'Database connection closed',
      );
    }
  }
}
