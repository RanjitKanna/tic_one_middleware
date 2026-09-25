class AppLogger {
  static String _timestamp() {
    return DateTime.now().toIso8601String();
  }

  static void info(
    String scope,
    String message,
  ) {
    print(
      '[${_timestamp()}] [$scope] $message',
    );
  }

  static void warning(
    String scope,
    String message,
  ) {
    print(
      '[${_timestamp()}] [$scope][WARNING] $message',
    );
  }

  static void error(
    String scope,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    print(
      '[${_timestamp()}] [$scope][ERROR] $message',
    );

    if (error != null) {
      print(
        '[${_timestamp()}] [$scope][ERROR] Exception: $error',
      );
    }

    if (stackTrace != null) {
      print(stackTrace);
    }
  }
}
