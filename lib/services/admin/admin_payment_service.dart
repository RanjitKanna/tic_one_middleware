import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/admin/admin_auth_service.dart';

class AdminPaymentService {
  /// List all payments (Movie + Bus)
  static Future<Response> listPayments(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final params = context.request.uri.queryParameters;
    final page = int.tryParse(params['page'] ?? '1') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
    final offset = (page - 1) * limit;
    final search = params['search']?.trim() ?? '';
    final type = params['type']?.trim() ?? ''; // 'movie', 'bus', 'all'
    final status = params['status']?.trim() ?? '';

    final conn = await openDatabaseConnection();
    try {
      final sqlParams = <String, dynamic>{'limit': limit, 'offset': offset};

      var searchClauseBus = '1=1';
      var searchClauseMovie = '1=1';
      if (search.isNotEmpty) {
        searchClauseBus = "(LOWER(p.payment_id) LIKE @search OR LOWER(p.transaction_reference) LIKE @search OR LOWER(u.name) LIKE @search OR LOWER(u.email) LIKE @search)";
        searchClauseMovie = "(LOWER(b.booking_code) LIKE @search OR LOWER(u.name) LIKE @search OR LOWER(u.email) LIKE @search)";
        sqlParams['search'] = '%${search.toLowerCase()}%';
      }

      var statusClauseBus = '1=1';
      var statusClauseMovie = '1=1';
      if (status.isNotEmpty && status != 'all') {
        statusClauseBus = "LOWER(p.status) = @status";
        statusClauseMovie = "LOWER(b.payment_status) = @status";
        sqlParams['status'] = status.toLowerCase();
      }

      // Query unified payments
      final unionQuery = '''
        WITH unified_payments AS (
          SELECT 
            p.payment_id as payment_id,
            b.booking_code as booking_code,
            p.booking_id as booking_id,
            p.user_id as user_id,
            u.name as user_name,
            u.email as user_email,
            p.amount as amount,
            p.payment_method as payment_method,
            p.status as status,
            p.transaction_reference as transaction_ref,
            p.created_at as created_at,
            'bus' as booking_type
          FROM bus_payments p
          JOIN login_auth u ON p.user_id = u.id
          LEFT JOIN bus_bookings b ON p.booking_id = b.id
          WHERE $searchClauseBus AND $statusClauseBus

          UNION ALL

          SELECT 
            ('PAY-MOV-' || b.id) as payment_id,
            b.booking_code as booking_code,
            b.id as booking_id,
            b.user_id as user_id,
            u.name as user_name,
            u.email as user_email,
            b.total_amount as amount,
            'UPI / Card' as payment_method,
            b.payment_status as status,
            ('TXN-' || b.booking_code) as transaction_ref,
            b.created_at as created_at,
            'movie' as booking_type
          FROM bookings b
          JOIN login_auth u ON b.user_id = u.id
          WHERE $searchClauseMovie AND $statusClauseMovie
        )
        SELECT * FROM unified_payments
        ${type == 'movie' ? "WHERE booking_type = 'movie'" : (type == 'bus' ? "WHERE booking_type = 'bus'" : "")}
        ORDER BY created_at DESC
        LIMIT @limit OFFSET @offset;
      ''';

      final res = await conn.execute(Sql.named(unionQuery), parameters: sqlParams);

      final payments = res.map((r) => {
        'paymentId': r[0],
        'bookingCode': r[1],
        'bookingId': r[2],
        'userId': r[3],
        'userName': r[4],
        'userEmail': r[5],
        'amount': double.parse(r[6].toString()),
        'paymentMethod': r[7],
        'status': r[8] ?? 'completed',
        'transactionReference': r[9] ?? 'N/A',
        'createdAt': (r[10] as DateTime).toIso8601String(),
        'bookingType': r[11],
      }).toList();

      return Response.json(
        body: {
          'payments': payments,
          'pagination': {
            'page': page,
            'limit': limit,
            'total': payments.length + (page > 1 ? (page - 1) * limit : 0),
          },
        },
      );
    } finally {
      await conn.close();
    }
  }

  /// List Refunds (Movie + Bus)
  static Future<Response> listRefunds(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final params = context.request.uri.queryParameters;
    final page = int.tryParse(params['page'] ?? '1') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
    final offset = (page - 1) * limit;

    final conn = await openDatabaseConnection();
    try {
      final unionQuery = '''
        WITH unified_refunds AS (
          SELECT 
            r.refund_id,
            b.booking_code,
            r.booking_id,
            r.user_id,
            u.name as user_name,
            u.email as user_email,
            r.refund_amount,
            r.refund_method,
            r.refund_status,
            r.initiated_at as created_at,
            'bus' as booking_type
          FROM bus_refunds r
          JOIN login_auth u ON r.user_id = u.id
          JOIN bus_bookings b ON r.booking_id = b.id

          UNION ALL

          SELECT 
            r.refund_id,
            b.booking_code,
            r.booking_id,
            r.user_id,
            u.name as user_name,
            u.email as user_email,
            r.refund_amount,
            r.refund_method,
            r.refund_status,
            r.initiated_at as created_at,
            'movie' as booking_type
          FROM movie_refunds r
          JOIN login_auth u ON r.user_id = u.id
          JOIN bookings b ON r.booking_id = b.id
        )
        SELECT * FROM unified_refunds
        ORDER BY created_at DESC
        LIMIT @limit OFFSET @offset;
      ''';

      final res = await conn.execute(
        Sql.named(unionQuery),
        parameters: {'limit': limit, 'offset': offset},
      );

      final refunds = res.map((r) => {
        'refundId': r[0],
        'bookingCode': r[1],
        'bookingId': r[2],
        'userId': r[3],
        'userName': r[4],
        'userEmail': r[5],
        'refundAmount': double.parse(r[6].toString()),
        'refundMethod': r[7] ?? 'original_source',
        'refundStatus': r[8] ?? 'completed',
        'createdAt': (r[9] as DateTime).toIso8601String(),
        'bookingType': r[10],
      }).toList();

      return Response.json(
        body: {
          'refunds': refunds,
          'pagination': {'page': page, 'limit': limit},
        },
      );
    } finally {
      await conn.close();
    }
  }
}
