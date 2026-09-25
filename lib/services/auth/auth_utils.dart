import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:tic_one_middleware/config/env.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

class AuthUtils {
  static const String issuer = 'tic_one_middleware';

  // --------------------------------------------------
  // JWT SECRET
  // --------------------------------------------------

  static String get jwtSecret {
    AppLogger.info(
      'AUTH_UTIL',
      'Reading JWT secret from configuration',
    );

    final secret = Env.jwtSecret;

    if (secret.isEmpty) {
      AppLogger.error(
        'AUTH_UTIL',
        'JWT secret is empty',
      );

      throw StateError(
        'JWT_SECRET is not configured.',
      );
    }

    AppLogger.info(
      'AUTH_UTIL',
      'JWT secret loaded successfully',
    );

    return secret;
  }

  // --------------------------------------------------
  // CREATE ACCESS TOKEN
  // --------------------------------------------------

  static String createAccessToken({
    required int userId,
    required String email,
  }) {
    AppLogger.info(
      'AUTH_UTIL',
      'Creating access token for userId=$userId',
    );

    try {
      final jwt = JWT(
        {
          'email': email,
          'type': 'access',
        },
        subject: userId.toString(),
        issuer: issuer,
      );

      final token = jwt.sign(
        SecretKey(jwtSecret),
        expiresIn: const Duration(minutes: 15),
      );

      AppLogger.info(
        'AUTH_UTIL',
        'Access token created successfully',
      );

      return token;
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH_UTIL',
        'Access token creation failed',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // --------------------------------------------------
  // CREATE RANDOM TOKEN
  // --------------------------------------------------

  static String createRandomToken() {
    AppLogger.info(
      'AUTH_UTIL',
      'Generating random token',
    );

    final random = Random.secure();

    final bytes = List<int>.generate(
      32,
      (_) => random.nextInt(256),
    );

    final token = base64UrlEncode(bytes);

    AppLogger.info(
      'AUTH_UTIL',
      'Random token generated successfully',
    );

    return token;
  }

  // --------------------------------------------------
  // HASH TOKEN
  // --------------------------------------------------

  static String hashToken(String token) {
    AppLogger.info(
      'AUTH_UTIL',
      'Hashing token',
    );

    final hash = sha256.convert(utf8.encode(token)).toString();

    AppLogger.info(
      'AUTH_UTIL',
      'Token hash generated',
    );

    return hash;
  }

  // --------------------------------------------------
  // GET BEARER TOKEN
  // --------------------------------------------------

  static String? getBearerToken(
    RequestContext context,
  ) {
    AppLogger.info(
      'AUTH_UTIL',
      'Reading Authorization header',
    );

    final authorization = context.request.headers['authorization'];

    AppLogger.info(
      'AUTH_UTIL',
      'Authorization header exists=${authorization != null}',
    );

    if (authorization == null || authorization.trim().isEmpty) {
      AppLogger.warning(
        'AUTH_UTIL',
        'Authorization header missing',
      );
      return null;
    }

    final value = authorization.trim();

    final parts = value.split(RegExp(r'\s+'));

    AppLogger.info(
      'AUTH_UTIL',
      'Authorization parts=${parts.length}',
    );

    if (parts.length != 2) {
      AppLogger.warning(
        'AUTH_UTIL',
        'Expected: Bearer <JWT>',
      );
      return null;
    }

    final scheme = parts[0];
    var token = parts[1].trim();

    AppLogger.info(
      'AUTH_UTIL',
      'Authorization scheme=$scheme',
    );

    // Remove accidental quotes from Postman/client input.
    token = token.replaceAll('"', '');

    AppLogger.info(
      'AUTH_UTIL',
      'Token length=${token.length}',
    );

    final segments = token.split('.');

    AppLogger.info(
      'AUTH_UTIL',
      'JWT segments=${segments.length}',
    );

    if (scheme.toLowerCase() != 'bearer') {
      AppLogger.warning(
        'AUTH_UTIL',
        'Scheme is not Bearer',
      );
      return null;
    }

    if (segments.length != 3) {
      AppLogger.warning(
        'AUTH_UTIL',
        'Token is not in HEADER.PAYLOAD.SIGNATURE format',
      );
      return null;
    }

    AppLogger.info(
      'AUTH_UTIL',
      'JWT format is valid',
    );

    return token;
  }

  // --------------------------------------------------
  // VERIFY ACCESS TOKEN
  // --------------------------------------------------

  static int verifyAccessToken(String token) {
    AppLogger.info(
      'AUTH_UTIL',
      'Starting JWT verification',
    );

    AppLogger.info(
      'AUTH_UTIL',
      'Token length=${token.length}',
    );

    AppLogger.info(
      'AUTH_UTIL',
      'Token segments=${token.split('.').length}',
    );

    try {
      final jwt = JWT.verify(
        token,
        SecretKey(jwtSecret),
        issuer: issuer,
      );

      AppLogger.info(
        'AUTH_UTIL',
        'JWT signature verified',
      );

      if (jwt.payload is! Map) {
        throw const FormatException(
          'Invalid token payload',
        );
      }

      final payload = Map<String, dynamic>.from(
        jwt.payload as Map,
      );

      AppLogger.info(
        'AUTH_UTIL',
        'JWT type=${payload['type']}',
      );

      if (payload['type'] != 'access') {
        throw const FormatException(
          'Invalid token type',
        );
      }

      final subject = jwt.subject;

      if (subject == null || subject.isEmpty) {
        throw const FormatException(
          'Missing user ID',
        );
      }

      final userId = int.tryParse(subject);

      if (userId == null) {
        throw const FormatException(
          'Invalid user ID',
        );
      }

      AppLogger.info(
        'AUTH_UTIL',
        'JWT verification successful userId=$userId',
      );

      return userId;
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH_UTIL',
        'JWT verification failed',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // --------------------------------------------------
  // READ JSON
  // --------------------------------------------------

  static Future<Map<String, dynamic>?> readJson(
    RequestContext context,
  ) async {
    AppLogger.info(
      'AUTH_UTIL',
      'Reading request JSON body',
    );

    try {
      final body = await context.request.json();

      if (body is! Map) {
        AppLogger.warning(
          'AUTH_UTIL',
          'Request body is not a JSON object',
        );

        return null;
      }

      final json = Map<String, dynamic>.from(body);

      AppLogger.info(
        'AUTH_UTIL',
        'JSON body parsed successfully',
      );

      return json;
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH_UTIL',
        'JSON parsing failed',
        error: error,
        stackTrace: stackTrace,
      );

      return null;
    }
  }
}
