import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/wallet/wallet_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    return WalletService.purchaseRoyalPass(context);
  }

  return Response.json(
    statusCode: HttpStatus.methodNotAllowed,
    body: {'status': 'error', 'message': 'Method not allowed'},
  );
}
