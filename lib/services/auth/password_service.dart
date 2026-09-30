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

    final email = body['email'] as String?;
    final phone = body['phone'] as String?;
    final identifier = (body['identifier'] as String?) ?? email ?? phone;
    final otp = body['otp'] as String?;
    final newPassword = body['newPassword'] as String?;

    // ==================================================
    // STAGE 1: IDENTIFIER ONLY = GENERATE OTP
    // ==================================================

    if (identifier != null &&
        identifier.trim().isNotEmpty &&
        otp == null &&
        newPassword == null) {
      return _generateOtp(
        rawIdentifier: identifier.trim(),
      );
    }

    // ==================================================
    // STAGE 2: IDENTIFIER + OTP + NEW PASSWORD = RESET
    // ==================================================

    if (identifier != null &&
        identifier.trim().isNotEmpty &&
        otp != null &&
        newPassword != null) {
      return _resetPassword(
        rawIdentifier: identifier.trim(),
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
        'error': 'Provide email/phone to request OTP, or email/phone + otp + newPassword to reset',
      },
    );
  }

  // Helper to normalize phone number
  static String? _normalizePhone(String input) {
    String digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }
    if (digits.length == 10) {
      return '+91$digits';
    }
    return null;
  }

  // ==================================================
  // GENERATE OTP
  // ==================================================

  static Future<Response> _generateOtp({
    required String rawIdentifier,
  }) async {
    AppLogger.info(
      'PASSWORD',
      '[REQUEST][01] OTP generation started for: $rawIdentifier',
    );

    final cleanIdentifier = rawIdentifier.trim().toLowerCase();
    final normalizedPhone = _normalizePhone(rawIdentifier) ?? cleanIdentifier;

    if (cleanIdentifier.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Email or phone number is required',
        },
      );
    }

    final connection = await openDatabaseConnection();

    try {
      AppLogger.info(
        'PASSWORD',
        '[REQUEST][05] Database connected',
      );

      // ----------------------------------------------
      // Find user by email OR phone
      // ----------------------------------------------

      final userResult = await connection.execute(
        Sql.named('''
          SELECT id, email, phone
          FROM login_auth
          WHERE email = @identifier
             OR phone = @identifier
             OR phone = @normalizedPhone
          LIMIT 1
        '''),
        parameters: {
          'identifier': cleanIdentifier,
          'normalizedPhone': normalizedPhone,
        },
      );

      AppLogger.info(
        'PASSWORD',
        '[REQUEST][06] User query completed',
      );

      // Same response whether user exists or not (security best practice)
      if (userResult.isEmpty) {
        AppLogger.info(
          'PASSWORD',
          '[REQUEST][07] No matching user for $cleanIdentifier',
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

      // Expiry = 10 minutes
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
      // DEVELOPMENT CONSOLE OTP LOG
      // ----------------------------------------------

      print('=============================================');
      print('DEV PASSWORD OTP: $otp (for $rawIdentifier)');
      print('=============================================');

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
    required String rawIdentifier,
    required String otp,
    required String newPassword,
  }) async {
    AppLogger.info(
      'PASSWORD',
      '[RESET][01] Password reset started for: $rawIdentifier',
    );

    final cleanIdentifier = rawIdentifier.trim().toLowerCase();
    final normalizedPhone = _normalizePhone(rawIdentifier) ?? cleanIdentifier;
    final cleanOtp = otp.trim();

    // ----------------------------------------------
    // Basic validation
    // ----------------------------------------------

    if (cleanIdentifier.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Email or phone is required',
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

    // ----------------------------------------------
    // Hash OTP
    // ----------------------------------------------

    final otpHash = AuthUtils.hashToken(cleanOtp);

    final connection = await openDatabaseConnection();

    try {
      AppLogger.info(
        'PASSWORD',
        '[RESET][07] Database connected',
      );

      // ----------------------------------------------
      // Find valid OTP for user (by email OR phone)
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
            AND (
              u.email = @identifier
              OR u.phone = @identifier
              OR u.phone = @normalizedPhone
            )
          ORDER BY pr.id DESC
          LIMIT 1
        '''),
        parameters: {
          'tokenHash': otpHash,
          'identifier': cleanIdentifier,
          'normalizedPhone': normalizedPhone,
        },
      );

      AppLogger.info(
        'PASSWORD',
        '[RESET][08] OTP query completed',
      );

      if (result.isEmpty) {
        AppLogger.warning(
          'PASSWORD',
          '[RESET][09] Invalid OTP or identifier',
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
        '[RESET][10] OTP found id=$resetTokenId userId=$userId',
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

      if (expiresAt.isBefore(DateTime.now().toUtc())) {
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

      // ----------------------------------------------
      // Hash new password
      // ----------------------------------------------

      final passwordHash = BCrypt.hashpw(
        newPassword,
        BCrypt.gensalt(),
      );

      // ----------------------------------------------
      // Update password in login_auth
      // ----------------------------------------------

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

      // ----------------------------------------------
      // Revoke all refresh tokens
      // ----------------------------------------------

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
        '[RESET][21] Password reset successful for userId=$userId',
      );

      return Response.json(
        statusCode: 200,
        body: {
          'message': 'Password reset successfully',
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
