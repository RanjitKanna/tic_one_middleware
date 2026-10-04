import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/admin/admin_auth_service.dart';

class AdminBookingService {
  // ==========================================
  // MOVIE BOOKINGS
  // ==========================================

  static Future<Response> listMovieBookings(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final params = context.request.uri.queryParameters;
    final page = int.tryParse(params['page'] ?? '1') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
    final offset = (page - 1) * limit;
    final search = params['search']?.trim() ?? '';
    final status = params['status']?.trim() ?? '';
    final date = params['date']?.trim();

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>["1=1"];
      final sqlParams = <String, dynamic>{'limit': limit, 'offset': offset};

      if (search.isNotEmpty) {
        whereClauses.add("(LOWER(b.booking_code) LIKE @search OR LOWER(u.name) LIKE @search OR LOWER(u.email) LIKE @search OR LOWER(m.title) LIKE @search)");
        sqlParams['search'] = '%${search.toLowerCase()}%';
      }
      if (status.isNotEmpty && status != 'all') {
        whereClauses.add("LOWER(b.booking_status) = @status");
        sqlParams['status'] = status.toLowerCase();
      }
      if (date != null && date.isNotEmpty && date != 'all') {
        whereClauses.add("b.created_at::date = @date::date");
        sqlParams['date'] = date;
      }

      final whereSql = whereClauses.join(' AND ');

      final countRes = await conn.execute(
        Sql.named('''
          SELECT COUNT(*)
          FROM bookings b
          JOIN login_auth u ON b.user_id = u.id
          JOIN shows s ON b.show_id = s.id
          JOIN movies m ON s.movie_id = m.id
          WHERE $whereSql
        '''),
        parameters: sqlParams,
      );
      final total = int.parse(countRes.first[0].toString());

      final res = await conn.execute(
        Sql.named('''
          SELECT b.id, b.booking_code, b.user_id, u.name as user_name, u.email as user_email, u.phone as user_phone,
                 b.show_id, m.title as movie_title, m.image_url as movie_image,
                 t.name as theater_name, sc.screen_name, s.show_time, s.show_time_formatted,
                 b.total_seats, b.ticket_amount, b.convenience_fee, b.total_amount,
                 b.payment_status, b.booking_status, b.qr_code_data, b.created_at
          FROM bookings b
          JOIN login_auth u ON b.user_id = u.id
          JOIN shows s ON b.show_id = s.id
          JOIN movies m ON s.movie_id = m.id
          JOIN screens sc ON s.screen_id = sc.id
          JOIN theaters t ON sc.theater_id = t.id
          WHERE $whereSql
          ORDER BY b.created_at DESC
          LIMIT @limit OFFSET @offset
        '''),
        parameters: sqlParams,
      );

      final bookings = res.map((r) => {
        'id': r[0],
        'bookingCode': r[1],
        'userId': r[2],
        'userName': r[3],
        'userEmail': r[4],
        'userPhone': r[5],
        'showId': r[6],
        'movieTitle': r[7],
        'movieImage': r[8],
        'theaterName': r[9],
        'screenName': r[10],
        'showTime': (r[11] as DateTime).toIso8601String(),
        'showTimeFormatted': r[12],
        'totalSeats': r[13],
        'ticketAmount': double.parse(r[14].toString()),
        'convenienceFee': double.parse(r[15]?.toString() ?? '35.4'),
        'totalAmount': double.parse(r[16].toString()),
        'paymentStatus': r[17] ?? 'completed',
        'bookingStatus': r[18] ?? 'confirmed',
        'qrCodeData': r[19],
        'createdAt': (r[20] as DateTime).toIso8601String(),
      }).toList();

      return Response.json(
        body: {
          'bookings': bookings,
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

  static Future<Response> getMovieBookingDetails(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid booking ID'});

    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute(
        Sql.named('''
          SELECT b.id, b.booking_code, b.user_id, u.name as user_name, u.email as user_email, u.phone as user_phone,
                 b.show_id, m.title as movie_title, m.image_url as movie_image, m.language, m.format,
                 t.name as theater_name, t.address as theater_address, sc.screen_name,
                 s.show_time, s.show_time_formatted,
                 b.total_seats, b.ticket_amount, b.convenience_fee, b.total_amount,
                 b.payment_status, b.booking_status, b.qr_code_data, b.created_at
          FROM bookings b
          JOIN login_auth u ON b.user_id = u.id
          JOIN shows s ON b.show_id = s.id
          JOIN movies m ON s.movie_id = m.id
          JOIN screens sc ON s.screen_id = sc.id
          JOIN theaters t ON sc.theater_id = t.id
          WHERE b.id = @id
          LIMIT 1
        '''),
        parameters: {'id': id},
      );

      if (res.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Booking not found'});
      final r = res.first;

      final seatsRes = await conn.execute(
        Sql.named('''
          SELECT seat_identifier, tier_name, price
          FROM booking_seats
          WHERE booking_id = @id
        '''),
        parameters: {'id': id},
      );

      final seats = seatsRes.map((s) => {
        'seatIdentifier': s[0],
        'tierName': s[1],
        'price': double.parse(s[2].toString()),
      }).toList();

      return Response.json(
        body: {
          'booking': {
            'id': r[0],
            'bookingCode': r[1],
            'userId': r[2],
            'userName': r[3],
            'userEmail': r[4],
            'userPhone': r[5],
            'showId': r[6],
            'movieTitle': r[7],
            'movieImage': r[8],
            'movieLanguage': r[9],
            'movieFormat': r[10],
            'theaterName': r[11],
            'theaterAddress': r[12],
            'screenName': r[13],
            'showTime': (r[14] as DateTime).toIso8601String(),
            'showTimeFormatted': r[15],
            'totalSeats': r[16],
            'ticketAmount': double.parse(r[17].toString()),
            'convenienceFee': double.parse(r[18]?.toString() ?? '35.4'),
            'totalAmount': double.parse(r[19].toString()),
            'paymentStatus': r[20],
            'bookingStatus': r[21],
            'qrCodeData': r[22],
            'createdAt': (r[23] as DateTime).toIso8601String(),
            'seats': seats,
          },
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<Response> cancelMovieBooking(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid booking ID'});

    final body = await context.request.json();
    final reason = (body is Map ? body['reason'] : null)?.toString().trim() ?? 'Cancelled by Admin';
    final refundPct = double.tryParse((body is Map ? body['refundPercentage'] : null)?.toString() ?? '100') ?? 100.0;

    final conn = await openDatabaseConnection();
    try {
      final bRes = await conn.execute(
        Sql.named('SELECT id, booking_code, user_id, total_amount, booking_status FROM bookings WHERE id = @id LIMIT 1'),
        parameters: {'id': id},
      );
      if (bRes.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Booking not found'});

      final b = bRes.first;
      if (b[4] == 'cancelled') {
        return Response.json(statusCode: 400, body: {'error': 'Booking is already cancelled'});
      }

      final totalAmt = double.parse(b[3].toString());
      final refundAmt = (totalAmt * (refundPct / 100)).roundToDouble();

      // Update booking status
      await conn.execute(
        Sql.named("UPDATE bookings SET booking_status = 'cancelled', payment_status = 'refunded' WHERE id = @id"),
        parameters: {'id': id},
      );

      // Create refund record
      final refundId = 'REF-MOV-${DateTime.now().millisecondsSinceEpoch}';
      await conn.execute(
        Sql.named('''
          INSERT INTO movie_refunds (refund_id, booking_id, user_id, refund_amount, refund_method, refund_status)
          VALUES (@refId, @bid, @uid, @amt, 'original_source', 'completed')
        '''),
        parameters: {
          'refId': refundId,
          'bid': id,
          'uid': b[2],
          'amt': refundAmt,
        },
      );

      await AdminAuthService.logAction(
        adminId: admin['id'] as int,
        adminEmail: admin['email'] as String,
        action: 'CANCEL_MOVIE_BOOKING',
        entityType: 'movie_booking',
        entityId: id.toString(),
        details: {'reason': reason, 'refundAmount': refundAmt, 'refundId': refundId},
        connection: conn,
      );

      return Response.json(
        body: {
          'message': 'Movie booking cancelled and refund processed',
          'refundId': refundId,
          'refundAmount': refundAmt,
        },
      );
    } finally {
      await conn.close();
    }
  }

  // ==========================================
  // BUS BOOKINGS
  // ==========================================

  static Future<Response> listBusBookings(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final params = context.request.uri.queryParameters;
    final page = int.tryParse(params['page'] ?? '1') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
    final offset = (page - 1) * limit;
    final search = params['search']?.trim() ?? '';
    final status = params['status']?.trim() ?? '';
    final date = params['date']?.trim();

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>["1=1"];
      final sqlParams = <String, dynamic>{'limit': limit, 'offset': offset};

      if (search.isNotEmpty) {
        whereClauses.add("(LOWER(b.booking_code) LIKE @search OR LOWER(b.pnr_number) LIKE @search OR LOWER(u.name) LIKE @search OR LOWER(u.email) LIKE @search)");
        sqlParams['search'] = '%${search.toLowerCase()}%';
      }
      if (status.isNotEmpty && status != 'all') {
        whereClauses.add("LOWER(b.booking_status) = @status");
        sqlParams['status'] = status.toLowerCase();
      }
      if (date != null && date.isNotEmpty && date != 'all') {
        whereClauses.add("b.created_at::date = @date::date");
        sqlParams['date'] = date;
      }

      final whereSql = whereClauses.join(' AND ');

      final countRes = await conn.execute(
        Sql.named('''
          SELECT COUNT(*)
          FROM bus_bookings b
          JOIN login_auth u ON b.user_id = u.id
          JOIN bus_trips t ON b.trip_id = t.id
          JOIN bus_routes r ON t.route_id = r.id
          JOIN buses bus ON b.bus_id = bus.id
          WHERE $whereSql
        '''),
        parameters: sqlParams,
      );
      final total = int.parse(countRes.first[0].toString());

      final res = await conn.execute(
        Sql.named('''
          SELECT b.id, b.booking_code, b.pnr_number, b.user_id, u.name as user_name, u.email as user_email, u.phone as user_phone,
                 b.trip_id, bus.bus_name, bus.bus_number, bus.bus_type,
                 r.source_city, r.destination_city, t.travel_date, t.departure_time_formatted, t.arrival_time_formatted,
                 b.total_seats, b.base_fare_amount, b.convenience_fee, b.tax_amount, b.discount_amount, b.total_amount,
                 b.payment_status, b.booking_status, b.created_at
          FROM bus_bookings b
          JOIN login_auth u ON b.user_id = u.id
          JOIN bus_trips t ON b.trip_id = t.id
          JOIN bus_routes r ON t.route_id = r.id
          JOIN buses bus ON b.bus_id = bus.id
          WHERE $whereSql
          ORDER BY b.created_at DESC
          LIMIT @limit OFFSET @offset
        '''),
        parameters: sqlParams,
      );

      final bookings = res.map((r) => {
        'id': r[0],
        'bookingCode': r[1],
        'pnrNumber': r[2],
        'userId': r[3],
        'userName': r[4],
        'userEmail': r[5],
        'userPhone': r[6],
        'tripId': r[7],
        'busName': r[8],
        'busNumber': r[9],
        'busType': r[10],
        'sourceCity': r[11],
        'destinationCity': r[12],
        'travelDate': (r[13] is DateTime) ? (r[13] as DateTime).toIso8601String().substring(0, 10) : r[13].toString(),
        'departureTimeFormatted': r[14],
        'arrivalTimeFormatted': r[15],
        'totalSeats': r[16],
        'baseFare': double.parse(r[17].toString()),
        'convenienceFee': double.parse(r[18]?.toString() ?? '25.0'),
        'taxAmount': double.parse(r[19]?.toString() ?? '0.0'),
        'discountAmount': double.parse(r[20]?.toString() ?? '0.0'),
        'totalAmount': double.parse(r[21].toString()),
        'paymentStatus': r[22] ?? 'completed',
        'bookingStatus': r[23] ?? 'confirmed',
        'createdAt': (r[24] as DateTime).toIso8601String(),
      }).toList();

      return Response.json(
        body: {
          'bookings': bookings,
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

  static Future<Response> getBusBookingDetails(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid booking ID'});

    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute(
        Sql.named('''
          SELECT b.id, b.booking_code, b.pnr_number, b.user_id, u.name as user_name, u.email as user_email, u.phone as user_phone,
                 b.trip_id, bus.bus_name, bus.bus_number, bus.bus_type, o.name as operator_name,
                 r.source_city, r.destination_city, t.travel_date, t.departure_time, t.arrival_time,
                 t.departure_time_formatted, t.arrival_time_formatted,
                 bp.point_name as boarding_name, bp.time_formatted as boarding_time,
                 dp.point_name as dropping_name, dp.time_formatted as dropping_time,
                 b.total_seats, b.base_fare_amount, b.convenience_fee, b.tax_amount, b.discount_amount, b.total_amount,
                 b.payment_status, b.booking_status, b.contact_email, b.contact_phone, b.qr_code_data, b.created_at
          FROM bus_bookings b
          JOIN login_auth u ON b.user_id = u.id
          JOIN bus_trips t ON b.trip_id = t.id
          JOIN bus_routes r ON t.route_id = r.id
          JOIN buses bus ON b.bus_id = bus.id
          JOIN bus_operators o ON bus.operator_id = o.id
          LEFT JOIN boarding_points bp ON b.boarding_point_id = bp.id
          LEFT JOIN dropping_points dp ON b.dropping_point_id = dp.id
          WHERE b.id = @id
          LIMIT 1
        '''),
        parameters: {'id': id},
      );

      if (res.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Bus booking not found'});
      final r = res.first;

      // Passengers
      final passRes = await conn.execute(
        Sql.named('''
          SELECT seat_number, passenger_name, age, gender, seat_fare, seat_tier
          FROM bus_booking_passengers
          WHERE booking_id = @id
        '''),
        parameters: {'id': id},
      );

      final passengers = passRes.map((p) => {
        'seatNumber': p[0],
        'passengerName': p[1],
        'age': p[2],
        'gender': p[3],
        'seatFare': double.parse(p[4].toString()),
        'seatTier': p[5],
      }).toList();

      return Response.json(
        body: {
          'booking': {
            'id': r[0],
            'bookingCode': r[1],
            'pnrNumber': r[2],
            'userId': r[3],
            'userName': r[4],
            'userEmail': r[5],
            'userPhone': r[6],
            'tripId': r[7],
            'busName': r[8],
            'busNumber': r[9],
            'busType': r[10],
            'operatorName': r[11],
            'sourceCity': r[12],
            'destinationCity': r[13],
            'travelDate': (r[14] is DateTime) ? (r[14] as DateTime).toIso8601String().substring(0, 10) : r[14].toString(),
            'departureTime': (r[15] as DateTime).toIso8601String(),
            'arrivalTime': (r[16] as DateTime).toIso8601String(),
            'departureTimeFormatted': r[17],
            'arrivalTimeFormatted': r[18],
            'boardingName': r[19],
            'boardingTime': r[20],
            'droppingName': r[21],
            'droppingTime': r[22],
            'totalSeats': r[23],
            'baseFareAmount': double.parse(r[24].toString()),
            'convenienceFee': double.parse(r[25]?.toString() ?? '25.0'),
            'taxAmount': double.parse(r[26]?.toString() ?? '0.0'),
            'discountAmount': double.parse(r[27]?.toString() ?? '0.0'),
            'totalAmount': double.parse(r[28].toString()),
            'paymentStatus': r[29],
            'bookingStatus': r[30],
            'contactEmail': r[31],
            'contactPhone': r[32],
            'qrCodeData': r[33],
            'createdAt': (r[34] as DateTime).toIso8601String(),
            'passengers': passengers,
          },
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<Response> cancelBusBooking(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid booking ID'});

    final body = await context.request.json();
    final reason = (body is Map ? body['reason'] : null)?.toString().trim() ?? 'Cancelled by Admin';
    final refundPct = double.tryParse((body is Map ? body['refundPercentage'] : null)?.toString() ?? '90') ?? 90.0;

    final conn = await openDatabaseConnection();
    try {
      final bRes = await conn.execute(
        Sql.named('SELECT id, booking_code, user_id, total_amount, booking_status FROM bus_bookings WHERE id = @id LIMIT 1'),
        parameters: {'id': id},
      );
      if (bRes.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Bus booking not found'});

      final b = bRes.first;
      if (b[4] == 'cancelled') {
        return Response.json(statusCode: 400, body: {'error': 'Booking is already cancelled'});
      }

      final totalAmt = double.parse(b[3].toString());
      final refundAmt = (totalAmt * (refundPct / 100)).roundToDouble();

      // Update booking status
      await conn.execute(
        Sql.named("UPDATE bus_bookings SET booking_status = 'cancelled', payment_status = 'refunded' WHERE id = @id"),
        parameters: {'id': id},
      );

      // Record bus cancellation
      final cancelCode = 'CNL-BUS-${DateTime.now().millisecondsSinceEpoch}';
      final cancelInsert = await conn.execute(
        Sql.named('''
          INSERT INTO bus_cancellations (booking_id, user_id, cancellation_code, cancellation_reason, refund_percentage, refund_amount)
          VALUES (@bid, @uid, @code, @reason, @pct, @amt)
          RETURNING id
        '''),
        parameters: {
          'bid': id,
          'uid': b[2],
          'code': cancelCode,
          'reason': reason,
          'pct': refundPct,
          'amt': refundAmt,
        },
      );
      final cnlId = cancelInsert.first[0] as int;

      // Record bus refund
      final refundId = 'REF-BUS-${DateTime.now().millisecondsSinceEpoch}';
      await conn.execute(
        Sql.named('''
          INSERT INTO bus_refunds (refund_id, cancellation_id, booking_id, user_id, refund_amount, refund_method, refund_status)
          VALUES (@refId, @cnlId, @bid, @uid, @amt, 'original_payment_source', 'completed')
        '''),
        parameters: {
          'refId': refundId,
          'cnlId': cnlId,
          'bid': id,
          'uid': b[2],
          'amt': refundAmt,
        },
      );

      await AdminAuthService.logAction(
        adminId: admin['id'] as int,
        adminEmail: admin['email'] as String,
        action: 'CANCEL_BUS_BOOKING',
        entityType: 'bus_booking',
        entityId: id.toString(),
        details: {'reason': reason, 'refundAmount': refundAmt, 'refundId': refundId},
        connection: conn,
      );

      return Response.json(
        body: {
          'message': 'Bus booking cancelled and refund processed',
          'cancellationCode': cancelCode,
          'refundId': refundId,
          'refundAmount': refundAmt,
        },
      );
    } finally {
      await conn.close();
    }
  }
}
