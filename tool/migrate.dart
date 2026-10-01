import 'dart:io';
import 'package:tic_one_middleware/database.dart';

List<String> splitSqlStatements(String sql) {
  final statements = <String>[];
  final buffer = StringBuffer();
  var inDollarQuote = false;
  var inSingleQuote = false;

  final lines = sql.split('\n');
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('--') && !inDollarQuote && !inSingleQuote) {
      continue;
    }

    // Check for $$ block toggle
    var i = 0;
    while (i < line.length) {
      if (i + 1 < line.length && line.substring(i, i + 2) == '\$\$') {
        inDollarQuote = !inDollarQuote;
        i += 2;
        continue;
      }
      if (line[i] == "'" && !inDollarQuote) {
        inSingleQuote = !inSingleQuote;
      }
      i++;
    }

    buffer.writeln(line);

    if (!inDollarQuote && !inSingleQuote && trimmed.endsWith(';')) {
      final stmt = buffer.toString().trim();
      if (stmt.isNotEmpty) {
        statements.add(stmt);
      }
      buffer.clear();
    }
  }

  final remaining = buffer.toString().trim();
  if (remaining.isNotEmpty) {
    statements.add(remaining);
  }

  return statements;
}

Future<void> main() async {
  print('Starting database migration and seeding...');
  final connection = await openDatabaseConnection();

  try {
    // 1. Run Schema
    final schemaSql = await File('db/02_movie_booking_schema.sql').readAsString();
    print('Applying db/02_movie_booking_schema.sql...');
    final schemaStmts = splitSqlStatements(schemaSql);
    for (final stmt in schemaStmts) {
      if (stmt.trim().isNotEmpty) {
        await connection.execute(stmt);
      }
    }
    print('✓ Schema created successfully (${schemaStmts.length} statements).');

    // 2. Run Seed
    final seedSql = await File('db/03_seed_data.sql').readAsString();
    print('Applying db/03_seed_data.sql...');
    final seedStmts = splitSqlStatements(seedSql);
    for (final stmt in seedStmts) {
      if (stmt.trim().isNotEmpty) {
        await connection.execute(stmt);
      }
    }
    print('✓ Seed data populated successfully (${seedStmts.length} statements).');

    print('All migrations completed successfully!');
  } catch (e, st) {
    print('Migration failed: $e');
    print(st);
    exit(1);
  } finally {
    await connection.close();
  }
}
