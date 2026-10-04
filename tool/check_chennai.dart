import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

void main() async {
  final connection = await openDatabaseConnection();
  try {
    final theaters = await connection.execute(
      Sql.named('''
        SELECT t.id, t.name, t.distance_info, t.landmark, t.address, c.name, COUNT(sc.id)
        FROM theaters t
        JOIN cities c ON t.city_id = c.id
        LEFT JOIN screens sc ON sc.theater_id = t.id
        WHERE LOWER(c.name) = 'chennai'
        GROUP BY t.id, t.name, t.distance_info, t.landmark, t.address, c.name
        ORDER BY t.id ASC
      '''),
    );
    print('Theaters in Chennai: ${theaters.length}');
    for (final row in theaters) {
      print('  Theater ${row[0]}: "${row[1]}" (${row[2]}) - Screens: ${row[6]}');
    }

    final movies = await connection.execute(
      Sql.named('SELECT id, movie_code, title, language, genre, status FROM movies ORDER BY id ASC'),
    );
    print('\nTotal Movies: ${movies.length}');
    for (final row in movies) {
      print('  Movie ${row[0]}: "${row[2]}" (${row[3]} - ${row[4]}) [${row[5]}]');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await connection.close();
  }
}
