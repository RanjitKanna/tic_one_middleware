import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

void main() async {
  final connection = await openDatabaseConnection();
  try {
    final movies = await connection.execute(
      Sql.named('SELECT id, movie_code, slug, title, status, language FROM movies ORDER BY id ASC'),
    );

    print('=== Checking shows for all movies in Chennai for Today ===');
    for (final m in movies) {
      final movieId = m[0] as int;
      final movieCode = m[1] as String;
      final slug = m[2] as String;
      final title = m[3] as String;
      final status = m[4] as String;

      final countRes = await connection.execute(
        Sql.named('''
          SELECT COUNT(s.id)
          FROM shows s
          JOIN screens sc ON s.screen_id = sc.id
          JOIN theaters t ON sc.theater_id = t.id
          JOIN cities c ON t.city_id = c.id
          WHERE s.movie_id = @movieId
            AND LOWER(c.name) = 'chennai'
            AND DATE(s.show_time) = CURRENT_DATE
        '''),
        parameters: {'movieId': movieId},
      );

      final count = countRes.first[0] as int;
      final marker = count == 0 ? '❌ NO SHOWS' : '✅ $count shows';
      print('Movie $movieId: "$title" (slug="$slug", status="$status") -> $marker');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await connection.close();
  }
}
