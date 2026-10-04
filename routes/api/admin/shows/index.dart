import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/admin/admin_show_service.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return AdminShowService.listShows(context);
    case HttpMethod.post:
      return AdminShowService.createShow(context);
    default:
      return Response(statusCode: 405);
  }
}
