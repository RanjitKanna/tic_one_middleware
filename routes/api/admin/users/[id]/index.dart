import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/admin/admin_user_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return AdminUserService.getUserDetails(context, id);
    case HttpMethod.put:
    case HttpMethod.patch:
      return AdminUserService.updateUser(context, id);
    case HttpMethod.delete:
      return AdminUserService.deleteUser(context, id);
    default:
      return Response(statusCode: 405);
  }
}
