import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/config/env.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

Future<Connection> openDatabaseConnection() async {
  AppLogger.info(
    'DB',
    'Opening PostgreSQL connection',
  );

  AppLogger.info(
    'DB',
    'Host=${Env.dbHost} Port=${Env.dbPort} Database=${Env.dbName} User=${Env.dbUser}',
  );

  try {
    final connection = await Connection.open(
      Endpoint(
        host: Env.dbHost,
        port: Env.dbPort,
        database: Env.dbName,
        username: Env.dbUser,
        password: Env.dbPassword,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );

    AppLogger.info(
      'DB',
      'PostgreSQL connection successful',
    );

    return connection;
  } catch (error, stackTrace) {
    AppLogger.error(
      'DB',
      'PostgreSQL connection failed',
      error: error,
      stackTrace: stackTrace,
    );

    rethrow;
  }
}
