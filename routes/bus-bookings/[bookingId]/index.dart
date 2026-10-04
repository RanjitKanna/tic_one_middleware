import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/bus/bus_booking_service.dart';

Future<Response> onRequest(RequestContext context, String bookingId) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed. Use GET.'},
    );
  }

  return BusBookingService.getBookingDetails(context, bookingId);
}
