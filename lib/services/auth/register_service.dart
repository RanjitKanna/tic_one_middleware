import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

class RegisterService {
  static Future<Response> execute(
    RequestContext context,
  ) async {
    // --------------------------------------------------
    // 1. Read request body
    // --------------------------------------------------

    final body = await context.request.json();

    // Make sure JSON is an object
    if (body is! Map) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Request body must be a JSON object',
        },
      );
    }

    // --------------------------------------------------
    // 2. Read fields
    // --------------------------------------------------

    final name = body['name'];
    final email = body['email'];
    final password = body['password'];

    // --------------------------------------------------
    // 3. Validate field types
    // --------------------------------------------------

    if (name is! String || email is! String || password is! String) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'name, email and password are required',
        },
      );
    }

    // --------------------------------------------------
    // 4. Clean input
    // --------------------------------------------------

    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    // --------------------------------------------------
    // 5. Check empty values
    // --------------------------------------------------

    if (cleanName.isEmpty || cleanEmail.isEmpty || password.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Name, email and password cannot be empty',
        },
      );
    }

    // --------------------------------------------------
    // 6. Validate password length
    // --------------------------------------------------

    if (password.length < 8) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Password must contain at least 8 characters',
        },
      );
    }

    // bcrypt has a 72-byte password input limit.
    if (password.length > 72) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Password cannot exceed 72 characters',
        },
      );
    }

    // --------------------------------------------------
    // 7. Basic email validation
    // --------------------------------------------------

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(cleanEmail)) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Invalid email address',
        },
      );
    }

    // --------------------------------------------------
    // 8. Hash password
    // --------------------------------------------------

    final passwordHash = BCrypt.hashpw(
      password,
      BCrypt.gensalt(),
    );

    // --------------------------------------------------
    // 9. Connect to PostgreSQL
    // --------------------------------------------------

    final connection = await openDatabaseConnection();

    try {
      // ------------------------------------------------
      // 10. Insert user
      // ------------------------------------------------

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

      // ------------------------------------------------
      // 11. Check duplicate email
      // ------------------------------------------------

      if (result.isEmpty) {
        return Response.json(
          statusCode: 409,
          body: {
            'error': 'Email already registered',
          },
        );
      }

      // ------------------------------------------------
      // 12. Read inserted row
      // ------------------------------------------------

      final row = result.first;

      // ------------------------------------------------
      // 13. Return response
      // ------------------------------------------------

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
    } finally {
      // ------------------------------------------------
      // 14. Always close database connection
      // ------------------------------------------------

      await connection.close();
    }
  }
}
