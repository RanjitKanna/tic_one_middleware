import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

import 'package:tic_one_middleware/database.dart';

class RegisterService {
  static Future<Response> execute(RequestContext context) async {
    final body = await context.request.json();

    final name = body['name'];
    final email = body['email'];
    final password = body['password'];

    if (name is! String ||
        email is! String ||
        password is! String ||
        name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.length < 8) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message':
              'Valid name, email, and password of at least 8 characters are required.',
        },
      );
    }

    final normalizedEmail = email.trim().toLowerCase();

    final passwordHash = BCrypt.hashpw(
      password,
      BCrypt.gensalt(),
    );

    final db = await Database.connect();

    try {
      final result = await db.execute(
        Sql.named('''
          INSERT INTO login_auth (name, email, password_hash)
          VALUES (@name, @email, @passwordHash)
          RETURNING id, name, email, created_at
        '''),
        parameters: {
          'name': name.trim(),
          'email': normalizedEmail,
          'passwordHash': passwordHash,
        },
      );

      final row = result.first;

      return Response.json(
        statusCode: 201,
        body: {
          'success': true,
          'message': 'User registered successfully',
          'data': {
            'id': row[0],
            'name': row[1],
            'email': row[2],
            'createdAt': row[3].toString(),
          },
        },
      );
    } on ServerException catch (e) {
      if (e.code == '23505') {
        return Response.json(
          statusCode: 409,
          body: {
            'success': false,
            'message': 'Email already registered',
          },
        );
      }

      rethrow;
    } finally {
      await db.close();
    }
  }
}
