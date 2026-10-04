import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';

class AdminAuthService {
  /// Verify whether the request is from an authorized admin user.
  /// Returns the admin user Map or throws/returns null.
  static Future<Map<String, dynamic>?> authenticateAdmin(RequestContext context) async {
    final token = AuthUtils.getBearerToken(context);
    if (token == null) return null;

    try {
      final userId = AuthUtils.verifyAccessToken(token);
      final conn = await openDatabaseConnection();
      try {
        final result = await conn.execute(
          Sql.named('''
            SELECT id, name, email, role, is_active, phone
            FROM login_auth
            WHERE id = @userId
            LIMIT 1
          '''),
          parameters: {'userId': userId},
        );

        if (result.isEmpty) return null;
        final row = result.first;
        final role = (row[3] as String?)?.toLowerCase() ?? 'user';
        final isActive = (row[4] as bool?) ?? true;

        if (role != 'admin' && role != 'super_admin') return null;
        if (!isActive) return null;

        return {
          'id': row[0] as int,
          'name': row[1] as String,
          'email': row[2] as String,
          'role': role,
          'is_active': isActive,
          'phone': row[5] as String?,
        };
      } finally {
        await conn.close();
      }
    } catch (_) {
      return null;
    }
  }

  /// Admin Login handler
  static Future<Response> login(RequestContext context) async {
    final body = await context.request.json();
    if (body is! Map) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid JSON body'},
      );
    }

    final identifier = (body['email'] ?? body['identifier'])?.toString().trim();
    final password = body['password']?.toString();

    if (identifier == null || identifier.isEmpty || password == null || password.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Email and password are required'},
      );
    }

    final conn = await openDatabaseConnection();
    try {
      final result = await conn.execute(
        Sql.named('''
          SELECT id, name, email, phone, password_hash, role, is_active
          FROM login_auth
          WHERE LOWER(email) = LOWER(@identifier) OR phone = @identifier
          LIMIT 1
        '''),
        parameters: {'identifier': identifier},
      );

      if (result.isEmpty) {
        return Response.json(
          statusCode: 401,
          body: {'error': 'Invalid admin credentials'},
        );
      }

      final row = result.first;
      final userId = row[0] as int;
      final name = row[1] as String;
      final userEmail = row[2] as String;
      final userPhone = row[3] as String?;
      final passwordHash = row[4] as String;
      final role = (row[5] as String?)?.toLowerCase() ?? 'user';
      final isActive = (row[6] as bool?) ?? true;

      if (role != 'admin' && role != 'super_admin') {
        return Response.json(
          statusCode: 403,
          body: {'error': 'Access denied: Admin privileges required'},
        );
      }

      if (!isActive) {
        return Response.json(
          statusCode: 403,
          body: {'error': 'Account has been disabled. Contact system administrator.'},
        );
      }

      final isValid = BCrypt.checkpw(password, passwordHash);
      if (!isValid) {
        return Response.json(
          statusCode: 401,
          body: {'error': 'Invalid admin credentials'},
        );
      }

      final accessToken = AuthUtils.createAccessToken(
        userId: userId,
        email: userEmail,
      );
      final refreshToken = AuthUtils.createRandomToken();
      final refreshTokenHash = AuthUtils.hashToken(refreshToken);

      await conn.execute(
        Sql.named('''
          INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
          VALUES (@userId, @tokenHash, @expiresAt)
        '''),
        parameters: {
          'userId': userId,
          'tokenHash': refreshTokenHash,
          'expiresAt': DateTime.now().toUtc().add(const Duration(days: 30)),
        },
      );

      // Record audit log
      await conn.execute(
        Sql.named('''
          INSERT INTO audit_logs (admin_id, admin_email, action, entity_type, entity_id, details)
          VALUES (@adminId, @adminEmail, 'ADMIN_LOGIN', 'auth', @adminIdStr, @details)
        '''),
        parameters: {
          'adminId': userId,
          'adminEmail': userEmail,
          'adminIdStr': userId.toString(),
          'details': jsonEncode({'ip': context.request.headers['x-forwarded-for'] ?? 'local'}),
        },
      );

      return Response.json(
        body: {
          'message': 'Admin login successful',
          'accessToken': accessToken,
          'refreshToken': refreshToken,
          'expiresIn': 900,
          'user': {
            'id': userId,
            'name': name,
            'email': userEmail,
            'phone': userPhone,
            'role': role,
          },
        },
      );
    } finally {
      await conn.close();
    }
  }

  /// Get current admin details
  static Future<Response> getMe(RequestContext context) async {
    final admin = await authenticateAdmin(context);
    if (admin == null) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Unauthorized: Valid admin token required'},
      );
    }

    return Response.json(body: {'user': admin});
  }

  /// Logout
  static Future<Response> logout(RequestContext context) async {
    final admin = await authenticateAdmin(context);
    if (admin == null) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Unauthorized'},
      );
    }

    return Response.json(body: {'message': 'Logged out successfully'});
  }

  /// Helper to record audit log
  static Future<void> logAction({
    required int adminId,
    required String adminEmail,
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? details,
    Connection? connection,
  }) async {
    final conn = connection ?? await openDatabaseConnection();
    try {
      await conn.execute(
        Sql.named('''
          INSERT INTO audit_logs (admin_id, admin_email, action, entity_type, entity_id, details)
          VALUES (@adminId, @adminEmail, @action, @entityType, @entityId, @details)
        '''),
        parameters: {
          'adminId': adminId,
          'adminEmail': adminEmail,
          'action': action,
          'entityType': entityType,
          'entityId': entityId,
          'details': details != null ? jsonEncode(details) : null,
        },
      );
    } catch (_) {
      // Ignore logging failure to prevent breaking main operation
    } finally {
      if (connection == null) {
        await conn.close();
      }
    }
  }
}
