import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

import '../../database.dart';
import 'auth_utils.dart';

class LogoutService {
  static Future<Response> execute(
    RequestContext context,
  ) async {
    AppLogger.info(
      'LOGOUT',
      '[01] Logout request received',
    );

    // -----------------------------------------------
    // 2. Read request JSON
    // -----------------------------------------------

    final body = await AuthUtils.readJson(context);

    if (body == null) {
      AppLogger.warning(
        'LOGOUT',
        '[02] Invalid JSON body',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Invalid JSON body',
        },
      );
    }

    AppLogger.info(
      'LOGOUT',
      '[03] JSON body parsed',
    );

    // -----------------------------------------------
    // 3. Read refresh token
    // -----------------------------------------------

    final refreshToken = body['refreshToken'];

    if (refreshToken is! String || refreshToken.trim().isEmpty) {
      AppLogger.warning(
        'LOGOUT',
        '[04] Refresh token missing',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'refreshToken is required',
        },
      );
    }

    final cleanRefreshToken = refreshToken.trim();

    AppLogger.info(
      'LOGOUT',
      '[05] Refresh token received',
    );

    // -----------------------------------------------
    // 4. Hash refresh token
    // -----------------------------------------------

    final tokenHash = AuthUtils.hashToken(
      cleanRefreshToken,
    );

    AppLogger.info(
      'LOGOUT',
      '[06] Refresh token hash generated',
    );

    // -----------------------------------------------
    // 5. Open database
    // -----------------------------------------------

    AppLogger.info(
      'LOGOUT',
      '[07] Opening database connection',
    );

    final connection = await openDatabaseConnection();

    try {
      AppLogger.info(
        'LOGOUT',
        '[08] Database connected',
      );

      // ---------------------------------------------
      // 6. Revoke refresh token
      // ---------------------------------------------

      AppLogger.info(
        'LOGOUT',
        '[09] Searching active refresh token',
      );

      final result = await connection.execute(
        Sql.named('''
          UPDATE refresh_tokens
          SET revoked_at = CURRENT_TIMESTAMP
          WHERE token_hash = @tokenHash
            AND revoked_at IS NULL
        '''),
        parameters: {
          'tokenHash': tokenHash,
        },
      );

      AppLogger.info(
        'LOGOUT',
        '[10] Logout update completed',
      );

      AppLogger.info(
        'LOGOUT',
        '[11] Rows affected=${result.affectedRows}',
      );

      // ---------------------------------------------
      // 7. Token not found / already revoked
      // ---------------------------------------------

      if (result.affectedRows == 0) {
        AppLogger.warning(
          'LOGOUT',
          '[12] Token not found or already revoked',
        );

        return Response.json(
          statusCode: 401,
          body: {
            'error': 'Invalid or already revoked refresh token',
          },
        );
      }

      // ---------------------------------------------
      // 8. Success
      // ---------------------------------------------

      AppLogger.info(
        'LOGOUT',
        '[13] Logout successful',
      );

      return Response.json(
        statusCode: 200,
        body: {
          'message': 'Logout successful',
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'LOGOUT',
        '[ERROR] Logout failed',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      AppLogger.info(
        'LOGOUT',
        '[14] Closing database connection',
      );

      await connection.close();

      AppLogger.info(
        'LOGOUT',
        '[15] Database connection closed',
      );
    }
  }
}
