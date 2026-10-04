import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/admin/admin_bus_service.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return AdminBusService.listRoutes(context);
    case HttpMethod.post:
      return AdminBusService.createRoute(context);
    default:
      return Response(statusCode: 405);
  }
}
