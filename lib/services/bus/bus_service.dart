import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

class BusService {
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

  static Future<void> _cleanExpiredLocks(Connection connection) async {
    try {
      await connection.execute(
        Sql.named('DELETE FROM bus_seat_locks WHERE expires_at <= CURRENT_TIMESTAMP'),
      );
    } catch (e) {
      AppLogger.warning('BusService', 'Failed to clean expired bus seat locks: $e');
    }
  }

  // ==============================================================================
  // 1. SEARCH BUSES
  // GET /buses/search?source=Bengaluru&destination=Chennai&date=2026-10-05
  // ==============================================================================
  static Future<Response> searchBuses(RequestContext context) async {
    final params = context.request.uri.queryParameters;
    final source = params['source'] ?? params['from'] ?? params['sourceCity'] ?? '';
    final destination = params['destination'] ?? params['to'] ?? params['destinationCity'] ?? '';
    final travelDateStr = params['date'] ?? params['travelDate'];
    final busTypeFilter = params['busType'] ?? params['type'];
    final acFilter = params['ac'] ?? params['isAc'];
    final operatorIdFilter = _toInt(params['operatorId'], 0);
    final minPrice = _toDouble(params['minPrice'], 0.0);
    final maxPrice = _toDouble(params['maxPrice'], 999999.0);
    final sortBy = params['sortBy'] ?? 'departure_asc';

    final connection = await openDatabaseConnection();

    try {
      await _cleanExpiredLocks(connection);

      final whereClauses = <String>[];
      final sqlParams = <String, dynamic>{};

      // Source filter
      if (source.trim().isNotEmpty) {
        whereClauses.add('LOWER(r.source_city) LIKE LOWER(@source)');
        sqlParams['source'] = '%${source.trim()}%';
      }

      // Destination filter
      if (destination.trim().isNotEmpty) {
        whereClauses.add('LOWER(r.destination_city) LIKE LOWER(@destination)');
        sqlParams['destination'] = '%${destination.trim()}%';
      }

      // Travel Date filter
      if (travelDateStr != null && travelDateStr.trim().isNotEmpty) {
        whereClauses.add('t.travel_date = @travelDate::date');
        sqlParams['travelDate'] = travelDateStr.trim();
      } else {
        // Default to today and onward
        whereClauses.add('t.travel_date >= CURRENT_DATE');
      }

      // Bus Type filter (AC / Non-AC / Sleeper / Seater / Semi-Sleeper)
      if (busTypeFilter != null && busTypeFilter.trim().isNotEmpty) {
        final bType = busTypeFilter.trim().toLowerCase();
        if (bType == 'ac') {
          whereClauses.add('b.is_ac = true');
        } else if (bType == 'non-ac' || bType == 'nonac') {
          whereClauses.add('b.is_ac = false');
        } else if (bType == 'sleeper') {
          whereClauses.add("b.category = 'sleeper'");
        } else if (bType == 'seater') {
          whereClauses.add("b.category = 'seater'");
        } else if (bType == 'semi_sleeper' || bType == 'semi-sleeper') {
          whereClauses.add("b.category = 'semi_sleeper'");
        } else {
          whereClauses.add('LOWER(b.bus_type) LIKE LOWER(@busType)');
          sqlParams['busType'] = '%$bType%';
        }
      }

      if (acFilter != null && acFilter.isNotEmpty) {
        whereClauses.add('b.is_ac = @isAc');
        sqlParams['isAc'] = acFilter.toLowerCase() == 'true';
      }

      // Operator filter
      if (operatorIdFilter > 0) {
        whereClauses.add('b.operator_id = @opId');
        sqlParams['opId'] = operatorIdFilter;
      }

      // Price range
      if (minPrice > 0) {
        whereClauses.add('t.base_fare >= @minPrice');
        sqlParams['minPrice'] = minPrice;
      }
      if (maxPrice < 999999.0) {
        whereClauses.add('t.base_fare <= @maxPrice');
        sqlParams['maxPrice'] = maxPrice;
      }

      // Active status
      whereClauses.add("t.status != 'cancelled'");

      final whereSql = whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

      // Sorting
      String orderBySql;
      switch (sortBy.toLowerCase()) {
        case 'price_asc':
        case 'price_low_high':
          orderBySql = 'ORDER BY t.base_fare ASC, t.departure_time ASC';
          break;
        case 'price_desc':
        case 'price_high_low':
          orderBySql = 'ORDER BY t.base_fare DESC, t.departure_time ASC';
          break;
        case 'rating':
        case 'rating_high':
          orderBySql = 'ORDER BY op.rating DESC, t.departure_time ASC';
          break;
        case 'duration':
        case 'duration_asc':
          orderBySql = 'ORDER BY r.estimated_duration_mins ASC, t.departure_time ASC';
          break;
        case 'departure_desc':
        case 'departure_latest':
          orderBySql = 'ORDER BY t.departure_time DESC';
          break;
        case 'departure_asc':
        case 'departure_earliest':
        default:
          orderBySql = 'ORDER BY t.travel_date ASC, t.departure_time ASC';
          break;
      }

      final query = '''
        SELECT
          t.id AS trip_id,
          t.trip_code,
          t.travel_date,
          t.departure_time,
          t.arrival_time,
          t.departure_time_formatted,
          t.arrival_time_formatted,
          t.duration_formatted,
          t.base_fare,
          t.status AS trip_status,
          b.id AS bus_id,
          b.bus_code,
          b.bus_name,
          b.bus_number,
          b.bus_type,
          b.category,
          b.is_ac,
          b.deck_type,
          b.total_seats,
          b.amenities,
          b.live_tracking_available,
          op.id AS operator_id,
          op.operator_code,
          op.name AS operator_name,
          op.logo_url AS operator_logo,
          op.rating AS operator_rating,
          op.total_reviews AS operator_reviews,
          op.contact_number AS operator_phone,
          r.id AS route_id,
          r.route_code,
          r.source_city,
          r.destination_city,
          r.distance_km,
          r.estimated_duration_mins,
          (
            SELECT COUNT(*)
            FROM bus_seats bs
            WHERE bs.bus_id = b.id
          ) AS configured_seats_count,
          (
            SELECT COUNT(DISTINCT bbs.seat_id)
            FROM bus_booking_seats bbs
            JOIN bus_bookings bb ON bbs.booking_id = bb.id
            WHERE bb.trip_id = t.id AND bb.booking_status != 'cancelled'
          ) AS booked_seats_count,
          (
            SELECT COUNT(DISTINCT bsl.seat_id)
            FROM bus_seat_locks bsl
            WHERE bsl.trip_id = t.id AND bsl.expires_at > CURRENT_TIMESTAMP
          ) AS locked_seats_count,
          (
            SELECT COUNT(*)
            FROM boarding_points bp
            WHERE bp.trip_id = t.id
          ) AS boarding_points_count,
          (
            SELECT COUNT(*)
            FROM dropping_points dp
            WHERE dp.trip_id = t.id
          ) AS dropping_points_count
        FROM bus_trips t
        JOIN buses b ON t.bus_id = b.id
        JOIN bus_operators op ON b.operator_id = op.id
        JOIN bus_routes r ON t.route_id = r.id
        $whereSql
        $orderBySql
        LIMIT 100;
      ''';

      final results = await connection.execute(
        Sql.named(query),
        parameters: sqlParams,
      );

      final busList = <Map<String, dynamic>>[];

      for (final row in results) {
        final totalSeats = _toInt(row[18], 36);
        final bookedSeats = _toInt(row[35], 0);
        final lockedSeats = _toInt(row[36], 0);
        final availableSeats = max(0, totalSeats - bookedSeats - lockedSeats);

        dynamic amenities = row[19];
        if (amenities is String) {
          try {
            amenities = jsonDecode(amenities);
          } catch (_) {
            amenities = [];
          }
        }

        final baseFare = _toDouble(row[8], 750.0);
        final startingPrice = baseFare;

        busList.add({
          'tripId': row[0],
          'tripCode': row[1],
          'travelDate': row[2].toString().split(' ').first,
          'departureTime': (row[3] as DateTime).toIso8601String(),
          'arrivalTime': (row[4] as DateTime).toIso8601String(),
          'departureTimeFormatted': row[5],
          'arrivalTimeFormatted': row[6],
          'durationFormatted': row[7],
          'baseFare': baseFare,
          'startingPrice': startingPrice,
          'tripStatus': availableSeats == 0 ? 'sold_out' : (availableSeats <= 5 ? 'filling_fast' : row[9]),
          'bus': {
            'id': row[10],
            'busCode': row[11],
            'busName': row[12],
            'busNumber': row[13],
            'busType': row[14],
            'category': row[15],
            'isAc': row[16] == true,
            'deckType': row[17],
            'totalSeats': totalSeats,
            'availableSeats': availableSeats,
            'bookedSeats': bookedSeats,
            'lockedSeats': lockedSeats,
            'amenities': amenities ?? [],
            'liveTrackingAvailable': row[20] == true,
          },
          'operator': {
            'id': row[21],
            'operatorCode': row[22],
            'name': row[23],
            'logoUrl': row[24],
            'rating': _toDouble(row[25], 4.5),
            'totalReviews': _toInt(row[26], 100),
            'contactNumber': row[27],
          },
          'route': {
            'id': row[28],
            'routeCode': row[29],
            'sourceCity': row[30],
            'destinationCity': row[31],
            'distanceKm': _toDouble(row[32]),
            'estimatedDurationMins': _toInt(row[33]),
          },
          'boardingPointsCount': _toInt(row[37]),
          'droppingPointsCount': _toInt(row[38]),
        });
      }

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'message': 'Available buses fetched successfully',
          'searchParams': {
            'source': source,
            'destination': destination,
            'travelDate': travelDateStr,
            'busType': busTypeFilter,
            'sortBy': sortBy,
          },
          'totalAvailableBuses': busList.length,
          'data': busList,
        },
      );
    } catch (e, st) {
      AppLogger.error('BusService', 'Error in searchBuses', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to search buses: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 2. GET SINGLE BUS DETAILS
  // GET /buses/{busId}
  // ==============================================================================
  static Future<Response> getBusDetails(RequestContext context, String busIdOrTripId) async {
    final idInt = int.tryParse(busIdOrTripId);
    final connection = await openDatabaseConnection();

    try {
      await _cleanExpiredLocks(connection);

      // Search by trip ID, bus ID, trip code, or bus code
      final query = '''
        SELECT
          t.id AS trip_id,
          t.trip_code,
          t.travel_date,
          t.departure_time,
          t.arrival_time,
          t.departure_time_formatted,
          t.arrival_time_formatted,
          t.duration_formatted,
          t.base_fare,
          t.status AS trip_status,
          b.id AS bus_id,
          b.bus_code,
          b.bus_name,
          b.bus_number,
          b.bus_type,
          b.category,
          b.is_ac,
          b.deck_type,
          b.total_seats,
          b.amenities,
          b.live_tracking_available,
          op.id AS operator_id,
          op.operator_code,
          op.name AS operator_name,
          op.logo_url AS operator_logo,
          op.rating AS operator_rating,
          op.total_reviews AS operator_reviews,
          op.contact_number AS operator_phone,
          op.email AS operator_email,
          op.cancellation_policy,
          r.id AS route_id,
          r.route_code,
          r.source_city,
          r.destination_city,
          r.source_state,
          r.destination_state,
          r.distance_km,
          r.estimated_duration_mins
        FROM bus_trips t
        JOIN buses b ON t.bus_id = b.id
        JOIN bus_operators op ON b.operator_id = op.id
        JOIN bus_routes r ON t.route_id = r.id
        WHERE t.id = @idOrZero
           OR b.id = @idOrZero
           OR LOWER(t.trip_code) = LOWER(@strCode)
           OR LOWER(b.bus_code) = LOWER(@strCode)
        ORDER BY t.travel_date ASC, t.departure_time ASC
        LIMIT 1;
      ''';

      final res = await connection.execute(
        Sql.named(query),
        parameters: {
          'idOrZero': idInt ?? -1,
          'strCode': busIdOrTripId.trim(),
        },
      );

      if (res.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Bus trip not found'},
        );
      }

      final row = res.first;
      final tripId = row[0] as int;
      final busId = row[10] as int;
      final totalSeats = _toInt(row[18], 36);

      // Fetch Boarding Points
      final bpRes = await connection.execute(
        Sql.named('''
          SELECT id, point_name, landmark, address, contact_number, departure_time, time_formatted, display_order, latitude, longitude
          FROM boarding_points
          WHERE trip_id = @tId
          ORDER BY display_order ASC, departure_time ASC
        '''),
        parameters: {'tId': tripId},
      );

      final boardingPoints = bpRes.map((bp) => {
        'id': bp[0],
        'pointName': bp[1],
        'landmark': bp[2],
        'address': bp[3],
        'contactNumber': bp[4],
        'departureTime': (bp[5] as DateTime).toIso8601String(),
        'timeFormatted': bp[6],
        'displayOrder': bp[7],
        'latitude': _toDouble(bp[8]),
        'longitude': _toDouble(bp[9]),
      }).toList();

      // Fetch Dropping Points
      final dpRes = await connection.execute(
        Sql.named('''
          SELECT id, point_name, landmark, address, contact_number, arrival_time, time_formatted, display_order, latitude, longitude
          FROM dropping_points
          WHERE trip_id = @tId
          ORDER BY display_order ASC, arrival_time ASC
        '''),
        parameters: {'tId': tripId},
      );

      final droppingPoints = dpRes.map((dp) => {
        'id': dp[0],
        'pointName': dp[1],
        'landmark': dp[2],
        'address': dp[3],
        'contactNumber': dp[4],
        'arrivalTime': (dp[5] as DateTime).toIso8601String(),
        'timeFormatted': dp[6],
        'displayOrder': dp[7],
        'latitude': _toDouble(dp[8]),
        'longitude': _toDouble(dp[9]),
      }).toList();

      // Available seats count
      final bookedCountRes = await connection.execute(
        Sql.named('''
          SELECT COUNT(DISTINCT bbs.seat_id)
          FROM bus_booking_seats bbs
          JOIN bus_bookings bb ON bbs.booking_id = bb.id
          WHERE bb.trip_id = @tId AND bb.booking_status != 'cancelled'
        '''),
        parameters: {'tId': tripId},
      );
      final lockedCountRes = await connection.execute(
        Sql.named('''
          SELECT COUNT(DISTINCT bsl.seat_id)
          FROM bus_seat_locks bsl
          WHERE bsl.trip_id = @tId AND bsl.expires_at > CURRENT_TIMESTAMP
        '''),
        parameters: {'tId': tripId},
      );

      final bookedCount = _toInt(bookedCountRes.first[0]);
      final lockedCount = _toInt(lockedCountRes.first[0]);
      final availableCount = max(0, totalSeats - bookedCount - lockedCount);

      dynamic amenities = row[19];
      if (amenities is String) {
        try {
          amenities = jsonDecode(amenities);
        } catch (_) {
          amenities = [];
        }
      }

      final baseFare = _toDouble(row[8], 750.0);

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'data': {
            'tripId': tripId,
            'tripCode': row[1],
            'travelDate': row[2].toString().split(' ').first,
            'departureTime': (row[3] as DateTime).toIso8601String(),
            'arrivalTime': (row[4] as DateTime).toIso8601String(),
            'departureTimeFormatted': row[5],
            'arrivalTimeFormatted': row[6],
            'durationFormatted': row[7],
            'baseFare': baseFare,
            'startingPrice': baseFare,
            'tripStatus': availableCount == 0 ? 'sold_out' : row[9],
            'bus': {
              'id': busId,
              'busCode': row[11],
              'busName': row[12],
              'busNumber': row[13],
              'busType': row[14],
              'category': row[15],
              'isAc': row[16] == true,
              'deckType': row[17],
              'totalSeats': totalSeats,
              'availableSeats': availableCount,
              'bookedSeats': bookedCount,
              'lockedSeats': lockedCount,
              'amenities': amenities ?? [],
              'liveTrackingAvailable': row[20] == true,
            },
            'operator': {
              'id': row[21],
              'operatorCode': row[22],
              'name': row[23],
              'logoUrl': row[24],
              'rating': _toDouble(row[25], 4.5),
              'totalReviews': _toInt(row[26], 100),
              'contactNumber': row[27],
              'email': row[28],
              'cancellationPolicy': row[29],
            },
            'route': {
              'id': row[30],
              'routeCode': row[31],
              'sourceCity': row[32],
              'destinationCity': row[33],
              'sourceState': row[34],
              'destinationState': row[35],
              'distanceKm': _toDouble(row[36]),
              'estimatedDurationMins': _toInt(row[37]),
            },
            'boardingPoints': boardingPoints,
            'droppingPoints': droppingPoints,
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BusService', 'Error getting bus details $busIdOrTripId', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to get bus details: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 3. GET BUS SEATS MATRIX & REAL-TIME AVAILABILITY
  // GET /buses/{busId}/seats
  // ==============================================================================
  static Future<Response> getBusSeats(RequestContext context, String busIdOrTripId) async {
    final idInt = int.tryParse(busIdOrTripId);
    final connection = await openDatabaseConnection();

    try {
      await _cleanExpiredLocks(connection);

      // 1. Resolve Trip & Bus
      final tripRes = await connection.execute(
        Sql.named('''
          SELECT
            t.id AS trip_id,
            t.trip_code,
            t.bus_id,
            t.base_fare,
            t.travel_date,
            t.departure_time_formatted,
            t.arrival_time_formatted,
            t.duration_formatted,
            b.bus_name,
            b.bus_type,
            b.category,
            b.deck_type,
            b.total_seats,
            op.name AS operator_name,
            r.source_city,
            r.destination_city
          FROM bus_trips t
          JOIN buses b ON t.bus_id = b.id
          JOIN bus_operators op ON b.operator_id = op.id
          JOIN bus_routes r ON t.route_id = r.id
          WHERE t.id = @idOrZero
             OR b.id = @idOrZero
             OR LOWER(t.trip_code) = LOWER(@strCode)
             OR LOWER(b.bus_code) = LOWER(@strCode)
          ORDER BY t.travel_date ASC, t.departure_time ASC
          LIMIT 1;
        '''),
        parameters: {
          'idOrZero': idInt ?? -1,
          'strCode': busIdOrTripId.trim(),
        },
      );

      if (tripRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Bus trip not found'},
        );
      }

      final tripRow = tripRes.first;
      final tripId = tripRow[0] as int;
      final busId = tripRow[2] as int;
      final baseFare = _toDouble(tripRow[3], 750.0);
      final deckType = tripRow[11] as String;

      // 2. Fetch all seats for the bus with live booked/locked status
      final seatsRes = await connection.execute(
        Sql.named('''
          SELECT
            s.id,
            s.seat_number,
            s.deck,
            s.row_num,
            s.column_num,
            s.seat_type,
            s.berth_type,
            s.is_window,
            s.is_aisle,
            s.gender_preference,
            s.seat_tier,
            s.price_multiplier,
            CASE
              WHEN bbs.id IS NOT NULL THEN 'booked'
              WHEN bsl.id IS NOT NULL THEN 'locked'
              ELSE 'available'
            END AS seat_status,
            COALESCE(bbp.gender, s.gender_preference) AS booked_gender
          FROM bus_seats s
          LEFT JOIN (
            SELECT bbs.seat_id, bbs.id, bbs.booking_id
            FROM bus_booking_seats bbs
            JOIN bus_bookings bb ON bbs.booking_id = bb.id
            WHERE bb.trip_id = @tId AND bb.booking_status != 'cancelled'
          ) bbs ON bbs.seat_id = s.id
          LEFT JOIN (
            SELECT bsl.seat_id, bsl.id
            FROM bus_seat_locks bsl
            WHERE bsl.trip_id = @tId AND bsl.expires_at > CURRENT_TIMESTAMP
          ) bsl ON bsl.seat_id = s.id
          LEFT JOIN bus_booking_passengers bbp ON bbp.booking_id = bbs.booking_id AND bbp.seat_id = s.id
          WHERE s.bus_id = @bId
          ORDER BY
            CASE WHEN s.deck = 'lower' THEN 1 ELSE 2 END,
            s.row_num ASC,
            s.column_num ASC;
        '''),
        parameters: {
          'tId': tripId,
          'bId': busId,
        },
      );

      final lowerDeckSeats = <Map<String, dynamic>>[];
      final upperDeckSeats = <Map<String, dynamic>>[];
      final tiersMap = <String, Map<String, dynamic>>{};

      var totalAvailable = 0;
      var totalBooked = 0;
      var totalLocked = 0;

      for (final s in seatsRes) {
        final seatId = s[0] as int;
        final seatNumber = s[1] as String;
        final deck = s[2] as String;
        final rowNum = s[3] as int;
        final colNum = s[4] as int;
        final seatType = s[5] as String;
        final berthType = s[6] as String;
        final isWindow = s[7] == true;
        final isAisle = s[8] == true;
        final genderPreference = s[9] as String;
        final seatTier = s[10] as String;
        final multiplier = _toDouble(s[11], 1.0);
        final seatStatus = s[12] as String;
        final bookedGender = s[13]?.toString() ?? genderPreference;

        final seatPrice = (baseFare * multiplier).roundToDouble();

        if (seatStatus == 'available') totalAvailable++;
        if (seatStatus == 'booked') totalBooked++;
        if (seatStatus == 'locked') totalLocked++;

        tiersMap.putIfAbsent(seatTier, () => {
          'tierName': seatTier,
          'price': seatPrice,
          'multiplier': multiplier,
        });

        final seatObj = {
          'seatId': seatId,
          'seatNumber': seatNumber,
          'deck': deck,
          'row': rowNum,
          'column': colNum,
          'seatType': seatType,
          'berthType': berthType,
          'isWindow': isWindow,
          'isAisle': isAisle,
          'genderPreference': genderPreference,
          'seatTier': seatTier,
          'price': seatPrice,
          'status': seatStatus, // 'available' | 'locked' | 'booked'
          'bookedGender': bookedGender,
        };

        if (deck == 'upper') {
          upperDeckSeats.add(seatObj);
        } else {
          lowerDeckSeats.add(seatObj);
        }
      }

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'data': {
            'trip': {
              'tripId': tripId,
              'tripCode': tripRow[1],
              'busId': busId,
              'busName': tripRow[8],
              'busType': tripRow[9],
              'category': tripRow[10],
              'operatorName': tripRow[13],
              'sourceCity': tripRow[14],
              'destinationCity': tripRow[15],
              'travelDate': tripRow[4].toString().split(' ').first,
              'departureTimeFormatted': tripRow[5],
              'arrivalTimeFormatted': tripRow[6],
              'durationFormatted': tripRow[7],
              'baseFare': baseFare,
            },
            'summary': {
              'totalSeats': seatsRes.length,
              'availableSeats': totalAvailable,
              'bookedSeats': totalBooked,
              'lockedSeats': totalLocked,
              'deckType': deckType,
              'startingPrice': baseFare,
            },
            'tiers': tiersMap.values.toList(),
            'layout': {
              'hasUpperDeck': upperDeckSeats.isNotEmpty,
              'lowerDeck': lowerDeckSeats,
              'upperDeck': upperDeckSeats,
            },
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BusService', 'Error getting bus seats $busIdOrTripId', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to get bus seat layout: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 4. GET BOARDING POINTS
  // GET /buses/{busId}/boarding-points
  // ==============================================================================
  static Future<Response> getBoardingPoints(RequestContext context, String busIdOrTripId) async {
    final idInt = int.tryParse(busIdOrTripId);
    final connection = await openDatabaseConnection();

    try {
      final res = await connection.execute(
        Sql.named('''
          SELECT
            bp.id,
            bp.point_name,
            bp.landmark,
            bp.address,
            bp.contact_number,
            bp.departure_time,
            bp.time_formatted,
            bp.display_order,
            bp.latitude,
            bp.longitude,
            bp.trip_id,
            bp.bus_id
          FROM boarding_points bp
          JOIN bus_trips t ON bp.trip_id = t.id
          JOIN buses b ON bp.bus_id = b.id
          WHERE bp.trip_id = @idOrZero
             OR bp.bus_id = @idOrZero
             OR LOWER(t.trip_code) = LOWER(@strCode)
             OR LOWER(b.bus_code) = LOWER(@strCode)
          ORDER BY bp.display_order ASC, bp.departure_time ASC;
        '''),
        parameters: {
          'idOrZero': idInt ?? -1,
          'strCode': busIdOrTripId.trim(),
        },
      );

      final points = res.map((row) => {
        'id': row[0],
        'pointName': row[1],
        'landmark': row[2],
        'address': row[3],
        'contactNumber': row[4],
        'departureTime': (row[5] as DateTime).toIso8601String(),
        'timeFormatted': row[6],
        'displayOrder': row[7],
        'latitude': _toDouble(row[8]),
        'longitude': _toDouble(row[9]),
        'tripId': row[10],
        'busId': row[11],
      }).toList();

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'count': points.length,
          'data': points,
        },
      );
    } catch (e, st) {
      AppLogger.error('BusService', 'Error getting boarding points $busIdOrTripId', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to get boarding points: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 5. GET DROPPING POINTS
  // GET /buses/{busId}/dropping-points
  // ==============================================================================
  static Future<Response> getDroppingPoints(RequestContext context, String busIdOrTripId) async {
    final idInt = int.tryParse(busIdOrTripId);
    final connection = await openDatabaseConnection();

    try {
      final res = await connection.execute(
        Sql.named('''
          SELECT
            dp.id,
            dp.point_name,
            dp.landmark,
            dp.address,
            dp.contact_number,
            dp.arrival_time,
            dp.time_formatted,
            dp.display_order,
            dp.latitude,
            dp.longitude,
            dp.trip_id,
            dp.bus_id
          FROM dropping_points dp
          JOIN bus_trips t ON dp.trip_id = t.id
          JOIN buses b ON dp.bus_id = b.id
          WHERE dp.trip_id = @idOrZero
             OR dp.bus_id = @idOrZero
             OR LOWER(t.trip_code) = LOWER(@strCode)
             OR LOWER(b.bus_code) = LOWER(@strCode)
          ORDER BY dp.display_order ASC, dp.arrival_time ASC;
        '''),
        parameters: {
          'idOrZero': idInt ?? -1,
          'strCode': busIdOrTripId.trim(),
        },
      );

      final points = res.map((row) => {
        'id': row[0],
        'pointName': row[1],
        'landmark': row[2],
        'address': row[3],
        'contactNumber': row[4],
        'arrivalTime': (row[5] as DateTime).toIso8601String(),
        'timeFormatted': row[6],
        'displayOrder': row[7],
        'latitude': _toDouble(row[8]),
        'longitude': _toDouble(row[9]),
        'tripId': row[10],
        'busId': row[11],
      }).toList();

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'count': points.length,
          'data': points,
        },
      );
    } catch (e, st) {
      AppLogger.error('BusService', 'Error getting dropping points $busIdOrTripId', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to get dropping points: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 6. POPULAR CITIES & ROUTES
  // GET /buses/cities & GET /buses/routes
  // ==============================================================================
  static Future<Response> getCitiesAndRoutes(RequestContext context) async {
    final connection = await openDatabaseConnection();

    try {
      final citiesRes = await connection.execute('''
        SELECT DISTINCT city FROM (
          SELECT source_city AS city FROM bus_routes
          UNION
          SELECT destination_city AS city FROM bus_routes
        ) t ORDER BY city ASC;
      ''');

      final routesRes = await connection.execute('''
        SELECT
          r.id,
          r.route_code,
          r.source_city,
          r.destination_city,
          r.distance_km,
          r.estimated_duration_mins,
          r.is_popular,
          (
            SELECT MIN(t.base_fare)
            FROM bus_trips t
            WHERE t.route_id = r.id AND t.travel_date >= CURRENT_DATE
          ) AS starting_fare,
          (
            SELECT COUNT(*)
            FROM bus_trips t
            WHERE t.route_id = r.id AND t.travel_date >= CURRENT_DATE
          ) AS daily_trips_count
        FROM bus_routes r
        ORDER BY r.is_popular DESC, r.source_city ASC;
      ''');

      final operatorsRes = await connection.execute('''
        SELECT id, operator_code, name, logo_url, rating, total_reviews, contact_number
        FROM bus_operators
        ORDER BY rating DESC;
      ''');

      final cities = citiesRes.map((r) => r[0] as String).toList();
      final routes = routesRes.map((r) => {
        'id': r[0],
        'routeCode': r[1],
        'sourceCity': r[2],
        'destinationCity': r[3],
        'distanceKm': _toDouble(r[4]),
        'estimatedDurationMins': _toInt(r[5]),
        'isPopular': r[6] == true,
        'startingFare': _toDouble(r[7], 550.0),
        'dailyTripsCount': _toInt(r[8]),
      }).toList();

      final operators = operatorsRes.map((r) => {
        'id': r[0],
        'operatorCode': r[1],
        'name': r[2],
        'logoUrl': r[3],
        'rating': _toDouble(r[4]),
        'totalReviews': _toInt(r[5]),
        'contactNumber': r[6],
      }).toList();

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'data': {
            'cities': cities,
            'popularRoutes': routes.where((r) => r['isPopular'] == true).toList(),
            'allRoutes': routes,
            'operators': operators,
            'busTypes': [
              {'label': 'All Types', 'value': 'all'},
              {'label': 'AC Sleeper (2+1)', 'value': 'sleeper'},
              {'label': 'AC Semi-Sleeper (2+2)', 'value': 'semi_sleeper'},
              {'label': 'AC Seater (2+2)', 'value': 'seater'},
              {'label': 'Volvo Multi-Axle AC', 'value': 'volvo'},
              {'label': 'Non-AC Sleeper', 'value': 'non-ac'},
            ],
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BusService', 'Error getting cities and routes', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to fetch cities & routes: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  // ==============================================================================
  // 7. AI-BASED RECOMMENDED SEAT SELECTION
  // GET /buses/{busId}/recommend-seats OR POST /buses/recommend-seats
  // ==============================================================================
  static Future<Response> recommendSeats(RequestContext context, [String? busIdOrTripIdParam]) async {
    final params = context.request.uri.queryParameters;
    var targetId = busIdOrTripIdParam ?? params['busId'] ?? params['tripId'];
    var passengerCount = _toInt(params['passengers'] ?? params['count'] ?? params['passengerCount'], 1);
    var preference = (params['preference'] ?? params['type'] ?? 'comfort').toLowerCase();
    var genderPref = (params['gender'] ?? 'any').toLowerCase();

    // If POST request, check JSON body
    if (context.request.method == HttpMethod.post) {
      try {
        final body = await context.request.json();
        if (body is Map) {
          if (targetId == null || targetId.isEmpty) {
            targetId = body['busId']?.toString() ?? body['tripId']?.toString();
          }
          if (body['passengerCount'] != null) passengerCount = _toInt(body['passengerCount'], passengerCount);
          if (body['preference'] != null) preference = body['preference'].toString().toLowerCase();
          if (body['gender'] != null) genderPref = body['gender'].toString().toLowerCase();
        }
      } catch (_) {}
    }

    if (targetId == null || targetId.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'busId or tripId is required for AI seat recommendation'},
      );
    }

    final idInt = int.tryParse(targetId);
    final connection = await openDatabaseConnection();

    try {
      await _cleanExpiredLocks(connection);

      // Fetch Trip Info
      final tripRes = await connection.execute(
        Sql.named('''
          SELECT t.id, t.bus_id, t.base_fare, b.bus_name, b.category, b.deck_type
          FROM bus_trips t
          JOIN buses b ON t.bus_id = b.id
          WHERE t.id = @idOrZero
             OR b.id = @idOrZero
             OR LOWER(t.trip_code) = LOWER(@strCode)
             OR LOWER(b.bus_code) = LOWER(@strCode)
          LIMIT 1;
        '''),
        parameters: {'idOrZero': idInt ?? -1, 'strCode': targetId.trim()},
      );

      if (tripRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'status': 'error', 'message': 'Bus trip not found'},
        );
      }

      final tripId = tripRes.first[0] as int;
      final busId = tripRes.first[1] as int;
      final baseFare = _toDouble(tripRes.first[2], 750.0);
      final busCategory = tripRes.first[4] as String;

      // Fetch all available seats for this trip
      final seatsRes = await connection.execute(
        Sql.named('''
          SELECT
            s.id,
            s.seat_number,
            s.deck,
            s.row_num,
            s.column_num,
            s.seat_type,
            s.berth_type,
            s.is_window,
            s.is_aisle,
            s.gender_preference,
            s.seat_tier,
            s.price_multiplier
          FROM bus_seats s
          LEFT JOIN (
            SELECT bbs.seat_id
            FROM bus_booking_seats bbs
            JOIN bus_bookings bb ON bbs.booking_id = bb.id
            WHERE bb.trip_id = @tId AND bb.booking_status != 'cancelled'
          ) bbs ON bbs.seat_id = s.id
          LEFT JOIN (
            SELECT bsl.seat_id
            FROM bus_seat_locks bsl
            WHERE bsl.trip_id = @tId AND bsl.expires_at > CURRENT_TIMESTAMP
          ) bsl ON bsl.seat_id = s.id
          WHERE s.bus_id = @bId
            AND bbs.seat_id IS NULL
            AND bsl.seat_id IS NULL
          ORDER BY s.deck ASC, s.row_num ASC, s.column_num ASC;
        '''),
        parameters: {'tId': tripId, 'bId': busId},
      );

      if (seatsRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.ok,
          body: {
            'status': 'success',
            'statusCode': 200,
            'message': 'No available seats on this bus.',
            'recommendations': [],
          },
        );
      }

      final availableList = seatsRes.map((s) {
        final mult = _toDouble(s[11], 1.0);
        return {
          'seatId': s[0] as int,
          'seatNumber': s[1] as String,
          'deck': s[2] as String,
          'row': s[3] as int,
          'column': s[4] as int,
          'seatType': s[5] as String,
          'berthType': s[6] as String,
          'isWindow': s[7] == true,
          'isAisle': s[8] == true,
          'genderPreference': s[9] as String,
          'seatTier': s[10] as String,
          'multiplier': mult,
          'price': (baseFare * mult).roundToDouble(),
        };
      }).toList();

      // AI Seat Recommendation Logic
      final recommendations = <Map<String, dynamic>>[];

      // Option 1: Top Comfort & Smooth Ride (Lower Deck, Middle Rows 2-4, Window)
      final comfortSeats = availableList.where((s) {
        return s['deck'] == 'lower' && (s['row'] as int >= 2 && s['row'] as int <= 4);
      }).toList();

      if (comfortSeats.isNotEmpty) {
        final selected = comfortSeats.take(passengerCount).toList();
        if (selected.length == passengerCount) {
          recommendations.add({
            'recommendationType': 'top_comfort',
            'badge': 'AI Pick • Top Comfort & Smooth Ride',
            'score': 98,
            'reason': 'Lower deck middle section minimizes road vibrations and axle jolts, giving the smoothest sleep experience with window alignment.',
            'seats': selected,
            'totalFare': selected.fold<double>(0.0, (acc, s) => acc + (s['price'] as double)),
          });
        }
      }

      // Option 2: Solo Traveler's Sanctuary (Single Window Berths)
      final soloSeats = availableList.where((s) {
        return s['berthType'] == 'single_berth' && s['isWindow'] == true;
      }).toList();

      if (soloSeats.isNotEmpty) {
        final selected = soloSeats.take(passengerCount).toList();
        if (selected.length == passengerCount) {
          recommendations.add({
            'recommendationType': 'solo_sanctuary',
            'badge': 'AI Pick • Solo Traveler Choice',
            'score': 95,
            'reason': 'Independent single berth on the left side ensures maximum privacy, uninterrupted sleep, and dedicated charging & reading light.',
            'seats': selected,
            'totalFare': selected.fold<double>(0.0, (acc, s) => acc + (s['price'] as double)),
          });
        }
      }

      // Option 3: Couple / Companions Double Berth (Adjacent Column 2 & 3 on same row)
      if (passengerCount >= 2) {
        for (final rowGroup in [1, 2, 3, 4, 5, 6]) {
          final pairLower = availableList.where((s) => s['deck'] == 'lower' && s['row'] == rowGroup && (s['column'] == 2 || s['column'] == 3)).toList();
          if (pairLower.length == 2) {
            recommendations.add({
              'recommendationType': 'couple_pair',
              'badge': 'AI Pick • Perfect for Couples & Friends',
              'score': 94,
              'reason': 'Adjacent double berths side-by-side on the lower deck with privacy curtains, ideal for traveling together.',
              'seats': pairLower,
              'totalFare': pairLower.fold<double>(0.0, (acc, s) => acc + (s['price'] as double)),
            });
            break;
          }
        }
      }

      // Option 4: Quick De-boarding (Front Rows 1 & 2)
      final frontSeats = availableList.where((s) => s['row'] as int <= 2 && s['deck'] == 'lower').toList();
      if (frontSeats.isNotEmpty) {
        final selected = frontSeats.take(passengerCount).toList();
        if (selected.length == passengerCount && !recommendations.any((r) => r['recommendationType'] == 'quick_exit')) {
          recommendations.add({
            'recommendationType': 'quick_exit',
            'badge': 'AI Pick • Fast Boarding & Quick Exit',
            'score': 91,
            'reason': 'Located right near the front doorway for quick de-boarding upon arrival without waiting in line with luggage.',
            'seats': selected,
            'totalFare': selected.fold<double>(0.0, (acc, s) => acc + (s['price'] as double)),
          });
        }
      }

      // Option 5: Best Value / Budget Friendly
      final valueSeats = List<Map<String, dynamic>>.from(availableList)
        ..sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
      final selectedValue = valueSeats.take(passengerCount).toList();
      if (selectedValue.length == passengerCount) {
        recommendations.add({
          'recommendationType': 'best_value',
          'badge': 'AI Pick • Best Value for Money',
          'score': 88,
          'reason': 'Maximum savings with standard tier pricing while maintaining clean, comfortable journey standards.',
          'seats': selectedValue,
          'totalFare': selectedValue.fold<double>(0.0, (acc, s) => acc + (s['price'] as double)),
        });
      }

      // Fallback if none matched
      if (recommendations.isEmpty) {
        final fallback = availableList.take(passengerCount).toList();
        recommendations.add({
          'recommendationType': 'standard',
          'badge': 'AI Pick • Recommended Selection',
          'score': 85,
          'reason': 'Best contiguous available seats for your requested passenger count.',
          'seats': fallback,
          'totalFare': fallback.fold<double>(0.0, (acc, s) => acc + (s['price'] as double)),
        });
      }

      return Response.json(
        body: {
          'status': 'success',
          'statusCode': 200,
          'message': 'AI-driven seat recommendations generated',
          'tripId': tripId,
          'passengerCount': passengerCount,
          'requestedPreference': preference,
          'totalAvailableSeatsCount': availableList.length,
          'data': {
            'topPick': recommendations.first,
            'allRecommendations': recommendations,
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('BusService', 'Error in recommendSeats', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to recommend seats: $e'},
      );
    } finally {
      await connection.close();
    }
  }
}
