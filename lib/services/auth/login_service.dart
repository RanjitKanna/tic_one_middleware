import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:postgres/postgres.dart';

import 'package:tic_one_middleware/database.dart';

class LoginService {
  static Future<Response> execute(RequestContext context) async {
    final body = await context.request.json();

    final email = body['email'];
    final password = body['password'];

    if (email is! String ||
        password is! String ||
        email.trim().isEmpty ||
        password.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message': 'Email and password are required',
        },
      );
    }

    final jwtSecret = Platform.environment['JWT_SECRET'];

    if (jwtSecret == null || jwtSecret.isEmpty) {
      return Response.json(
        statusCode: 500,
        body: {
          'success': false,
          'message': 'Authentication is not configured',
        },
      );
    }

    final db = await Database.connect();

    try {
      final result = await db.execute(
        Sql.named('''
          SELECT id, name, email, password_hash
          FROM login_auth
          WHERE email = @email
        '''),
        parameters: {
          'email': email.trim().toLowerCase(),
        },
      );

      if (result.isEmpty) {
        return Response.json(
          statusCode: 401,
          body: {
            'success': false,
            'message': 'Invalid email or password',
          },
        );
      }

      final row = result.first;

      final passwordHash = row[3] as String;

      final isPasswordValid = BCrypt.checkpw(
        password,
        passwordHash,
      );

      if (!isPasswordValid) {
        return Response.json(
          statusCode: 401,
          body: {
            'success': false,
            'message': 'Invalid email or password',
          },
        );
      }

      final userId = row[0];

      final jwt = JWT(
        {
          'userId': userId,
          'email': row[2],
        },
        issuer: 'tic_one_middleware',
      );

      final token = jwt.sign(
        SecretKey(jwtSecret),
        expiresIn: const Duration(hours: 1),
      );

      return Response.json(
        body: {
          'success': true,
          'message': 'Login successful',
          'data': {
            'token': token,
            'user': {
              'id': userId,
              'name': row[1],
              'email': row[2],
            },
          },
        },
      );
    } finally {
      await db.close();
    }
  }
}
