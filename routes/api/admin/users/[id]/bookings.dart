import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/admin/admin_user_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method == HttpMethod.get) {
    return AdminUserService.getUserDetails(context, id);
  }
  return Response(statusCode: 405);
}
