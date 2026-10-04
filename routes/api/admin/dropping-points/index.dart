import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/admin/admin_trip_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return AdminTripService.listDroppingPoints(context);
  }
  return Response(statusCode: 405);
}
