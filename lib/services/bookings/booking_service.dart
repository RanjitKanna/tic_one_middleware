import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';
import 'package:tic_one_middleware/services/wallet/wallet_service.dart';

class BookingService {
  static double _toDouble(dynamic val, [double def = 0.0]) {
    if (val == null) return def;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? def;
    return def;
  }

  // 1. Create Booking from Locked Seats
  static Future<Response> createBooking(RequestContext context) async {
    final token = AuthUtils.getBearerToken(context);
    if (token == null) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'status': 'error', 'message': 'Authentication required. Please login.'},
      );
    }

    int userId;
    try {
      userId = AuthUtils.verifyAccessToken(token);
    } catch (_) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'status': 'error', 'message': 'Invalid or expired session token.'},
      );
    }

    final body = await AuthUtils.readJson(context);
    if (body == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Request body must be a valid JSON object'},
      );
    }

    final showIdRaw = body['showId'];
    final lockToken = body['lockToken'] as String?;

    if (showIdRaw == null || lockToken == null || lockToken.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'showId and lockToken are required'},
      );
    }

    final showId = int.tryParse(showIdRaw.toString());
    if (showId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Invalid showId'},
      );
    }

    final connection = await openDatabaseConnection();

    try {
      // 1. Fetch locked seats
      final locksRes = await connection.execute(
        Sql.named('''
          SELECT
            sl.seat_id,
            st.seat_identifier,
            st.tier_name,
            st.multiplier,
            s.base_price
          FROM seat_locks sl
          JOIN seats st ON sl.seat_id = st.id
          JOIN shows s ON sl.show_id = s.id
          WHERE sl.show_id = @showId
            AND sl.lock_token = @lockToken
            AND sl.expires_at > CURRENT_TIMESTAMP
        '''),
        parameters: {
          'showId': showId,
          'lockToken': lockToken,
        },
      );

      if (locksRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.gone,
          body: {
            'status': 'error',
            'message': 'Seat lock expired or invalid. Please select your seats again.',
          },
        );
      }

      // Fetch user's active Royal Pass Premium status (Backend source of truth)
      final royalPass = await WalletService.getRoyalPass(connection, userId);
      final isPremium = royalPass['status'] == 'PREMIUM_USER' && (royalPass['isActive'] == true);

      // Calculate totals
      var subtotal = 0.0;
      final seatsList = <Map<String, dynamic>>[];

      for (final row in locksRes) {
        final seatId = row[0] as int;
        final identifier = row[1] as String;
        final tier = row[2] as String;
        final multiplier = _toDouble(row[3], 1.0);
        final basePrice = _toDouble(row[4], 250.0);
        final price = (basePrice * multiplier).roundToDouble();

        subtotal += price;
        seatsList.add({
          'seatId': seatId,
          'identifier': identifier,
          'tier': tier,
          'price': price,
        });
      }

      // Automatically apply 20% discount if Royal Pass Premium is active
      final discountAmount = isPremium ? (subtotal * 0.20).roundToDouble() : 0.0;
      const convenienceFee = 35.40;
      final totalAmount = (subtotal - discountAmount) + convenienceFee;

      final randSuffix = Random().nextInt(899999) + 100000;
      final bookingCode = 'TIC-${DateTime.now().year}-$randSuffix';

      final qrDataObj = {
        'code': bookingCode,
        'showId': showId,
        'userId': userId,
        'seats': seatsList.map((s) => s['identifier']).toList(),
        'issuedAt': DateTime.now().toIso8601String(),
      };
      final qrCodeData = base64UrlEncode(utf8.encode(jsonEncode(qrDataObj)));

      // Insert booking
      final bookingInsertRes = await connection.execute(
        Sql.named('''
          INSERT INTO bookings (
            booking_code, user_id, show_id, total_seats, ticket_amount,
            convenience_fee, total_amount, payment_status, booking_status, qr_code_data
          )
          VALUES (
            @code, @userId, @showId, @totalSeats, @ticketAmount,
            @convenienceFee, @totalAmount, 'completed', 'confirmed', @qrData
          )
          RETURNING id, created_at
        '''),
        parameters: {
          'code': bookingCode,
          'userId': userId,
          'showId': showId,
          'totalSeats': seatsList.length,
          'ticketAmount': subtotal,
          'convenienceFee': convenienceFee,
          'totalAmount': totalAmount,
          'qrData': qrCodeData,
        },
      );

      final bookingId = bookingInsertRes.first[0] as int;
      final createdAt = bookingInsertRes.first[1] as DateTime;

      // Insert booking seats
      for (final s in seatsList) {
        await connection.execute(
          Sql.named('''
            INSERT INTO booking_seats (booking_id, seat_id, seat_identifier, tier_name, price)
            VALUES (@bookingId, @seatId, @identifier, @tier, @price)
          '''),
          parameters: {
            'bookingId': bookingId,
            'seatId': s['seatId'],
            'identifier': s['identifier'],
            'tier': s['tier'],
            'price': s['price'],
          },
        );
      }

      // Clear the locks
      await connection.execute(
        Sql.named('DELETE FROM seat_locks WHERE show_id = @showId AND lock_token = @lockToken'),
        parameters: {
          'showId': showId,
          'lockToken': lockToken,
        },
      );

      // Fetch show & movie metadata for instant receipt
      final detailsRes = await connection.execute(
        Sql.named('''
          SELECT
            m.title as movie_title,
            m.image_url,
            m.format as movie_format,
            t.name as theater_name,
            t.address as theater_address,
            sc.screen_name,
            s.show_time,
            s.show_time_formatted,
            s.language
          FROM shows s
          JOIN movies m ON s.movie_id = m.id
          JOIN screens sc ON s.screen_id = sc.id
          JOIN theaters t ON sc.theater_id = t.id
          WHERE s.id = @showId
        '''),
        parameters: {'showId': showId},
      );

      final details = detailsRes.first;

      // Award CinePoints: 1 ticket book = 5 cinepoints
      final earnedPoints = seatsList.length * 5;
      final currentPoints = await WalletService.awardPoints(
        connection,
        userId,
        earnedPoints,
        'Movie Ticket Booking ($bookingCode - ${seatsList.length} tickets)',
        bookingCode,
      );

      return Response.json(
        statusCode: HttpStatus.created,
        body: {
          'status': 'success',
          'message': 'Booking confirmed successfully!',
          'data': {
            'bookingId': bookingId,
            'bookingCode': bookingCode,
            'bookingStatus': 'confirmed',
            'paymentStatus': 'completed',
            'createdAt': createdAt.toIso8601String(),
            'movie': {
              'title': details[0],
              'imageUrl': details[1],
              'format': details[2],
              'language': details[8],
            },
            'theater': {
              'name': details[3],
              'address': details[4],
              'screen': details[5],
            },
            'showTime': (details[6] as DateTime).toIso8601String(),
            'timeFormatted': details[7],
            'seats': seatsList,
            'pricing': {
              'ticketCount': seatsList.length,
              'subtotal': subtotal,
              'convenienceFee': convenienceFee,
              'totalAmount': totalAmount,
            },
            'qrCodeData': qrCodeData,
            'cinepointsEarned': earnedPoints,
            'currentCinepoints': currentPoints,
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BookingService', 'Error creating booking', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': e.toString()},
      );
    } finally {
      await connection.close();
    }
  }

  // 2. Get User's Booking History (My Tickets, Cancelled, Past, Upcoming)
  static Future<Response> getUserBookings(RequestContext context, [String? statusFilter]) async {
    final token = AuthUtils.getBearerToken(context);
    if (token == null) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'status': 'error', 'message': 'Authentication required.'},
      );
    }

    int userId;
    try {
      userId = AuthUtils.verifyAccessToken(token);
    } catch (_) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'status': 'error', 'message': 'Invalid session.'},
      );
    }

    final requestedStatus = (statusFilter ??
            context.request.uri.queryParameters['status'] ??
            context.request.uri.queryParameters['type'])
        ?.trim()
        .toLowerCase();

    var statusCondition = '';
    if (requestedStatus == 'cancelled') {
      statusCondition = "AND LOWER(b.booking_status) = 'cancelled'";
    } else if (requestedStatus == 'past' || requestedStatus == 'completed') {
      statusCondition =
          "AND (LOWER(b.booking_status) = 'completed' OR (LOWER(b.booking_status) = 'confirmed' AND s.show_time < CURRENT_TIMESTAMP))";
    } else if (requestedStatus == 'upcoming' || requestedStatus == 'active') {
      statusCondition =
          "AND LOWER(b.booking_status) = 'confirmed' AND s.show_time >= CURRENT_TIMESTAMP";
    }

    final connection = await openDatabaseConnection();

    try {
      final sqlQuery = '''
          SELECT
            b.id,
            b.booking_code,
            b.total_seats,
            b.ticket_amount,
            b.convenience_fee,
            b.total_amount,
            b.payment_status,
            b.booking_status,
            b.qr_code_data,
            b.created_at,
            m.title as movie_title,
            m.image_url as movie_poster,
            m.certificate,
            t.name as theater_name,
            t.address as theater_address,
            sc.screen_name,
            s.show_time,
            s.show_time_formatted,
            s.format,
            s.language,
            COALESCE(
              ARRAY_AGG(bs.seat_identifier ORDER BY bs.seat_identifier ASC),
              ARRAY[]::VARCHAR[]
            ) as booked_seats
          FROM bookings b
          JOIN shows s ON b.show_id = s.id
          JOIN movies m ON s.movie_id = m.id
          JOIN screens sc ON s.screen_id = sc.id
          JOIN theaters t ON sc.theater_id = t.id
          LEFT JOIN booking_seats bs ON bs.booking_id = b.id
          WHERE b.user_id = @userId
            $statusCondition
          GROUP BY b.id, b.booking_code, b.total_seats, b.ticket_amount, b.convenience_fee,
                   b.total_amount, b.payment_status, b.booking_status, b.qr_code_data, b.created_at,
                   m.title, m.image_url, m.certificate, t.name, t.address, sc.screen_name,
                   s.show_time, s.show_time_formatted, s.format, s.language
          ORDER BY b.created_at DESC
      ''';

      final result = await connection.execute(
        Sql.named(sqlQuery),
        parameters: {'userId': userId},
      );

      final now = DateTime.now();
      final bookings = result.map((row) {
        final seats = (row[20] as List?)?.cast<String>() ?? <String>[];
        final rawStatus = (row[7] as String? ?? 'confirmed').toLowerCase();
        final showDateTime = (row[16] as DateTime?) ?? now;
        final isPastShow = showDateTime.isBefore(now);

        var statusCategory = 'upcoming';
        var effectiveBookingStatus = row[7] as String? ?? 'confirmed';

        if (rawStatus == 'cancelled') {
          statusCategory = 'cancelled';
          effectiveBookingStatus = 'cancelled';
        } else if (rawStatus == 'completed' || isPastShow) {
          statusCategory = 'past';
          effectiveBookingStatus = rawStatus == 'confirmed' ? 'completed' : rawStatus;
        } else {
          statusCategory = 'upcoming';
          effectiveBookingStatus = 'confirmed';
        }

        return {
          'id': row[0],
          'bookingCode': row[1],
          'totalSeats': row[2],
          'ticketAmount': _toDouble(row[3]),
          'convenienceFee': _toDouble(row[4]),
          'totalAmount': _toDouble(row[5]),
          'paymentStatus': row[6],
          'bookingStatus': effectiveBookingStatus,
          'statusCategory': statusCategory,
          'qrCodeData': row[8],
          'createdAt': (row[9] as DateTime).toIso8601String(),
          'movie': {
            'title': row[10],
            'posterUrl': row[11],
            'certificate': row[12],
          },
          'theater': {
            'name': row[13],
            'address': row[14],
            'screen': row[15],
          },
          'showTime': showDateTime.toIso8601String(),
          'timeFormatted': row[17],
          'format': row[18],
          'language': row[19],
          'seats': seats,
        };
      }).toList();

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'filter': requestedStatus ?? 'all',
          'count': bookings.length,
          'data': bookings,
        },
      );
    } catch (e, st) {
      AppLogger.error('BookingService', 'Error fetching user bookings', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': e.toString()},
      );
    } finally {
      await connection.close();
    }
  }

  // 2.1 Get Cancelled Bookings
  static Future<Response> getCancelledBookings(RequestContext context) async {
    return getUserBookings(context, 'cancelled');
  }

  // 2.2 Get Past Bookings
  static Future<Response> getPastBookings(RequestContext context) async {
    return getUserBookings(context, 'past');
  }

  // 2.3 Get Upcoming Bookings
  static Future<Response> getUpcomingBookings(RequestContext context) async {
    return getUserBookings(context, 'upcoming');
  }

  // 3. Get Single Booking / Ticket by Code
  static Future<Response> getBookingByCode(RequestContext context, String bookingCode) async {
    final connection = await openDatabaseConnection();

    try {
      final result = await connection.execute(
        Sql.named('''
          SELECT
            b.id,
            b.booking_code,
            b.total_seats,
            b.ticket_amount,
            b.convenience_fee,
            b.total_amount,
            b.payment_status,
            b.booking_status,
            b.qr_code_data,
            b.created_at,
            m.title as movie_title,
            m.image_url as movie_poster,
            m.certificate,
            t.name as theater_name,
            t.address as theater_address,
            sc.screen_name,
            s.show_time,
            s.show_time_formatted,
            s.format,
            s.language,
            u.name as user_name,
            u.email as user_email,
            u.phone as user_phone,
            COALESCE(
              JSON_AGG(
                JSON_BUILD_OBJECT(
                  'seatId', bs.seat_id,
                  'identifier', bs.seat_identifier,
                  'tier', bs.tier_name,
                  'price', bs.price
                )
              ) FILTER (WHERE bs.id IS NOT NULL),
              '[]'::json
            ) as seats
          FROM bookings b
          JOIN shows s ON b.show_id = s.id
          JOIN movies m ON s.movie_id = m.id
          JOIN screens sc ON s.screen_id = sc.id
          JOIN theaters t ON sc.theater_id = t.id
          JOIN login_auth u ON b.user_id = u.id
          LEFT JOIN booking_seats bs ON bs.booking_id = b.id
          WHERE LOWER(b.booking_code) = LOWER(@code)
             OR CAST(b.id AS TEXT) = @code
          GROUP BY b.id, b.booking_code, b.total_seats, b.ticket_amount, b.convenience_fee,
                   b.total_amount, b.payment_status, b.booking_status, b.qr_code_data, b.created_at,
                   m.title, m.image_url, m.certificate, t.name, t.address, sc.screen_name,
                   s.show_time, s.show_time_formatted, s.format, s.language,
                   u.name, u.email, u.phone
          LIMIT 1
        '''),
        parameters: {'code': bookingCode.replaceAll('#', '').trim()},
      );

      if (result.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Booking not found'},
        );
      }

      final row = result.first;

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'data': {
            'id': row[0],
            'bookingCode': row[1],
            'totalSeats': row[2],
            'pricing': {
              'ticketAmount': _toDouble(row[3]),
              'convenienceFee': _toDouble(row[4]),
              'totalAmount': _toDouble(row[5]),
            },
            'paymentStatus': row[6],
            'bookingStatus': row[7],
            'qrCodeData': row[8],
            'createdAt': (row[9] as DateTime).toIso8601String(),
            'movie': {
              'title': row[10],
              'posterUrl': row[11],
              'certificate': row[12],
            },
            'theater': {
              'name': row[13],
              'address': row[14],
              'screen': row[15],
            },
            'show': {
              'showTime': (row[16] as DateTime).toIso8601String(),
              'timeFormatted': row[17],
              'format': row[18],
              'language': row[19],
            },
            'user': {
              'name': row[20],
              'email': row[21],
              'phone': row[22],
            },
            'seats': row[23],
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BookingService', 'Error getting booking $bookingCode', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': e.toString()},
      );
    } finally {
      await connection.close();
    }
  }

  // 4. Cancel Booking & Initiate Refund
  static Future<Response> cancelBooking(RequestContext context, [String? bookingCodeParam]) async {
    String? code = bookingCodeParam?.replaceAll('#', '').trim();
    String? reason;

    try {
      final body = await AuthUtils.readJson(context);
      if (body != null) {
        if (code == null || code.isEmpty) {
          code = body['bookingCode']?.toString().replaceAll('#', '').trim();
        }
        reason = body['reason']?.toString().trim();
      }
    } catch (_) {}

    if (code == null || code.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'bookingCode is required.'},
      );
    }

    final connection = await openDatabaseConnection();

    try {
      final selectRes = await connection.execute(
        Sql.named('''
          SELECT id, booking_code, total_amount, booking_status, payment_status, user_id
          FROM bookings
          WHERE LOWER(booking_code) = LOWER(@code)
             OR CAST(id AS TEXT) = @code
          LIMIT 1
        '''),
        parameters: {'code': code},
      );

      if (selectRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Booking not found.'},
        );
      }

      final row = selectRes.first;
      final bookingId = row[0] as int;
      final bookingCode = row[1] as String;
      final totalAmount = _toDouble(row[2]);
      final currentStatus = (row[3] as String).toLowerCase();

      if (currentStatus == 'cancelled') {
        return Response.json(
          body: {
            'status': 'success',
            'message': 'Booking $bookingCode is cancelled.',
            'data': {
              'bookingId': bookingId,
              'bookingCode': bookingCode,
              'bookingStatus': 'cancelled',
              'paymentStatus': 'refunded',
              'refundAmount': totalAmount,
              'refundStatus': 'completed',
            },
          },
        );
      }

      final now = DateTime.now().toUtc();
      await connection.execute(
        Sql.named('''
          UPDATE bookings
          SET booking_status = 'cancelled',
              payment_status = 'refunded'
          WHERE id = @id
        '''),
        parameters: {'id': bookingId},
      );

      AppLogger.info('BookingService', 'Booking $bookingCode cancelled successfully. Refund: ₹$totalAmount');

      return Response.json(
        body: {
          'status': 'success',
          'message': 'Booking $bookingCode cancelled successfully. Refund of ₹${totalAmount.toStringAsFixed(2)} initiated.',
          'data': {
            'bookingId': bookingId,
            'bookingCode': bookingCode,
            'bookingStatus': 'cancelled',
            'paymentStatus': 'refunded',
            'refundAmount': totalAmount,
            'refundStatus': 'initiated',
            'cancelledAt': now.toIso8601String(),
            if (reason != null && reason.isNotEmpty) 'reason': reason,
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BookingService', 'Error cancelling booking $code', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': e.toString()},
      );
    } finally {
      await connection.close();
    }
  }
}
