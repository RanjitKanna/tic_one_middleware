import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/admin/admin_theater_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.put:
    case HttpMethod.patch:
      return AdminTheaterService.updateScreen(context, id);
    case HttpMethod.delete:
      return AdminTheaterService.deleteScreen(context, id);
    default:
      return Response(statusCode: 405);
  }
}
