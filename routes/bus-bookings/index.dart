import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/bus/bus_booking_service.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.post:
      return BusBookingService.createBooking(context);
    case HttpMethod.get:
      return BusBookingService.getUserBookings(context);
    default:
      return Response.json(
        statusCode: HttpStatus.methodNotAllowed,
        body: {'status': 'error', 'message': 'Method not allowed. Use GET or POST.'},
      );
  }
}
