// ignore_for_file: avoid_print

import 'dart:io';
import 'package:tic_one_middleware/config/env.dart';
import 'package:tic_one_middleware/database.dart';

/// Tests the database connection and queries basic information.
/// Returns `true` if the connection and checks succeed, `false` otherwise.
Future<bool> testDatabaseConnection() async {
  print('==================================================');
  print('🔍 Starting Database Connection & Health Check...');
  print('==================================================');
  print('Host:     ${Env.dbHost}:${Env.dbPort}');
  print('Database: ${Env.dbName}');
  print('User:     ${Env.dbUser}');
  print('--------------------------------------------------');

  final stopwatch = Stopwatch()..start();

  try {
    print('⏳ Connecting to PostgreSQL database...');
    final connection = await openDatabaseConnection();

    try {
      final ms = stopwatch.elapsedMilliseconds;
      print('✅ Connection established successfully in ${ms}ms.');

      // 1. Basic Ping & Server Info
      final pingResult = await connection.execute(
        'SELECT 1 AS ping, current_database() AS db, '
        'current_user AS usr, version() AS version;',
      );

      if (pingResult.isNotEmpty) {
        final row = pingResult.first;
        final rawVersion = (row[3] as String?) ?? 'Unknown';
        final shortVersion = rawVersion.split('\n').first;

        print('✅ Ping check passed (result: ${row[0]}).');
        print('   - Connected Database: ${row[1]}');
        print('   - Connected User:     ${row[2]}');
        print('   - Postgres Version:   $shortVersion');
      }

      // 2. Query Public Tables
      final tablesResult = await connection.execute(
        '''
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        ORDER BY table_name;
        ''',
      );

      print('--------------------------------------------------');
      print('📊 Tables in database (${tablesResult.length} found):');
      if (tablesResult.isEmpty) {
        print('   (No public tables found)');
      } else {
        for (final row in tablesResult) {
          final tableName = row[0]! as String;
          try {
            final countResult = await connection.execute(
              'SELECT COUNT(*) FROM "$tableName";',
            );
            final count = countResult.first[0];
            print('   • $tableName: $count records');
          } catch (_) {
            print('   • $tableName');
          }
        }
      }

      print('==================================================');
      final totalMs = stopwatch.elapsedMilliseconds;
      print('🎉 Database check completed successfully in ${totalMs}ms!');
      print('==================================================');
      return true;
    } finally {
      await connection.close();
      print('🔒 Database connection closed cleanly.');
    }
  } catch (e, stackTrace) {
    print('❌ Database connection failed!');
    print('Error: $e');
    print('StackTrace:\n$stackTrace');
    print('==================================================');
    return false;
  }
}

Future<void> main() async {
  final success = await testDatabaseConnection();
  if (!success) {
    exitCode = 1;
  }
}
