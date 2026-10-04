import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

void main() async {
  final conn = await openDatabaseConnection();
  try {
    final cols = await conn.execute(
      "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'movies' ORDER BY ordinal_position;",
    );
    for (final row in cols) {
      print('movies: ${row[0]} (${row[1]})');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await conn.close();
  }
}
