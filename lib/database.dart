import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/config/env.dart';

Future<Connection> openDatabaseConnection() async {
  return Connection.open(
    Endpoint(
      host: Env.dbHost,
      port: Env.dbPort,
      database: Env.dbName,
      username: Env.dbUser,
      password: Env.dbPassword,
    ),
    settings: const ConnectionSettings(
      sslMode: SslMode.require,
    ),
  );
}
