import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/admin/admin_auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return AdminAuthService.getMe(context);
  }
  return Response(statusCode: 405);
}
