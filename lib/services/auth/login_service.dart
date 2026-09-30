import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';

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

    // Accept email, phone, or identifier
    final email = body['email'];
    final phone = body['phone'];
    final identifier = body['identifier'] ?? email ?? phone;
    final password = body['password'];

    // Validate fields
    if (identifier is! String || password is! String) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Email or mobile number, and password are required',
        },
      );
    }

    final cleanIdentifier = identifier.trim();

    if (cleanIdentifier.isEmpty || password.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Identifier and password cannot be empty',
        },
      );
    }

    final cleanEmail = cleanIdentifier.toLowerCase();

    // Connect to PostgreSQL
    final connection = await openDatabaseConnection();

    try {
      // Find user by email OR phone
      final result = await connection.execute(
        Sql.named('''
          SELECT
            id,
            name,
            email,
            phone,
            password_hash
          FROM login_auth
          WHERE email = @cleanEmail
             OR (phone IS NOT NULL AND phone = @cleanIdentifier)
          LIMIT 1
        '''),
        parameters: {
          'cleanEmail': cleanEmail,
          'cleanIdentifier': cleanIdentifier,
        },
      );

      // User does not exist
      if (result.isEmpty) {
        return Response.json(
          statusCode: 401,
          body: {
            'error': 'Invalid credentials. Please check your email/mobile and password.',
          },
        );
      }

      final row = result.first;

      final userId = row[0]! as int;
      final name = row[1]! as String;
      final userEmail = row[2]! as String;
      final userPhone = row[3] as String?;
      final passwordHash = row[4]! as String;

      // Verify password
      final passwordValid = BCrypt.checkpw(
        password,
        passwordHash,
      );

      if (!passwordValid) {
        return Response.json(
          statusCode: 401,
          body: {
            'error': 'Invalid credentials. Please check your email/mobile and password.',
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
        body: {
          'message': 'Login successful',
          'accessToken': accessToken,
          'refreshToken': refreshToken,
          'expiresIn': 900,
          'user': {
            'id': userId,
            'name': name,
            'email': userEmail,
            'phone': userPhone,
          },
        },
      );
    } finally {
      await connection.close();
    }
  }
}
