import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/admin/admin_auth_service.dart';

class AdminSeatService {
  /// Get seats for a screen (and optionally show status)
  static Future<Response> getSeats(RequestContext context) async {
    final params = context.request.uri.queryParameters;
    final screenId = int.tryParse(params['screenId'] ?? '');
    final showId = int.tryParse(params['showId'] ?? '');

    if (screenId == null && showId == null) {
      return Response.json(statusCode: 400, body: {'error': 'screenId or showId is required'});
    }

    final conn = await openDatabaseConnection();
    try {
      var targetScreenId = screenId;
      var basePrice = 250.0;

      if (showId != null) {
        final showRes = await conn.execute(
          Sql.named('SELECT screen_id, base_price FROM shows WHERE id = @showId'),
          parameters: {'showId': showId},
        );
        if (showRes.isNotEmpty) {
          targetScreenId = showRes.first[0] as int;
          basePrice = double.tryParse(showRes.first[1]?.toString() ?? '250') ?? 250.0;
        }
      }

      if (targetScreenId == null) {
        return Response.json(statusCode: 404, body: {'error': 'Screen not found'});
      }

      // Fetch all seats in screen
      final seatsRes = await conn.execute(
        Sql.named('''
          SELECT id, row_label, seat_number, seat_identifier, tier_name, seat_type, multiplier, is_active
          FROM seats
          WHERE screen_id = @screenId
          ORDER BY row_label ASC, seat_number ASC
        '''),
        parameters: {'screenId': targetScreenId},
      );

      // Booked & locked seats if showId provided
      final bookedSeatIds = <int>{};
      final lockedSeatIds = <int>{};

      if (showId != null) {
        final bookedRes = await conn.execute(
          Sql.named('''
            SELECT bs.seat_id
            FROM booking_seats bs
            JOIN bookings b ON bs.booking_id = b.id
            WHERE b.show_id = @showId AND b.booking_status != 'cancelled'
          '''),
          parameters: {'showId': showId},
        );
        for (final r in bookedRes) {
          bookedSeatIds.add(r[0] as int);
        }

        final lockedRes = await conn.execute(
          Sql.named('SELECT seat_id FROM seat_locks WHERE show_id = @showId AND expires_at > CURRENT_TIMESTAMP'),
          parameters: {'showId': showId},
        );
        for (final r in lockedRes) {
          lockedSeatIds.add(r[0] as int);
        }
      }

      final seats = seatsRes.map((r) {
        final seatId = r[0] as int;
        final multiplier = double.tryParse(r[6]?.toString() ?? '1.0') ?? 1.0;
        final isActive = (r[7] as bool?) ?? true;

        var status = 'available';
        if (!isActive) {
          status = 'unavailable';
        } else if (bookedSeatIds.contains(seatId)) {
          status = 'booked';
        } else if (lockedSeatIds.contains(seatId)) {
          status = 'locked';
        }

        return {
          'id': seatId,
          'rowLabel': r[1],
          'seatNumber': r[2],
          'seatIdentifier': r[3],
          'tierName': r[4] ?? 'Gold',
          'seatType': r[5] ?? 'normal',
          'multiplier': multiplier,
          'price': (basePrice * multiplier).roundToDouble(),
          'isActive': isActive,
          'status': status,
        };
      }).toList();

      return Response.json(
        body: {
          'screenId': targetScreenId,
          'showId': showId,
          'basePrice': basePrice,
          'seats': seats,
        },
      );
    } finally {
      await conn.close();
    }
  }

  /// Add a single seat
  static Future<Response> addSeat(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final screenId = int.tryParse(body['screenId']?.toString() ?? '');
    final rowLabel = body['rowLabel']?.toString().trim().toUpperCase();
    final seatNumber = int.tryParse(body['seatNumber']?.toString() ?? '');
    final tierName = body['tierName']?.toString().trim() ?? 'Gold';
    final seatType = body['seatType']?.toString().trim() ?? 'normal';
    final multiplier = double.tryParse(body['multiplier']?.toString() ?? '1.0') ?? 1.0;

    if (screenId == null || rowLabel == null || rowLabel.isEmpty || seatNumber == null) {
      return Response.json(statusCode: 400, body: {'error': 'screenId, rowLabel, and seatNumber are required'});
    }

    final identifier = '$rowLabel$seatNumber';

    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute(
        Sql.named('''
          INSERT INTO seats (screen_id, row_label, seat_number, seat_identifier, tier_name, seat_type, multiplier, is_active)
          VALUES (@screenId, @rowLabel, @seatNumber, @identifier, @tierName, @seatType, @multiplier, true)
          ON CONFLICT (screen_id, row_label, seat_number) 
          DO UPDATE SET tier_name = @tierName, seat_type = @seatType, multiplier = @multiplier, is_active = true
          RETURNING id
        '''),
        parameters: {
          'screenId': screenId,
          'rowLabel': rowLabel,
          'seatNumber': seatNumber,
          'identifier': identifier,
          'tierName': tierName,
          'seatType': seatType,
          'multiplier': multiplier,
        },
      );

      return Response.json(statusCode: 201, body: {'message': 'Seat added successfully', 'id': res.first[0]});
    } finally {
      await conn.close();
    }
  }

  /// Update seat (tier, type, price multiplier, active status)
  static Future<Response> updateSeat(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid seat ID'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final conn = await openDatabaseConnection();
    try {
      final updates = <String>[];
      final sqlParams = <String, dynamic>{'id': id};

      if (body.containsKey('tierName')) {
        updates.add('tier_name = @tierName');
        sqlParams['tierName'] = body['tierName'].toString().trim();
      }
      if (body.containsKey('seatType')) {
        updates.add('seat_type = @seatType');
        sqlParams['seatType'] = body['seatType'].toString().trim();
      }
      if (body.containsKey('multiplier')) {
        updates.add('multiplier = @multiplier');
        sqlParams['multiplier'] = double.tryParse(body['multiplier'].toString()) ?? 1.0;
      }
      if (body.containsKey('isActive')) {
        updates.add('is_active = @isActive');
        sqlParams['isActive'] = body['isActive'] == true;
      }

      if (updates.isEmpty) return Response.json(statusCode: 400, body: {'error': 'No fields provided'});

      await conn.execute(
        Sql.named('UPDATE seats SET ${updates.join(', ')} WHERE id = @id'),
        parameters: sqlParams,
      );

      return Response.json(body: {'message': 'Seat updated successfully'});
    } finally {
      await conn.close();
    }
  }

  /// Delete seat
  static Future<Response> deleteSeat(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid seat ID'});

    final conn = await openDatabaseConnection();
    try {
      await conn.execute(
        Sql.named('DELETE FROM seats WHERE id = @id'),
        parameters: {'id': id},
      );
      return Response.json(body: {'message': 'Seat deleted successfully'});
    } finally {
      await conn.close();
    }
  }

  /// Batch generate / replace seats layout for a screen
  static Future<Response> batchGenerateLayout(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final screenId = int.tryParse(body['screenId']?.toString() ?? '');
    final rowsCount = int.tryParse(body['rows']?.toString() ?? '8') ?? 8;
    final seatsPerRow = int.tryParse(body['seatsPerRow']?.toString() ?? '12') ?? 12;
    final clearExisting = body['clearExisting'] == true;

    if (screenId == null) return Response.json(statusCode: 400, body: {'error': 'screenId is required'});

    final rowLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'];

    final conn = await openDatabaseConnection();
    try {
      if (clearExisting) {
        await conn.execute(
          Sql.named('DELETE FROM seats WHERE screen_id = @screenId'),
          parameters: {'screenId': screenId},
        );
      }

      var totalInserted = 0;
      for (var r = 0; r < rowsCount && r < rowLabels.length; r++) {
        final rowLabel = rowLabels[r];
        final tier = r < 2 ? 'Recliner' : (r < 5 ? 'Platinum' : 'Gold');
        final mult = r < 2 ? 1.6 : (r < 5 ? 1.25 : 1.0);

        for (var s = 1; s <= seatsPerRow; s++) {
          final ident = '$rowLabel$s';
          await conn.execute(
            Sql.named('''
              INSERT INTO seats (screen_id, row_label, seat_number, seat_identifier, tier_name, seat_type, multiplier, is_active)
              VALUES (@screenId, @rowLabel, @num, @ident, @tier, 'normal', @mult, true)
              ON CONFLICT (screen_id, row_label, seat_number) 
              DO UPDATE SET tier_name = @tier, multiplier = @mult, is_active = true
            '''),
            parameters: {
              'screenId': screenId,
              'rowLabel': rowLabel,
              'num': s,
              'ident': ident,
              'tier': tier,
              'mult': mult,
            },
          );
          totalInserted++;
        }
      }

      // Update screen total seats count
      await conn.execute(
        Sql.named('UPDATE screens SET total_seats = @total WHERE id = @screenId'),
        parameters: {'total': totalInserted, 'screenId': screenId},
      );

      return Response.json(
        body: {
          'message': 'Seating layout generated successfully',
          'totalSeats': totalInserted,
        },
      );
    } finally {
      await conn.close();
    }
  }
}
