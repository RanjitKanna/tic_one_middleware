import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

void main() async {
  final connection = await openDatabaseConnection();
  try {
    final result = await connection.execute(
      Sql.named('SELECT id, movie_code, slug, title FROM movies ORDER BY id'),
    );
    for (final row in result) {
      print('Movie ${row[0]}: id=${row[0]}, slug="${row[2]}", title="${row[3]}"');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await connection.close();
  }
}
