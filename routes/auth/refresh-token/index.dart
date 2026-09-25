import 'package:dart_frog/dart_frog.dart';

import '../../../lib/services/auth/refresh_token_service.dart';

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

  return RefreshTokenService.execute(context);
}
