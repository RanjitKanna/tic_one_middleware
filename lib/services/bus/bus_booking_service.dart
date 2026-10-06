import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

class BusBookingService {
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

  static Future<void> _cleanExpiredLocks(Connection connection) async {
    try {
      await connection.execute(
        Sql.named('DELETE FROM bus_seat_locks WHERE expires_at <= CURRENT_TIMESTAMP'),
      );
    } catch (_) {}
  }

  // ==============================================================================
  // 1. TEMPORARY SEAT LOCKING (10 MINUTES HOLD)
  // POST /bus-bookings/hold-seats
  // ==============================================================================
  static Future<Response> holdSeats(RequestContext context) async {
    final body = await AuthUtils.readJson(context);
    if (body == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Request body must be a valid JSON object'},
      );
    }

    final tripIdRaw = body['tripId'] ?? body['busId'];
    if (tripIdRaw == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'tripId is required'},
      );
    }

    final tripId = _toInt(tripIdRaw);
    final seatNumbers = <String>[];

    if (body['seatNumbers'] is List) {
      for (final s in body['seatNumbers'] as List) {
        if (s != null && s.toString().trim().isNotEmpty) {
          seatNumbers.add(s.toString().trim().toUpperCase());
        }
      }
    } else if (body['seats'] is List) {
      for (final s in body['seats'] as List) {
        if (s != null && s.toString().trim().isNotEmpty) {
          seatNumbers.add(s.toString().trim().toUpperCase());
        }
      }
    } else if (body['seatNumber'] != null) {
      seatNumbers.add(body['seatNumber'].toString().trim().toUpperCase());
    }

    if (seatNumbers.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'seatNumbers array must contain at least one seat'},
      );
    }

    final userId = _extractUserId(context);
    final connection = await openDatabaseConnection();

    try {
      await _cleanExpiredLocks(connection);

      // 1. Fetch trip and bus info
      final tripRes = await connection.execute(
        Sql.named('''
          SELECT t.id, t.bus_id, t.base_fare, b.bus_name, b.bus_type
          FROM bus_trips t
          JOIN buses b ON t.bus_id = b.id
          WHERE t.id = @tId
          LIMIT 1;
        '''),
        parameters: {'tId': tripId},
      );

      if (tripRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Bus trip not found with ID $tripId'},
        );
      }

      final busId = tripRes.first[1] as int;
      final baseFare = _toDouble(tripRes.first[2], 750.0);
      final busName = tripRes.first[3] as String;
      final busType = tripRes.first[4] as String;

      // 2. Fetch seat records
      final seatsRes = await connection.execute(
        Sql.named('''
          SELECT id, seat_number, deck, seat_type, berth_type, seat_tier, price_multiplier
          FROM bus_seats
          WHERE bus_id = @bId AND UPPER(seat_number) = ANY(@seats)
        '''),
        parameters: {
          'bId': busId,
          'seats': seatNumbers,
        },
      );

      if (seatsRes.length != seatNumbers.length) {
        final foundSeats = seatsRes.map((r) => (r[1] as String).toUpperCase()).toSet();
        final missing = seatNumbers.where((s) => !foundSeats.contains(s)).toList();
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'status': 'error',
            'message': 'Some requested seats were not found on this bus: ${missing.join(', ')}',
          },
        );
      }

      final seatIds = seatsRes.map((r) => r[0] as int).toList();

      // 3. Check already booked seats
      final bookedRes = await connection.execute(
        Sql.named('''
          SELECT bs.seat_number
          FROM bus_booking_seats bs
          JOIN bus_bookings bb ON bs.booking_id = bb.id
          WHERE bb.trip_id = @tId
            AND bb.booking_status != 'cancelled'
            AND bs.seat_id = ANY(@sIds)
        '''),
        parameters: {
          'tId': tripId,
          'sIds': seatIds,
        },
      );

      if (bookedRes.isNotEmpty) {
        final alreadyBooked = bookedRes.map((r) => r[0] as String).toList();
        return Response.json(
          statusCode: HttpStatus.conflict,
          body: {
            'status': 'error',
            'message': 'Seat(s) ${alreadyBooked.join(', ')} are already booked. Please pick different seats.',
          },
        );
      }

      // 4. Check already locked seats by active locks
      final lockedRes = await connection.execute(
        Sql.named('''
          SELECT bs.seat_number
          FROM bus_seat_locks bsl
          JOIN bus_seats bs ON bsl.seat_id = bs.id
          WHERE bsl.trip_id = @tId
            AND bsl.seat_id = ANY(@sIds)
            AND bsl.expires_at > CURRENT_TIMESTAMP
        '''),
        parameters: {
          'tId': tripId,
          'sIds': seatIds,
        },
      );

      if (lockedRes.isNotEmpty) {
        final alreadyLocked = lockedRes.map((r) => r[0] as String).toList();
        return Response.json(
          statusCode: HttpStatus.conflict,
          body: {
            'status': 'error',
            'message': 'Seat(s) ${alreadyLocked.join(', ')} are currently on hold by another customer. Try again in a few minutes or choose another seat.',
          },
        );
      }

      // 5. Create temporary lock token
      final random = Random();
      final lockToken = 'BUS_LOCK_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(900000) + 100000}';
      final expiresAt = DateTime.now().toUtc().add(const Duration(minutes: 10));

      final lockedSeatsList = <Map<String, dynamic>>[];
      var subtotal = 0.0;

      for (final s in seatsRes) {
        final seatId = s[0] as int;
        final seatNum = s[1] as String;
        final deck = s[2] as String;
        final seatType = s[3] as String;
        final berthType = s[4] as String;
        final tier = s[5] as String;
        final multiplier = _toDouble(s[6], 1.0);
        final price = (baseFare * multiplier).roundToDouble();

        subtotal += price;

        await connection.execute(
          Sql.named('''
            INSERT INTO bus_seat_locks (trip_id, seat_id, user_id, lock_token, expires_at)
            VALUES (@tId, @sId, @uId, @token, @exp)
            ON CONFLICT (trip_id, seat_id) DO UPDATE SET
              user_id = EXCLUDED.user_id,
              lock_token = EXCLUDED.lock_token,
              expires_at = EXCLUDED.expires_at,
              created_at = CURRENT_TIMESTAMP;
          '''),
          parameters: {
            'tId': tripId,
            'sId': seatId,
            'uId': userId,
            'token': lockToken,
            'exp': expiresAt,
          },
        );

        lockedSeatsList.add({
          'seatId': seatId,
          'seatNumber': seatNum,
          'deck': deck,
          'seatType': seatType,
          'berthType': berthType,
          'tier': tier,
          'price': price,
        });
      }

      final taxAmount = (subtotal * 0.05).roundToDouble(); // 5% GST
      final convenienceFee = 25.00;
      final totalAmount = subtotal + taxAmount + convenienceFee;

      AppLogger.info('BusBookingService', 'Held ${lockedSeatsList.length} seats for trip $tripId with token $lockToken');

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'message': 'Seats successfully locked for 10 minutes',
          'data': {
            'lockToken': lockToken,
            'tripId': tripId,
            'busName': busName,
            'busType': busType,
            'expiresAt': expiresAt.toIso8601String(),
            'expiresInSeconds': 600,
            'seatCount': lockedSeatsList.length,
            'lockedSeats': lockedSeatsList,
            'pricing': {
              'baseFareSubtotal': subtotal,
              'gstTaxAmount': taxAmount,
              'convenienceFee': convenienceFee,
              'totalAmount': totalAmount,
            },
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BusBookingService', 'Error holding seats', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to lock seats: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 2. CREATE & CONFIRM BUS BOOKING
  // POST /bus-bookings
  // ==============================================================================
  static Future<Response> createBooking(RequestContext context) async {
    // 1. Mandatory JWT authentication
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
        body: {'status': 'error', 'message': 'Invalid or expired authentication session. Please re-login.'},
      );
    }

    final body = await AuthUtils.readJson(context);
    if (body == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Request body must be a valid JSON object'},
      );
    }

    final tripIdRaw = body['tripId'] ?? body['busId'];
    final lockToken = body['lockToken'] as String?;

    if (tripIdRaw == null || lockToken == null || lockToken.trim().isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'tripId and lockToken are required'},
      );
    }

    final tripId = _toInt(tripIdRaw);
    final boardingPointId = body['boardingPointId'] != null ? _toInt(body['boardingPointId']) : null;
    final droppingPointId = body['droppingPointId'] != null ? _toInt(body['droppingPointId']) : null;
    final contactEmail = body['contactEmail']?.toString().trim() ?? '';
    final contactPhone = body['contactPhone']?.toString().trim() ?? '';
    final promoCode = body['promoCode']?.toString().trim().toUpperCase();
    final paymentMethod = body['paymentMethod']?.toString().trim().toLowerCase() ?? 'upi';

    // Validate passengers array
    final rawPassengers = body['passengers'];
    if (rawPassengers is! List || rawPassengers.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'passengers list is required with at least one passenger'},
      );
    }

    final passengerList = <Map<String, dynamic>>[];
    for (final p in rawPassengers) {
      if (p is Map) {
        final name = p['name']?.toString().trim() ?? p['passengerName']?.toString().trim() ?? '';
        final age = _toInt(p['age'], 0);
        final gender = p['gender']?.toString().trim() ?? 'Male';
        final seatNumber = p['seatNumber']?.toString().trim().toUpperCase() ?? '';

        if (name.isEmpty || age <= 0 || seatNumber.isEmpty) {
          return Response.json(
            statusCode: HttpStatus.badRequest,
            body: {'status': 'error', 'message': 'Each passenger requires a valid name, age (>0), and seatNumber'},
          );
        }

        passengerList.add({
          'name': name,
          'age': age,
          'gender': gender,
          'seatNumber': seatNumber,
        });
      }
    }

    final connection = await openDatabaseConnection();

    try {
      await _cleanExpiredLocks(connection);

      // 1. Fetch locked seats for this lock token
      final locksRes = await connection.execute(
        Sql.named('''
          SELECT
            bsl.seat_id,
            bs.seat_number,
            bs.deck,
            bs.seat_tier,
            bs.price_multiplier,
            t.base_fare,
            t.bus_id,
            t.trip_code,
            t.travel_date,
            t.departure_time,
            t.arrival_time,
            t.departure_time_formatted,
            t.arrival_time_formatted,
            t.duration_formatted,
            b.bus_name,
            b.bus_number,
            b.bus_type,
            b.category,
            op.name AS operator_name,
            op.logo_url AS operator_logo,
            r.source_city,
            r.destination_city
          FROM bus_seat_locks bsl
          JOIN bus_seats bs ON bsl.seat_id = bs.id
          JOIN bus_trips t ON bsl.trip_id = t.id
          JOIN buses b ON t.bus_id = b.id
          JOIN bus_operators op ON b.operator_id = op.id
          JOIN bus_routes r ON t.route_id = r.id
          WHERE bsl.trip_id = @tId
            AND bsl.lock_token = @token
            AND bsl.expires_at > CURRENT_TIMESTAMP
        '''),
        parameters: {
          'tId': tripId,
          'token': lockToken.trim(),
        },
      );

      if (locksRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.gone,
          body: {
            'status': 'error',
            'message': 'Seat lock expired or invalid. Please select your seats again and re-lock.',
          },
        );
      }

      if (locksRes.length != passengerList.length) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'status': 'error',
            'message': 'Number of passengers (${passengerList.length}) does not match locked seats (${locksRes.length})',
          },
        );
      }

      // Check seat numbers match
      final lockedSeatNums = locksRes.map((r) => (r[1] as String).toUpperCase()).toSet();
      for (final p in passengerList) {
        if (!lockedSeatNums.contains(p['seatNumber'])) {
          return Response.json(
            statusCode: HttpStatus.badRequest,
            body: {
              'status': 'error',
              'message': "Passenger '${p['name']}' is assigned to seat '${p['seatNumber']}', which is not in your locked seats list (${lockedSeatNums.join(', ')})",
            },
          );
        }
      }

      final firstRow = locksRes.first;
      final busId = firstRow[6] as int;
      final tripCode = firstRow[7] as String;
      final travelDate = firstRow[8].toString().split(' ').first;
      final depTime = firstRow[9] as DateTime;
      final arrTime = firstRow[10] as DateTime;
      final depFmt = firstRow[11] as String;
      final arrFmt = firstRow[12] as String;
      final durFmt = firstRow[13] as String;
      final busName = firstRow[14] as String;
      final busNumber = firstRow[15] as String;
      final busType = firstRow[16] as String;
      final operatorName = firstRow[18] as String;
      final operatorLogo = firstRow[19] as String?;
      final sourceCity = firstRow[20] as String;
      final destinationCity = firstRow[21] as String;

      // Calculate seat amounts
      var baseFareSubtotal = 0.0;
      final seatsList = <Map<String, dynamic>>[];
      final seatPriceMap = <String, double>{};
      final seatIdMap = <String, int>{};
      final seatTierMap = <String, String>{};

      for (final row in locksRes) {
        final sId = row[0] as int;
        final sNum = (row[1] as String).toUpperCase();
        final sDeck = row[2] as String;
        final sTier = row[3] as String;
        final mult = _toDouble(row[4], 1.0);
        final baseFare = _toDouble(row[5], 750.0);
        final price = (baseFare * mult).roundToDouble();

        baseFareSubtotal += price;
        seatPriceMap[sNum] = price;
        seatIdMap[sNum] = sId;
        seatTierMap[sNum] = sTier;

        seatsList.add({
          'seatId': sId,
          'seatNumber': sNum,
          'deck': sDeck,
          'tier': sTier,
          'price': price,
        });
      }

      // Check Promo Code if provided
      var discountAmount = 0.0;
      String? appliedPromoCode;

      if (promoCode != null && promoCode.isNotEmpty) {
        final promoRes = await connection.execute(
          Sql.named('''
            SELECT id, promo_code, discount_type, discount_value, min_booking_amount, max_discount_amount
            FROM bus_promos
            WHERE UPPER(promo_code) = @code
              AND is_active = true
              AND (valid_until IS NULL OR valid_until > CURRENT_TIMESTAMP)
            LIMIT 1
          '''),
          parameters: {'code': promoCode},
        );

        if (promoRes.isNotEmpty) {
          final pRow = promoRes.first;
          final pType = pRow[2] as String;
          final pVal = _toDouble(pRow[3]);
          final minAmt = _toDouble(pRow[4]);
          final maxDiscount = _toDouble(pRow[5]);

          if (baseFareSubtotal >= minAmt) {
            if (pType == 'percentage') {
              discountAmount = (baseFareSubtotal * (pVal / 100.0)).roundToDouble();
              if (maxDiscount > 0 && discountAmount > maxDiscount) {
                discountAmount = maxDiscount;
              }
            } else {
              discountAmount = pVal;
            }
            appliedPromoCode = promoCode;
          }
        }
      }

      final taxAmount = (baseFareSubtotal * 0.05).roundToDouble(); // 5% GST
      final convenienceFee = 25.00;
      final totalAmount = max(0.0, baseFareSubtotal + taxAmount + convenienceFee - discountAmount);

      // Generate unique booking code and PNR
      final rand = Random();
      final bookingCode = 'TIC-BUS-2026-${rand.nextInt(900000) + 100000}';
      final pnrNumber = 'PNR${rand.nextInt(9000000) + 1000000}';

      // Digital QR payload
      final qrPayload = base64UrlEncode(utf8.encode(jsonEncode({
        'code': bookingCode,
        'pnr': pnrNumber,
        'tripId': tripId,
        'userId': userId,
        'seats': seatsList.map((s) => s['seatNumber']).toList(),
        'operator': operatorName,
        'from': sourceCity,
        'to': destinationCity,
        'date': travelDate,
      })));

      // Fetch user details for defaults
      final userRes = await connection.execute(
        Sql.named('SELECT name, email, phone FROM login_auth WHERE id = @uId LIMIT 1'),
        parameters: {'uId': userId},
      );
      final finalEmail = contactEmail.isNotEmpty
          ? contactEmail
          : ((userRes.isNotEmpty ? userRes.first[1] as String? : null) ?? 'user@ticone.com');
      final finalPhone = contactPhone.isNotEmpty
          ? contactPhone
          : ((userRes.isNotEmpty ? userRes.first[2] as String? : null) ?? '9876543210');

      // ── ATOMIC INSERTION ──
      final insertBkRes = await connection.execute(
        Sql.named('''
          INSERT INTO bus_bookings (
            booking_code, pnr_number, user_id, trip_id, bus_id, boarding_point_id, dropping_point_id,
            total_seats, base_fare_amount, tax_amount, convenience_fee, discount_amount, promo_code,
            total_amount, payment_status, booking_status, contact_email, contact_phone, qr_code_data
          ) VALUES (
            @code, @pnr, @uId, @tId, @bId, @bpId, @dpId,
            @seatsCount, @subtotal, @tax, @conv, @disc, @promo,
            @total, 'completed', 'confirmed', @email, @phone, @qr
          ) RETURNING id, created_at;
        '''),
        parameters: {
          'code': bookingCode,
          'pnr': pnrNumber,
          'uId': userId,
          'tId': tripId,
          'bId': busId,
          'bpId': boardingPointId,
          'dpId': droppingPointId,
          'seatsCount': seatsList.length,
          'subtotal': baseFareSubtotal,
          'tax': taxAmount,
          'conv': convenienceFee,
          'disc': discountAmount,
          'promo': appliedPromoCode,
          'total': totalAmount,
          'email': finalEmail,
          'phone': finalPhone,
          'qr': qrPayload,
        },
      );

      final bookingId = insertBkRes.first[0] as int;
      final createdAt = (insertBkRes.first[1] as DateTime).toIso8601String();

      // Insert Passenger Details
      for (final p in passengerList) {
        final sNum = p['seatNumber'] as String;
        final sId = seatIdMap[sNum];
        final sTier = seatTierMap[sNum] ?? 'Standard';
        final sPrice = seatPriceMap[sNum] ?? 750.0;

        await connection.execute(
          Sql.named('''
            INSERT INTO bus_booking_passengers (booking_id, seat_id, seat_number, passenger_name, age, gender, seat_fare, seat_tier)
            VALUES (@bkId, @sId, @sNum, @name, @age, @gender, @fare, @tier)
          '''),
          parameters: {
            'bkId': bookingId,
            'sId': sId,
            'sNum': sNum,
            'name': p['name'],
            'age': p['age'],
            'gender': p['gender'],
            'fare': sPrice,
            'tier': sTier,
          },
        );
      }

      // Insert Seats records
      for (final s in seatsList) {
        await connection.execute(
          Sql.named('''
            INSERT INTO bus_booking_seats (booking_id, seat_id, seat_number, deck, tier_name, price)
            VALUES (@bkId, @sId, @sNum, @deck, @tier, @price)
          '''),
          parameters: {
            'bkId': bookingId,
            'sId': s['seatId'],
            'sNum': s['seatNumber'],
            'deck': s['deck'],
            'tier': s['tier'],
            'price': s['price'],
          },
        );
      }

      // Record Payment
      final paymentId = 'PAY-BUS-${DateTime.now().millisecondsSinceEpoch}';
      await connection.execute(
        Sql.named('''
          INSERT INTO bus_payments (payment_id, booking_id, user_id, amount, currency, payment_method, transaction_reference, status, verified_at)
          VALUES (@pId, @bkId, @uId, @amount, 'INR', @method, @ref, 'completed', CURRENT_TIMESTAMP)
        '''),
        parameters: {
          'pId': paymentId,
          'bkId': bookingId,
          'uId': userId,
          'amount': totalAmount,
          'method': paymentMethod,
          'ref': 'TXN_${bookingCode.replaceAll('-', '')}',
        },
      );

      // Release locks
      await connection.execute(
        Sql.named('DELETE FROM bus_seat_locks WHERE lock_token = @token'),
        parameters: {'token': lockToken.trim()},
      );

      // Fetch Boarding & Dropping Point objects
      Map<String, dynamic>? boardingPointData;
      if (boardingPointId != null) {
        final bp = await connection.execute(
          Sql.named('SELECT point_name, landmark, address, contact_number, time_formatted FROM boarding_points WHERE id = @id LIMIT 1'),
          parameters: {'id': boardingPointId},
        );
        if (bp.isNotEmpty) {
          boardingPointData = {
            'id': boardingPointId,
            'pointName': bp.first[0],
            'landmark': bp.first[1],
            'address': bp.first[2],
            'contactNumber': bp.first[3],
            'timeFormatted': bp.first[4],
          };
        }
      }

      Map<String, dynamic>? droppingPointData;
      if (droppingPointId != null) {
        final dp = await connection.execute(
          Sql.named('SELECT point_name, landmark, address, contact_number, time_formatted FROM dropping_points WHERE id = @id LIMIT 1'),
          parameters: {'id': droppingPointId},
        );
        if (dp.isNotEmpty) {
          droppingPointData = {
            'id': droppingPointId,
            'pointName': dp.first[0],
            'landmark': dp.first[1],
            'address': dp.first[2],
            'contactNumber': dp.first[3],
            'timeFormatted': dp.first[4],
          };
        }
      }

      AppLogger.info('BusBookingService', 'Booking confirmed successfully: $bookingCode ($pnrNumber) for user $userId');

      return Response.json(
        statusCode: HttpStatus.created,
        body: {
          'status': 'success',
          'statusCode': 201,
          'message': 'Bus booking confirmed successfully!',
          'data': {
            'bookingId': bookingId,
            'bookingCode': bookingCode,
            'pnrNumber': pnrNumber,
            'bookingStatus': 'confirmed',
            'paymentStatus': 'completed',
            'createdAt': createdAt,
            'trip': {
              'tripId': tripId,
              'tripCode': tripCode,
              'travelDate': travelDate,
              'departureTime': depTime.toIso8601String(),
              'arrivalTime': arrTime.toIso8601String(),
              'departureTimeFormatted': depFmt,
              'arrivalTimeFormatted': arrFmt,
              'durationFormatted': durFmt,
            },
            'bus': {
              'id': busId,
              'name': busName,
              'number': busNumber,
              'type': busType,
            },
            'operator': {
              'name': operatorName,
              'logoUrl': operatorLogo,
            },
            'route': {
              'sourceCity': sourceCity,
              'destinationCity': destinationCity,
            },
            'boardingPoint': boardingPointData,
            'droppingPoint': droppingPointData,
            'seats': seatsList,
            'passengers': passengerList,
            'pricing': {
              'ticketCount': seatsList.length,
              'baseFareSubtotal': baseFareSubtotal,
              'gstTaxAmount': taxAmount,
              'convenienceFee': convenienceFee,
              'discountAmount': discountAmount,
              'promoCodeApplied': appliedPromoCode,
              'totalAmount': totalAmount,
            },
            'payment': {
              'paymentId': paymentId,
              'method': paymentMethod,
              'status': 'completed',
            },
            'qrCodeData': qrPayload,
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BusBookingService', 'Error creating bus booking', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to create bus booking: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 3. GET USER BUS BOOKING HISTORY
  // GET /bus-bookings?status=upcoming|completed|cancelled|all
  // ==============================================================================
  static Future<Response> getUserBookings(RequestContext context) async {
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
        body: {'status': 'error', 'message': 'Invalid session token'},
      );
    }

    final params = context.request.uri.queryParameters;
    final statusFilter = params['status']?.toLowerCase();

    final connection = await openDatabaseConnection();

    try {
      final whereClauses = <String>['bb.user_id = @userId'];
      final sqlParams = <String, dynamic>{'userId': userId};

      if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'all') {
        if (statusFilter == 'cancelled') {
          whereClauses.add("bb.booking_status = 'cancelled'");
        } else if (statusFilter == 'completed' || statusFilter == 'past') {
          whereClauses.add("(bb.booking_status = 'completed' OR (bb.booking_status = 'confirmed' AND t.arrival_time < CURRENT_TIMESTAMP))");
        } else if (statusFilter == 'upcoming') {
          whereClauses.add("bb.booking_status = 'confirmed' AND t.arrival_time >= CURRENT_TIMESTAMP");
        }
      }

      final query = '''
        SELECT
          bb.id AS booking_id,
          bb.booking_code,
          bb.pnr_number,
          bb.total_seats,
          bb.base_fare_amount,
          bb.tax_amount,
          bb.convenience_fee,
          bb.discount_amount,
          bb.total_amount,
          bb.payment_status,
          bb.booking_status,
          bb.qr_code_data,
          bb.created_at,
          t.id AS trip_id,
          t.travel_date,
          t.departure_time,
          t.arrival_time,
          t.departure_time_formatted,
          t.arrival_time_formatted,
          t.duration_formatted,
          b.id AS bus_id,
          b.bus_name,
          b.bus_number,
          b.bus_type,
          op.name AS operator_name,
          op.logo_url AS operator_logo,
          r.source_city,
          r.destination_city,
          bp.point_name AS boarding_point_name,
          bp.time_formatted AS boarding_time,
          dp.point_name AS dropping_point_name,
          dp.time_formatted AS dropping_time,
          COALESCE(
            JSON_AGG(
              JSON_BUILD_OBJECT(
                'seatNumber', bbs.seat_number,
                'deck', bbs.deck,
                'tier', bbs.tier_name,
                'price', bbs.price
              )
            ) FILTER (WHERE bbs.id IS NOT NULL),
            '[]'::json
          ) AS seats
        FROM bus_bookings bb
        JOIN bus_trips t ON bb.trip_id = t.id
        JOIN buses b ON bb.bus_id = b.id
        JOIN bus_operators op ON b.operator_id = op.id
        JOIN bus_routes r ON t.route_id = r.id
        LEFT JOIN boarding_points bp ON bb.boarding_point_id = bp.id
        LEFT JOIN dropping_points dp ON bb.dropping_point_id = dp.id
        LEFT JOIN bus_booking_seats bbs ON bbs.booking_id = bb.id
        WHERE ${whereClauses.join(' AND ')}
        GROUP BY
          bb.id, bb.booking_code, bb.pnr_number, bb.total_seats, bb.base_fare_amount,
          bb.tax_amount, bb.convenience_fee, bb.discount_amount, bb.total_amount,
          bb.payment_status, bb.booking_status, bb.qr_code_data, bb.created_at,
          t.id, t.travel_date, t.departure_time, t.arrival_time, t.departure_time_formatted,
          t.arrival_time_formatted, t.duration_formatted, b.id, b.bus_name, b.bus_number,
          b.bus_type, op.name, op.logo_url, r.source_city, r.destination_city,
          bp.point_name, bp.time_formatted, dp.point_name, dp.time_formatted
        ORDER BY bb.created_at DESC;
      ''';

      final results = await connection.execute(
        Sql.named(query),
        parameters: sqlParams,
      );

      final bookings = results.map((row) {
        return {
          'bookingId': row[0],
          'bookingCode': row[1],
          'pnrNumber': row[2],
          'totalSeats': row[3],
          'pricing': {
            'baseFareSubtotal': _toDouble(row[4]),
            'taxAmount': _toDouble(row[5]),
            'convenienceFee': _toDouble(row[6]),
            'discountAmount': _toDouble(row[7]),
            'totalAmount': _toDouble(row[8]),
          },
          'paymentStatus': row[9],
          'bookingStatus': row[10],
          'qrCodeData': row[11],
          'createdAt': (row[12] as DateTime).toIso8601String(),
          'trip': {
            'tripId': row[13],
            'travelDate': row[14].toString().split(' ').first,
            'departureTime': (row[15] as DateTime).toIso8601String(),
            'arrivalTime': (row[16] as DateTime).toIso8601String(),
            'departureTimeFormatted': row[17],
            'arrivalTimeFormatted': row[18],
            'durationFormatted': row[19],
          },
          'bus': {
            'id': row[20],
            'busName': row[21],
            'busNumber': row[22],
            'busType': row[23],
          },
          'operator': {
            'name': row[24],
            'logoUrl': row[25],
          },
          'route': {
            'sourceCity': row[26],
            'destinationCity': row[27],
          },
          'boardingPoint': row[28] != null ? {'name': row[28], 'time': row[29]} : null,
          'droppingPoint': row[30] != null ? {'name': row[30], 'time': row[31]} : null,
          'seats': row[32],
        };
      }).toList();

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'count': bookings.length,
          'filter': statusFilter ?? 'all',
          'data': bookings,
        },
      );
    } catch (e, st) {
      AppLogger.error('BusBookingService', 'Error getting user bus bookings', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to fetch user bookings: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 4. GET SINGLE BUS BOOKING DETAILS & TICKET
  // GET /bus-bookings/{bookingId}
  // ==============================================================================
  static Future<Response> getBookingDetails(RequestContext context, String bookingIdOrCodeOrPnr) async {
    final cleanCode = bookingIdOrCodeOrPnr.replaceAll('#', '').trim();
    final idInt = int.tryParse(cleanCode);
    final connection = await openDatabaseConnection();

    try {
      final query = '''
        SELECT
          bb.id AS booking_id,
          bb.booking_code,
          bb.pnr_number,
          bb.total_seats,
          bb.base_fare_amount,
          bb.tax_amount,
          bb.convenience_fee,
          bb.discount_amount,
          bb.total_amount,
          bb.payment_status,
          bb.booking_status,
          bb.contact_email,
          bb.contact_phone,
          bb.qr_code_data,
          bb.created_at,
          t.id AS trip_id,
          t.trip_code,
          t.travel_date,
          t.departure_time,
          t.arrival_time,
          t.departure_time_formatted,
          t.arrival_time_formatted,
          t.duration_formatted,
          b.id AS bus_id,
          b.bus_name,
          b.bus_number,
          b.bus_type,
          b.amenities,
          op.name AS operator_name,
          op.logo_url AS operator_logo,
          op.contact_number AS operator_phone,
          op.cancellation_policy,
          r.source_city,
          r.destination_city,
          r.distance_km,
          bp.id AS bp_id,
          bp.point_name AS bp_name,
          bp.landmark AS bp_landmark,
          bp.address AS bp_address,
          bp.contact_number AS bp_contact,
          bp.time_formatted AS bp_time,
          dp.id AS dp_id,
          dp.point_name AS dp_name,
          dp.landmark AS dp_landmark,
          dp.address AS dp_address,
          dp.contact_number AS dp_contact,
          dp.time_formatted AS dp_time,
          u.name AS user_name,
          u.email AS user_email,
          u.phone AS user_phone,
          COALESCE(
            JSON_AGG(
              JSON_BUILD_OBJECT(
                'seatNumber', bbs.seat_number,
                'deck', bbs.deck,
                'tier', bbs.tier_name,
                'price', bbs.price
              )
            ) FILTER (WHERE bbs.id IS NOT NULL),
            '[]'::json
          ) AS seats
        FROM bus_bookings bb
        JOIN bus_trips t ON bb.trip_id = t.id
        JOIN buses b ON bb.bus_id = b.id
        JOIN bus_operators op ON b.operator_id = op.id
        JOIN bus_routes r ON t.route_id = r.id
        JOIN login_auth u ON bb.user_id = u.id
        LEFT JOIN boarding_points bp ON bb.boarding_point_id = bp.id
        LEFT JOIN dropping_points dp ON bb.dropping_point_id = dp.id
        LEFT JOIN bus_booking_seats bbs ON bbs.booking_id = bb.id
        WHERE bb.id = @idOrZero
           OR LOWER(bb.booking_code) = LOWER(@code)
           OR LOWER(bb.pnr_number) = LOWER(@code)
        GROUP BY
          bb.id, bb.booking_code, bb.pnr_number, bb.total_seats, bb.base_fare_amount,
          bb.tax_amount, bb.convenience_fee, bb.discount_amount, bb.total_amount,
          bb.payment_status, bb.booking_status, bb.contact_email, bb.contact_phone,
          bb.qr_code_data, bb.created_at, t.id, t.trip_code, t.travel_date, t.departure_time,
          t.arrival_time, t.departure_time_formatted, t.arrival_time_formatted,
          t.duration_formatted, b.id, b.bus_name, b.bus_number, b.bus_type, b.amenities,
          op.name, op.logo_url, op.contact_number, op.cancellation_policy,
          r.source_city, r.destination_city, r.distance_km,
          bp.id, bp.point_name, bp.landmark, bp.address, bp.contact_number, bp.time_formatted,
          dp.id, dp.point_name, dp.landmark, dp.address, dp.contact_number, dp.time_formatted,
          u.name, u.email, u.phone
        LIMIT 1;
      ''';

      final res = await connection.execute(
        Sql.named(query),
        parameters: {
          'idOrZero': idInt ?? -1,
          'code': cleanCode,
        },
      );

      if (res.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Bus booking not found for identifier $cleanCode'},
        );
      }

      final row = res.first;
      final bookingId = row[0] as int;

      // Fetch passenger list
      final passRes = await connection.execute(
        Sql.named('''
          SELECT seat_number, passenger_name, age, gender, seat_fare, seat_tier
          FROM bus_booking_passengers
          WHERE booking_id = @bkId
          ORDER BY seat_number ASC
        '''),
        parameters: {'bkId': bookingId},
      );

      final passengers = passRes.map((p) => {
        'seatNumber': p[0],
        'name': p[1],
        'age': p[2],
        'gender': p[3],
        'fare': _toDouble(p[4]),
        'tier': p[5],
      }).toList();

      dynamic amenities = row[27];
      if (amenities is String) {
        try {
          amenities = jsonDecode(amenities);
        } catch (_) {
          amenities = <dynamic>[];
        }
      }

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'data': {
            'bookingId': bookingId,
            'bookingCode': row[1],
            'pnrNumber': row[2],
            'totalSeats': row[3],
            'pricing': {
              'baseFareSubtotal': _toDouble(row[4]),
              'taxAmount': _toDouble(row[5]),
              'convenienceFee': _toDouble(row[6]),
              'discountAmount': _toDouble(row[7]),
              'totalAmount': _toDouble(row[8]),
            },
            'paymentStatus': row[9],
            'bookingStatus': row[10],
            'contactEmail': row[11],
            'contactPhone': row[12],
            'qrCodeData': row[13],
            'createdAt': (row[14] as DateTime).toIso8601String(),
            'trip': {
              'tripId': row[15],
              'tripCode': row[16],
              'travelDate': row[17].toString().split(' ').first,
              'departureTime': (row[18] as DateTime).toIso8601String(),
              'arrivalTime': (row[19] as DateTime).toIso8601String(),
              'departureTimeFormatted': row[20],
              'arrivalTimeFormatted': row[21],
              'durationFormatted': row[22],
            },
            'bus': {
              'id': row[23],
              'name': row[24],
              'number': row[25],
              'type': row[26],
              'amenities': amenities ?? <dynamic>[],
            },
            'operator': {
              'name': row[28],
              'logoUrl': row[29],
              'contactNumber': row[30],
              'cancellationPolicy': row[31],
            },
            'route': {
              'sourceCity': row[32],
              'destinationCity': row[33],
              'distanceKm': _toDouble(row[34]),
            },
            'boardingPoint': row[35] != null ? {
              'id': row[35],
              'name': row[36],
              'landmark': row[37],
              'address': row[38],
              'contact': row[39],
              'timeFormatted': row[40],
            } : null,
            'droppingPoint': row[41] != null ? {
              'id': row[41],
              'name': row[42],
              'landmark': row[43],
              'address': row[44],
              'contact': row[45],
              'timeFormatted': row[46],
            } : null,
            'customer': {
              'name': row[47],
              'email': row[48],
              'phone': row[49],
            },
            'seats': row[50],
            'passengers': passengers,
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BusBookingService', 'Error getting booking details $cleanCode', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to retrieve booking: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 5. CANCEL BUS BOOKING & COMPUTE REFUND
  // POST /bus-bookings/{bookingId}/cancel
  // ==============================================================================
  static Future<Response> cancelBooking(RequestContext context, [String? bookingIdOrCodeParam]) async {
    String? code = bookingIdOrCodeParam?.replaceAll('#', '').trim();
    String? reason = 'Customer requested cancellation';

    try {
      final body = await AuthUtils.readJson(context);
      if (body != null) {
        if (code == null || code.isEmpty) {
          code = body['bookingId']?.toString() ?? body['bookingCode']?.toString() ?? body['pnrNumber']?.toString();
        }
        if (body['reason'] != null) {
          reason = body['reason'].toString().trim();
        }
      }
    } catch (_) {}

    if (code == null || code.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'bookingId or bookingCode is required.'},
      );
    }

    final idInt = int.tryParse(code);
    final connection = await openDatabaseConnection();

    try {
      // 1. Fetch booking status, total amount, departure time, and user
      final bkRes = await connection.execute(
        Sql.named('''
          SELECT
            bb.id,
            bb.booking_code,
            bb.pnr_number,
            bb.user_id,
            bb.total_amount,
            bb.booking_status,
            bb.payment_status,
            t.departure_time,
            t.travel_date
          FROM bus_bookings bb
          JOIN bus_trips t ON bb.trip_id = t.id
          WHERE bb.id = @idOrZero
             OR LOWER(bb.booking_code) = LOWER(@code)
             OR LOWER(bb.pnr_number) = LOWER(@code)
          LIMIT 1;
        '''),
        parameters: {
          'idOrZero': idInt ?? -1,
          'code': code.trim(),
        },
      );

      if (bkRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Bus booking not found.'},
        );
      }

      final row = bkRes.first;
      final bookingId = row[0] as int;
      final bookingCode = row[1] as String;
      final pnrNumber = row[2] as String;
      final userId = row[3] as int;
      final totalAmount = _toDouble(row[4]);
      final currentStatus = (row[5] as String).toLowerCase();
      final depTime = row[7] as DateTime;

      if (currentStatus == 'cancelled') {
        // Return existing cancellation
        final existingRef = await connection.execute(
          Sql.named('''
            SELECT refund_amount, refund_status, refund_id, cancellation_code
            FROM bus_refunds br
            JOIN bus_cancellations bc ON br.cancellation_id = bc.id
            WHERE br.booking_id = @id
            LIMIT 1;
          '''),
          parameters: {'id': bookingId},
        );

        final refundAmt = existingRef.isNotEmpty ? _toDouble(existingRef.first[0]) : totalAmount;
        final refundStatus = existingRef.isNotEmpty ? existingRef.first[1] as String : 'completed';
        final refId = existingRef.isNotEmpty ? existingRef.first[2] as String : 'REF-$bookingCode';

        return Response.json(
          body: {
            'status': 'success',
            'message': 'Booking $bookingCode ($pnrNumber) is already cancelled.',
            'data': {
              'bookingId': bookingId,
              'bookingCode': bookingCode,
              'pnrNumber': pnrNumber,
              'bookingStatus': 'cancelled',
              'paymentStatus': 'refunded',
              'refundAmount': refundAmt,
              'refundStatus': refundStatus,
              'refundId': refId,
            },
          },
        );
      }

      // Calculate refund percentage according to cancellation window
      final now = DateTime.now().toUtc();
      final hoursUntilDeparture = depTime.difference(now).inHours;

      double refundPercentage;
      if (hoursUntilDeparture >= 24) {
        refundPercentage = 90.0; // 10% cancellation charge
      } else if (hoursUntilDeparture >= 12) {
        refundPercentage = 75.0; // 25% cancellation charge
      } else if (hoursUntilDeparture >= 6) {
        refundPercentage = 50.0; // 50% cancellation charge
      } else {
        refundPercentage = 25.0; // 75% cancellation charge (last minute)
      }

      final refundAmount = ((totalAmount * refundPercentage) / 100.0).roundToDouble();
      final cancellationFee = totalAmount - refundAmount;

      // Update Booking Status
      await connection.execute(
        Sql.named('''
          UPDATE bus_bookings
          SET booking_status = 'cancelled',
              payment_status = 'refunded',
              updated_at = CURRENT_TIMESTAMP
          WHERE id = @id
        '''),
        parameters: {'id': bookingId},
      );

      // Create Cancellation Record
      final rand = Random();
      final cancelCode = 'CAN-BUS-${DateTime.now().millisecondsSinceEpoch}-${rand.nextInt(900) + 100}';
      final cancelRes = await connection.execute(
        Sql.named('''
          INSERT INTO bus_cancellations (booking_id, user_id, cancellation_code, cancellation_reason, refund_percentage, refund_amount, cancellation_fee)
          VALUES (@bkId, @uId, @cCode, @reason, @pct, @refAmt, @fee)
          RETURNING id;
        '''),
        parameters: {
          'bkId': bookingId,
          'uId': userId,
          'cCode': cancelCode,
          'reason': reason,
          'pct': refundPercentage,
          'refAmt': refundAmount,
          'fee': cancellationFee,
        },
      );

      final cancellationId = cancelRes.first[0] as int;

      // Create Refund Record
      final refundId = 'REF-BUS-${DateTime.now().millisecondsSinceEpoch}';
      await connection.execute(
        Sql.named('''
          INSERT INTO bus_refunds (refund_id, cancellation_id, booking_id, user_id, refund_amount, refund_method, refund_status, transaction_reference, completed_at)
          VALUES (@rId, @cId, @bkId, @uId, @amount, 'original_payment_source', 'completed', @txRef, CURRENT_TIMESTAMP)
        '''),
        parameters: {
          'rId': refundId,
          'cId': cancellationId,
          'bkId': bookingId,
          'uId': userId,
          'amount': refundAmount,
          'txRef': 'TXN_REFUND_${bookingCode.replaceAll('-', '')}',
        },
      );

      AppLogger.info('BusBookingService', 'Booking $bookingCode cancelled. Refund of ₹$refundAmount ($refundPercentage%) initiated.');

      return Response.json(
        body: {
          'status': 'success',
          'message': 'Booking $bookingCode ($pnrNumber) cancelled successfully. Refund of ₹${refundAmount.toStringAsFixed(2)} ($refundPercentage%) initiated.',
          'data': {
            'bookingId': bookingId,
            'bookingCode': bookingCode,
            'pnrNumber': pnrNumber,
            'bookingStatus': 'cancelled',
            'paymentStatus': 'refunded',
            'cancellationCode': cancelCode,
            'refundId': refundId,
            'refundPercentage': refundPercentage,
            'refundAmount': refundAmount,
            'cancellationFee': cancellationFee,
            'refundStatus': 'completed',
            'cancelledAt': now.toIso8601String(),
            'reason': reason,
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BusBookingService', 'Error cancelling bus booking $code', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to cancel booking: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 6. GET REFUND STATUS
  // GET /bus-bookings/{bookingId}/refund
  // ==============================================================================
  static Future<Response> getRefundStatus(RequestContext context, String bookingIdOrCode) async {
    final cleanCode = bookingIdOrCode.replaceAll('#', '').trim();
    final idInt = int.tryParse(cleanCode);
    final connection = await openDatabaseConnection();

    try {
      final res = await connection.execute(
        Sql.named('''
          SELECT
            br.refund_id,
            br.refund_amount,
            br.refund_method,
            br.refund_status,
            br.transaction_reference,
            br.initiated_at,
            br.completed_at,
            bc.cancellation_code,
            bc.cancellation_reason,
            bc.refund_percentage,
            bc.cancellation_fee,
            bb.id AS booking_id,
            bb.booking_code,
            bb.pnr_number,
            bb.total_amount
          FROM bus_refunds br
          JOIN bus_cancellations bc ON br.cancellation_id = bc.id
          JOIN bus_bookings bb ON br.booking_id = bb.id
          WHERE bb.id = @idOrZero
             OR LOWER(bb.booking_code) = LOWER(@code)
             OR LOWER(bb.pnr_number) = LOWER(@code)
             OR LOWER(br.refund_id) = LOWER(@code)
          LIMIT 1;
        '''),
        parameters: {
          'idOrZero': idInt ?? -1,
          'code': cleanCode,
        },
      );

      if (res.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Refund record not found for $cleanCode'},
        );
      }

      final row = res.first;

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'data': {
            'refundId': row[0],
            'refundAmount': _toDouble(row[1]),
            'refundMethod': row[2],
            'refundStatus': row[3],
            'transactionReference': row[4],
            'initiatedAt': (row[5] as DateTime).toIso8601String(),
            'completedAt': row[6] != null ? (row[6] as DateTime).toIso8601String() : null,
            'cancellationCode': row[7],
            'cancellationReason': row[8],
            'refundPercentage': _toDouble(row[9]),
            'cancellationFee': _toDouble(row[10]),
            'booking': {
              'bookingId': row[11],
              'bookingCode': row[12],
              'pnrNumber': row[13],
              'originalTotalAmount': _toDouble(row[14]),
            },
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BusBookingService', 'Error getting refund status $cleanCode', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to get refund status: $e'},
      );
    } finally {
      await connection.close();
    }
  }
}
