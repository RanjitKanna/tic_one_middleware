import 'package:dart_frog/dart_frog.dart';
import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/admin/admin_auth_service.dart';

class AdminShowService {
  static Future<Response> listShows(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final params = context.request.uri.queryParameters;
    final page = int.tryParse(params['page'] ?? '1') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
    final offset = (page - 1) * limit;
    final movieId = int.tryParse(params['movieId'] ?? '');
    final theaterId = int.tryParse(params['theaterId'] ?? '');
    final screenId = int.tryParse(params['screenId'] ?? '');
    final date = params['date']?.trim();
    final status = params['status']?.trim() ?? '';
    final search = params['search']?.trim() ?? '';

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>["(s.is_deleted = false OR s.is_deleted IS NULL)"];
      final countParams = <String, dynamic>{};

      if (movieId != null) {
        whereClauses.add("s.movie_id = @movieId");
        countParams['movieId'] = movieId;
      }
      if (screenId != null) {
        whereClauses.add("s.screen_id = @screenId");
        countParams['screenId'] = screenId;
      }
      if (theaterId != null) {
        whereClauses.add("sc.theater_id = @theaterId");
        countParams['theaterId'] = theaterId;
      }
      if (date != null && date.isNotEmpty && date != 'all') {
        whereClauses.add("s.show_time::date = @date::date");
        countParams['date'] = date;
      }
      if (status.isNotEmpty && status != 'all') {
        whereClauses.add("LOWER(s.status) = @status");
        countParams['status'] = status.toLowerCase();
      }
      if (search.isNotEmpty) {
        whereClauses.add("(LOWER(m.title) LIKE @search OR LOWER(t.name) LIKE @search)");
        countParams['search'] = '%${search.toLowerCase()}%';
      }

      final whereSql = whereClauses.join(' AND ');

      final countRes = await conn.execute(
        Sql.named('''
          SELECT COUNT(*)
          FROM shows s
          JOIN movies m ON s.movie_id = m.id
          JOIN screens sc ON s.screen_id = sc.id
          JOIN theaters t ON sc.theater_id = t.id
          WHERE $whereSql
        '''),
        parameters: countParams,
      );
      final total = int.parse(countRes.first[0].toString());

      final queryParams = Map<String, dynamic>.from(countParams)
        ..addAll({'limit': limit, 'offset': offset});

      final res = await conn.execute(
        Sql.named('''
          SELECT s.id, s.movie_id, m.title as movie_title, m.image_url as movie_image, m.duration_mins,
                 s.screen_id, sc.screen_name, t.id as theater_id, t.name as theater_name,
                 s.show_time, s.show_time_formatted, s.language, s.format, s.base_price,
                 s.status, s.is_fast_filling, s.created_at,
                 (SELECT COUNT(*) FROM bookings WHERE show_id = s.id AND booking_status != 'cancelled') as booking_count,
                 sc.total_seats
          FROM shows s
          JOIN movies m ON s.movie_id = m.id
          JOIN screens sc ON s.screen_id = sc.id
          JOIN theaters t ON sc.theater_id = t.id
          WHERE $whereSql
          ORDER BY s.show_time DESC
          LIMIT @limit OFFSET @offset
        '''),
        parameters: queryParams,
      );

      final shows = res.map((r) => {
        'id': r[0],
        'movieId': r[1],
        'movieTitle': r[2],
        'movieImage': r[3],
        'durationMins': r[4] ?? 120,
        'screenId': r[5],
        'screenName': r[6],
        'theaterId': r[7],
        'theaterName': r[8],
        'showTime': (r[9] as DateTime).toIso8601String(),
        'showTimeFormatted': r[10],
        'language': r[11],
        'format': r[12],
        'basePrice': double.parse(r[13].toString()),
        'status': r[14],
        'isFastFilling': r[15] ?? false,
        'createdAt': (r[16] as DateTime?)?.toIso8601String(),
        'bookingCount': int.parse(r[17].toString()),
        'totalSeats': r[18] ?? 100,
      }).toList();

      return Response.json(
        body: {
          'shows': shows,
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

  static Future<Response> getShow(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid show ID'});

    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute(
        Sql.named('''
          SELECT s.id, s.movie_id, m.title as movie_title, m.image_url as movie_image, m.duration_mins,
                 s.screen_id, sc.screen_name, t.id as theater_id, t.name as theater_name,
                 s.show_time, s.show_time_formatted, s.language, s.format, s.base_price,
                 s.status, s.is_fast_filling, s.created_at, sc.total_seats
          FROM shows s
          JOIN movies m ON s.movie_id = m.id
          JOIN screens sc ON s.screen_id = sc.id
          JOIN theaters t ON sc.theater_id = t.id
          WHERE s.id = @id
          LIMIT 1
        '''),
        parameters: {'id': id},
      );

      if (res.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Show not found'});
      final r = res.first;

      return Response.json(
        body: {
          'show': {
            'id': r[0],
            'movieId': r[1],
            'movieTitle': r[2],
            'movieImage': r[3],
            'durationMins': r[4] ?? 120,
            'screenId': r[5],
            'screenName': r[6],
            'theaterId': r[7],
            'theaterName': r[8],
            'showTime': (r[9] as DateTime).toIso8601String(),
            'showTimeFormatted': r[10],
            'language': r[11],
            'format': r[12],
            'basePrice': double.parse(r[13].toString()),
            'status': r[14],
            'isFastFilling': r[15] ?? false,
            'createdAt': (r[16] as DateTime?)?.toIso8601String(),
            'totalSeats': r[17],
          },
        },
      );
    } finally {
      await conn.close();
    }
  }

  static Future<Response> createShow(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});

    final movieId = int.tryParse(body['movieId']?.toString() ?? '');
    final screenId = int.tryParse(body['screenId']?.toString() ?? '');
    final rawShowTime = body['showTime']?.toString();
    final basePrice = double.tryParse(body['basePrice']?.toString() ?? '250') ?? 250.0;
    final language = body['language']?.toString().trim() ?? 'English';
    final format = body['format']?.toString().trim() ?? '2D';
    final status = body['status']?.toString().trim() ?? 'active';

    if (movieId == null || screenId == null || rawShowTime == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'movieId, screenId, and showTime are required'},
      );
    }

    final showDateTime = DateTime.tryParse(rawShowTime);
    if (showDateTime == null) {
      return Response.json(statusCode: 400, body: {'error': 'Invalid showTime format (ISO-8601 required)'});
    }

    final conn = await openDatabaseConnection();
    try {
      final movieRes = await conn.execute(
        Sql.named('SELECT title, duration_mins FROM movies WHERE id = @movieId'),
        parameters: {'movieId': movieId},
      );
      if (movieRes.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Movie not found'});
      final durationMins = (movieRes.first[1] as int?) ?? 120;
      final showEndTime = showDateTime.add(Duration(minutes: durationMins + 30));

      final conflictRes = await conn.execute(
        Sql.named('''
          SELECT s.id, s.show_time, m.title, m.duration_mins
          FROM shows s
          JOIN movies m ON s.movie_id = m.id
          WHERE s.screen_id = @screenId
            AND (s.is_deleted = false OR s.is_deleted IS NULL)
            AND s.status != 'cancelled'
            AND (
              (s.show_time <= @newStart AND s.show_time + (COALESCE(m.duration_mins, 120) + 30) * INTERVAL '1 minute' > @newStart)
              OR
              (@newStart <= s.show_time AND @newEnd > s.show_time)
            )
          LIMIT 1
        '''),
        parameters: {
          'screenId': screenId,
          'newStart': showDateTime,
          'newEnd': showEndTime,
        },
      );

      if (conflictRes.isNotEmpty) {
        final conflict = conflictRes.first;
        final confTime = DateFormat('hh:mm a, dd MMM').format((conflict[1] as DateTime).toLocal());
        return Response.json(
          statusCode: 409,
          body: {
            'error': 'Schedule Conflict: Screen already has show "${conflict[2]}" at $confTime. Please choose a different time or screen.',
            'conflict': {
              'showId': conflict[0],
              'movieTitle': conflict[2],
              'showTime': confTime,
            }
          },
        );
      }

      final showTimeFormatted = DateFormat('hh:mm a').format(showDateTime.toLocal());

      final insertRes = await conn.execute(
        Sql.named('''
          INSERT INTO shows (movie_id, screen_id, show_time, show_time_formatted, language, format, base_price, status)
          VALUES (@movieId, @screenId, @showTime, @showTimeFormatted, @language, @format, @basePrice, @status)
          RETURNING id
        '''),
        parameters: {
          'movieId': movieId,
          'screenId': screenId,
          'showTime': showDateTime,
          'showTimeFormatted': showTimeFormatted,
          'language': language,
          'format': format,
          'basePrice': basePrice,
          'status': status,
        },
      );

      final newId = insertRes.first[0] as int;

      await AdminAuthService.logAction(
        adminId: admin['id'] as int,
        adminEmail: admin['email'] as String,
        action: 'CREATE_SHOW',
        entityType: 'show',
        entityId: newId.toString(),
        details: {'movieId': movieId, 'screenId': screenId, 'showTime': rawShowTime},
        connection: conn,
      );

      return Response.json(statusCode: 201, body: {'message': 'Show created successfully', 'id': newId});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> updateShow(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid show ID'});

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
      if (body.containsKey('basePrice')) {
        updates.add('base_price = @basePrice');
        sqlParams['basePrice'] = double.tryParse(body['basePrice'].toString()) ?? 250.0;
      }
      if (body.containsKey('language')) {
        updates.add('language = @language');
        sqlParams['language'] = body['language'].toString().trim();
      }
      if (body.containsKey('format')) {
        updates.add('format = @format');
        sqlParams['format'] = body['format'].toString().trim();
      }
      if (body.containsKey('showTime')) {
        final showDateTime = DateTime.tryParse(body['showTime'].toString());
        if (showDateTime != null) {
          updates.add('show_time = @showTime');
          updates.add('show_time_formatted = @showTimeFormatted');
          sqlParams['showTime'] = showDateTime;
          sqlParams['showTimeFormatted'] = DateFormat('hh:mm a').format(showDateTime.toLocal());
        }
      }

      if (updates.isEmpty) return Response.json(statusCode: 400, body: {'error': 'No update fields provided'});

      await conn.execute(
        Sql.named('UPDATE shows SET ${updates.join(', ')} WHERE id = @id'),
        parameters: sqlParams,
      );

      return Response.json(body: {'message': 'Show updated successfully'});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> deleteShow(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid show ID'});

    final conn = await openDatabaseConnection();
    try {
      await conn.execute(
        Sql.named("UPDATE shows SET is_deleted = true, deleted_at = CURRENT_TIMESTAMP, status = 'cancelled' WHERE id = @id"),
        parameters: {'id': id},
      );
      return Response.json(body: {'message': 'Show deleted / cancelled successfully'});
    } finally {
      await conn.close();
    }
  }
}
