import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final stopwatch = Stopwatch()..start();

    final method = context.request.method;
    final uri = context.request.uri;

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

      return response;
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
