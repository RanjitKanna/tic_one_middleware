import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

import '../../database.dart';
import 'auth_utils.dart';

class RefreshTokenService {
  static Future<Response> execute(
    RequestContext context,
  ) async {
    // --------------------------------------------------
    // 1. Request received
    // --------------------------------------------------

    AppLogger.info(
      'REFRESH',
      '[01] Refresh token request received',
    );

    // --------------------------------------------------
    // 2. Read JSON body
    // --------------------------------------------------

    final body = await AuthUtils.readJson(context);

    if (body == null) {
      AppLogger.warning(
        'REFRESH',
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
      'REFRESH',
      '[03] JSON body parsed',
    );

    // --------------------------------------------------
    // 3. Read refresh token
    // --------------------------------------------------

    final refreshToken = body['refreshToken'];

    if (refreshToken is! String || refreshToken.trim().isEmpty) {
      AppLogger.warning(
        'REFRESH',
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
      'REFRESH',
      '[05] Refresh token received',
    );

    // --------------------------------------------------
    // 4. Hash refresh token
    // --------------------------------------------------

    final tokenHash = AuthUtils.hashToken(cleanRefreshToken);

    AppLogger.info(
      'REFRESH',
      '[06] Refresh token hash created',
    );

    // --------------------------------------------------
    // 5. Database connection
    // --------------------------------------------------

    AppLogger.info(
      'REFRESH',
      '[07] Opening database connection',
    );

    final connection = await openDatabaseConnection();

    try {
      AppLogger.info(
        'REFRESH',
        '[08] Database connection successful',
      );

      // ------------------------------------------------
      // 6. Find refresh token
      // ------------------------------------------------

      AppLogger.info(
        'REFRESH',
        '[09] Searching refresh token',
      );

      final result = await connection.execute(
        Sql.named('''
          SELECT
            id,
            user_id,
            expires_at,
            revoked_at
          FROM refresh_tokens
          WHERE token_hash = @tokenHash
          LIMIT 1
        '''),
        parameters: {
          'tokenHash': tokenHash,
        },
      );

      AppLogger.info(
        'REFRESH',
        '[10] Refresh token query completed',
      );

      // ------------------------------------------------
      // 7. Token not found
      // ------------------------------------------------

      if (result.isEmpty) {
        AppLogger.warning(
          'REFRESH',
          '[11] Refresh token not found',
        );

        return Response.json(
          statusCode: 401,
          body: {
            'error': 'Invalid refresh token',
          },
        );
      }

      // ------------------------------------------------
      // 8. Read token record
      // ------------------------------------------------

      final row = result.first;

      final refreshTokenId = row[0] as int;
      final userId = row[1] as int;
      final expiresAt = row[2] as DateTime;
      final revokedAt = row[3];

      AppLogger.info(
        'REFRESH',
        '[12] Refresh token found '
            'id=$refreshTokenId userId=$userId',
      );

      // ------------------------------------------------
      // 9. Check revoked
      // ------------------------------------------------

      if (revokedAt != null) {
        AppLogger.warning(
          'REFRESH',
          '[13] Refresh token already revoked',
        );

        return Response.json(
          statusCode: 401,
          body: {
            'error': 'Refresh token has been revoked',
          },
        );
      }

      // ------------------------------------------------
      // 10. Check expiration
      // ------------------------------------------------

      if (expiresAt.isBefore(
        DateTime.now().toUtc(),
      )) {
        AppLogger.warning(
          'REFRESH',
          '[14] Refresh token expired',
        );

        return Response.json(
          statusCode: 401,
          body: {
            'error': 'Refresh token has expired',
          },
        );
      }

      AppLogger.info(
        'REFRESH',
        '[15] Refresh token is valid',
      );

      // ------------------------------------------------
      // 11. Find user
      // ------------------------------------------------

      AppLogger.info(
        'REFRESH',
        '[16] Searching user id=$userId',
      );

      final userResult = await connection.execute(
        Sql.named('''
          SELECT
            id,
            name,
            email
          FROM login_auth
          WHERE id = @userId
          LIMIT 1
        '''),
        parameters: {
          'userId': userId,
        },
      );

      AppLogger.info(
        'REFRESH',
        '[17] User query completed',
      );

      if (userResult.isEmpty) {
        AppLogger.warning(
          'REFRESH',
          '[18] User not found id=$userId',
        );

        return Response.json(
          statusCode: 401,
          body: {
            'error': 'User not found',
          },
        );
      }

      final user = userResult.first;

      final userEmail = user[2] as String;

      AppLogger.info(
        'REFRESH',
        '[19] User found id=$userId',
      );

      // ------------------------------------------------
      // 12. Create new access token
      // ------------------------------------------------

      AppLogger.info(
        'REFRESH',
        '[20] Creating new access token',
      );

      final accessToken = AuthUtils.createAccessToken(
        userId: userId,
        email: userEmail,
      );

      AppLogger.info(
        'REFRESH',
        '[21] New access token created',
      );

      // ------------------------------------------------
      // 13. Revoke old refresh token
      // ------------------------------------------------

      AppLogger.info(
        'REFRESH',
        '[22] Revoking old refresh token',
      );

      await connection.execute(
        Sql.named('''
          UPDATE refresh_tokens
          SET revoked_at = CURRENT_TIMESTAMP
          WHERE id = @id
            AND revoked_at IS NULL
        '''),
        parameters: {
          'id': refreshTokenId,
        },
      );

      AppLogger.info(
        'REFRESH',
        '[23] Old refresh token revoked',
      );

      // ------------------------------------------------
      // 14. Generate new refresh token
      // ------------------------------------------------

      AppLogger.info(
        'REFRESH',
        '[24] Generating new refresh token',
      );

      final newRefreshToken = AuthUtils.createRandomToken();

      AppLogger.info(
        'REFRESH',
        '[25] New refresh token generated',
      );

      // ------------------------------------------------
      // 15. Hash new refresh token
      // ------------------------------------------------

      final newRefreshTokenHash = AuthUtils.hashToken(
        newRefreshToken,
      );

      final newExpiresAt = DateTime.now().toUtc().add(
        const Duration(days: 30),
      );

      AppLogger.info(
        'REFRESH',
        '[26] New refresh token hash created',
      );

      // ------------------------------------------------
      // 16. Save new refresh token
      // ------------------------------------------------

      AppLogger.info(
        'REFRESH',
        '[27] Saving new refresh token',
      );

      await connection.execute(
        Sql.named('''
          INSERT INTO refresh_tokens (
            user_id,
            token_hash,
            expires_at
          )
          VALUES (
            @userId,
            @tokenHash,
            @expiresAt
          )
        '''),
        parameters: {
          'userId': userId,
          'tokenHash': newRefreshTokenHash,
          'expiresAt': newExpiresAt,
        },
      );

      AppLogger.info(
        'REFRESH',
        '[28] New refresh token saved',
      );

      // ------------------------------------------------
      // 17. Success
      // ------------------------------------------------

      AppLogger.info(
        'REFRESH',
        '[29] Token refresh successful '
            'for userId=$userId',
      );

      return Response.json(
        statusCode: 200,
        body: {
          'message': 'Token refreshed successfully',
          'accessToken': accessToken,
          'refreshToken': newRefreshToken,
          'expiresIn': 900,
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'REFRESH',
        'Refresh token flow failed',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      AppLogger.info(
        'REFRESH',
        'Closing database connection',
      );

      await connection.close();

      AppLogger.info(
        'REFRESH',
        'Database connection closed',
      );
    }
  }
}
