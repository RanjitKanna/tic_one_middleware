import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

import '../../database.dart';
import 'auth_utils.dart';

class PasswordService {
  static Future<Response> execute(
    RequestContext context,
  ) async {
    AppLogger.info(
      'PASSWORD',
      '[01] Password recovery request received',
    );

    final body = await AuthUtils.readJson(context);

    if (body == null) {
      AppLogger.warning(
        'PASSWORD',
        '[02] Invalid JSON body',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Invalid JSON body',
        },
      );
    }

    final email = body['email'];
    final otp = body['otp'];
    final newPassword = body['newPassword'];

    // ==================================================
    // STAGE 1
    // EMAIL ONLY = GENERATE OTP
    // ==================================================

    if (email is String && otp == null && newPassword == null) {
      return _generateOtp(
        email: email,
      );
    }

    // ==================================================
    // STAGE 2
    // EMAIL + OTP + NEW PASSWORD
    // ==================================================

    if (email is String && otp is String && newPassword is String) {
      return _resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
    }

    // ==================================================
    // INVALID REQUEST
    // ==================================================

    AppLogger.warning(
      'PASSWORD',
      '[03] Invalid password recovery request format',
    );

    return Response.json(
      statusCode: 400,
      body: {
        'error': 'Send email OR email, otp and newPassword',
      },
    );
  }

  // ==================================================
  // GENERATE OTP
  // ==================================================

  static Future<Response> _generateOtp({
    required String email,
  }) async {
    AppLogger.info(
      'PASSWORD',
      '[REQUEST][01] OTP generation started',
    );

    final cleanEmail = email.trim().toLowerCase();

    if (cleanEmail.isEmpty) {
      AppLogger.warning(
        'PASSWORD',
        '[REQUEST][02] Email is empty',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Email is required',
        },
      );
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(cleanEmail)) {
      AppLogger.warning(
        'PASSWORD',
        '[REQUEST][03] Invalid email format',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Invalid email address',
        },
      );
    }

    AppLogger.info(
      'PASSWORD',
      '[REQUEST][04] Email validated',
    );

    final connection = await openDatabaseConnection();

    try {
      AppLogger.info(
        'PASSWORD',
        '[REQUEST][05] Database connected',
      );

      // ----------------------------------------------
      // Find user
      // ----------------------------------------------

      final userResult = await connection.execute(
        Sql.named('''
          SELECT
            id
          FROM login_auth
          WHERE email = @email
          LIMIT 1
        '''),
        parameters: {
          'email': cleanEmail,
        },
      );

      AppLogger.info(
        'PASSWORD',
        '[REQUEST][06] User query completed',
      );

      // Same response whether user exists or not.
      if (userResult.isEmpty) {
        AppLogger.info(
          'PASSWORD',
          '[REQUEST][07] No matching user',
        );

        return Response.json(
          statusCode: 200,
          body: {
            'message': 'If the account exists, an OTP has been sent.',
          },
        );
      }

      final userId = userResult.first[0] as int;

      AppLogger.info(
        'PASSWORD',
        '[REQUEST][07] User found id=$userId',
      );

      // ----------------------------------------------
      // Delete previous unused OTP
      // ----------------------------------------------

      await connection.execute(
        Sql.named('''
          DELETE FROM password_reset_tokens
          WHERE user_id = @userId
            AND used_at IS NULL
        '''),
        parameters: {
          'userId': userId,
        },
      );

      AppLogger.info(
        'PASSWORD',
        '[REQUEST][08] Previous OTP records removed',
      );

      // ----------------------------------------------
      // Generate 6-digit OTP
      // ----------------------------------------------

      final random = Random.secure();

      final otp = random.nextInt(1000000).toString().padLeft(6, '0');

      AppLogger.info(
        'PASSWORD',
        '[REQUEST][09] 6-digit OTP generated',
      );

      // ----------------------------------------------
      // Hash OTP
      // ----------------------------------------------

      final otpHash = AuthUtils.hashToken(otp);

      AppLogger.info(
        'PASSWORD',
        '[REQUEST][10] OTP hash generated',
      );

      // ----------------------------------------------
      // Expiry = 10 minutes
      // ----------------------------------------------

      final expiresAt = DateTime.now().toUtc().add(
        const Duration(minutes: 10),
      );

      // ----------------------------------------------
      // Save OTP hash
      // ----------------------------------------------

      await connection.execute(
        Sql.named('''
          INSERT INTO password_reset_tokens (
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
          'tokenHash': otpHash,
          'expiresAt': expiresAt,
        },
      );

      AppLogger.info(
        'PASSWORD',
        '[REQUEST][11] OTP hash saved',
      );

      // ----------------------------------------------
      // DEVELOPMENT ONLY
      // ----------------------------------------------

      AppLogger.warning(
        'PASSWORD',
        '[REQUEST][12] DEV MODE OTP generated',
      );

      print(
        'DEV PASSWORD OTP: $otp',
      );

      AppLogger.info(
        'PASSWORD',
        '[REQUEST][13] OTP generation completed',
      );

      return Response.json(
        statusCode: 200,
        body: {
          'message': 'If the account exists, an OTP has been sent.',
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'PASSWORD',
        '[REQUEST][ERROR] OTP generation failed',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      await connection.close();

      AppLogger.info(
        'PASSWORD',
        '[REQUEST][14] Database connection closed',
      );
    }
  }

  // ==================================================
  // RESET PASSWORD USING OTP
  // ==================================================

  static Future<Response> _resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    AppLogger.info(
      'PASSWORD',
      '[RESET][01] Password reset started',
    );

    final cleanEmail = email.trim().toLowerCase();

    final cleanOtp = otp.trim();

    // ----------------------------------------------
    // Basic validation
    // ----------------------------------------------

    if (cleanEmail.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Email is required',
        },
      );
    }

    if (cleanOtp.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'OTP is required',
        },
      );
    }

    if (!RegExp(r'^\d{6}$').hasMatch(cleanOtp)) {
      AppLogger.warning(
        'PASSWORD',
        '[RESET][02] OTP format invalid',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'OTP must contain exactly 6 digits',
        },
      );
    }

    if (newPassword.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'New password is required',
        },
      );
    }

    if (newPassword.length < 8) {
      AppLogger.warning(
        'PASSWORD',
        '[RESET][03] New password too short',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'New password must contain at least 8 characters',
        },
      );
    }

    if (newPassword.length > 72) {
      AppLogger.warning(
        'PASSWORD',
        '[RESET][04] New password too long',
      );

      return Response.json(
        statusCode: 400,
        body: {
          'error': 'New password cannot exceed 72 characters',
        },
      );
    }

    AppLogger.info(
      'PASSWORD',
      '[RESET][05] Input validation passed',
    );

    // ----------------------------------------------
    // Hash OTP
    // ----------------------------------------------

    final otpHash = AuthUtils.hashToken(cleanOtp);

    AppLogger.info(
      'PASSWORD',
      '[RESET][06] OTP hash generated',
    );

    final connection = await openDatabaseConnection();

    try {
      AppLogger.info(
        'PASSWORD',
        '[RESET][07] Database connected',
      );

      // ----------------------------------------------
      // Find valid OTP
      // ----------------------------------------------

      final result = await connection.execute(
        Sql.named('''
          SELECT
            pr.id,
            pr.user_id,
            pr.expires_at,
            pr.used_at
          FROM password_reset_tokens pr
          INNER JOIN login_auth u
            ON u.id = pr.user_id
          WHERE pr.token_hash = @tokenHash
            AND u.email = @email
          ORDER BY pr.id DESC
          LIMIT 1
        '''),
        parameters: {
          'tokenHash': otpHash,
          'email': cleanEmail,
        },
      );

      AppLogger.info(
        'PASSWORD',
        '[RESET][08] OTP query completed',
      );

      if (result.isEmpty) {
        AppLogger.warning(
          'PASSWORD',
          '[RESET][09] Invalid OTP or email',
        );

        return Response.json(
          statusCode: 401,
          body: {
            'error': 'Invalid or expired OTP',
          },
        );
      }

      final row = result.first;

      final resetTokenId = row[0] as int;

      final userId = row[1] as int;

      final expiresAt = row[2] as DateTime;

      final usedAt = row[3];

      AppLogger.info(
        'PASSWORD',
        '[RESET][10] OTP found '
            'id=$resetTokenId userId=$userId',
      );

      // ----------------------------------------------
      // Check used
      // ----------------------------------------------

      if (usedAt != null) {
        AppLogger.warning(
          'PASSWORD',
          '[RESET][11] OTP already used',
        );

        return Response.json(
          statusCode: 401,
          body: {
            'error': 'OTP has already been used',
          },
        );
      }

      // ----------------------------------------------
      // Check expiry
      // ----------------------------------------------

      if (expiresAt.isBefore(
        DateTime.now().toUtc(),
      )) {
        AppLogger.warning(
          'PASSWORD',
          '[RESET][12] OTP expired',
        );

        return Response.json(
          statusCode: 401,
          body: {
            'error': 'OTP has expired',
          },
        );
      }

      AppLogger.info(
        'PASSWORD',
        '[RESET][13] OTP is valid',
      );

      // ----------------------------------------------
      // Hash new password
      // ----------------------------------------------

      AppLogger.info(
        'PASSWORD',
        '[RESET][14] Hashing new password',
      );

      final passwordHash = BCrypt.hashpw(
        newPassword,
        BCrypt.gensalt(),
      );

      AppLogger.info(
        'PASSWORD',
        '[RESET][15] New password hash created',
      );

      // ----------------------------------------------
      // Update password
      // ----------------------------------------------

      AppLogger.info(
        'PASSWORD',
        '[RESET][16] Updating login_auth',
      );

      await connection.execute(
        Sql.named('''
          UPDATE login_auth
          SET password_hash = @passwordHash
          WHERE id = @userId
        '''),
        parameters: {
          'passwordHash': passwordHash,
          'userId': userId,
        },
      );

      AppLogger.info(
        'PASSWORD',
        '[RESET][17] Password updated successfully',
      );

      // ----------------------------------------------
      // Mark OTP as used
      // ----------------------------------------------

      await connection.execute(
        Sql.named('''
          UPDATE password_reset_tokens
          SET used_at = CURRENT_TIMESTAMP
          WHERE id = @id
        '''),
        parameters: {
          'id': resetTokenId,
        },
      );

      AppLogger.info(
        'PASSWORD',
        '[RESET][18] OTP marked as used',
      );

      // ----------------------------------------------
      // Revoke all refresh tokens
      // ----------------------------------------------

      AppLogger.info(
        'PASSWORD',
        '[RESET][19] Revoking active refresh tokens',
      );

      await connection.execute(
        Sql.named('''
          UPDATE refresh_tokens
          SET revoked_at = CURRENT_TIMESTAMP
          WHERE user_id = @userId
            AND revoked_at IS NULL
        '''),
        parameters: {
          'userId': userId,
        },
      );

      AppLogger.info(
        'PASSWORD',
        '[RESET][20] Existing refresh tokens revoked',
      );

      AppLogger.info(
        'PASSWORD',
        '[RESET][21] Password reset successful',
      );

      return Response.json(
        statusCode: 200,
        body: {
          'message': 'Password reset successful',
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'PASSWORD',
        '[RESET][ERROR] Password reset failed',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      await connection.close();

      AppLogger.info(
        'PASSWORD',
        '[RESET][22] Database connection closed',
      );
    }
  }
}
