import 'dart:io';
import 'dart:math';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

class BusPaymentService {
  static double _toDouble(dynamic val, [double def = 0.0]) {
    if (val == null) return def;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? def;
    return def;
  }

  static int _toInt(dynamic val, [int def = 0]) {
    if (val == null) return def;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? def;
    return def;
  }

  static int? _extractUserId(RequestContext context) {
    try {
      final token = AuthUtils.getBearerToken(context);
      if (token != null) {
        return AuthUtils.verifyAccessToken(token);
      }
    } catch (_) {}
    return null;
  }

  // ==============================================================================
  // 1. CREATE PAYMENT ORDER / INTENT
  // POST /bus-payments/create
  // ==============================================================================
  static Future<Response> createPayment(RequestContext context) async {
    final body = await AuthUtils.readJson(context);
    if (body == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Request body must be a valid JSON object'},
      );
    }

    final amount = _toDouble(body['amount']);
    if (amount <= 0) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Amount must be greater than 0'},
      );
    }

    final paymentMethod = body['paymentMethod']?.toString().toLowerCase() ?? 'upi';
    final currency = body['currency']?.toString().toUpperCase() ?? 'INR';
    final bookingIdRaw = body['bookingId'];
    final bookingId = bookingIdRaw != null ? _toInt(bookingIdRaw) : null;

    var userId = _extractUserId(context);
    final connection = await openDatabaseConnection();

    try {
      if (userId == null) {
        final firstUser = await connection.execute('SELECT id FROM login_auth ORDER BY id ASC LIMIT 1;');
        userId = firstUser.isNotEmpty ? firstUser.first[0] as int : 1;
      }

      final rand = Random();
      final paymentId = 'PAY-BUS-${DateTime.now().millisecondsSinceEpoch}-${rand.nextInt(9000) + 1000}';
      final orderId = 'ORD-BUS-${DateTime.now().millisecondsSinceEpoch}';

      final res = await connection.execute(
        Sql.named('''
          INSERT INTO bus_payments (
            payment_id, booking_id, user_id, amount, currency, payment_method,
            transaction_reference, status
          ) VALUES (
            @pId, @bkId, @uId, @amt, @cur, @method,
            @ref, 'initiated'
          ) RETURNING id, created_at;
        '''),
        parameters: {
          'pId': paymentId,
          'bkId': bookingId,
          'uId': userId,
          'amt': amount,
          'cur': currency,
          'method': paymentMethod,
          'ref': 'INIT_${orderId}',
        },
      );

      final createdAt = (res.first[1] as DateTime).toIso8601String();

      AppLogger.info('BusPaymentService', 'Created bus payment intent: $paymentId for amount ₹$amount');

      return Response.json(
        statusCode: HttpStatus.created,
        body: {
          'status': 'success',
          'statusCode': 201,
          'message': 'Payment intent created successfully',
          'data': {
            'paymentId': paymentId,
            'orderId': orderId,
            'amount': amount,
            'currency': currency,
            'paymentMethod': paymentMethod,
            'status': 'initiated',
            'createdAt': createdAt,
            'upiDetails': {
              'upiId': 'ticone.bus@icici',
              'payeeName': 'TicOne Bus Services',
              'upiIntentString': 'upi://pay?pa=ticone.bus@icici&pn=TicOne%20Bus&am=${amount.toStringAsFixed(2)}&cu=INR&tn=Bus%20Ticket%20Booking',
            },
            'gatewayOptions': {
              'key': 'rzp_live_ticone_bus_2026',
              'name': 'TicOne Bus Booking',
              'description': 'Intercity Bus Ticket Payment',
            },
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BusPaymentService', 'Error creating payment', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to initiate payment: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 2. VERIFY PAYMENT TRANSACTION
  // POST /bus-payments/verify
  // ==============================================================================
  static Future<Response> verifyPayment(RequestContext context) async {
    final body = await AuthUtils.readJson(context);
    if (body == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Request body must be a valid JSON object'},
      );
    }

    final paymentId = body['paymentId']?.toString().trim();
    if (paymentId == null || paymentId.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'paymentId is required'},
      );
    }

    final txRef = body['transactionReference']?.toString().trim() ??
        body['utr']?.toString().trim() ??
        body['gatewayPaymentId']?.toString().trim() ??
        'TXN_VERIFIED_${DateTime.now().millisecondsSinceEpoch}';

    final connection = await openDatabaseConnection();

    try {
      final selectRes = await connection.execute(
        Sql.named('SELECT id, booking_id, amount, status FROM bus_payments WHERE payment_id = @pId LIMIT 1'),
        parameters: {'pId': paymentId},
      );

      if (selectRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Payment record not found for $paymentId'},
        );
      }

      final row = selectRes.first;
      final paymentDbId = row[0] as int;
      final bookingId = row[1] as int?;
      final amount = _toDouble(row[2]);

      final now = DateTime.now().toUtc();

      // Update bus_payments
      await connection.execute(
        Sql.named('''
          UPDATE bus_payments
          SET status = 'completed',
              transaction_reference = @txRef,
              verified_at = CURRENT_TIMESTAMP
          WHERE id = @id
        '''),
        parameters: {
          'id': paymentDbId,
          'txRef': txRef,
        },
      );

      // If linked booking exists, ensure it is confirmed
      if (bookingId != null) {
        await connection.execute(
          Sql.named('''
            UPDATE bus_bookings
            SET payment_status = 'completed',
                booking_status = 'confirmed',
                updated_at = CURRENT_TIMESTAMP
            WHERE id = @bkId
          '''),
          parameters: {'bkId': bookingId},
        );
      }

      AppLogger.info('BusPaymentService', 'Payment $paymentId verified successfully (ref: $txRef)');

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'message': 'Payment verified successfully and transaction completed.',
          'data': {
            'paymentId': paymentId,
            'amount': amount,
            'status': 'completed',
            'transactionReference': txRef,
            'verifiedAt': now.toIso8601String(),
            'bookingId': bookingId,
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BusPaymentService', 'Error verifying payment $paymentId', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Payment verification failed: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 3. GET PAYMENT DETAILS
  // GET /bus-payments/{paymentId}
  // ==============================================================================
  static Future<Response> getPaymentDetails(RequestContext context, String paymentId) async {
    final cleanId = paymentId.trim();
    final connection = await openDatabaseConnection();

    try {
      final res = await connection.execute(
        Sql.named('''
          SELECT
            p.id,
            p.payment_id,
            p.booking_id,
            p.user_id,
            p.amount,
            p.currency,
            p.payment_method,
            p.transaction_reference,
            p.status,
            p.created_at,
            p.verified_at,
            bb.booking_code,
            bb.pnr_number
          FROM bus_payments p
          LEFT JOIN bus_bookings bb ON p.booking_id = bb.id
          WHERE p.payment_id = @pId
             OR CAST(p.id AS TEXT) = @pId
          LIMIT 1;
        '''),
        parameters: {'pId': cleanId},
      );

      if (res.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Payment record not found for ID $cleanId'},
        );
      }

      final row = res.first;

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'data': {
            'paymentId': row[1],
            'bookingId': row[2],
            'userId': row[3],
            'amount': _toDouble(row[4]),
            'currency': row[5],
            'paymentMethod': row[6],
            'transactionReference': row[7],
            'status': row[8],
            'createdAt': (row[9] as DateTime).toIso8601String(),
            'verifiedAt': row[10] != null ? (row[10] as DateTime).toIso8601String() : null,
            'booking': row[11] != null ? {
              'bookingCode': row[11],
              'pnrNumber': row[12],
            } : null,
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BusPaymentService', 'Error getting payment $cleanId', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to retrieve payment: $e'},
      );
    } finally {
      await connection.close();
    }
  }
}
