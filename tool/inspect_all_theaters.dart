import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

void main() async {
  final connection = await openDatabaseConnection();
  try {
    final result = await connection.execute(
      Sql.named('''
        SELECT c.name AS city, t.id AS theater_id, t.name AS theater_name, COUNT(sc.id) AS screens
        FROM cities c
        JOIN theaters t ON t.city_id = c.id
        LEFT JOIN screens sc ON sc.theater_id = t.id
        GROUP BY c.name, t.id, t.name
        ORDER BY c.name, t.id
      '''),
    );
    for (final row in result) {
      print('[${row[0]}] Theater ${row[1]}: "${row[2]}" (${row[3]} screens)');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await connection.close();
  }
}
