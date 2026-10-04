import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/admin/admin_auth_service.dart';

class AdminTheaterService {
  static Future<Response> listCities(RequestContext context) async {
    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute("SELECT id, name, is_popular FROM cities ORDER BY name ASC;");
      final cities = res.map((r) => {
        'id': r[0],
        'name': r[1],
        'isPopular': r[2] ?? false,
      }).toList();
      return Response.json(body: {'cities': cities});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> listTheaters(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) {
      return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});
    }

    final params = context.request.uri.queryParameters;
    final cityId = int.tryParse(params['cityId'] ?? '');
    final search = params['search']?.trim() ?? '';
    final page = int.tryParse(params['page'] ?? '1') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
    final offset = (page - 1) * limit;

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>["(t.is_deleted = false OR t.is_deleted IS NULL)"];
      final countParams = <String, dynamic>{};

      if (cityId != null) {
        whereClauses.add("t.city_id = @cityId");
        countParams['cityId'] = cityId;
      }

      if (search.isNotEmpty) {
        whereClauses.add("(LOWER(t.name) LIKE @search OR LOWER(t.address) LIKE @search OR LOWER(c.name) LIKE @search)");
        countParams['search'] = '%${search.toLowerCase()}%';
      }

      final whereSql = whereClauses.join(' AND ');

      final countRes = await conn.execute(
        Sql.named('''
          SELECT COUNT(*) 
          FROM theaters t
          JOIN cities c ON t.city_id = c.id
          WHERE $whereSql
        '''),
        parameters: countParams,
      );
      final total = int.parse(countRes.first[0].toString());

      final queryParams = Map<String, dynamic>.from(countParams)
        ..addAll({'limit': limit, 'offset': offset});

      final res = await conn.execute(
        Sql.named('''
          SELECT t.id, t.theater_code, t.name, t.city_id, c.name as city_name,
                 t.distance_info, t.landmark, t.address, t.formats,
                 t.latitude, t.longitude, t.is_fast_filling, t.created_at,
                 COUNT(sc.id) as screen_count
          FROM theaters t
          JOIN cities c ON t.city_id = c.id
          LEFT JOIN screens sc ON t.id = sc.theater_id AND (sc.is_deleted = false OR sc.is_deleted IS NULL)
          WHERE $whereSql
          GROUP BY t.id, t.theater_code, t.name, t.city_id, c.name, t.distance_info, t.landmark, t.address, t.formats, t.latitude, t.longitude, t.is_fast_filling, t.created_at
          ORDER BY t.id DESC
          LIMIT @limit OFFSET @offset
        '''),
        parameters: queryParams,
      );

      final theaters = res.map((r) => {
        'id': r[0],
        'theaterCode': r[1],
        'name': r[2],
        'cityId': r[3],
        'cityName': r[4],
        'distanceInfo': r[5],
        'landmark': r[6],
        'address': r[7],
        'formats': r[8],
        'latitude': double.tryParse(r[9]?.toString() ?? ''),
        'longitude': double.tryParse(r[10]?.toString() ?? ''),
        'isFastFilling': r[11] ?? false,
        'createdAt': (r[12] as DateTime?)?.toIso8601String(),
        'screenCount': int.parse(r[13].toString()),
      }).toList();

      return Response.json(
        body: {
          'theaters': theaters,
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

  static Future<Response> getTheater(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid theater ID'});

    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute(
        Sql.named('''
          SELECT t.id, t.theater_code, t.name, t.city_id, c.name as city_name,
                 t.distance_info, t.landmark, t.address, t.formats,
                 t.latitude, t.longitude, t.is_fast_filling, t.created_at
          FROM theaters t
          JOIN cities c ON t.city_id = c.id
          WHERE t.id = @id
          LIMIT 1
        '''),
        parameters: {'id': id},
      );

      if (res.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Theater not found'});
      final r = res.first;

      final screensRes = await conn.execute(
        Sql.named('''
          SELECT s.id, s.screen_name, s.total_seats, s.created_at,
                 (SELECT COUNT(*) FROM seats WHERE screen_id = s.id) as actual_seats
          FROM screens s
          WHERE s.theater_id = @id AND (s.is_deleted = false OR s.is_deleted IS NULL)
          ORDER BY s.id ASC
        '''),
        parameters: {'id': id},
      );

      final screens = screensRes.map((s) => {
        'id': s[0],
        'screenName': s[1],
        'totalSeats': s[2],
        'createdAt': (s[3] as DateTime?)?.toIso8601String(),
        'actualSeats': int.parse(s[4].toString()),
      }).toList();

      return Response.json(
        body: {
          'theater': {
            'id': r[0],
            'theaterCode': r[1],
            'name': r[2],
            'cityId': r[3],
            'cityName': r[4],
            'distanceInfo': r[5],
            'landmark': r[6],
            'address': r[7],
            'formats': r[8],
            'latitude': double.tryParse(r[9]?.toString() ?? ''),
            'longitude': double.tryParse(r[10]?.toString() ?? ''),
            'isFastFilling': r[11] ?? false,
            'createdAt': (r[12] as DateTime?)?.toIso8601String(),
            'screens': screens,
          },
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<Response> createTheater(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final name = body['name']?.toString().trim();
    final cityId = int.tryParse(body['cityId']?.toString() ?? '');
    if (name == null || name.isEmpty || cityId == null) {
      return Response.json(statusCode: 400, body: {'error': 'Name and cityId are required'});
    }

    final theaterCode = body['theaterCode']?.toString().trim().isNotEmpty == true
        ? body['theaterCode'].toString().trim()
        : 'THT_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    final address = body['address']?.toString().trim() ?? '';
    final landmark = body['landmark']?.toString().trim();
    final formats = body['formats']?.toString().trim() ?? 'IMAX, Dolby Atmos 4K';
    final distanceInfo = body['distanceInfo']?.toString().trim() ?? 'Central';
    final lat = double.tryParse(body['latitude']?.toString() ?? '');
    final lng = double.tryParse(body['longitude']?.toString() ?? '');

    final conn = await openDatabaseConnection();
    try {
      final insertRes = await conn.execute(
        Sql.named('''
          INSERT INTO theaters (theater_code, city_id, name, distance_info, landmark, address, formats, latitude, longitude)
          VALUES (@theaterCode, @cityId, @name, @distanceInfo, @landmark, @address, @formats, @lat, @lng)
          RETURNING id
        '''),
        parameters: {
          'theaterCode': theaterCode,
          'cityId': cityId,
          'name': name,
          'distanceInfo': distanceInfo,
          'landmark': landmark,
          'address': address,
          'formats': formats,
          'lat': lat,
          'lng': lng,
        },
      );

      final newId = insertRes.first[0] as int;

      final screenName = body['initialScreenName']?.toString().trim() ?? 'Screen 1';
      final totalSeats = int.tryParse(body['initialSeats']?.toString() ?? '80') ?? 80;
      await conn.execute(
        Sql.named("INSERT INTO screens (theater_id, screen_name, total_seats) VALUES (@theaterId, @screenName, @totalSeats)"),
        parameters: {'theaterId': newId, 'screenName': screenName, 'totalSeats': totalSeats},
      );

      await AdminAuthService.logAction(
        adminId: admin['id'] as int,
        adminEmail: admin['email'] as String,
        action: 'CREATE_THEATER',
        entityType: 'theater',
        entityId: newId.toString(),
        details: {'name': name, 'cityId': cityId},
        connection: conn,
      );

      return Response.json(statusCode: 201, body: {'message': 'Theater created successfully', 'id': newId});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> updateTheater(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid theater ID'});

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
      if (body.containsKey('cityId')) {
        updates.add('city_id = @cityId');
        sqlParams['cityId'] = int.tryParse(body['cityId'].toString());
      }
      if (body.containsKey('address')) {
        updates.add('address = @address');
        sqlParams['address'] = body['address'].toString().trim();
      }
      if (body.containsKey('landmark')) {
        updates.add('landmark = @landmark');
        sqlParams['landmark'] = body['landmark']?.toString().trim();
      }
      if (body.containsKey('formats')) {
        updates.add('formats = @formats');
        sqlParams['formats'] = body['formats']?.toString().trim();
      }
      if (body.containsKey('distanceInfo')) {
        updates.add('distance_info = @distanceInfo');
        sqlParams['distanceInfo'] = body['distanceInfo']?.toString().trim();
      }
      if (body.containsKey('latitude')) {
        updates.add('latitude = @lat');
        sqlParams['lat'] = double.tryParse(body['latitude'].toString());
      }
      if (body.containsKey('longitude')) {
        updates.add('longitude = @lng');
        sqlParams['lng'] = double.tryParse(body['longitude'].toString());
      }

      if (updates.isEmpty) {
        return Response.json(statusCode: 400, body: {'error': 'No fields provided'});
      }

      await conn.execute(
        Sql.named('UPDATE theaters SET ${updates.join(', ')} WHERE id = @id'),
        parameters: sqlParams,
      );

      return Response.json(body: {'message': 'Theater updated successfully'});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> deleteTheater(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid theater ID'});

    final conn = await openDatabaseConnection();
    try {
      await conn.execute(
        Sql.named('UPDATE theaters SET is_deleted = true, deleted_at = CURRENT_TIMESTAMP WHERE id = @id'),
        parameters: {'id': id},
      );
      return Response.json(body: {'message': 'Theater deleted successfully'});
    } finally {
      await conn.close();
    }
  }

  // --- Screens CRUD ---

  static Future<Response> listScreens(RequestContext context) async {
    final params = context.request.uri.queryParameters;
    final theaterId = int.tryParse(params['theaterId'] ?? '');

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>["(s.is_deleted = false OR s.is_deleted IS NULL)"];
      final sqlParams = <String, dynamic>{};

      if (theaterId != null) {
        whereClauses.add("s.theater_id = @theaterId");
        sqlParams['theaterId'] = theaterId;
      }

      final res = await conn.execute(
        Sql.named('''
          SELECT s.id, s.theater_id, s.screen_name, s.total_seats, t.name as theater_name,
                 (SELECT COUNT(*) FROM seats WHERE screen_id = s.id) as actual_seats
          FROM screens s
          JOIN theaters t ON s.theater_id = t.id
          WHERE ${whereClauses.join(' AND ')}
          ORDER BY s.id ASC
        '''),
        parameters: sqlParams,
      );

      final screens = res.map((s) => {
        'id': s[0],
        'theaterId': s[1],
        'screenName': s[2],
        'totalSeats': s[3],
        'theaterName': s[4],
        'actualSeats': int.parse(s[5].toString()),
      }).toList();

      return Response.json(body: {'screens': screens});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> createScreen(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final theaterId = int.tryParse(body['theaterId']?.toString() ?? '');
    final screenName = body['screenName']?.toString().trim();
    final totalSeats = int.tryParse(body['totalSeats']?.toString() ?? '80') ?? 80;

    if (theaterId == null || screenName == null || screenName.isEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'theaterId and screenName are required'});
    }

    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute(
        Sql.named('''
          INSERT INTO screens (theater_id, screen_name, total_seats)
          VALUES (@theaterId, @screenName, @totalSeats)
          RETURNING id
        '''),
        parameters: {'theaterId': theaterId, 'screenName': screenName, 'totalSeats': totalSeats},
      );

      final screenId = res.first[0] as int;

      if (body['autoGenerateSeats'] == true || body['autoGenerateSeats'] == 'true') {
        final rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
        for (var r = 0; r < rows.length; r++) {
          final rowLabel = rows[r];
          final tier = r < 2 ? 'Recliner' : (r < 5 ? 'Platinum' : 'Gold');
          final multiplier = r < 2 ? 1.5 : (r < 5 ? 1.2 : 1.0);
          for (var s = 1; s <= 10; s++) {
            await conn.execute(
              Sql.named('''
                INSERT INTO seats (screen_id, row_label, seat_number, seat_identifier, tier_name, seat_type, multiplier)
                VALUES (@screenId, @row, @num, @ident, @tier, 'normal', @mult)
                ON CONFLICT DO NOTHING
              '''),
              parameters: {
                'screenId': screenId,
                'row': rowLabel,
                'num': s,
                'ident': '$rowLabel$s',
                'tier': tier,
                'mult': multiplier,
              },
            );
          }
        }
      }

      return Response.json(statusCode: 201, body: {'message': 'Screen created successfully', 'id': screenId});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> updateScreen(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid screen ID'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final conn = await openDatabaseConnection();
    try {
      final updates = <String>[];
      final sqlParams = <String, dynamic>{'id': id};

      if (body.containsKey('screenName')) {
        updates.add('screen_name = @screenName');
        sqlParams['screenName'] = body['screenName'].toString().trim();
      }
      if (body.containsKey('totalSeats')) {
        updates.add('total_seats = @totalSeats');
        sqlParams['totalSeats'] = int.tryParse(body['totalSeats'].toString());
      }

      if (updates.isEmpty) return Response.json(statusCode: 400, body: {'error': 'No fields provided'});

      await conn.execute(
        Sql.named('UPDATE screens SET ${updates.join(', ')} WHERE id = @id'),
        parameters: sqlParams,
      );

      return Response.json(body: {'message': 'Screen updated successfully'});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> deleteScreen(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid screen ID'});

    final conn = await openDatabaseConnection();
    try {
      await conn.execute(
        Sql.named('UPDATE screens SET is_deleted = true, deleted_at = CURRENT_TIMESTAMP WHERE id = @id'),
        parameters: {'id': id},
      );
      return Response.json(body: {'message': 'Screen deleted successfully'});
    } finally {
      await conn.close();
    }
  }
}
