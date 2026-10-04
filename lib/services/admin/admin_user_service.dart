import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/admin/admin_auth_service.dart';

class AdminUserService {
  static Future<Response> listUsers(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Unauthorized: Admin privileges required'},
      );
    }

    final params = context.request.uri.queryParameters;
    final page = int.tryParse(params['page'] ?? '1') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
    final offset = (page - 1) * limit;
    final search = params['search']?.trim() ?? '';
    final role = params['role']?.trim() ?? '';
    final status = params['status']?.trim() ?? '';

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>["(is_deleted = false OR is_deleted IS NULL)"];
      final countParams = <String, dynamic>{};

      if (search.isNotEmpty) {
        whereClauses.add("(LOWER(name) LIKE @search OR LOWER(email) LIKE @search OR phone LIKE @search)");
        countParams['search'] = '%${search.toLowerCase()}%';
      }

      if (role.isNotEmpty && role != 'all') {
        whereClauses.add("LOWER(role) = @role");
        countParams['role'] = role.toLowerCase();
      }

      if (status.isNotEmpty && status != 'all') {
        if (status == 'active') {
          whereClauses.add("is_active = true");
        } else if (status == 'inactive') {
          whereClauses.add("is_active = false");
        }
      }

      final whereSql = whereClauses.join(' AND ');

      // Total count
      final countRes = await conn.execute(
        Sql.named('SELECT COUNT(*) FROM login_auth WHERE $whereSql'),
        parameters: countParams,
      );
      final total = int.parse(countRes.first[0].toString());

      // Fetch users
      final queryParams = Map<String, dynamic>.from(countParams)
        ..addAll({'limit': limit, 'offset': offset});

      final res = await conn.execute(
        Sql.named('''
          SELECT id, name, email, phone, role, is_active, created_at
          FROM login_auth
          WHERE $whereSql
          ORDER BY id DESC
          LIMIT @limit OFFSET @offset
        '''),
        parameters: queryParams,
      );

      final users = res.map((r) => {
        'id': r[0],
        'name': r[1],
        'email': r[2],
        'phone': r[3],
        'role': r[4] ?? 'user',
        'isActive': r[5] ?? true,
        'createdAt': (r[6] as DateTime?)?.toIso8601String(),
      }).toList();

      return Response.json(
        body: {
          'users': users,
          'pagination': {
            'page': page,
            'limit': limit,
            'total': total,
            'totalPages': (total / limit).ceil(),
          },
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<Response> getUserDetails(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) {
      return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});
    }

    final userId = int.tryParse(idStr);
    if (userId == null) {
      return Response.json(statusCode: 400, body: {'error': 'Invalid user ID'});
    }

    final conn = await openDatabaseConnection();
    try {
      final userRes = await conn.execute(
        Sql.named('''
          SELECT id, name, email, phone, role, is_active, created_at
          FROM login_auth
          WHERE id = @id
          LIMIT 1
        '''),
        parameters: {'id': userId},
      );

      if (userRes.isEmpty) {
        return Response.json(statusCode: 404, body: {'error': 'User not found'});
      }

      final r = userRes.first;
      final user = {
        'id': r[0],
        'name': r[1],
        'email': r[2],
        'phone': r[3],
        'role': r[4] ?? 'user',
        'isActive': r[5] ?? true,
        'createdAt': (r[6] as DateTime?)?.toIso8601String(),
      };

      final movieBookingsRes = await conn.execute(
        Sql.named('''
          SELECT b.id, b.booking_code, b.total_seats, b.total_amount, b.booking_status, b.payment_status, b.created_at, m.title
          FROM bookings b
          JOIN shows s ON b.show_id = s.id
          JOIN movies m ON s.movie_id = m.id
          WHERE b.user_id = @userId
          ORDER BY b.created_at DESC
        '''),
        parameters: {'userId': userId},
      );
      final movieBookings = movieBookingsRes.map((b) => {
        'id': b[0],
        'bookingCode': b[1],
        'seats': b[2],
        'amount': double.parse(b[3].toString()),
        'bookingStatus': b[4],
        'paymentStatus': b[5],
        'createdAt': (b[6] as DateTime).toIso8601String(),
        'movieTitle': b[7],
      }).toList();

      final busBookingsRes = await conn.execute(
        Sql.named('''
          SELECT b.id, b.booking_code, b.pnr_number, b.total_seats, b.total_amount, b.booking_status, b.payment_status, b.created_at,
                 (r.source_city || ' -> ' || r.destination_city) as route_name
          FROM bus_bookings b
          JOIN bus_trips t ON b.trip_id = t.id
          JOIN bus_routes r ON t.route_id = r.id
          WHERE b.user_id = @userId
          ORDER BY b.created_at DESC
        '''),
        parameters: {'userId': userId},
      );
      final busBookings = busBookingsRes.map((b) => {
        'id': b[0],
        'bookingCode': b[1],
        'pnrNumber': b[2],
        'seats': b[3],
        'amount': double.parse(b[4].toString()),
        'bookingStatus': b[5],
        'paymentStatus': b[6],
        'createdAt': (b[7] as DateTime).toIso8601String(),
        'routeName': b[8],
      }).toList();

      final paymentsRes = await conn.execute(
        Sql.named('''
          SELECT payment_id, amount, payment_method, status, transaction_reference, created_at, 'bus' as type
          FROM bus_payments
          WHERE user_id = @userId
          ORDER BY created_at DESC
        '''),
        parameters: {'userId': userId},
      );
      final payments = paymentsRes.map((p) => {
        'paymentId': p[0],
        'amount': double.parse(p[1].toString()),
        'paymentMethod': p[2],
        'status': p[3],
        'transactionRef': p[4],
        'createdAt': (p[5] as DateTime).toIso8601String(),
        'type': p[6],
      }).toList();

      return Response.json(
        body: {
          'user': user,
          'movieBookings': movieBookings,
          'busBookings': busBookings,
          'payments': payments,
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<Response> updateUser(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) {
      return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});
    }

    final userId = int.tryParse(idStr);
    if (userId == null) return Response.json(statusCode: 400, body: {'error': 'Invalid user ID'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final conn = await openDatabaseConnection();
    try {
      final updates = <String>[];
      final sqlParams = <String, dynamic>{'id': userId};

      if (body.containsKey('isActive')) {
        updates.add('is_active = @isActive');
        sqlParams['isActive'] = body['isActive'] == true;
      }
      if (body.containsKey('role')) {
        final role = body['role'].toString().toLowerCase();
        if (role == 'admin' || role == 'user') {
          updates.add('role = @role');
          sqlParams['role'] = role;
        }
      }

      if (updates.isEmpty) return Response.json(statusCode: 400, body: {'error': 'No fields provided'});

      await conn.execute(
        Sql.named('UPDATE login_auth SET ${updates.join(', ')} WHERE id = @id'),
        parameters: sqlParams,
      );

      return Response.json(body: {'message': 'User updated successfully'});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> deleteUser(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final userId = int.tryParse(idStr);
    if (userId == null) return Response.json(statusCode: 400, body: {'error': 'Invalid user ID'});

    final conn = await openDatabaseConnection();
    try {
      await conn.execute(
        Sql.named('UPDATE login_auth SET is_deleted = true, deleted_at = CURRENT_TIMESTAMP, is_active = false WHERE id = @id'),
        parameters: {'id': userId},
      );
      return Response.json(body: {'message': 'User deleted successfully'});
    } finally {
      await conn.close();
    }
  }
}
