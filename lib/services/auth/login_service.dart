import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

import '../../database.dart';
import 'auth_utils.dart';

class LoginService {
  static Future<Response> execute(
    RequestContext context,
  ) async {
    // Read request body
    final body = await context.request.json();

    if (body is! Map) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Request body must be a JSON object',
        },
      );
    }

    // Get login fields
    final email = body['email'];
    final password = body['password'];

    // Validate fields
    if (email is! String || password is! String) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Email and password are required',
        },
      );
    }

    final cleanEmail = email.trim().toLowerCase();

    if (cleanEmail.isEmpty || password.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Email and password cannot be empty',
        },
      );
    }

    // Connect to PostgreSQL
    final connection = await openDatabaseConnection();

    try {
      // Find user
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

      // User does not exist
      if (result.isEmpty) {
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

      // Verify password
      final passwordValid = BCrypt.checkpw(
        password,
        passwordHash,
      );

      if (!passwordValid) {
        return Response.json(
          statusCode: 401,
          body: {
            'error': 'Invalid email or password',
          },
        );
      }

      // Create access token
      final accessToken = AuthUtils.createAccessToken(
        userId: userId,
        email: userEmail,
      );

      // Create refresh token
      final refreshToken = AuthUtils.createRandomToken();

      // Never store raw refresh token in DB
      final refreshTokenHash = AuthUtils.hashToken(
        refreshToken,
      );

      final refreshExpiresAt = DateTime.now().toUtc().add(
        const Duration(days: 30),
      );

      // Save refresh token hash
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

      // Login successful
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
    } finally {
      await connection.close();
    }
  }
}
