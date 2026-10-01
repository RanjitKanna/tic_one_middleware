import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/theaters/theater_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed'},
    );
  }

  return TheaterService.listTheaters(context);
}
