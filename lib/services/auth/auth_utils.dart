import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthUtils {
  // --------------------------------------------------
  // JWT CONFIGURATION
  // --------------------------------------------------

  static const String issuer = 'tic_one_middleware';

  static String get jwtSecret {
    final secret = Platform.environment['JWT_SECRET'];

    if (secret == null || secret.isEmpty) {
      throw StateError(
        'JWT_SECRET environment variable is not configured.',
      );
    }

    return secret;
  }

  // --------------------------------------------------
  // CREATE ACCESS TOKEN
  // --------------------------------------------------

  static String createAccessToken({
    required int userId,
    required String email,
  }) {
    final jwt = JWT(
      {
        'email': email,
        'type': 'access',
      },
      subject: userId.toString(),
      issuer: issuer,
    );

    return jwt.sign(
      SecretKey(jwtSecret),
      expiresIn: const Duration(minutes: 15),
    );
  }

  // --------------------------------------------------
  // CREATE RANDOM TOKEN
  // Used for refresh token / reset token
  // --------------------------------------------------

  static String createRandomToken() {
    final random = Random.secure();

    final bytes = List<int>.generate(
      32,
      (_) => random.nextInt(256),
    );

    return base64UrlEncode(bytes);
  }

  // --------------------------------------------------
  // HASH TOKEN
  // We store the hash in PostgreSQL,
  // not the actual refresh/reset token.
  // --------------------------------------------------

  static String hashToken(String token) {
    return sha256.convert(utf8.encode(token)).toString();
  }

  // --------------------------------------------------
  // GET BEARER TOKEN
  //
  // Authorization: Bearer eyJ....
  // --------------------------------------------------

  static String? getBearerToken(
    RequestContext context,
  ) {
    final authorization = context.request.headers['authorization'];

    if (authorization == null || authorization.trim().isEmpty) {
      return null;
    }

    final parts = authorization.trim().split(' ');

    if (parts.length != 2) {
      return null;
    }

    if (parts[0].toLowerCase() != 'bearer') {
      return null;
    }

    if (parts[1].isEmpty) {
      return null;
    }

    return parts[1];
  }

  // --------------------------------------------------
  // VERIFY ACCESS TOKEN
  // --------------------------------------------------

  static int verifyAccessToken(String token) {
    final jwt = JWT.verify(
      token,
      SecretKey(jwtSecret),
      issuer: issuer,
    );

    if (jwt.payload is! Map) {
      throw const FormatException(
        'Invalid token payload',
      );
    }

    final payload = Map<String, dynamic>.from(
      jwt.payload as Map,
    );

    // Make sure this is our access token
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

    return userId;
  }

  // --------------------------------------------------
  // READ JSON REQUEST BODY SAFELY
  // --------------------------------------------------

  static Future<Map<String, dynamic>?> readJson(
    RequestContext context,
  ) async {
    try {
      final body = await context.request.json();

      if (body is! Map) {
        return null;
      }

      return Map<String, dynamic>.from(body);
    } catch (_) {
      return null;
    }
  }
}
