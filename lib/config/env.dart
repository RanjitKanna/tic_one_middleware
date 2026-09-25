import 'package:dotenv/dotenv.dart';

class Env {
  static final DotEnv _env = DotEnv(
    includePlatformEnvironment: true,
    quiet: true,
  )..load();

  static String get dbHost => _required('DB_HOST');

  static int get dbPort => int.parse(_required('DB_PORT'));

  static String get dbName => _required('DB_NAME');

  static String get dbUser => _required('DB_USER');

  static String get dbPassword => _required('DB_PASSWORD');

  static String get jwtSecret => _required('JWT_SECRET');

  static String get jwtIssuer => _required('JWT_ISSUER');

  static int get jwtAccessMinutes => int.parse(_required('JWT_ACCESS_MINUTES'));

  static int get jwtRefreshDays => int.parse(_required('JWT_REFRESH_DAYS'));

  static int get jwtResetMinutes => int.parse(_required('JWT_RESET_MINUTES'));

  static String _required(String key) {
    final value = _env[key];

    if (value == null || value.trim().isEmpty) {
      throw StateError(
        '$key is not configured in .env',
      );
    }

    return value.trim();
  }
}
