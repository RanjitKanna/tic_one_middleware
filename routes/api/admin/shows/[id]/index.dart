import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/admin/admin_show_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return AdminShowService.getShow(context, id);
    case HttpMethod.put:
    case HttpMethod.patch:
      return AdminShowService.updateShow(context, id);
    case HttpMethod.delete:
      return AdminShowService.deleteShow(context, id);
    default:
      return Response(statusCode: 405);
  }
}
