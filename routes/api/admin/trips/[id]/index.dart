import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/admin/admin_trip_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return AdminTripService.getTrip(context, id);
    case HttpMethod.put:
    case HttpMethod.patch:
      return AdminTripService.updateTrip(context, id);
    case HttpMethod.delete:
      return AdminTripService.deleteTrip(context, id);
    default:
      return Response(statusCode: 405);
  }
}
