import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) async {
    print(
      '➡️ ${context.request.method} ${context.request.uri}',
    );

    final response = await handler(context);

    print(
      '⬅️ ${response.statusCode}',
    );

    return response;
  };
}
