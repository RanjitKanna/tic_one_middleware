import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/auth/password_service.dart';

Future<Response> onRequest(
  RequestContext context,
) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {
        'error': 'Method not allowed',
      },
    );
  }

  return PasswordService.execute(context);
}
