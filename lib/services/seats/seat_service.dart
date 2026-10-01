import 'dart:io';
import 'dart:math';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

class SeatService {
  static double _toDouble(dynamic val, [double def = 0.0]) {
    if (val == null) return def;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? def;
    return def;
  }

  // 1. Get Seat Layout & Status for a Show
  static Future<Response> getShowSeats(RequestContext context, String showIdStr) async {
    final showId = int.tryParse(showIdStr);
    if (showId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Invalid show ID'},
      );
    }

    final connection = await openDatabaseConnection();

    try {
      // Fetch show header
      final showRes = await connection.execute(
        Sql.named('''
          SELECT
            s.id,
            m.title as movie_title,
            m.certificate,
            m.duration_mins,
            t.name as theater_name,
            t.address as theater_address,
            sc.id as screen_id,
            sc.screen_name,
            s.show_time,
            s.show_time_formatted,
            s.format,
            s.language,
            s.base_price
          FROM shows s
          JOIN movies m ON s.movie_id = m.id
          JOIN screens sc ON s.screen_id = sc.id
          JOIN theaters t ON sc.theater_id = t.id
          WHERE s.id = @showId
          LIMIT 1
        '''),
        parameters: {'showId': showId},
      );

      if (showRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Show not found'},
        );
      }

      final showRow = showRes.first;
      final screenId = showRow[6] as int;
      final basePrice = _toDouble(showRow[12], 250.0);

      // Clean expired locks
      await connection.execute(
        Sql.named('DELETE FROM seat_locks WHERE expires_at <= CURRENT_TIMESTAMP'),
      );

      // Fetch all seats for the screen
      final seatsRes = await connection.execute(
        Sql.named('''
          SELECT
            st.id,
            st.row_label,
            st.seat_number,
            st.seat_identifier,
            st.tier_name,
            st.seat_type,
            st.multiplier,
            CASE
              WHEN bs.id IS NOT NULL THEN 'booked'
              WHEN sl.id IS NOT NULL THEN 'locked'
              ELSE 'available'
            END AS seat_status
          FROM seats st
          LEFT JOIN (
            SELECT bs.seat_id, bs.id
            FROM booking_seats bs
            JOIN bookings b ON bs.booking_id = b.id
            WHERE b.show_id = @showId AND b.booking_status != 'cancelled'
          ) bs ON bs.seat_id = st.id
          LEFT JOIN (
            SELECT sl.seat_id, sl.id
            FROM seat_locks sl
            WHERE sl.show_id = @showId AND sl.expires_at > CURRENT_TIMESTAMP
          ) sl ON sl.seat_id = st.id
          WHERE st.screen_id = @screenId
          ORDER BY st.row_label ASC, st.seat_number ASC
        '''),
        parameters: {
          'showId': showId,
          'screenId': screenId,
        },
      );

      final rowsMap = <String, List<Map<String, dynamic>>>{};
      final tiersMap = <String, Map<String, dynamic>>{};

      for (final s in seatsRes) {
        final seatId = s[0] as int;
        final rowLabel = s[1] as String;
        final seatNum = s[2] as int;
        final seatIdentifier = s[3] as String;
        final tierName = s[4] as String;
        final seatType = s[5] as String;
        final multiplier = _toDouble(s[6], 1.0);
        final status = s[7] as String;
        final calculatedPrice = (basePrice * multiplier).roundToDouble();

        if (!tiersMap.containsKey(tierName)) {
          tiersMap[tierName] = {
            'tierName': tierName,
            'price': calculatedPrice,
          };
        }

        if (!rowsMap.containsKey(rowLabel)) {
          rowsMap[rowLabel] = [];
        }

        rowsMap[rowLabel]!.add({
          'seatId': seatId,
          'row': rowLabel,
          'number': seatNum,
          'identifier': seatIdentifier,
          'tier': tierName,
          'type': seatType,
          'price': calculatedPrice,
          'status': status,
        });
      }

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'data': {
            'show': {
              'id': showRow[0],
              'movieTitle': showRow[1],
              'certificate': showRow[2],
              'durationMins': showRow[3],
              'theaterName': showRow[4],
              'theaterAddress': showRow[5],
              'screenName': showRow[7],
              'showTime': (showRow[8] as DateTime).toIso8601String(),
              'timeFormatted': showRow[9],
              'format': showRow[10],
              'language': showRow[11],
              'basePrice': basePrice,
            },
            'tiers': tiersMap.values.toList(),
            'rows': rowsMap.entries.map((e) {
              return {
                'rowLabel': e.key,
                'seats': e.value,
              };
            }).toList(),
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('SeatService', 'Error getting seats for show $showIdStr', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': e.toString()},
      );
    } finally {
      await connection.close();
    }
  }

  // 2. Lock Seats for Checkout (8 minutes hold)
  static Future<Response> lockSeats(RequestContext context, String showIdStr) async {
    final showId = int.tryParse(showIdStr);
    if (showId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Invalid show ID'},
      );
    }

    final body = await AuthUtils.readJson(context);
    if (body == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Request body must be a valid JSON object'},
      );
    }

    final seatIdentifiers = body['seatIdentifiers'] as List?;
    final seatIdsRaw = body['seatIds'] as List?;

    if ((seatIdentifiers == null || seatIdentifiers.isEmpty) &&
        (seatIdsRaw == null || seatIdsRaw.isEmpty)) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'At least one seat must be selected'},
      );
    }

    // Optional user ID from token
    int? userId;
    final token = AuthUtils.getBearerToken(context);
    if (token != null) {
      try {
        userId = AuthUtils.verifyAccessToken(token);
      } catch (_) {}
    }

    final connection = await openDatabaseConnection();

    try {
      // Clean expired locks first
      await connection.execute(
        Sql.named('DELETE FROM seat_locks WHERE expires_at <= CURRENT_TIMESTAMP'),
      );

      // Resolve seat IDs
      var seatFilterSql = '';
      final params = <String, dynamic>{'showId': showId};

      if (seatIdentifiers != null && seatIdentifiers.isNotEmpty) {
        seatFilterSql = 'st.seat_identifier = ANY(@identifiers)';
        params['identifiers'] = seatIdentifiers.cast<String>();
      } else {
        seatFilterSql = 'st.id = ANY(@ids)';
        params['ids'] = seatIdsRaw!.map((e) => int.parse(e.toString())).toList();
      }

      final seatsToLockRes = await connection.execute(
        Sql.named('''
          SELECT
            st.id,
            st.seat_identifier,
            st.tier_name,
            st.multiplier,
            s.base_price,
            CASE
              WHEN bs.id IS NOT NULL THEN 'booked'
              WHEN sl.id IS NOT NULL THEN 'locked'
              ELSE 'available'
            END AS current_status
          FROM shows s
          JOIN screens sc ON s.screen_id = sc.id
          JOIN seats st ON st.screen_id = sc.id
          LEFT JOIN (
            SELECT bs.seat_id, bs.id
            FROM booking_seats bs
            JOIN bookings b ON bs.booking_id = b.id
            WHERE b.show_id = @showId AND b.booking_status != 'cancelled'
          ) bs ON bs.seat_id = st.id
          LEFT JOIN (
            SELECT sl.seat_id, sl.id
            FROM seat_locks sl
            WHERE sl.show_id = @showId AND sl.expires_at > CURRENT_TIMESTAMP
          ) sl ON sl.seat_id = st.id
          WHERE s.id = @showId AND $seatFilterSql
        '''),
        parameters: params,
      );

      if (seatsToLockRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Selected seats not found for this show'},
        );
      }

      // Check if any seat is unavailable
      final unavailable = <String>[];
      final targetSeats = <Map<String, dynamic>>[];
      var subtotal = 0.0;

      for (final s in seatsToLockRes) {
        final seatId = s[0] as int;
        final identifier = s[1] as String;
        final tier = s[2] as String;
        final multiplier = _toDouble(s[3], 1.0);
        final basePrice = _toDouble(s[4], 250.0);
        final status = s[5] as String;
        final price = (basePrice * multiplier).roundToDouble();

        if (status != 'available') {
          unavailable.add(identifier);
        } else {
          subtotal += price;
          targetSeats.add({
            'seatId': seatId,
            'identifier': identifier,
            'tier': tier,
            'price': price,
          });
        }
      }

      if (unavailable.isNotEmpty) {
        return Response.json(
          statusCode: HttpStatus.conflict,
          body: {
            'status': 'error',
            'message': 'Some seats are already booked or locked by another user',
            'unavailableSeats': unavailable,
          },
        );
      }

      final lockToken = 'LOCK_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
      final expiresAt = DateTime.now().toUtc().add(const Duration(minutes: 8));

      // Insert locks
      for (final item in targetSeats) {
        await connection.execute(
          Sql.named('''
            INSERT INTO seat_locks (show_id, seat_id, user_id, lock_token, expires_at)
            VALUES (@showId, @seatId, @userId, @lockToken, @expiresAt)
            ON CONFLICT (show_id, seat_id) DO UPDATE
            SET lock_token = @lockToken, expires_at = @expiresAt, user_id = @userId
          '''),
          parameters: {
            'showId': showId,
            'seatId': item['seatId'],
            'userId': userId,
            'lockToken': lockToken,
            'expiresAt': expiresAt,
          },
        );
      }

      const convenienceFee = 35.40;
      final totalAmount = subtotal + convenienceFee;

      return Response.json(
        statusCode: HttpStatus.ok,
        body: {
          'status': 'success',
          'message': 'Seats locked for 8 minutes',
          'data': {
            'lockToken': lockToken,
            'expiresAt': expiresAt.toIso8601String(),
            'expiresInSeconds': 480,
            'lockedSeats': targetSeats,
            'pricing': {
              'ticketCount': targetSeats.length,
              'subtotal': subtotal,
              'convenienceFee': convenienceFee,
              'totalAmount': totalAmount,
            },
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('SeatService', 'Error locking seats', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': e.toString()},
      );
    } finally {
      await connection.close();
    }
  }
}
