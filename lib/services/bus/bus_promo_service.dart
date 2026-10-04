import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

class BusPromoService {
  static double _toDouble(dynamic val, [double def = 0.0]) {
    if (val == null) return def;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? def;
    return def;
  }

  // ==============================================================================
  // 1. VALIDATE PROMO CODE FOR BUS BOOKING
  // POST /bus-promos/validate
  // ==============================================================================
  static Future<Response> validatePromo(RequestContext context) async {
    final body = await AuthUtils.readJson(context);
    if (body == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Request body must be valid JSON'},
      );
    }

    final code = body['code']?.toString().trim().toUpperCase() ??
        body['promoCode']?.toString().trim().toUpperCase();
    final amount = _toDouble(body['amount'] ?? body['bookingAmount'] ?? body['subtotal']);

    if (code == null || code.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'promoCode is required'},
      );
    }

    if (amount <= 0) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Valid booking amount is required'},
      );
    }

    final connection = await openDatabaseConnection();

    try {
      final res = await connection.execute(
        Sql.named('''
          SELECT
            id,
            promo_code,
            title,
            description,
            discount_type,
            discount_value,
            min_booking_amount,
            max_discount_amount,
            valid_until,
            is_active
          FROM bus_promos
          WHERE UPPER(promo_code) = @code
          LIMIT 1;
        '''),
        parameters: {'code': code},
      );

      if (res.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {
            'status': 'error',
            'isValid': false,
            'message': 'Invalid promo code \'$code\'. Please check and try again.',
          },
        );
      }

      final row = res.first;
      final promoTitle = row[2] as String;
      final promoDesc = row[3] as String?;
      final discType = row[4] as String;
      final discVal = _toDouble(row[5]);
      final minAmt = _toDouble(row[6]);
      final maxDisc = _toDouble(row[7]);
      final validUntil = row[8] as DateTime?;
      final isActive = row[9] == true;

      final now = DateTime.now().toUtc();
      if (!isActive || (validUntil != null && validUntil.isBefore(now))) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'status': 'error',
            'isValid': false,
            'message': 'Promo code \'$code\' has expired.',
          },
        );
      }

      if (amount < minAmt) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'status': 'error',
            'isValid': false,
            'message': 'Minimum booking amount of ₹${minAmt.toStringAsFixed(2)} required to apply code \'$code\'.',
          },
        );
      }

      double discountAmount;
      if (discType == 'percentage') {
        discountAmount = (amount * (discVal / 100.0)).roundToDouble();
        if (maxDisc > 0 && discountAmount > maxDisc) {
          discountAmount = maxDisc;
        }
      } else {
        discountAmount = discVal;
      }

      if (discountAmount > amount) {
        discountAmount = amount;
      }

      final finalPayable = amount - discountAmount;

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'isValid': true,
          'message': 'Promo code \'$code\' applied successfully! You saved ₹${discountAmount.toStringAsFixed(2)}.',
          'data': {
            'promoCode': code,
            'title': promoTitle,
            'description': promoDesc,
            'discountType': discType,
            'discountValue': discVal,
            'originalAmount': amount,
            'discountAmount': discountAmount,
            'finalPayableAmount': finalPayable,
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BusPromoService', 'Error validating promo code $code', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to validate promo code: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 2. LIST ACTIVE PROMOS
  // GET /bus-promos
  // ==============================================================================
  static Future<Response> listPromos(RequestContext context) async {
    final connection = await openDatabaseConnection();

    try {
      final res = await connection.execute('''
        SELECT
          id,
          promo_code,
          title,
          description,
          discount_type,
          discount_value,
          min_booking_amount,
          max_discount_amount,
          valid_until
        FROM bus_promos
        WHERE is_active = true
          AND (valid_until IS NULL OR valid_until > CURRENT_TIMESTAMP)
        ORDER BY id ASC;
      ''');

      final promos = res.map((r) => {
        'id': r[0],
        'promoCode': r[1],
        'title': r[2],
        'description': r[3],
        'discountType': r[4],
        'discountValue': _toDouble(r[5]),
        'minBookingAmount': _toDouble(r[6]),
        'maxDiscountAmount': _toDouble(r[7]),
        'validUntil': r[8] != null ? (r[8] as DateTime).toIso8601String() : null,
      }).toList();

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'count': promos.length,
          'data': promos,
        },
      );
    } catch (e, st) {
      AppLogger.error('BusPromoService', 'Error listing bus promos', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to list promos: $e'},
      );
    } finally {
      await connection.close();
    }
  }
}
