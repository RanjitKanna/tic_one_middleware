import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';

class ProfileService {
  static Future<Response> execute(
    RequestContext context,
  ) async {
    print('Bear access token ');

    // -----------------------------------------
    // 1. Get access token from header
    // -----------------------------------------

    final token = AuthUtils.getBearerToken(context);
    print('Bear access token $token');

    if (token == null) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Authorization token is required', 'tocke': '$token'},
      );
    }

    // -----------------------------------------
    // 2. Verify JWT
    // -----------------------------------------

    final int userId;

    try {
      print('verifyAccessToken');

      userId = AuthUtils.verifyAccessToken(token);
      print('verifyAccessToken $userId');
    } catch (_) {
      print('catch');

      return Response.json(
        statusCode: 4014,
        body: {'error': 'Authorization token is required', 'tocke': token},
      );
    }

    // -----------------------------------------
    // 3. Connect to database
    // -----------------------------------------

    final connection = await openDatabaseConnection();

    try {
      // ---------------------------------------
      // 4. Find user using userId
      // ---------------------------------------

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

      // ---------------------------------------
      // 5. User not found
      // ---------------------------------------

      if (result.isEmpty) {
        return Response.json(
          statusCode: 404,
          body: {
            'error': 'User not found',
          },
        );
      }

      final row = result.first;

      // ---------------------------------------
      // 6. Return profile
      // ---------------------------------------

      return Response.json(
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
    } finally {
      await connection.close();
    }
  }
}
