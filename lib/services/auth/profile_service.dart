import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';
import 'package:tic_one_middleware/services/wallet/wallet_service.dart';

class ProfileService {
  static Future<Response> execute(
    RequestContext context,
  ) async {
    // 1. Get access token from header
    final token = AuthUtils.getBearerToken(context);

    if (token == null) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Authorization token is required'},
      );
    }

    // 2. Verify JWT
    final int userId;

    try {
      userId = AuthUtils.verifyAccessToken(token);
    } catch (_) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Invalid or expired authorization token'},
      );
    }

    // 3. Connect to database
    final connection = await openDatabaseConnection();

    try {
      // 4. Find user using userId
      final result = await connection.execute(
        Sql.named('''
          SELECT
            id,
            name,
            email,
            phone,
            created_at
          FROM login_auth
          WHERE id = @userId
          LIMIT 1
        '''),
        parameters: {
          'userId': userId,
        },
      );

      // 5. User not found
      if (result.isEmpty) {
        return Response.json(
          statusCode: 404,
          body: {
            'error': 'User not found',
          },
        );
      }

      final row = result.first;
      final royalPass = await WalletService.getRoyalPass(connection, userId);

      // 6. Return profile
      return Response.json(
        body: {
          'message': 'Profile fetched successfully',
          'user': {
            'id': row[0],
            'name': row[1],
            'email': row[2],
            'phone': row[3],
            'createdAt': row[4].toString(),
            'membership': royalPass,
          },
          'membership': royalPass,
        },
      );
    } finally {
      await connection.close();
    }
  }
}
