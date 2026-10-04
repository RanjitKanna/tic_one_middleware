import 'package:dart_frog/dart_frog.dart';
import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/admin/admin_auth_service.dart';

class AdminTripService {
  static Future<Response> listTrips(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final params = context.request.uri.queryParameters;
    final page = int.tryParse(params['page'] ?? '1') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
    final offset = (page - 1) * limit;
    final routeId = int.tryParse(params['routeId'] ?? '');
    final busId = int.tryParse(params['busId'] ?? '');
    final date = params['date']?.trim();
    final status = params['status']?.trim() ?? '';
    final search = params['search']?.trim() ?? '';

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>["(t.is_deleted = false OR t.is_deleted IS NULL)"];
      final countParams = <String, dynamic>{};

      if (routeId != null) {
        whereClauses.add("t.route_id = @routeId");
        countParams['routeId'] = routeId;
      }
      if (busId != null) {
        whereClauses.add("t.bus_id = @busId");
        countParams['busId'] = busId;
      }
      if (date != null && date.isNotEmpty && date != 'all') {
        whereClauses.add("t.travel_date = @date::date");
        countParams['date'] = date;
      }
      if (status.isNotEmpty && status != 'all') {
        whereClauses.add("LOWER(t.status) = @status");
        countParams['status'] = status.toLowerCase();
      }
      if (search.isNotEmpty) {
        whereClauses.add("(LOWER(r.source_city) LIKE @search OR LOWER(r.destination_city) LIKE @search OR LOWER(b.bus_name) LIKE @search OR LOWER(o.name) LIKE @search)");
        countParams['search'] = '%${search.toLowerCase()}%';
      }

      final whereSql = whereClauses.join(' AND ');

      final countRes = await conn.execute(
        Sql.named('''
          SELECT COUNT(*)
          FROM bus_trips t
          JOIN bus_routes r ON t.route_id = r.id
          JOIN buses b ON t.bus_id = b.id
          JOIN bus_operators o ON b.operator_id = o.id
          WHERE $whereSql
        '''),
        parameters: countParams,
      );
      final total = int.parse(countRes.first[0].toString());

      final queryParams = Map<String, dynamic>.from(countParams)
        ..addAll({'limit': limit, 'offset': offset});

      final res = await conn.execute(
        Sql.named('''
          SELECT t.id, t.trip_code, t.bus_id, b.bus_name, b.bus_number, b.bus_type,
                 o.id as operator_id, o.name as operator_name, o.logo_url as operator_logo,
                 t.route_id, r.source_city, r.destination_city,
                 t.travel_date, t.departure_time, t.arrival_time,
                 t.departure_time_formatted, t.arrival_time_formatted, t.duration_formatted,
                 t.base_fare, t.status, t.created_at,
                 (SELECT COUNT(*) FROM bus_bookings WHERE trip_id = t.id AND booking_status != 'cancelled') as booking_count,
                 b.total_seats
          FROM bus_trips t
          JOIN bus_routes r ON t.route_id = r.id
          JOIN buses b ON t.bus_id = b.id
          JOIN bus_operators o ON b.operator_id = o.id
          WHERE $whereSql
          ORDER BY t.departure_time DESC
          LIMIT @limit OFFSET @offset
        '''),
        parameters: queryParams,
      );

      final trips = res.map((r) => {
        'id': r[0],
        'tripCode': r[1],
        'busId': r[2],
        'busName': r[3],
        'busNumber': r[4],
        'busType': r[5],
        'operatorId': r[6],
        'operatorName': r[7],
        'operatorLogo': r[8],
        'routeId': r[9],
        'sourceCity': r[10],
        'destinationCity': r[11],
        'travelDate': (r[12] is DateTime) ? (r[12] as DateTime).toIso8601String().substring(0, 10) : r[12].toString(),
        'departureTime': (r[13] as DateTime).toIso8601String(),
        'arrivalTime': (r[14] as DateTime).toIso8601String(),
        'departureTimeFormatted': r[15],
        'arrivalTimeFormatted': r[16],
        'durationFormatted': r[17],
        'baseFare': double.parse(r[18].toString()),
        'status': r[19] ?? 'scheduled',
        'createdAt': (r[20] as DateTime?)?.toIso8601String(),
        'bookingCount': int.parse(r[21].toString()),
        'totalSeats': r[22],
      }).toList();

      return Response.json(
        body: {
          'trips': trips,
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

  static Future<Response> getTrip(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid trip ID'});

    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute(
        Sql.named('''
          SELECT t.id, t.trip_code, t.bus_id, b.bus_name, b.bus_number, b.bus_type,
                 o.id as operator_id, o.name as operator_name, o.logo_url as operator_logo,
                 t.route_id, r.source_city, r.destination_city,
                 t.travel_date, t.departure_time, t.arrival_time,
                 t.departure_time_formatted, t.arrival_time_formatted, t.duration_formatted,
                 t.base_fare, t.status, t.created_at, b.total_seats
          FROM bus_trips t
          JOIN bus_routes r ON t.route_id = r.id
          JOIN buses b ON t.bus_id = b.id
          JOIN bus_operators o ON b.operator_id = o.id
          WHERE t.id = @id
          LIMIT 1
        '''),
        parameters: {'id': id},
      );

      if (res.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Trip not found'});
      final r = res.first;

      final bpRes = await conn.execute(
        Sql.named('''
          SELECT id, point_name, landmark, address, contact_number, departure_time, time_formatted, display_order
          FROM boarding_points
          WHERE trip_id = @id OR (bus_id = @busId AND trip_id IS NULL)
          ORDER BY display_order ASC, departure_time ASC
        '''),
        parameters: {'id': id, 'busId': r[2]},
      );

      final boardingPoints = bpRes.map((bp) => {
        'id': bp[0],
        'pointName': bp[1],
        'landmark': bp[2],
        'address': bp[3],
        'contactNumber': bp[4],
        'departureTime': (bp[5] as DateTime).toIso8601String(),
        'timeFormatted': bp[6],
        'displayOrder': bp[7] ?? 1,
      }).toList();

      final dpRes = await conn.execute(
        Sql.named('''
          SELECT id, point_name, landmark, address, contact_number, arrival_time, time_formatted, display_order
          FROM dropping_points
          WHERE trip_id = @id OR (bus_id = @busId AND trip_id IS NULL)
          ORDER BY display_order ASC, arrival_time ASC
        '''),
        parameters: {'id': id, 'busId': r[2]},
      );

      final droppingPoints = dpRes.map((dp) => {
        'id': dp[0],
        'pointName': dp[1],
        'landmark': dp[2],
        'address': dp[3],
        'contactNumber': dp[4],
        'arrivalTime': (dp[5] as DateTime).toIso8601String(),
        'timeFormatted': dp[6],
        'displayOrder': dp[7] ?? 1,
      }).toList();

      final seatsRes = await conn.execute(
        Sql.named('''
          SELECT id, seat_number, deck, row_num, column_num, seat_type, berth_type,
                 is_window, is_aisle, seat_tier, price_multiplier, is_active
          FROM bus_seats
          WHERE bus_id = @busId
          ORDER BY deck ASC, row_num ASC, column_num ASC
        '''),
        parameters: {'busId': r[2]},
      );

      final bookedSeatNumbers = <String>{};
      final bookedRes = await conn.execute(
        Sql.named('''
          SELECT bs.seat_number
          FROM bus_booking_seats bs
          JOIN bus_bookings b ON bs.booking_id = b.id
          WHERE b.trip_id = @id AND b.booking_status != 'cancelled'
        '''),
        parameters: {'id': id},
      );
      for (final br in bookedRes) {
        bookedSeatNumbers.add(br[0] as String);
      }

      final baseFare = double.parse(r[18].toString());
      final seats = seatsRes.map((s) => {
        'id': s[0],
        'seatNumber': s[1],
        'deck': s[2] ?? 'lower',
        'rowNum': s[3],
        'columnNum': s[4],
        'seatType': s[5] ?? 'sleeper',
        'berthType': s[6] ?? 'single',
        'isWindow': s[7] ?? false,
        'isAisle': s[8] ?? false,
        'seatTier': s[9] ?? 'Standard',
        'price': (baseFare * (double.tryParse(s[10]?.toString() ?? '1.0') ?? 1.0)).roundToDouble(),
        'isActive': s[11] ?? true,
        'status': bookedSeatNumbers.contains(s[1]) ? 'booked' : ((s[11] == false) ? 'unavailable' : 'available'),
      }).toList();

      return Response.json(
        body: {
          'trip': {
            'id': r[0],
            'tripCode': r[1],
            'busId': r[2],
            'busName': r[3],
            'busNumber': r[4],
            'busType': r[5],
            'operatorId': r[6],
            'operatorName': r[7],
            'operatorLogo': r[8],
            'routeId': r[9],
            'sourceCity': r[10],
            'destinationCity': r[11],
            'travelDate': (r[12] is DateTime) ? (r[12] as DateTime).toIso8601String().substring(0, 10) : r[12].toString(),
            'departureTime': (r[13] as DateTime).toIso8601String(),
            'arrivalTime': (r[14] as DateTime).toIso8601String(),
            'departureTimeFormatted': r[15],
            'arrivalTimeFormatted': r[16],
            'durationFormatted': r[17],
            'baseFare': baseFare,
            'status': r[19] ?? 'scheduled',
            'createdAt': (r[20] as DateTime?)?.toIso8601String(),
            'totalSeats': r[21],
            'boardingPoints': boardingPoints,
            'droppingPoints': droppingPoints,
            'seats': seats,
          },
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<Response> createTrip(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final busId = int.tryParse(body['busId']?.toString() ?? '');
    final routeId = int.tryParse(body['routeId']?.toString() ?? '');
    final rawTravelDate = body['travelDate']?.toString().trim();
    final rawDepTime = body['departureTime']?.toString();
    final rawArrTime = body['arrivalTime']?.toString();
    final baseFare = double.tryParse(body['baseFare']?.toString() ?? '850') ?? 850.0;
    final status = body['status']?.toString().trim() ?? 'scheduled';

    if (busId == null || routeId == null || rawDepTime == null || rawArrTime == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'busId, routeId, departureTime, and arrivalTime are required'},
      );
    }

    final depDateTime = DateTime.tryParse(rawDepTime);
    final arrDateTime = DateTime.tryParse(rawArrTime);
    if (depDateTime == null || arrDateTime == null) {
      return Response.json(statusCode: 400, body: {'error': 'Invalid departure/arrival datetime format'});
    }

    final travelDate = rawTravelDate ?? depDateTime.toIso8601String().substring(0, 10);
    final depFormatted = DateFormat('hh:mm a').format(depDateTime.toLocal());
    final arrFormatted = DateFormat('hh:mm a').format(arrDateTime.toLocal());

    final diffMins = arrDateTime.difference(depDateTime).inMinutes;
    final hours = diffMins ~/ 60;
    final mins = diffMins % 60;
    final durationFormatted = '${hours}h ${mins}m';

    final tripCode = body['tripCode']?.toString().trim().isNotEmpty == true
        ? body['tripCode'].toString().trim()
        : 'TRP_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute(
        Sql.named('''
          INSERT INTO bus_trips (trip_code, bus_id, route_id, travel_date, departure_time, arrival_time, departure_time_formatted, arrival_time_formatted, duration_formatted, base_fare, status)
          VALUES (@code, @busId, @routeId, @date::date, @dep, @arr, @depFmt, @arrFmt, @durFmt, @fare, @status)
          RETURNING id
        '''),
        parameters: {
          'code': tripCode,
          'busId': busId,
          'routeId': routeId,
          'date': travelDate,
          'dep': depDateTime,
          'arr': arrDateTime,
          'depFmt': depFormatted,
          'arrFmt': arrFormatted,
          'durFmt': durationFormatted,
          'fare': baseFare,
          'status': status,
        },
      );

      final tripId = res.first[0] as int;

      if (body['boardingPoints'] is List) {
        final list = body['boardingPoints'] as List;
        for (var i = 0; i < list.length; i++) {
          final bp = list[i] as Map;
          final bpTime = DateTime.tryParse(bp['departureTime']?.toString() ?? '') ?? depDateTime;
          await conn.execute(
            Sql.named('''
              INSERT INTO boarding_points (trip_id, bus_id, point_name, landmark, address, contact_number, departure_time, time_formatted, display_order)
              VALUES (@tripId, @busId, @name, @landmark, @address, @phone, @depTime, @timeFmt, @order)
            '''),
            parameters: {
              'tripId': tripId,
              'busId': busId,
              'name': bp['pointName']?.toString() ?? 'Main Boarding Point',
              'landmark': bp['landmark']?.toString(),
              'address': bp['address']?.toString() ?? '',
              'phone': bp['contactNumber']?.toString() ?? '+919876543210',
              'depTime': bpTime,
              'timeFmt': DateFormat('hh:mm a').format(bpTime.toLocal()),
              'order': i + 1,
            },
          );
        }
      }

      if (body['droppingPoints'] is List) {
        final list = body['droppingPoints'] as List;
        for (var i = 0; i < list.length; i++) {
          final dp = list[i] as Map;
          final dpTime = DateTime.tryParse(dp['arrivalTime']?.toString() ?? '') ?? arrDateTime;
          await conn.execute(
            Sql.named('''
              INSERT INTO dropping_points (trip_id, bus_id, point_name, landmark, address, contact_number, arrival_time, time_formatted, display_order)
              VALUES (@tripId, @busId, @name, @landmark, @address, @phone, @arrTime, @timeFmt, @order)
            '''),
            parameters: {
              'tripId': tripId,
              'busId': busId,
              'name': dp['pointName']?.toString() ?? 'Main Dropping Point',
              'landmark': dp['landmark']?.toString(),
              'address': dp['address']?.toString() ?? '',
              'phone': dp['contactNumber']?.toString() ?? '+919876543210',
              'arrTime': dpTime,
              'timeFmt': DateFormat('hh:mm a').format(dpTime.toLocal()),
              'order': i + 1,
            },
          );
        }
      }

      await AdminAuthService.logAction(
        adminId: admin['id'] as int,
        adminEmail: admin['email'] as String,
        action: 'CREATE_BUS_TRIP',
        entityType: 'bus_trip',
        entityId: tripId.toString(),
        connection: conn,
      );

      return Response.json(statusCode: 201, body: {'message': 'Bus trip created successfully', 'id': tripId});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> updateTrip(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid trip ID'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final conn = await openDatabaseConnection();
    try {
      final updates = <String>[];
      final sqlParams = <String, dynamic>{'id': id};

      if (body.containsKey('status')) {
        updates.add('status = @status');
        sqlParams['status'] = body['status'].toString().trim();
      }
      if (body.containsKey('baseFare')) {
        updates.add('base_fare = @baseFare');
        sqlParams['baseFare'] = double.tryParse(body['baseFare'].toString()) ?? 850.0;
      }
      if (body.containsKey('departureTime')) {
        final dep = DateTime.tryParse(body['departureTime'].toString());
        if (dep != null) {
          updates.add('departure_time = @dep');
          updates.add('departure_time_formatted = @depFmt');
          sqlParams['dep'] = dep;
          sqlParams['depFmt'] = DateFormat('hh:mm a').format(dep.toLocal());
        }
      }
      if (body.containsKey('arrivalTime')) {
        final arr = DateTime.tryParse(body['arrivalTime'].toString());
        if (arr != null) {
          updates.add('arrival_time = @arr');
          updates.add('arrival_time_formatted = @arrFmt');
          sqlParams['arr'] = arr;
          sqlParams['arrFmt'] = DateFormat('hh:mm a').format(arr.toLocal());
        }
      }

      if (updates.isEmpty) return Response.json(statusCode: 400, body: {'error': 'No fields provided'});

      await conn.execute(
        Sql.named('UPDATE bus_trips SET ${updates.join(', ')} WHERE id = @id'),
        parameters: sqlParams,
      );

      return Response.json(body: {'message': 'Bus trip updated successfully'});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> deleteTrip(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid trip ID'});

    final conn = await openDatabaseConnection();
    try {
      await conn.execute(
        Sql.named("UPDATE bus_trips SET is_deleted = true, deleted_at = CURRENT_TIMESTAMP, status = 'cancelled' WHERE id = @id"),
        parameters: {'id': id},
      );
      return Response.json(body: {'message': 'Bus trip cancelled / deleted successfully'});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> listBoardingPoints(RequestContext context) async {
    final params = context.request.uri.queryParameters;
    final tripId = int.tryParse(params['tripId'] ?? '');
    final busId = int.tryParse(params['busId'] ?? '');

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>[];
      final sqlParams = <String, dynamic>{};
      if (tripId != null) {
        whereClauses.add("trip_id = @tripId");
        sqlParams['tripId'] = tripId;
      }
      if (busId != null) {
        whereClauses.add("bus_id = @busId");
        sqlParams['busId'] = busId;
      }

      final whereSql = whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';
      final res = await conn.execute(
        Sql.named('SELECT id, trip_id, bus_id, point_name, landmark, address, contact_number, departure_time, time_formatted, display_order FROM boarding_points $whereSql ORDER BY display_order ASC'),
        parameters: sqlParams,
      );

      final points = res.map((r) => {
        'id': r[0],
        'tripId': r[1],
        'busId': r[2],
        'pointName': r[3],
        'landmark': r[4],
        'address': r[5],
        'contactNumber': r[6],
        'departureTime': (r[7] as DateTime).toIso8601String(),
        'timeFormatted': r[8],
        'displayOrder': r[9] ?? 1,
      }).toList();

      return Response.json(body: {'boardingPoints': points});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> listDroppingPoints(RequestContext context) async {
    final params = context.request.uri.queryParameters;
    final tripId = int.tryParse(params['tripId'] ?? '');
    final busId = int.tryParse(params['busId'] ?? '');

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>[];
      final sqlParams = <String, dynamic>{};
      if (tripId != null) {
        whereClauses.add("trip_id = @tripId");
        sqlParams['tripId'] = tripId;
      }
      if (busId != null) {
        whereClauses.add("bus_id = @busId");
        sqlParams['busId'] = busId;
      }

      final whereSql = whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';
      final res = await conn.execute(
        Sql.named('SELECT id, trip_id, bus_id, point_name, landmark, address, contact_number, arrival_time, time_formatted, display_order FROM dropping_points $whereSql ORDER BY display_order ASC'),
        parameters: sqlParams,
      );

      final points = res.map((r) => {
        'id': r[0],
        'tripId': r[1],
        'busId': r[2],
        'pointName': r[3],
        'landmark': r[4],
        'address': r[5],
        'contactNumber': r[6],
        'arrivalTime': (r[7] as DateTime).toIso8601String(),
        'timeFormatted': r[8],
        'displayOrder': r[9] ?? 1,
      }).toList();

      return Response.json(body: {'droppingPoints': points});
    } finally {
      await conn.close();
    }
  }
}
