import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD',
  'Access-Control-Allow-Headers':
      'Origin, Content-Type, Authorization, Accept, X-Requested-With, Application, x-client-info',
  'Access-Control-Max-Age': '86400',
};

Handler middleware(Handler handler) {
  return (context) async {
    final method = context.request.method;
    final uri = context.request.uri;

    // ── Handle CORS Preflight (OPTIONS) ──
    if (method == HttpMethod.options) {
      return Response(
        statusCode: HttpStatus.noContent,
        headers: _corsHeaders,
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
