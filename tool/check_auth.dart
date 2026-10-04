import 'dart:convert';
import 'dart:io';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';

void main() async {
  final token = AuthUtils.createAccessToken(userId: 1, email: 'test@ticone.com');
  print('Generated JWT Token: $token');
  final verifiedId = AuthUtils.verifyAccessToken(token);
  print('Verified User ID: $verifiedId');
}
