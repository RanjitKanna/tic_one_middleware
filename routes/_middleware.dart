import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods':
      'GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD',
  'Access-Control-Allow-Headers':
      'Origin, Content-Type, Authorization, Accept, X-Requested-With, Application, x-client-info',
  'Access-Control-Max-Age': '86400',
};

/// Transport-security headers. HSTS makes clients refuse plain HTTP to this
/// host; it is only honoured by clients when received over HTTPS.
const _securityHeaders = {
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'Referrer-Policy': 'no-referrer',
  'Cache-Control': 'no-store',
};

/// True when a TLS-terminating proxy (Railway, nginx, ...) reports that the
/// original client request was plain HTTP. Requests without the header
/// (local dev, internal health checks) are not affected.
bool _isInsecureProxiedRequest(Request request) {
  final proto = request.headers['x-forwarded-proto'];
  return proto != null && proto.split(',').first.trim().toLowerCase() == 'http';
}

/// Endpoints reachable without an access token: they are how a client obtains
/// or ends a session (logout is authorised by the refresh token in its body).
const _publicPaths = {
  '/auth/login',
  '/auth/register',
  '/auth/refresh-token',
  '/auth/forgot-password',
  '/auth/logout',
  '/api/admin/auth/login',
};

bool _isPublicPath(String path) {
  final normalized = path.length > 1 && path.endsWith('/')
      ? path.substring(0, path.length - 1)
      : path;
  return _publicPaths.contains(normalized);
}

/// Returns true only for a validly signed, unexpired access JWT.
bool _hasValidAccessToken(Request request) {
  final authorization = request.headers['authorization'];
  if (authorization == null) return false;
  final parts = authorization.trim().split(' ');
  if (parts.length != 2 || parts[0].toLowerCase() != 'bearer') return false;
  try {
    AuthUtils.verifyAccessToken(parts[1]);
    return true;
  } catch (_) {
    return false;
  }
}

Handler middleware(Handler handler) {
  return (context) async {
    final method = context.request.method;
    final uri = context.request.uri;

    // ── Enforce HTTPS: never serve API traffic over plain HTTP ──
    if (_isInsecureProxiedRequest(context.request)) {
      final host =
          context.request.headers['x-forwarded-host'] ??
          context.request.headers['host'] ??
          context.request.uri.host;
      return Response(
        statusCode: HttpStatus.permanentRedirect,
        headers: {
          'Location':
              'https://$host${uri.path}'
              '${uri.hasQuery ? '?${uri.query}' : ''}',
          ..._securityHeaders,
        },
      );
    }

    // ── Handle CORS Preflight (OPTIONS) ──
    if (method == HttpMethod.options) {
      return Response(
        statusCode: HttpStatus.noContent,
        headers: {..._corsHeaders, ..._securityHeaders},
      );
    }

    // ── Require a valid JWT on every route except session endpoints ──
    // Per-route services still run their own checks (user ownership, admin
    // role); this is the baseline so no endpoint is reachable anonymously.
    if (!_isPublicPath(uri.path) && !_hasValidAccessToken(context.request)) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        headers: {
          ..._corsHeaders,
          ..._securityHeaders,
          'WWW-Authenticate': 'Bearer',
        },
        body: {'status': 'error', 'message': 'Authentication required'},
      );
    }

    final stopwatch = Stopwatch()..start();

    AppLogger.info(
      'HTTP',
      'REQUEST $method $uri',
    );

    try {
      final response = await handler(context);

      stopwatch.stop();

      AppLogger.info(
        'HTTP',
        'RESPONSE $method $uri '
            'status=${response.statusCode} '
            'time=${stopwatch.elapsedMilliseconds}ms',
      );

      // Append CORS headers to all HTTP responses
      return response.copyWith(
        headers: {
          ...response.headers,
          ..._corsHeaders,
          ..._securityHeaders,
        },
      );
    } catch (error, stackTrace) {
      stopwatch.stop();

      AppLogger.error(
        'HTTP',
        'UNHANDLED ERROR $method $uri '
            'time=${stopwatch.elapsedMilliseconds}ms',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  };
}
