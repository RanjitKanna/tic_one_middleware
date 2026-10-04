import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/admin/admin_theater_service.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return AdminTheaterService.listTheaters(context);
    case HttpMethod.post:
      return AdminTheaterService.createTheater(context);
    default:
      return Response(statusCode: 405);
  }
}
