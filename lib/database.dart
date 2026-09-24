import 'dart:io';
import 'package:postgres/postgres.dart';

Future<Connection> openDatabaseConnection() async {
  final password = Platform.environment['DB_PASSWORD'];

  if (password == null || password.isEmpty) {
    throw StateError(
      'DB_PASSWORD is not configured',
    );
  }

  return Connection.open(
    Endpoint(
      host: 'localhost',
      port: 5432,
      database: 'tic_one_backend',
      username: 'postgres',
      password: "root",
    ),
    settings: const ConnectionSettings(
      sslMode: SslMode.disable,
    ),
  );
}
