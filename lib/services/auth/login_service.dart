import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

import '../../database.dart';
import 'auth_utils.dart';

class LoginService {
  static Future<Response> execute(
    RequestContext context,
  ) async {
    AppLogger.info(
      'LOGIN',
      '[01] Login request received',
    );

    final body = await AuthUtils.readJson(context);

    if (body == null) {
      AppLogger.warning(
        'LOGIN',
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
      'LOGIN',
      '[03] JSON body parsed',
    );

    final email = body['email'];
    final password = body['password'];

    AppLogger.info(
      'LOGIN',
      '[04] Login fields extracted',
    );

    if (email is! String || password is! String) {
      AppLogger.warning(
        'LOGIN',
        '[05] Invalid email/password field types',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Email and password are required',
        },
      );
    }

    final cleanEmail = email.trim().toLowerCase();

    if (cleanEmail.isEmpty || password.isEmpty) {
      AppLogger.warning(
        'LOGIN',
        '[06] Empty email or password',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Email and password cannot be empty',
        },
      );
    }

    AppLogger.info(
      'LOGIN',
      '[07] Input validation passed',
    );

    AppLogger.info(
      'LOGIN',
      '[08] Connecting to database',
    );

    final connection = await openDatabaseConnection();

    try {
      AppLogger.info(
        'LOGIN',
        '[09] Database connected',
      );

      AppLogger.info(
        'LOGIN',
        '[10] Searching user in login_auth',
      );

      final result = await connection.execute(
        Sql.named('''
          SELECT
            id,
            name,
            email,
            password_hash
          FROM login_auth
          WHERE email = @email
          LIMIT 1
        '''),
        parameters: {
          'email': cleanEmail,
        },
      );

      AppLogger.info(
        'LOGIN',
        '[11] User query completed',
      );

      if (result.isEmpty) {
        AppLogger.warning(
          'LOGIN',
          '[12] User not found',
        );

        return Response.json(
          statusCode: 401,
          body: {
            'error': 'Invalid email or password',
          },
        );
      }

      final row = result.first;

      final userId = row[0] as int;
      final name = row[1] as String;
      final userEmail = row[2] as String;
      final passwordHash = row[3] as String;

      AppLogger.info(
        'LOGIN',
        '[13] User found id=$userId',
      );

      AppLogger.info(
        'LOGIN',
        '[14] Starting password verification',
      );

      final passwordValid = BCrypt.checkpw(
        password,
        passwordHash,
      );

      AppLogger.info(
        'LOGIN',
        '[15] Password verification completed',
      );

      if (!passwordValid) {
        AppLogger.warning(
          'LOGIN',
          '[16] Password verification failed',
        );

        return Response.json(
          statusCode: 401,
          body: {
            'error': 'Invalid email or password',
          },
        );
      }

      AppLogger.info(
        'LOGIN',
        '[17] Password verified successfully',
      );

      AppLogger.info(
        'LOGIN',
        '[18] Creating access token',
      );

      final accessToken = AuthUtils.createAccessToken(
        userId: userId,
        email: userEmail,
      );

      AppLogger.info(
        'LOGIN',
        '[19] Access token created',
      );

      AppLogger.info(
        'LOGIN',
        '[20] Creating refresh token',
      );

      final refreshToken = AuthUtils.createRandomToken();

      AppLogger.info(
        'LOGIN',
        '[21] Refresh token created',
      );

      AppLogger.info(
        'LOGIN',
        '[22] Hashing refresh token',
      );

      final refreshTokenHash = AuthUtils.hashToken(refreshToken);

      final refreshExpiresAt = DateTime.now().toUtc().add(
        const Duration(days: 30),
      );

      AppLogger.info(
        'LOGIN',
        '[23] Saving refresh token',
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
          'tokenHash': refreshTokenHash,
          'expiresAt': refreshExpiresAt,
        },
      );

      AppLogger.info(
        'LOGIN',
        '[24] Refresh token saved',
      );

      AppLogger.info(
        'LOGIN',
        '[25] Login successful for userId=$userId',
      );

      return Response.json(
        statusCode: 200,
        body: {
          'message': 'Login successful',
          'accessToken': accessToken,
          'refreshToken': refreshToken,
          'expiresIn': 900,
          'user': {
            'id': userId,
            'name': name,
            'email': userEmail,
          },
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'LOGIN',
        'Login failed unexpectedly',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      AppLogger.info(
        'LOGIN',
        'Closing database connection',
      );

      await connection.close();

      AppLogger.info(
        'LOGIN',
        'Database connection closed',
      );
    }
  }
}
