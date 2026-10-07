import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/config/env.dart';

/// SSL is disabled for local hosts and required otherwise. Set `DB_SSL=true`
/// or `DB_SSL=false` to override.
bool _useSsl() {
  final override = Platform.environment['DB_SSL']?.toLowerCase();
  if (override == 'true') return true;
  if (override == 'false') return false;
  const localHosts = {'localhost', '127.0.0.1', '::1'};
  return !localHosts.contains(Env.dbHost);
}

Future<Connection> openDatabaseConnection() async {
  return Connection.open(
    Endpoint(
      host: Env.dbHost,
      port: Env.dbPort,
      database: Env.dbName,
      username: Env.dbUser,
      password: Env.dbPassword,
    ),
    settings: ConnectionSettings(
      sslMode: _useSsl() ? SslMode.require : SslMode.disable,
    ),
  );
}
