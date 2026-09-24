import 'package:postgres/postgres.dart';

class Database {
  static Future<Connection> connect() async {
    return Connection.open(
      Endpoint(
        host: 'localhost',
        port: 5432,
        database: 'tic_one_backend',
        username: 'postgres',
        password: 'root',
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );
  }
}
