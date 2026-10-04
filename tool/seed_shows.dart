import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

void main() async {
  final connection = await openDatabaseConnection();
  try {
    print('Starting showtime seeding for all movies and cities...');

    // 1. Clear existing shows & seat_locks
    await connection.execute(Sql.named('DELETE FROM seat_locks'));
    await connection.execute(Sql.named('DELETE FROM booking_seats'));
    await connection.execute(Sql.named('DELETE FROM bookings'));
    await connection.execute(Sql.named('DELETE FROM shows'));

    // 2. Fetch all now_showing movies
    final moviesRes = await connection.execute(
      Sql.named('SELECT id, movie_code, title, language, genre, format FROM movies WHERE status = \'now_showing\' ORDER BY id ASC'),
    );

    // 3. Fetch all screens with theater & city info
    final screensRes = await connection.execute(
      Sql.named('''
        SELECT sc.id AS screen_id, sc.screen_name, t.id AS theater_id, t.name AS theater_name, c.name AS city_name, t.formats
        FROM screens sc
        JOIN theaters t ON sc.theater_id = t.id
        JOIN cities c ON t.city_id = c.id
        ORDER BY c.name, t.id, sc.id
      '''),
    );

    final screensByCity = <String, List<Map<String, dynamic>>>{};
    for (final r in screensRes) {
      final city = (r[4] as String).toLowerCase();
      screensByCity.putIfAbsent(city, () => []).add({
        'screenId': r[0] as int,
        'screenName': r[1] as String,
        'theaterId': r[2] as int,
        'theaterName': r[3] as String,
        'city': r[4] as String,
        'formats': r[5] as String?,
      });
    }

    final slotTemplates = [
      ['10:00 AM', '01:30 PM', '05:00 PM', '08:30 PM'],
      ['10:45 AM', '02:15 PM', '06:00 PM', '09:45 PM'],
      ['11:30 AM', '03:00 PM', '06:45 PM', '10:30 PM'],
      ['09:30 AM', '01:00 PM', '04:30 PM', '08:00 PM', '11:15 PM'],
      ['11:15 AM', '02:45 PM', '06:15 PM', '09:30 PM'],
      ['10:15 AM', '01:45 PM', '05:30 PM', '09:15 PM'],
    ];

    int insertedCount = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final mRow in moviesRes) {
      final movieId = mRow[0] as int;
      final movieCode = mRow[1] as String;
      final title = mRow[2] as String;
      final language = (mRow[3] as String?) ?? 'English';
      final genre = (mRow[4] as String?) ?? 'Action';
      final formatStr = (mRow[5] as String?) ?? 'IMAX / Dolby Atmos';

      for (final cityEntry in screensByCity.entries) {
        final cityName = cityEntry.key;
        final allScreens = cityEntry.value;

        // Select 2-4 screens in this city for this movie based on affinity
        final selectedScreens = <Map<String, dynamic>>[];
        for (int i = 0; i < allScreens.length; i++) {
          final sc = allScreens[i];
          final tName = sc['theaterName'].toString().toLowerCase();

          bool matchesAffinity = false;
          if (cityName == 'chennai') {
            if (language.toLowerCase() == 'tamil' && (tName.contains('sathyam') || tName.contains('ags') || tName.contains('palazzo') || tName.contains('luxe'))) {
              matchesAffinity = true;
            } else if (language.toLowerCase() == 'english' && (tName.contains('luxe') || tName.contains('epiq') || tName.contains('escape'))) {
              matchesAffinity = true;
            } else if (language.toLowerCase() == 'malayalam' && (tName.contains('escape') || tName.contains('palazzo') || tName.contains('sathyam'))) {
              matchesAffinity = true;
            } else if (language.toLowerCase() == 'telugu' && (tName.contains('palazzo') || tName.contains('epiq') || tName.contains('sathyam'))) {
              matchesAffinity = true;
            } else if (language.toLowerCase() == 'hindi' && (tName.contains('luxe') || tName.contains('escape') || tName.contains('palazzo'))) {
              matchesAffinity = true;
            }
          }

          // Fallback distribution
          if (matchesAffinity || (i + movieId) % 3 == 0) {
            selectedScreens.add(sc);
          }
        }

        // Ensure at least 2 distinct theaters per city
        if (selectedScreens.length < 2) {
          selectedScreens.addAll(allScreens.take(2));
        }

        // Deduplicate screens
        final uniqueScreens = <int, Map<String, dynamic>>{};
        for (final s in selectedScreens) {
          uniqueScreens[s['screenId'] as int] = s;
        }

        // Generate shows for next 10 days
        for (int dayOffset = 0; dayOffset < 10; dayOffset++) {
          final showDate = today.add(Duration(days: dayOffset));
          int screenIndex = 0;

          for (final sc in uniqueScreens.values) {
            final screenId = sc['screenId'] as int;
            final slots = slotTemplates[(screenIndex + movieId + dayOffset) % slotTemplates.length];
            screenIndex++;

            for (int sIdx = 0; sIdx < slots.length; sIdx++) {
              final slotTimeStr = slots[sIdx];
              final parts = slotTimeStr.split(' ');
              final timeParts = parts[0].split(':');
              int hour = int.parse(timeParts[0]);
              final min = int.parse(timeParts[1]);
              final isPm = parts[1].toUpperCase() == 'PM';
              if (isPm && hour != 12) hour += 12;
              if (!isPm && hour == 12) hour = 0;

              final showDateTime = DateTime(showDate.year, showDate.month, showDate.day, hour, min);
              final isFastFilling = (movieId + screenId + sIdx + dayOffset) % 3 == 0;
              final format = formatStr.contains('IMAX') && sc['screenName'].toString().contains('IMAX')
                  ? 'IMAX 3D Laser'
                  : formatStr.contains('4DX') || sc['screenName'].toString().contains('4DX')
                      ? '4DX 3D'
                      : 'Dolby Atmos 7.1';
              final basePrice = format.contains('IMAX') ? 350.0 : (format.contains('4DX') ? 420.0 : 250.0);

              await connection.execute(
                Sql.named('''
                  INSERT INTO shows (
                    movie_id, screen_id, show_time, show_time_formatted, language, format, base_price, status, is_fast_filling
                  ) VALUES (
                    @movieId, @screenId, @showTime, @showTimeFormatted, @language, @format, @basePrice, 'active', @isFastFilling
                  )
                '''),
                parameters: {
                  'movieId': movieId,
                  'screenId': screenId,
                  'showTime': showDateTime,
                  'showTimeFormatted': slotTimeStr,
                  'language': language,
                  'format': format,
                  'basePrice': basePrice,
                  'isFastFilling': isFastFilling,
                },
              );
              insertedCount++;
            }
          }
        }
      }
    }

    print('Successfully generated and seeded $insertedCount distinct showtimes across all movies, cities, and dates!');
  } catch (e, st) {
    print('Error seeding shows: $e\n$st');
  } finally {
    await connection.close();
  }
}
