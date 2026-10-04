import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

void main() async {
  final connection = await openDatabaseConnection();
  try {
    final result = await connection.execute(
      Sql.named('''
        SELECT s.id, s.movie_id, m.title, t.name, c.name, s.show_time, s.show_time_formatted
        FROM shows s
        JOIN movies m ON s.movie_id = m.id
        JOIN screens sc ON s.screen_id = sc.id
        JOIN theaters t ON sc.theater_id = t.id
        JOIN cities c ON t.city_id = c.id
        LIMIT 10
      '''),
    );
    print('Total shows in DB sample: ${result.length}');
    for (final row in result) {
      print('Show ${row[0]}: Movie="${row[2]}" (id=${row[1]}), Theater="${row[3]}", City="${row[4]}", Time="${row[6]}"');
    }

    final movieCount = await connection.execute(
      Sql.named('SELECT movie_id, COUNT(*) FROM shows GROUP BY movie_id'),
    );
    print('\nShows grouped by movie_id:');
    for (final row in movieCount) {
      print('  Movie ID ${row[0]}: ${row[1]} shows');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await connection.close();
  }
}
