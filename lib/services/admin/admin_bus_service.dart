import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/admin/admin_auth_service.dart';

class AdminBusService {
  // ==========================================
  // BUS OPERATORS
  // ==========================================

  static Future<Response> listOperators(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final params = context.request.uri.queryParameters;
    final search = params['search']?.trim() ?? '';

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>["(is_deleted = false OR is_deleted IS NULL)"];
      final sqlParams = <String, dynamic>{};

      if (search.isNotEmpty) {
        whereClauses.add("(LOWER(name) LIKE @search OR LOWER(operator_code) LIKE @search)");
        sqlParams['search'] = '%${search.toLowerCase()}%';
      }

      final res = await conn.execute(
        Sql.named('''
          SELECT id, operator_code, name, logo_url, rating, total_reviews, contact_number, email, cancellation_policy, created_at,
                 (SELECT COUNT(*) FROM buses WHERE operator_id = bus_operators.id AND (is_deleted = false OR is_deleted IS NULL)) as bus_count
          FROM bus_operators
          WHERE ${whereClauses.join(' AND ')}
          ORDER BY id DESC
        '''),
        parameters: sqlParams,
      );

      final operators = res.map((r) => {
        'id': r[0],
        'operatorCode': r[1],
        'name': r[2],
        'logoUrl': r[3],
        'rating': double.tryParse(r[4]?.toString() ?? '4.5') ?? 4.5,
        'totalReviews': r[5] ?? 0,
        'contactNumber': r[6],
        'email': r[7],
        'cancellationPolicy': r[8],
        'createdAt': (r[9] as DateTime?)?.toIso8601String(),
        'busCount': int.parse(r[10].toString()),
      }).toList();

      return Response.json(body: {'operators': operators});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> createOperator(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final name = body['name']?.toString().trim();
    if (name == null || name.isEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'Operator name is required'});
    }

    final operatorCode = body['operatorCode']?.toString().trim().isNotEmpty == true
        ? body['operatorCode'].toString().trim()
        : 'OP_${name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase().padRight(4, 'X').substring(0, 4)}_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final logoUrl = body['logoUrl']?.toString().trim() ?? 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=200';
    final rating = double.tryParse(body['rating']?.toString() ?? '4.5') ?? 4.5;
    final contactNumber = body['contactNumber']?.toString().trim() ?? '+919876543210';
    final email = body['email']?.toString().trim() ?? 'support@${name.toLowerCase().replaceAll(' ', '')}.com';
    final cancellationPolicy = body['cancellationPolicy']?.toString().trim() ?? 'Cancellation allowed up to 4 hours before departure with 90% refund.';

    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute(
        Sql.named('''
          INSERT INTO bus_operators (operator_code, name, logo_url, rating, contact_number, email, cancellation_policy)
          VALUES (@code, @name, @logo, @rating, @phone, @email, @policy)
          RETURNING id
        '''),
        parameters: {
          'code': operatorCode,
          'name': name,
          'logo': logoUrl,
          'rating': rating,
          'phone': contactNumber,
          'email': email,
          'policy': cancellationPolicy,
        },
      );

      final newId = res.first[0] as int;

      await AdminAuthService.logAction(
        adminId: admin['id'] as int,
        adminEmail: admin['email'] as String,
        action: 'CREATE_BUS_OPERATOR',
        entityType: 'bus_operator',
        entityId: newId.toString(),
        connection: conn,
      );

      return Response.json(statusCode: 201, body: {'message': 'Bus operator created successfully', 'id': newId});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> updateOperator(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid operator ID'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final conn = await openDatabaseConnection();
    try {
      final updates = <String>[];
      final sqlParams = <String, dynamic>{'id': id};

      if (body.containsKey('name')) {
        updates.add('name = @name');
        sqlParams['name'] = body['name'].toString().trim();
      }
      if (body.containsKey('logoUrl')) {
        updates.add('logo_url = @logo');
        sqlParams['logo'] = body['logoUrl'].toString().trim();
      }
      if (body.containsKey('rating')) {
        updates.add('rating = @rating');
        sqlParams['rating'] = double.tryParse(body['rating'].toString()) ?? 4.5;
      }
      if (body.containsKey('contactNumber')) {
        updates.add('contact_number = @phone');
        sqlParams['phone'] = body['contactNumber'].toString().trim();
      }
      if (body.containsKey('email')) {
        updates.add('email = @email');
        sqlParams['email'] = body['email'].toString().trim();
      }
      if (body.containsKey('cancellationPolicy')) {
        updates.add('cancellation_policy = @policy');
        sqlParams['policy'] = body['cancellationPolicy'].toString().trim();
      }

      if (updates.isEmpty) return Response.json(statusCode: 400, body: {'error': 'No fields provided'});

      await conn.execute(
        Sql.named('UPDATE bus_operators SET ${updates.join(', ')} WHERE id = @id'),
        parameters: sqlParams,
      );

      return Response.json(body: {'message': 'Bus operator updated successfully'});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> deleteOperator(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid operator ID'});

    final conn = await openDatabaseConnection();
    try {
      await conn.execute(
        Sql.named('UPDATE bus_operators SET is_deleted = true, deleted_at = CURRENT_TIMESTAMP WHERE id = @id'),
        parameters: {'id': id},
      );
      return Response.json(body: {'message': 'Operator deleted successfully'});
    } finally {
      await conn.close();
    }
  }

  // ==========================================
  // BUSES
  // ==========================================

  static Future<Response> listBuses(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final params = context.request.uri.queryParameters;
    final operatorId = int.tryParse(params['operatorId'] ?? '');
    final busType = params['busType']?.trim();
    final search = params['search']?.trim() ?? '';
    final page = int.tryParse(params['page'] ?? '1') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
    final offset = (page - 1) * limit;

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>["(b.is_deleted = false OR b.is_deleted IS NULL)"];
      final sqlParams = <String, dynamic>{'limit': limit, 'offset': offset};

      if (operatorId != null) {
        whereClauses.add("b.operator_id = @operatorId");
        sqlParams['operatorId'] = operatorId;
      }
      if (busType != null && busType.isNotEmpty && busType != 'all') {
        whereClauses.add("LOWER(b.bus_type) LIKE @busType");
        sqlParams['busType'] = '%${busType.toLowerCase()}%';
      }
      if (search.isNotEmpty) {
        whereClauses.add("(LOWER(b.bus_name) LIKE @search OR LOWER(b.bus_number) LIKE @search OR LOWER(o.name) LIKE @search)");
        sqlParams['search'] = '%${search.toLowerCase()}%';
      }

      final whereSql = whereClauses.join(' AND ');

      final countRes = await conn.execute(
        Sql.named('''
          SELECT COUNT(*)
          FROM buses b
          JOIN bus_operators o ON b.operator_id = o.id
          WHERE $whereSql
        '''),
        parameters: sqlParams,
      );
      final total = int.parse(countRes.first[0].toString());

      final res = await conn.execute(
        Sql.named('''
          SELECT b.id, b.bus_code, b.operator_id, o.name as operator_name, o.logo_url as operator_logo,
                 b.bus_name, b.bus_number, b.bus_type, b.category, b.is_ac, b.deck_type,
                 b.total_seats, b.amenities, b.live_tracking_available, b.created_at,
                 (SELECT COUNT(*) FROM bus_seats WHERE bus_id = b.id) as configured_seats
          FROM buses b
          JOIN bus_operators o ON b.operator_id = o.id
          WHERE $whereSql
          ORDER BY b.id DESC
          LIMIT @limit OFFSET @offset
        '''),
        parameters: sqlParams,
      );

      final buses = res.map((r) {
        dynamic amenities = r[12];
        if (amenities is String) {
          try {
            amenities = jsonDecode(amenities);
          } catch (_) {}
        }

        return {
          'id': r[0],
          'busCode': r[1],
          'operatorId': r[2],
          'operatorName': r[3],
          'operatorLogo': r[4],
          'busName': r[5],
          'busNumber': r[6],
          'busType': r[7],
          'category': r[8],
          'isAc': r[9] ?? true,
          'deckType': r[10] ?? 'single',
          'totalSeats': r[11],
          'amenities': amenities ?? ['WiFi', 'Charging Point', 'Water Bottle', 'Blanket'],
          'liveTrackingAvailable': r[13] ?? true,
          'createdAt': (r[14] as DateTime?)?.toIso8601String(),
          'configuredSeats': int.parse(r[15].toString()),
        };
      }).toList();

      return Response.json(
        body: {
          'buses': buses,
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

  static Future<Response> createBus(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final operatorId = int.tryParse(body['operatorId']?.toString() ?? '');
    final busName = body['busName']?.toString().trim();
    final busNumber = body['busNumber']?.toString().trim();
    final busType = body['busType']?.toString().trim() ?? 'AC Sleeper (2+1)';
    final category = body['category']?.toString().trim() ?? 'Premium';
    final isAc = body['isAc'] != false;
    final deckType = body['deckType']?.toString().trim() ?? 'single';
    final totalSeats = int.tryParse(body['totalSeats']?.toString() ?? '30') ?? 30;
    final amenities = body['amenities'] ?? ['WiFi', 'Charging Point', 'Water Bottle', 'Emergency Exit'];
    final liveTracking = body['liveTrackingAvailable'] != false;

    if (operatorId == null || busName == null || busName.isEmpty || busNumber == null || busNumber.isEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'operatorId, busName, and busNumber are required'});
    }

    final busCode = body['busCode']?.toString().trim().isNotEmpty == true
        ? body['busCode'].toString().trim()
        : 'BUS_${busNumber.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';

    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute(
        Sql.named('''
          INSERT INTO buses (bus_code, operator_id, bus_name, bus_number, bus_type, category, is_ac, deck_type, total_seats, amenities, live_tracking_available)
          VALUES (@code, @opId, @name, @num, @type, @cat, @isAc, @deck, @total, @amenities, @live)
          RETURNING id
        '''),
        parameters: {
          'code': busCode,
          'opId': operatorId,
          'name': busName,
          'num': busNumber,
          'type': busType,
          'cat': category,
          'isAc': isAc,
          'deck': deckType,
          'total': totalSeats,
          'amenities': TypedValue(Type.jsonb, jsonEncode(amenities)),
          'live': liveTracking,
        },
      );

      final busId = res.first[0] as int;

      // Auto generate bus seats layout (e.g. Sleeper 2+1, lower deck)
      final rows = (totalSeats / 3).ceil();
      for (var r = 1; r <= rows; r++) {
        // Seat L1 (Single / Window)
        await conn.execute(
          Sql.named('''
            INSERT INTO bus_seats (bus_id, seat_number, deck, row_num, column_num, seat_type, berth_type, is_window, is_aisle, seat_tier, price_multiplier)
            VALUES (@busId, @seatNum, 'lower', @r, 1, 'sleeper', 'single', true, false, 'Single Sleeper', 1.2)
            ON CONFLICT DO NOTHING
          '''),
          parameters: {'busId': busId, 'seatNum': 'L$r-1', 'r': r},
        );

        // Seat L2 & L3 (Double Sleeper)
        await conn.execute(
          Sql.named('''
            INSERT INTO bus_seats (bus_id, seat_number, deck, row_num, column_num, seat_type, berth_type, is_window, is_aisle, seat_tier, price_multiplier)
            VALUES (@busId, @seatNum, 'lower', @r, 2, 'sleeper', 'double', false, true, 'Double Sleeper', 1.0)
            ON CONFLICT DO NOTHING
          '''),
          parameters: {'busId': busId, 'seatNum': 'L$r-2', 'r': r},
        );

        await conn.execute(
          Sql.named('''
            INSERT INTO bus_seats (bus_id, seat_number, deck, row_num, column_num, seat_type, berth_type, is_window, is_aisle, seat_tier, price_multiplier)
            VALUES (@busId, @seatNum, 'lower', @r, 3, 'sleeper', 'double', true, false, 'Double Sleeper', 1.0)
            ON CONFLICT DO NOTHING
          '''),
          parameters: {'busId': busId, 'seatNum': 'L$r-3', 'r': r},
        );
      }

      await AdminAuthService.logAction(
        adminId: admin['id'] as int,
        adminEmail: admin['email'] as String,
        action: 'CREATE_BUS',
        entityType: 'bus',
        entityId: busId.toString(),
        connection: conn,
      );

      return Response.json(statusCode: 201, body: {'message': 'Bus created successfully', 'id': busId});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> updateBus(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid bus ID'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final conn = await openDatabaseConnection();
    try {
      final updates = <String>[];
      final sqlParams = <String, dynamic>{'id': id};

      if (body.containsKey('operatorId')) {
        updates.add('operator_id = @operatorId');
        sqlParams['operatorId'] = int.tryParse(body['operatorId'].toString());
      }
      if (body.containsKey('busName')) {
        updates.add('bus_name = @busName');
        sqlParams['busName'] = body['busName'].toString().trim();
      }
      if (body.containsKey('busNumber')) {
        updates.add('bus_number = @busNumber');
        sqlParams['busNumber'] = body['busNumber'].toString().trim();
      }
      if (body.containsKey('busType')) {
        updates.add('bus_type = @busType');
        sqlParams['busType'] = body['busType'].toString().trim();
      }
      if (body.containsKey('category')) {
        updates.add('category = @category');
        sqlParams['category'] = body['category'].toString().trim();
      }
      if (body.containsKey('isAc')) {
        updates.add('is_ac = @isAc');
        sqlParams['isAc'] = body['isAc'] == true;
      }
      if (body.containsKey('deckType')) {
        updates.add('deck_type = @deckType');
        sqlParams['deckType'] = body['deckType'].toString().trim();
      }
      if (body.containsKey('totalSeats')) {
        updates.add('total_seats = @totalSeats');
        sqlParams['totalSeats'] = int.tryParse(body['totalSeats'].toString()) ?? 30;
      }
      if (body.containsKey('liveTrackingAvailable')) {
        updates.add('live_tracking_available = @live');
        sqlParams['live'] = body['liveTrackingAvailable'] == true;
      }
      if (body.containsKey('amenities')) {
        updates.add('amenities = @amenities');
        sqlParams['amenities'] = TypedValue(Type.jsonb, jsonEncode(body['amenities']));
      }

      if (updates.isEmpty) return Response.json(statusCode: 400, body: {'error': 'No fields provided'});

      await conn.execute(
        Sql.named('UPDATE buses SET ${updates.join(', ')} WHERE id = @id'),
        parameters: sqlParams,
      );

      await AdminAuthService.logAction(
        adminId: admin['id'] as int,
        adminEmail: admin['email'] as String,
        action: 'UPDATE_BUS',
        entityType: 'bus',
        entityId: id.toString(),
        connection: conn,
      );

      return Response.json(body: {'message': 'Bus updated successfully'});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> deleteBus(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid bus ID'});

    final conn = await openDatabaseConnection();
    try {
      await conn.execute(
        Sql.named('UPDATE buses SET is_deleted = true, deleted_at = CURRENT_TIMESTAMP WHERE id = @id'),
        parameters: {'id': id},
      );
      await AdminAuthService.logAction(
        adminId: admin['id'] as int,
        adminEmail: admin['email'] as String,
        action: 'DELETE_BUS',
        entityType: 'bus',
        entityId: id.toString(),
        connection: conn,
      );

      return Response.json(body: {'message': 'Bus deleted successfully'});
    } finally {
      await conn.close();
    }
  }

  /// Get Bus Seats layout
  static Future<Response> getBusSeats(RequestContext context, String busIdStr) async {
    final busId = int.tryParse(busIdStr);
    if (busId == null) return Response.json(statusCode: 400, body: {'error': 'Invalid bus ID'});

    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute(
        Sql.named('''
          SELECT id, seat_number, deck, row_num, column_num, seat_type, berth_type,
                 is_window, is_aisle, gender_preference, seat_tier, price_multiplier, is_active
          FROM bus_seats
          WHERE bus_id = @busId
          ORDER BY deck ASC, row_num ASC, column_num ASC
        '''),
        parameters: {'busId': busId},
      );

      final seats = res.map((r) => {
        'id': r[0],
        'seatNumber': r[1],
        'deck': r[2] ?? 'lower',
        'rowNum': r[3],
        'columnNum': r[4],
        'seatType': r[5] ?? 'sleeper',
        'berthType': r[6] ?? 'single',
        'isWindow': r[7] ?? false,
        'isAisle': r[8] ?? false,
        'genderPreference': r[9] ?? 'any',
        'seatTier': r[10] ?? 'Standard',
        'priceMultiplier': double.tryParse(r[11]?.toString() ?? '1.0') ?? 1.0,
        'isActive': r[12] ?? true,
      }).toList();

      return Response.json(body: {'busId': busId, 'seats': seats});
    } finally {
      await conn.close();
    }
  }

  // ==========================================
  // BUS ROUTES
  // ==========================================

  static Future<Response> listRoutes(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final params = context.request.uri.queryParameters;
    final search = params['search']?.trim() ?? '';

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>["(is_deleted = false OR is_deleted IS NULL)"];
      final sqlParams = <String, dynamic>{};

      if (search.isNotEmpty) {
        whereClauses.add("(LOWER(source_city) LIKE @search OR LOWER(destination_city) LIKE @search OR LOWER(route_code) LIKE @search)");
        sqlParams['search'] = '%${search.toLowerCase()}%';
      }

      final res = await conn.execute(
        Sql.named('''
          SELECT id, route_code, source_city, destination_city, source_state, destination_state,
                 distance_km, estimated_duration_mins, is_popular, created_at,
                 (SELECT COUNT(*) FROM bus_trips WHERE route_id = bus_routes.id AND (is_deleted = false OR is_deleted IS NULL)) as trip_count
          FROM bus_routes
          WHERE ${whereClauses.join(' AND ')}
          ORDER BY id DESC
        '''),
        parameters: sqlParams,
      );

      final routes = res.map((r) => {
        'id': r[0],
        'routeCode': r[1],
        'sourceCity': r[2],
        'destinationCity': r[3],
        'sourceState': r[4],
        'destinationState': r[5],
        'distanceKm': double.parse(r[6].toString()),
        'estimatedDurationMins': r[7],
        'isPopular': r[8] ?? false,
        'createdAt': (r[9] as DateTime?)?.toIso8601String(),
        'tripCount': int.parse(r[10].toString()),
      }).toList();

      return Response.json(body: {'routes': routes});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> createRoute(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final sourceCity = body['sourceCity']?.toString().trim();
    final destCity = body['destinationCity']?.toString().trim();
    final sourceState = body['sourceState']?.toString().trim() ?? 'State';
    final destState = body['destinationState']?.toString().trim() ?? 'State';
    final distanceKm = double.tryParse(body['distanceKm']?.toString() ?? '350') ?? 350.0;
    final durationMins = int.tryParse(body['estimatedDurationMins']?.toString() ?? '420') ?? 420;
    final isPopular = body['isPopular'] == true;

    if (sourceCity == null || sourceCity.isEmpty || destCity == null || destCity.isEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'sourceCity and destinationCity are required'});
    }

    final routeCode = body['routeCode']?.toString().trim().isNotEmpty == true
        ? body['routeCode'].toString().trim()
        : 'ROU_${sourceCity.substring(0, 3).toUpperCase()}_${destCity.substring(0, 3).toUpperCase()}_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute(
        Sql.named('''
          INSERT INTO bus_routes (route_code, source_city, destination_city, source_state, destination_state, distance_km, estimated_duration_mins, is_popular)
          VALUES (@code, @src, @dest, @srcSt, @destSt, @dist, @dur, @pop)
          RETURNING id
        '''),
        parameters: {
          'code': routeCode,
          'src': sourceCity,
          'dest': destCity,
          'srcSt': sourceState,
          'destSt': destState,
          'dist': distanceKm,
          'dur': durationMins,
          'pop': isPopular,
        },
      );

      final newId = res.first[0] as int;
      return Response.json(statusCode: 201, body: {'message': 'Route created successfully', 'id': newId});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> updateRoute(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid route ID'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final conn = await openDatabaseConnection();
    try {
      final updates = <String>[];
      final sqlParams = <String, dynamic>{'id': id};

      if (body.containsKey('sourceCity')) {
        updates.add('source_city = @src');
        sqlParams['src'] = body['sourceCity'].toString().trim();
      }
      if (body.containsKey('destinationCity')) {
        updates.add('destination_city = @dest');
        sqlParams['dest'] = body['destinationCity'].toString().trim();
      }
      if (body.containsKey('distanceKm')) {
        updates.add('distance_km = @dist');
        sqlParams['dist'] = double.tryParse(body['distanceKm'].toString()) ?? 350.0;
      }
      if (body.containsKey('estimatedDurationMins')) {
        updates.add('estimated_duration_mins = @dur');
        sqlParams['dur'] = int.tryParse(body['estimatedDurationMins'].toString()) ?? 400;
      }
      if (body.containsKey('isPopular')) {
        updates.add('is_popular = @pop');
        sqlParams['pop'] = body['isPopular'] == true;
      }

      if (updates.isEmpty) return Response.json(statusCode: 400, body: {'error': 'No fields provided'});

      await conn.execute(
        Sql.named('UPDATE bus_routes SET ${updates.join(', ')} WHERE id = @id'),
        parameters: sqlParams,
      );

      return Response.json(body: {'message': 'Route updated successfully'});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> deleteRoute(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid route ID'});

    final conn = await openDatabaseConnection();
    try {
      await conn.execute(
        Sql.named('UPDATE bus_routes SET is_deleted = true, deleted_at = CURRENT_TIMESTAMP WHERE id = @id'),
        parameters: {'id': id},
      );
      return Response.json(body: {'message': 'Route deleted successfully'});
    } finally {
      await conn.close();
    }
  }
}
