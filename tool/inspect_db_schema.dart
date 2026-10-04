import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

void main() async {
  final conn = await openDatabaseConnection();
  try {
    final tables = await conn.execute(
      "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;",
    );
    print('Tables in DB:');
    for (final row in tables) {
      print(' - ${row[0]}');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await conn.close();
  }
}
