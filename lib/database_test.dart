import 'database.dart';

Future<void> main() async {
  final db = await Database.connect();

  final result = await db.execute(
    'SELECT * FROM products',
  );

  for (final row in result) {
    print(row);
  }

  await db.close();
}
