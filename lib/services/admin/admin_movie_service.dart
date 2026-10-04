import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/admin/admin_auth_service.dart';

class AdminMovieService {
  static Future<Response> listMovies(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Unauthorized: Admin privileges required'},
      );
    }

    final params = context.request.uri.queryParameters;
    final page = int.tryParse(params['page'] ?? '1') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
    final offset = (page - 1) * limit;
    final search = params['search']?.trim() ?? '';
    final status = params['status']?.trim() ?? '';
    final genre = params['genre']?.trim() ?? '';
    final language = params['language']?.trim() ?? '';

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>["(is_deleted = false OR is_deleted IS NULL)"];
      final countParams = <String, dynamic>{};

      if (search.isNotEmpty) {
        whereClauses.add("(LOWER(title) LIKE @search OR LOWER(genre) LIKE @search OR LOWER(language) LIKE @search)");
        countParams['search'] = '%${search.toLowerCase()}%';
      }

      if (status.isNotEmpty && status != 'all') {
        whereClauses.add("LOWER(status) = @status");
        countParams['status'] = status.toLowerCase();
      }

      if (genre.isNotEmpty && genre != 'all') {
        whereClauses.add("LOWER(genre) LIKE @genre");
        countParams['genre'] = '%${genre.toLowerCase()}%';
      }

      if (language.isNotEmpty && language != 'all') {
        whereClauses.add("LOWER(language) = @language");
        countParams['language'] = language.toLowerCase();
      }

      final whereSql = whereClauses.join(' AND ');

      // Total count
      final countRes = await conn.execute(
        Sql.named('SELECT COUNT(*) FROM movies WHERE $whereSql'),
        parameters: countParams,
      );
      final total = int.parse(countRes.first[0].toString());

      // Fetch movies
      final queryParams = Map<String, dynamic>.from(countParams)
        ..addAll({'limit': limit, 'offset': offset});

      final res = await conn.execute(
        Sql.named('''
          SELECT id, movie_code, slug, title, subtitle, synopsis, genre, language,
                 duration_mins, certificate, rating, rating_count, image_url,
                 banner_url, trailer_url, status, release_date, format,
                 badge_text, match_percent, is_trending, is_filling_fast,
                 is_advance_booking_open, cast_members, director, created_at
          FROM movies
          WHERE $whereSql
          ORDER BY id DESC
          LIMIT @limit OFFSET @offset
        '''),
        parameters: queryParams,
      );

      final movies = res.map((r) => _mapMovie(r)).toList();

      return Response.json(
        body: {
          'movies': movies,
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

  static Future<Response> getMovie(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid movie ID'});

    final conn = await openDatabaseConnection();
    try {
      final res = await conn.execute(
        Sql.named('''
          SELECT id, movie_code, slug, title, subtitle, synopsis, genre, language,
                 duration_mins, certificate, rating, rating_count, image_url,
                 banner_url, trailer_url, status, release_date, format,
                 badge_text, match_percent, is_trending, is_filling_fast,
                 is_advance_booking_open, cast_members, director, created_at
          FROM movies
          WHERE id = @id
          LIMIT 1
        '''),
        parameters: {'id': id},
      );

      if (res.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Movie not found'});

      final movie = _mapMovie(res.first);

      final showsRes = await conn.execute(
        Sql.named('''
          SELECT s.id, s.show_time, s.show_time_formatted, s.language, s.format, s.base_price, s.status,
                 t.name as theater_name, sc.screen_name
          FROM shows s
          JOIN screens sc ON s.screen_id = sc.id
          JOIN theaters t ON sc.theater_id = t.id
          WHERE s.movie_id = @id AND (s.is_deleted = false OR s.is_deleted IS NULL)
          ORDER BY s.show_time ASC
          LIMIT 20
        '''),
        parameters: {'id': id},
      );

      final shows = showsRes.map((s) => {
        'id': s[0],
        'showTime': (s[1] as DateTime).toIso8601String(),
        'showTimeFormatted': s[2],
        'language': s[3],
        'format': s[4],
        'basePrice': double.parse(s[5].toString()),
        'status': s[6],
        'theaterName': s[7],
        'screenName': s[8],
      }).toList();

      return Response.json(body: {'movie': movie, 'shows': shows});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> createMovie(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON body'});

    final title = body['title']?.toString().trim();
    if (title == null || title.isEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'Title is required'});
    }

    final rawSlug = body['slug']?.toString().trim().isNotEmpty == true
        ? body['slug'].toString().trim()
        : title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    final movieCode = body['movieCode']?.toString().trim().isNotEmpty == true
        ? body['movieCode'].toString().trim()
        : 'MOV_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    final genre = body['genre']?.toString().trim() ?? 'Action / Drama';
    final language = body['language']?.toString().trim() ?? 'English';
    final durationMins = int.tryParse(body['durationMins']?.toString() ?? '120') ?? 120;
    final certificate = body['certificate']?.toString().trim() ?? 'UA';
    final rating = double.tryParse(body['rating']?.toString() ?? '8.5') ?? 8.5;
    final ratingCount = body['ratingCount']?.toString().trim() ?? '10K';
    final imageUrl = body['imageUrl']?.toString().trim() ?? 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800';
    final bannerUrl = body['bannerUrl']?.toString().trim();
    final trailerUrl = body['trailerUrl']?.toString().trim();
    final status = body['status']?.toString().trim() ?? 'now_showing';
    final releaseDate = body['releaseDate']?.toString().trim() ?? DateTime.now().toIso8601String().substring(0, 10);
    final format = body['format']?.toString().trim() ?? '2D / 3D / IMAX';
    final synopsis = body['synopsis']?.toString().trim() ?? '';
    final subtitle = body['subtitle']?.toString().trim();
    final badgeText = body['badgeText']?.toString().trim();
    final matchPercent = body['matchPercent']?.toString().trim() ?? '95%';
    final isTrending = body['isTrending'] == true;
    final isFillingFast = body['isFillingFast'] == true;
    final isAdvanceBookingOpen = body['isAdvanceBookingOpen'] == true;
    final castMembers = body['cast']?.toString().trim() ?? body['castMembers']?.toString().trim();
    final director = body['director']?.toString().trim();

    final conn = await openDatabaseConnection();
    try {
      final insertRes = await conn.execute(
        Sql.named('''
          INSERT INTO movies (
            movie_code, slug, title, subtitle, synopsis, genre, language,
            duration_mins, certificate, rating, rating_count, image_url,
            banner_url, trailer_url, status, release_date, format,
            badge_text, match_percent, is_trending, is_filling_fast,
            is_advance_booking_open, cast_members, director
          ) VALUES (
            @movieCode, @slug, @title, @subtitle, @synopsis, @genre, @language,
            @durationMins, @certificate, @rating, @ratingCount, @imageUrl,
            @bannerUrl, @trailerUrl, @status, @releaseDate::date, @format,
            @badgeText, @matchPercent, @isTrending, @isFillingFast,
            @isAdvanceBookingOpen, @castMembers, @director
          )
          RETURNING id
        '''),
        parameters: {
          'movieCode': movieCode,
          'slug': rawSlug,
          'title': title,
          'subtitle': subtitle,
          'synopsis': synopsis,
          'genre': genre,
          'language': language,
          'durationMins': durationMins,
          'certificate': certificate,
          'rating': rating,
          'ratingCount': ratingCount,
          'imageUrl': imageUrl,
          'bannerUrl': bannerUrl,
          'trailerUrl': trailerUrl,
          'status': status,
          'releaseDate': releaseDate,
          'format': format,
          'badgeText': badgeText,
          'matchPercent': matchPercent,
          'isTrending': isTrending,
          'isFillingFast': isFillingFast,
          'isAdvanceBookingOpen': isAdvanceBookingOpen,
          'castMembers': castMembers,
          'director': director,
        },
      );

      final newId = insertRes.first[0] as int;

      await AdminAuthService.logAction(
        adminId: admin['id'] as int,
        adminEmail: admin['email'] as String,
        action: 'CREATE_MOVIE',
        entityType: 'movie',
        entityId: newId.toString(),
        details: {'title': title, 'slug': rawSlug},
        connection: conn,
      );

      return Response.json(
        statusCode: 201,
        body: {'message': 'Movie created successfully', 'id': newId},
      );
    } finally {
      await conn.close();
    }
  }

  static Future<Response> updateMovie(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid movie ID'});

    final body = await context.request.json();
    if (body is! Map) return Response.json(statusCode: 400, body: {'error': 'Invalid JSON body'});

    final conn = await openDatabaseConnection();
    try {
      final updates = <String>[];
      final sqlParams = <String, dynamic>{'id': id};

      void addField(String key, String dbCol, dynamic val) {
        if (body.containsKey(key)) {
          updates.add('$dbCol = @$dbCol');
          sqlParams[dbCol] = val;
        }
      }

      addField('title', 'title', body['title']?.toString());
      addField('subtitle', 'subtitle', body['subtitle']?.toString());
      addField('slug', 'slug', body['slug']?.toString());
      addField('synopsis', 'synopsis', body['synopsis']?.toString());
      addField('genre', 'genre', body['genre']?.toString());
      addField('language', 'language', body['language']?.toString());
      if (body.containsKey('durationMins')) {
        addField('durationMins', 'duration_mins', int.tryParse(body['durationMins'].toString()) ?? 120);
      }
      addField('certificate', 'certificate', body['certificate']?.toString());
      if (body.containsKey('rating')) {
        addField('rating', 'rating', double.tryParse(body['rating'].toString()) ?? 8.0);
      }
      addField('ratingCount', 'rating_count', body['ratingCount']?.toString());
      addField('imageUrl', 'image_url', body['imageUrl']?.toString());
      addField('bannerUrl', 'banner_url', body['bannerUrl']?.toString());
      addField('trailerUrl', 'trailer_url', body['trailerUrl']?.toString());
      addField('status', 'status', body['status']?.toString());
      if (body.containsKey('releaseDate')) {
        updates.add('release_date = @release_date::date');
        sqlParams['release_date'] = body['releaseDate']?.toString();
      }
      addField('format', 'format', body['format']?.toString());
      addField('badgeText', 'badge_text', body['badgeText']?.toString());
      addField('matchPercent', 'match_percent', body['matchPercent']?.toString());
      if (body.containsKey('isTrending')) addField('isTrending', 'is_trending', body['isTrending'] == true);
      if (body.containsKey('isFillingFast')) addField('isFillingFast', 'is_filling_fast', body['isFillingFast'] == true);
      if (body.containsKey('isAdvanceBookingOpen')) addField('isAdvanceBookingOpen', 'is_advance_booking_open', body['isAdvanceBookingOpen'] == true);
      if (body.containsKey('cast') || body.containsKey('castMembers')) {
        addField('cast', 'cast_members', (body['cast'] ?? body['castMembers'])?.toString());
      }
      addField('director', 'director', body['director']?.toString());

      if (updates.isEmpty) {
        return Response.json(statusCode: 400, body: {'error': 'No fields provided for update'});
      }

      await conn.execute(
        Sql.named('UPDATE movies SET ${updates.join(', ')} WHERE id = @id'),
        parameters: sqlParams,
      );

      await AdminAuthService.logAction(
        adminId: admin['id'] as int,
        adminEmail: admin['email'] as String,
        action: 'UPDATE_MOVIE',
        entityType: 'movie',
        entityId: id.toString(),
        details: body.cast<String, dynamic>(),
        connection: conn,
      );

      return Response.json(body: {'message': 'Movie updated successfully'});
    } finally {
      await conn.close();
    }
  }

  static Future<Response> deleteMovie(RequestContext context, String idStr) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final id = int.tryParse(idStr);
    if (id == null) return Response.json(statusCode: 400, body: {'error': 'Invalid movie ID'});

    final conn = await openDatabaseConnection();
    try {
      await conn.execute(
        Sql.named('''
          UPDATE movies 
          SET is_deleted = true, deleted_at = CURRENT_TIMESTAMP, status = 'ended'
          WHERE id = @id
        '''),
        parameters: {'id': id},
      );

      await AdminAuthService.logAction(
        adminId: admin['id'] as int,
        adminEmail: admin['email'] as String,
        action: 'DELETE_MOVIE',
        entityType: 'movie',
        entityId: id.toString(),
        connection: conn,
      );

      return Response.json(body: {'message': 'Movie deleted successfully'});
    } finally {
      await conn.close();
    }
  }

  static Map<String, dynamic> _mapMovie(List<dynamic> r) {
    return {
      'id': r[0],
      'movieCode': r[1],
      'slug': r[2],
      'title': r[3],
      'subtitle': r[4],
      'synopsis': r[5],
      'genre': r[6],
      'language': r[7],
      'durationMins': r[8],
      'certificate': r[9],
      'rating': double.tryParse(r[10]?.toString() ?? '0') ?? 0.0,
      'ratingCount': r[11],
      'imageUrl': r[12],
      'bannerUrl': r[13],
      'trailerUrl': r[14],
      'status': r[15],
      'releaseDate': (r[16] is DateTime) ? (r[16] as DateTime).toIso8601String().substring(0, 10) : r[16]?.toString(),
      'format': r[17],
      'badgeText': r[18],
      'matchPercent': r[19],
      'isTrending': r[20] ?? false,
      'isFillingFast': r[21] ?? false,
      'isAdvanceBookingOpen': r[22] ?? false,
      'cast': r[23],
      'director': r[24],
      'createdAt': (r[25] as DateTime?)?.toIso8601String(),
    };
  }
}
