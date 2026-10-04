import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

void main() async {
  final conn = await openDatabaseConnection();
  try {
    for (final table in [
      'login_auth',
      'movies',
      'theaters',
      'screens',
      'shows',
      'seats',
      'bus_operators',
      'buses',
      'bus_routes',
      'bus_trips',
      'bus_seats',
      'boarding_points',
      'dropping_points',
      'bookings',
      'bus_bookings',
      'bus_payments',
      'bus_refunds'
    ]) {
      final cols = await conn.execute(
        "SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = '$table' ORDER BY ordinal_position;",
      );
      print('=== Table: $table ===');
      for (final row in cols) {
        print('  ${row[0]} (${row[1]}, nullable: ${row[2]})');
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await conn.close();
  }
}
