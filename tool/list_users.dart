import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

void main() async {
  final conn = await openDatabaseConnection();
  try {
    final res = await conn.execute("SELECT id, name, email, phone, role FROM login_auth;");
    for (final r in res) {
      print('User #${r[0]}: ${r[1]} <${r[2]}> phone: ${r[3]} role: ${r[4]}');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await conn.close();
  }
}
