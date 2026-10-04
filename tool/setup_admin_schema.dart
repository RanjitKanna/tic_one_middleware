import 'package:bcrypt/bcrypt.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

void main() async {
  final conn = await openDatabaseConnection();
  try {
    print('Applying schema updates for Admin...');

    // 1. Alter login_auth
    await conn.execute("ALTER TABLE login_auth ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'user';");
    await conn.execute("ALTER TABLE login_auth ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;");
    await conn.execute("ALTER TABLE login_auth ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false;");
    await conn.execute("ALTER TABLE login_auth ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;");

    // 2. Alter movies
    await conn.execute("ALTER TABLE movies ADD COLUMN IF NOT EXISTS cast_members TEXT;");
    await conn.execute("ALTER TABLE movies ADD COLUMN IF NOT EXISTS director VARCHAR(200);");
    await conn.execute("ALTER TABLE movies ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false;");
    await conn.execute("ALTER TABLE movies ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;");

    // 3. Alter theaters & screens
    await conn.execute("ALTER TABLE theaters ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false;");
    await conn.execute("ALTER TABLE theaters ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;");
    await conn.execute("ALTER TABLE screens ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false;");
    await conn.execute("ALTER TABLE screens ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;");

    // 4. Alter shows & seats
    await conn.execute("ALTER TABLE shows ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false;");
    await conn.execute("ALTER TABLE shows ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;");
    await conn.execute("ALTER TABLE seats ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;");
    await conn.execute("ALTER TABLE seats ADD COLUMN IF NOT EXISTS base_price NUMERIC(10, 2);");

    // 5. Alter bus tables
    await conn.execute("ALTER TABLE bus_operators ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false;");
    await conn.execute("ALTER TABLE bus_operators ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;");
    await conn.execute("ALTER TABLE buses ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false;");
    await conn.execute("ALTER TABLE buses ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;");
    await conn.execute("ALTER TABLE bus_routes ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false;");
    await conn.execute("ALTER TABLE bus_routes ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;");
    await conn.execute("ALTER TABLE bus_trips ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false;");
    await conn.execute("ALTER TABLE bus_trips ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;");
    await conn.execute("ALTER TABLE bus_seats ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;");
    await conn.execute("ALTER TABLE bus_seats ADD COLUMN IF NOT EXISTS seat_price NUMERIC(10, 2);");

    // 6. Create audit_logs table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS audit_logs (
        id SERIAL PRIMARY KEY,
        admin_id INTEGER REFERENCES login_auth(id) ON DELETE SET NULL,
        admin_email VARCHAR(150),
        action VARCHAR(100) NOT NULL,
        entity_type VARCHAR(50) NOT NULL,
        entity_id VARCHAR(100),
        details JSONB,
        ip_address VARCHAR(50),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    await conn.execute("CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at DESC);");
    await conn.execute("CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON audit_logs(entity_type, entity_id);");

    // 7. Create movie_payments table if needed
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS movie_payments (
        id SERIAL PRIMARY KEY,
        payment_id VARCHAR(80) UNIQUE NOT NULL,
        booking_id INTEGER REFERENCES bookings(id) ON DELETE SET NULL,
        user_id INTEGER REFERENCES login_auth(id) ON DELETE CASCADE NOT NULL,
        amount NUMERIC(10, 2) NOT NULL,
        currency VARCHAR(10) DEFAULT 'INR',
        payment_method VARCHAR(50) NOT NULL DEFAULT 'upi',
        transaction_reference VARCHAR(120),
        status VARCHAR(30) DEFAULT 'completed',
        failure_reason TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        verified_at TIMESTAMP WITH TIME ZONE
      );
    ''');

    // 8. Create movie_refunds table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS movie_refunds (
        id SERIAL PRIMARY KEY,
        refund_id VARCHAR(80) UNIQUE NOT NULL,
        booking_id INTEGER REFERENCES bookings(id) ON DELETE CASCADE NOT NULL,
        user_id INTEGER REFERENCES login_auth(id) ON DELETE CASCADE NOT NULL,
        refund_amount NUMERIC(10, 2) NOT NULL,
        refund_method VARCHAR(50) DEFAULT 'original_payment_source',
        refund_status VARCHAR(30) DEFAULT 'completed',
        transaction_reference VARCHAR(120),
        initiated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        completed_at TIMESTAMP WITH TIME ZONE
      );
    ''');

    // 9. Seed default admin user: admin@ticone.com / Admin@123
    final existingAdmin = await conn.execute(
      Sql.named("SELECT id, email, role FROM login_auth WHERE email = @email LIMIT 1"),
      parameters: {'email': 'admin@ticone.com'},
    );

    final hashedPw = BCrypt.hashpw('Admin@123', BCrypt.gensalt());

    if (existingAdmin.isEmpty) {
      await conn.execute(
        Sql.named('''
          INSERT INTO login_auth (name, email, password_hash, role, is_active, phone)
          VALUES (@name, @email, @hash, 'admin', true, '+919999988888')
        '''),
        parameters: {
          'name': 'TicOne Super Admin',
          'email': 'admin@ticone.com',
          'hash': hashedPw,
        },
      );
      print('Admin user created: admin@ticone.com / Admin@123');
    } else {
      await conn.execute(
        Sql.named('''
          UPDATE login_auth 
          SET role = 'admin', is_active = true, password_hash = @hash
          WHERE email = @email
        '''),
        parameters: {
          'email': 'admin@ticone.com',
          'hash': hashedPw,
        },
      );
      print('Existing admin user updated with role=admin and password=Admin@123');
    }

    print('Admin schema and admin user successfully configured!');
  } catch (e, st) {
    print('Schema error: $e\n$st');
  } finally {
    await conn.close();
  }
}
