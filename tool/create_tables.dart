import 'package:tic_one_middleware/database.dart';

void main() async {
  final connection = await openDatabaseConnection();
  try {
    print('Creating user_royal_pass table...');
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS user_royal_pass (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL UNIQUE REFERENCES login_auth(id) ON DELETE CASCADE,
        membership_status VARCHAR(50) NOT NULL DEFAULT 'FREE_USER',
        plan_name VARCHAR(100) NOT NULL DEFAULT 'TicOne Royal Pass',
        price NUMERIC(10, 2) NOT NULL DEFAULT 600.00,
        start_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        expiry_date TIMESTAMP NOT NULL,
        is_active BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    print('user_royal_pass table created successfully!');

    print('Creating user_cinepoints table...');
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS user_cinepoints (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL UNIQUE,
        points INT DEFAULT 0,
        total_earned INT DEFAULT 0,
        total_redeemed INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    print('Creating cinepoint_transactions table...');
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS cinepoint_transactions (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL,
        points INT NOT NULL,
        type VARCHAR(20) NOT NULL,
        title VARCHAR(150) NOT NULL,
        reference_id VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    print('All tables initialized successfully!');
  } catch (e) {
    print('Error creating tables: $e');
  } finally {
    await connection.close();
  }
}
