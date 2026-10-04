import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/admin/admin_seat_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.put:
    case HttpMethod.patch:
      return AdminSeatService.updateSeat(context, id);
    case HttpMethod.delete:
      return AdminSeatService.deleteSeat(context, id);
    default:
      return Response(statusCode: 405);
  }
}
