import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/auth/login_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    return LoginService.execute(context);
  }

  return Response.json(
    statusCode: 405,
    body: {
      'success': false,
      'message': 'Method not allowed',
    },
  );
}
