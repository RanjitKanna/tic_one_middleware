import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

class PromoService {
  static double _toDouble(dynamic val, [double def = 0.0]) {
    if (val == null) return def;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? def;
    return def;
  }

  /// GET /promos
  static Future<Response> getAllPromos(RequestContext context) async {
    final connection = await openDatabaseConnection();
    try {
      final result = await connection.execute(
        Sql.named('''
          SELECT id, code, title, description, discount_type, discount_value, min_order_amount, max_discount_amount, is_active
          FROM promos
          WHERE is_active = true
          ORDER BY id ASC
        '''),
      );

      final promoList = result.map((r) {
        return {
          'id': r[0],
          'code': r[1]?.toString() ?? '',
          'title': r[2]?.toString() ?? '',
          'description': r[3]?.toString() ?? '',
          'discountType': r[4]?.toString() ?? 'flat',
          'discountValue': _toDouble(r[5]),
          'minOrderAmount': _toDouble(r[6]),
          'maxDiscountAmount': r[7] != null ? _toDouble(r[7]) : null,
          'isActive': r[8] as bool? ?? true,
        };
      }).toList();

      return Response.json(
        body: {
          'status': 'success',
          'data': promoList,
        },
      );
    } catch (e, st) {
      AppLogger.error('PromoService', 'Error in getAllPromos: $e', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to load promos: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  /// POST /promos/validate
  static Future<Response> validatePromo(RequestContext context) async {
    final body = await AuthUtils.readJson(context);
    if (body == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Request body must be valid JSON'},
      );
    }

    final code = (body['code']?.toString() ?? '').trim().toUpperCase();
    final orderAmount = _toDouble(body['orderAmount']);

    if (code.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'isValid': false, 'message': 'Please enter a valid coupon code'},
      );
    }

    final connection = await openDatabaseConnection();
    try {
      final result = await connection.execute(
        Sql.named('''
          SELECT id, code, title, description, discount_type, discount_value, min_order_amount, max_discount_amount, is_active
          FROM promos
          WHERE UPPER(code) = @code AND is_active = true
          LIMIT 1
        '''),
        parameters: {'code': code},
      );

      if (result.isEmpty) {
        return Response.json(
          body: {
            'isValid': false,
            'message': 'Coupon code "$code" is invalid or expired.',
          },
        );
      }

      final r = result.first;
      final minOrder = _toDouble(r[6]);
      if (orderAmount < minOrder) {
        return Response.json(
          body: {
            'isValid': false,
            'message': 'Minimum order amount of ₹${minOrder.toStringAsFixed(0)} required for code "$code".',
          },
        );
      }

      final promoData = {
        'id': r[0],
        'code': r[1]?.toString() ?? '',
        'title': r[2]?.toString() ?? '',
        'description': r[3]?.toString() ?? '',
        'discountType': r[4]?.toString() ?? 'flat',
        'discountValue': _toDouble(r[5]),
        'minOrderAmount': minOrder,
        'maxDiscountAmount': r[7] != null ? _toDouble(r[7]) : null,
        'isActive': true,
      };

      return Response.json(
        body: {
          'isValid': true,
          'message': 'Coupon code "$code" applied successfully!',
          'data': promoData,
          ...promoData,
        },
      );
    } catch (e, st) {
      AppLogger.error('PromoService', 'Error in validatePromo: $e', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Validation failed: $e'},
      );
    } finally {
      await connection.close();
    }
  }
}
