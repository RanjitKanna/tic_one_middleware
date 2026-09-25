import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

import '../../database.dart';
import 'auth_utils.dart';

class RegisterService {
  static Future<Response> execute(
    RequestContext context,
  ) async {
    AppLogger.info(
      'REGISTER',
      '[01] Registration request received',
    );

    final body = await AuthUtils.readJson(context);

    if (body == null) {
      AppLogger.warning(
        'REGISTER',
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
      'REGISTER',
      '[03] JSON body parsed',
    );

    final name = body['name'];
    final email = body['email'];
    final password = body['password'];

    AppLogger.info(
      'REGISTER',
      '[04] Registration fields extracted',
    );

    if (name is! String || email is! String || password is! String) {
      AppLogger.warning(
        'REGISTER',
        '[05] Missing or invalid field types',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'name, email and password are required',
        },
      );
    }

    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    AppLogger.info(
      'REGISTER',
      '[06] Input cleaned',
    );

    if (cleanName.isEmpty || cleanEmail.isEmpty || password.isEmpty) {
      AppLogger.warning(
        'REGISTER',
        '[07] Empty input detected',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Name, email and password cannot be empty',
        },
      );
    }

    if (password.length < 8) {
      AppLogger.warning(
        'REGISTER',
        '[08] Password too short',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Password must contain at least 8 characters',
        },
      );
    }

    if (password.length > 72) {
      AppLogger.warning(
        'REGISTER',
        '[09] Password too long',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Password cannot exceed 72 characters',
        },
      );
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(cleanEmail)) {
      AppLogger.warning(
        'REGISTER',
        '[10] Invalid email format',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Invalid email address',
        },
      );
    }

    AppLogger.info(
      'REGISTER',
      '[11] Input validation passed',
    );

    AppLogger.info(
      'REGISTER',
      '[12] Hashing password',
    );

    final passwordHash = BCrypt.hashpw(
      password,
      BCrypt.gensalt(),
    );

    AppLogger.info(
      'REGISTER',
      '[13] Password hash generated',
    );

    AppLogger.info(
      'REGISTER',
      '[14] Opening database connection',
    );

    final connection = await openDatabaseConnection();

    try {
      AppLogger.info(
        'REGISTER',
        '[15] Database connected',
      );

      AppLogger.info(
        'REGISTER',
        '[16] Inserting user into login_auth',
      );

      final result = await connection.execute(
        Sql.named('''
          INSERT INTO login_auth (
            name,
            email,
            password_hash
          )
          VALUES (
            @name,
            @email,
            @passwordHash
          )
          ON CONFLICT (email) DO NOTHING
          RETURNING
            id,
            name,
            email,
            created_at
        '''),
        parameters: {
          'name': cleanName,
          'email': cleanEmail,
          'passwordHash': passwordHash,
        },
      );

      AppLogger.info(
        'REGISTER',
        '[17] Insert query completed',
      );

      if (result.isEmpty) {
        AppLogger.warning(
          'REGISTER',
          '[18] Email already exists',
        );

        return Response.json(
          statusCode: 409,
          body: {
            'error': 'Email already registered',
          },
        );
      }

      final row = result.first;

      AppLogger.info(
        'REGISTER',
        '[19] User created id=${row[0]}',
      );

      AppLogger.info(
        'REGISTER',
        '[20] Registration successful',
      );

      return Response.json(
        statusCode: 201,
        body: {
          'message': 'Registration successful',
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
        'REGISTER',
        'Registration failed',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      AppLogger.info(
        'REGISTER',
        '[21] Closing database connection',
      );

      await connection.close();

      AppLogger.info(
        'REGISTER',
        '[22] Database connection closed',
      );
    }
  }
}
