import 'dart:io';
import 'dart:convert';
import 'package:postgres/postgres.dart';
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

void main() async {
  print('🚌 Starting TicOne Bus Booking Database Migration & Seeding...');
  final connection = await openDatabaseConnection();

  try {
    // 1. Create Schema
    print('📄 1. Applying db/04_bus_booking_schema.sql...');
    final schemaSql = await File('db/04_bus_booking_schema.sql').readAsString();
    final stmts = splitSqlStatements(schemaSql);
    for (final s in stmts) {
      if (s.trim().isNotEmpty) {
        await connection.execute(s);
      }
    }
    print('✅ Schema created successfully (${stmts.length} statements).');

    // 2. Seed Operators
    print('🏢 2. Seeding Bus Operators...');
    final operators = [
      {
        'code': 'OP-INTRCITY',
        'name': 'IntrCity SmartBus',
        'logo': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=150&auto=format&fit=crop&q=80',
        'rating': 4.8,
        'reviews': 14250,
        'phone': '+91 80 4710 8888',
        'email': 'support@intrcity.com',
        'policy': 'Free cancellation up to 12 hours before departure. AC SmartBus with lounge access, onboard washroom, and real-time CCTV tracking.'
      },
      {
        'code': 'OP-KPN',
        'name': 'KPN Travels',
        'logo': 'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=150&auto=format&fit=crop&q=80',
        'rating': 4.6,
        'reviews': 11800,
        'phone': '+91 427 244 5555',
        'email': 'care@kpntravels.in',
        'policy': 'Cancellation charges: >24h: 10%, 12-24h: 25%, <12h: 50%, <6h: No refund.'
      },
      {
        'code': 'OP-SRS',
        'name': 'SRS Travels',
        'logo': 'https://images.unsplash.com/photo-1596733430284-f7437764b1a9?w=150&auto=format&fit=crop&q=80',
        'rating': 4.5,
        'reviews': 18900,
        'phone': '+91 80 2680 9999',
        'email': 'info@srsbooking.com',
        'policy': 'Standard South India premier bus operator. Punctual departures, sanitized sleeper berths, and luggage assistance.'
      },
      {
        'code': 'OP-ORANGE',
        'name': 'Orange Tours & Travels',
        'logo': 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=150&auto=format&fit=crop&q=80',
        'rating': 4.7,
        'reviews': 9820,
        'phone': '+91 40 3355 9999',
        'email': 'support@orangetravels.in',
        'policy': 'Direct AC Multi-Axle sleeper services. Free water bottle, sanitized blankets, and onboard entertainment.'
      },
      {
        'code': 'OP-VRL',
        'name': 'VRL Travels',
        'logo': 'https://images.unsplash.com/photo-1494515843206-f3117d3f51b7?w=150&auto=format&fit=crop&q=80',
        'rating': 4.7,
        'reviews': 24500,
        'phone': '+91 836 223 7511',
        'email': 'customercare@vrlbus.in',
        'policy': 'India’s largest commercial fleet operator. High punctuality record with GPS tracking.'
      },
      {
        'code': 'OP-ZING',
        'name': 'Zingbus Plus',
        'logo': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=150&auto=format&fit=crop&q=80',
        'rating': 4.6,
        'reviews': 8400,
        'phone': '+91 80 6918 8888',
        'email': 'care@zingbus.com',
        'policy': 'Zero-cancellation fee protection available. 100% on-time guarantee or 50% refund.'
      },
      {
        'code': 'OP-GREENLINE',
        'name': 'GreenLine Travels',
        'logo': 'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=150&auto=format&fit=crop&q=80',
        'rating': 4.5,
        'reviews': 6300,
        'phone': '+91 80 2222 7777',
        'email': 'support@greenlinebus.com',
        'policy': 'Eco-friendly Scania and Volvo fleet. Reclining semi-sleeper and sleeper comfort.'
      },
      {
        'code': 'OP-JABBAR',
        'name': 'Jabbar Travels',
        'logo': 'https://images.unsplash.com/photo-1596733430284-f7437764b1a9?w=150&auto=format&fit=crop&q=80',
        'rating': 4.4,
        'reviews': 7100,
        'phone': '+91 80 4114 4444',
        'email': 'help@jabbartravels.com',
        'policy': 'Reliable sleeper coach operations across Karnataka, Tamil Nadu, and Andhra Pradesh.'
      }
    ];

    final operatorIdMap = <String, int>{};
    for (final op in operators) {
      final res = await connection.execute(
        Sql.named('''
          INSERT INTO bus_operators (operator_code, name, logo_url, rating, total_reviews, contact_number, email, cancellation_policy)
          VALUES (@code, @name, @logo, @rating, @reviews, @phone, @email, @policy)
          ON CONFLICT (operator_code) DO UPDATE SET
            name = EXCLUDED.name,
            logo_url = EXCLUDED.logo_url,
            rating = EXCLUDED.rating,
            total_reviews = EXCLUDED.total_reviews,
            contact_number = EXCLUDED.contact_number,
            email = EXCLUDED.email,
            cancellation_policy = EXCLUDED.cancellation_policy
          RETURNING id;
        '''),
        parameters: {
          'code': op['code'],
          'name': op['name'],
          'logo': op['logo'],
          'rating': op['rating'],
          'reviews': op['reviews'],
          'phone': op['phone'],
          'email': op['email'],
          'policy': op['policy'],
        },
      );
      operatorIdMap[op['code'] as String] = res.first[0] as int;
    }
    print('✅ ${operatorIdMap.length} Bus Operators seeded.');

    // 3. Seed Buses
    print('🚌 3. Seeding Buses...');
    final buses = [
      {
        'code': 'BUS-INTR-VOLVO9600',
        'opCode': 'OP-INTRCITY',
        'name': 'IntrCity SmartBus Volvo 9600 AC Sleeper (2+1)',
        'number': 'KA-01-AJ-4001',
        'type': 'Volvo 9600 Multi-Axle AC Sleeper (2+1)',
        'category': 'sleeper',
        'isAc': true,
        'deckType': 'double',
        'totalSeats': 36,
        'amenities': ['WiFi', 'Live Tracking', 'Charging Point', 'Water Bottle', 'Sanitized Blanket', 'Reading Light', 'Emergency Exit', 'CCTV', 'Washroom'],
      },
      {
        'code': 'BUS-ORANGE-SCANIA',
        'opCode': 'OP-ORANGE',
        'name': 'Orange Scania AC Semi-Sleeper (2+2)',
        'number': 'TS-09-UB-8822',
        'type': 'Scania Metrolink AC Semi-Sleeper (2+2)',
        'category': 'semi_sleeper',
        'isAc': true,
        'deckType': 'single',
        'totalSeats': 40,
        'amenities': ['Live Tracking', 'Charging Point', 'Water Bottle', 'Blanket', 'Reading Light', 'CCTV'],
      },
      {
        'code': 'BUS-KPN-BENZ',
        'opCode': 'OP-KPN',
        'name': 'KPN BharatBenz AC Sleeper (2+1)',
        'number': 'TN-01-BK-3390',
        'type': 'BharatBenz AC Sleeper (2+1)',
        'category': 'sleeper',
        'isAc': true,
        'deckType': 'double',
        'totalSeats': 30,
        'amenities': ['Live Tracking', 'Charging Point', 'Water Bottle', 'Blanket', 'Reading Light', 'Emergency Exit'],
      },
      {
        'code': 'BUS-VRL-I-SHIFT',
        'opCode': 'OP-VRL',
        'name': 'VRL I-Shift Multi-Axle AC Sleeper (2+1)',
        'number': 'KA-25-D-7711',
        'type': 'Volvo Multi-Axle AC Sleeper (2+1)',
        'category': 'sleeper',
        'isAc': true,
        'deckType': 'double',
        'totalSeats': 36,
        'amenities': ['WiFi', 'Live Tracking', 'Charging Point', 'Water Bottle', 'Blanket', 'Reading Light', 'Snack Pack'],
      },
      {
        'code': 'BUS-SRS-VOLVO-B11R',
        'opCode': 'OP-SRS',
        'name': 'SRS Volvo B11R AC Sleeper / Semi-Sleeper',
        'number': 'KA-05-AA-5544',
        'type': 'Volvo B11R AC Multi-Axle (2+1)',
        'category': 'sleeper',
        'isAc': true,
        'deckType': 'double',
        'totalSeats': 36,
        'amenities': ['Live Tracking', 'Charging Point', 'Water Bottle', 'Blanket', 'Reading Light'],
      },
      {
        'code': 'BUS-ZING-ELECTRIC',
        'opCode': 'OP-ZING',
        'name': 'Zingbus Prime Electric AC Luxury Sleeper',
        'number': 'DL-01-EV-2026',
        'type': 'Electric AC Sleeper (2+1)',
        'category': 'sleeper',
        'isAc': true,
        'deckType': 'double',
        'totalSeats': 30,
        'amenities': ['WiFi', 'Zero Emission', 'Live Tracking', 'Charging Point', 'Water Bottle', 'Blanket', 'Reading Light', 'Air Purifier'],
      },
      {
        'code': 'BUS-GREEN-SEATER',
        'opCode': 'OP-GREENLINE',
        'name': 'GreenLine Executive AC Seater (2+2)',
        'number': 'KA-04-EX-1100',
        'type': 'Ashok Leyland AC Seater (2+2)',
        'category': 'seater',
        'isAc': true,
        'deckType': 'single',
        'totalSeats': 40,
        'amenities': ['Live Tracking', 'Charging Point', 'Reading Light', 'Reclining Seats'],
      },
      {
        'code': 'BUS-JABBAR-NONAC',
        'opCode': 'OP-JABBAR',
        'name': 'Jabbar Executive Non-AC Sleeper (2+1)',
        'number': 'KA-01-JB-9900',
        'type': 'Non-AC Executive Sleeper (2+1)',
        'category': 'sleeper',
        'isAc': false,
        'deckType': 'double',
        'totalSeats': 36,
        'amenities': ['Charging Point', 'Reading Light', 'Emergency Exit'],
      },
    ];

    final busIdMap = <String, int>{};
    for (final b in buses) {
      final opId = operatorIdMap[b['opCode'] as String]!;
      final res = await connection.execute(
        Sql.named('''
          INSERT INTO buses (bus_code, operator_id, bus_name, bus_number, bus_type, category, is_ac, deck_type, total_seats, amenities)
          VALUES (@code, @opId, @name, @number, @type, @cat, @isAc, @deck, @total, @amenities::jsonb)
          ON CONFLICT (bus_code) DO UPDATE SET
            operator_id = EXCLUDED.operator_id,
            bus_name = EXCLUDED.bus_name,
            bus_number = EXCLUDED.bus_number,
            bus_type = EXCLUDED.bus_type,
            category = EXCLUDED.category,
            is_ac = EXCLUDED.is_ac,
            deck_type = EXCLUDED.deck_type,
            total_seats = EXCLUDED.total_seats,
            amenities = EXCLUDED.amenities
          RETURNING id;
        '''),
        parameters: {
          'code': b['code'],
          'opId': opId,
          'name': b['name'],
          'number': b['number'],
          'type': b['type'],
          'cat': b['category'],
          'isAc': b['isAc'],
          'deck': b['deckType'],
          'total': b['totalSeats'],
          'amenities': jsonEncode(b['amenities']),
        },
      );
      busIdMap[b['code'] as String] = res.first[0] as int;
    }
    print('✅ ${busIdMap.length} Buses seeded.');

    // 4. Seed Bus Seats for each bus
    print('💺 4. Generating Seat Layouts for each Bus...');
    for (final b in buses) {
      final busId = busIdMap[b['code'] as String]!;
      final deckType = b['deckType'] as String;
      final category = b['category'] as String;

      await connection.execute(
        Sql.named('DELETE FROM bus_seats WHERE bus_id = @busId'),
        parameters: {'busId': busId},
      );

      if (category == 'sleeper') {
        final rowsCount = (b['totalSeats'] as int) ~/ 6;

        for (final deck in ['lower', 'upper']) {
          final deckPrefix = deck == 'lower' ? 'L' : 'U';
          for (var r = 1; r <= rowsCount; r++) {
            final seat1Num = '$deckPrefix${(r - 1) * 3 + 1}';
            await connection.execute(
              Sql.named('''
                INSERT INTO bus_seats (bus_id, seat_number, deck, row_num, column_num, seat_type, berth_type, is_window, is_aisle, gender_preference, seat_tier, price_multiplier)
                VALUES (@busId, @seatNum, @deck, @r, 1, 'sleeper', 'single_berth', true, false, @gender, @tier, @mult)
              '''),
              parameters: {
                'busId': busId,
                'seatNum': seat1Num,
                'deck': deck,
                'r': r,
                'gender': r == 1 ? 'ladies_only' : 'any',
                'tier': r <= 2 ? 'Premium Berth' : 'Standard',
                'mult': r <= 2 ? 1.15 : 1.00,
              },
            );

            final seat2Num = '$deckPrefix${(r - 1) * 3 + 2}';
            await connection.execute(
              Sql.named('''
                INSERT INTO bus_seats (bus_id, seat_number, deck, row_num, column_num, seat_type, berth_type, is_window, is_aisle, gender_preference, seat_tier, price_multiplier)
                VALUES (@busId, @seatNum, @deck, @r, 2, 'sleeper', 'double_berth', false, true, @gender, 'Standard', 1.00)
              '''),
              parameters: {
                'busId': busId,
                'seatNum': seat2Num,
                'deck': deck,
                'r': r,
                'gender': r == 1 ? 'ladies_only' : 'any',
              },
            );

            final seat3Num = '$deckPrefix${(r - 1) * 3 + 3}';
            await connection.execute(
              Sql.named('''
                INSERT INTO bus_seats (bus_id, seat_number, deck, row_num, column_num, seat_type, berth_type, is_window, is_aisle, gender_preference, seat_tier, price_multiplier)
                VALUES (@busId, @seatNum, @deck, @r, 3, 'sleeper', 'double_berth', true, false, @gender, @tier, @mult)
              '''),
              parameters: {
                'busId': busId,
                'seatNum': seat3Num,
                'deck': deck,
                'r': r,
                'gender': r == 1 ? 'ladies_only' : 'any',
                'tier': r <= 2 ? 'Premium Berth' : 'Standard',
                'mult': r <= 2 ? 1.10 : 1.00,
              },
            );
          }
        }
      } else {
        final totalSeats = b['totalSeats'] as int;
        final rowsCount = totalSeats ~/ 4;

        for (var r = 1; r <= rowsCount; r++) {
          final rowLabel = String.fromCharCode(64 + r);
          for (var c = 1; c <= 4; c++) {
            final seatNum = '$rowLabel$c';
            final isWindow = (c == 1 || c == 4);
            final isAisle = (c == 2 || c == 3);
            final tier = r <= 2 ? 'Prime Recliner' : 'Standard';
            final mult = r <= 2 ? 1.10 : 1.00;

            await connection.execute(
              Sql.named('''
                INSERT INTO bus_seats (bus_id, seat_number, deck, row_num, column_num, seat_type, berth_type, is_window, is_aisle, gender_preference, seat_tier, price_multiplier)
                VALUES (@busId, @seatNum, 'lower', @r, @c, @seatType, @berthType, @isWindow, @isAisle, @gender, @tier, @mult)
              '''),
              parameters: {
                'busId': busId,
                'seatNum': seatNum,
                'r': r,
                'c': c,
                'seatType': category == 'semi_sleeper' ? 'semi_sleeper' : 'seater',
                'berthType': isWindow ? 'window_seat' : 'aisle_seat',
                'isWindow': isWindow,
                'isAisle': isAisle,
                'gender': r == 1 ? 'ladies_only' : 'any',
                'tier': tier,
                'mult': mult,
              },
            );
          }
        }
      }
    }
    print('✅ Bus Seats generated for all buses.');

    // 5. Seed Routes
    print('🗺️  5. Seeding Bus Routes...');
    final routes = [
      {'code': 'RT-BLR-CHE', 'from': 'Bengaluru', 'to': 'Chennai', 'sState': 'Karnataka', 'dState': 'Tamil Nadu', 'dist': 350.0, 'dur': 360, 'pop': true},
      {'code': 'RT-CHE-BLR', 'from': 'Chennai', 'to': 'Bengaluru', 'sState': 'Tamil Nadu', 'dState': 'Karnataka', 'dist': 350.0, 'dur': 360, 'pop': true},
      {'code': 'RT-BLR-HYD', 'from': 'Bengaluru', 'to': 'Hyderabad', 'sState': 'Karnataka', 'dState': 'Telangana', 'dist': 570.0, 'dur': 510, 'pop': true},
      {'code': 'RT-HYD-BLR', 'from': 'Hyderabad', 'to': 'Bengaluru', 'sState': 'Telangana', 'dState': 'Karnataka', 'dist': 570.0, 'dur': 510, 'pop': true},
      {'code': 'RT-MUM-PUN', 'from': 'Mumbai', 'to': 'Pune', 'sState': 'Maharashtra', 'dState': 'Maharashtra', 'dist': 150.0, 'dur': 180, 'pop': true},
      {'code': 'RT-PUN-MUM', 'from': 'Pune', 'to': 'Mumbai', 'sState': 'Maharashtra', 'dState': 'Maharashtra', 'dist': 150.0, 'dur': 180, 'pop': true},
      {'code': 'RT-BLR-GOA', 'from': 'Bengaluru', 'to': 'Goa', 'sState': 'Karnataka', 'dState': 'Goa', 'dist': 590.0, 'dur': 630, 'pop': true},
      {'code': 'RT-GOA-BLR', 'from': 'Goa', 'to': 'Bengaluru', 'sState': 'Goa', 'dState': 'Karnataka', 'dist': 590.0, 'dur': 630, 'pop': true},
      {'code': 'RT-DEL-JAI', 'from': 'Delhi', 'to': 'Jaipur', 'sState': 'Delhi', 'dState': 'Rajasthan', 'dist': 280.0, 'dur': 300, 'pop': true},
      {'code': 'RT-JAI-DEL', 'from': 'Jaipur', 'to': 'Delhi', 'sState': 'Rajasthan', 'dState': 'Delhi', 'dist': 280.0, 'dur': 300, 'pop': true},
      {'code': 'RT-CHE-CBE', 'from': 'Chennai', 'to': 'Coimbatore', 'sState': 'Tamil Nadu', 'dState': 'Tamil Nadu', 'dist': 510.0, 'dur': 480, 'pop': true},
      {'code': 'RT-HYD-VIJ', 'from': 'Hyderabad', 'to': 'Vijayawada', 'sState': 'Telangana', 'dState': 'Andhra Pradesh', 'dist': 275.0, 'dur': 270, 'pop': true},
    ];

    final routeIdMap = <String, int>{};
    for (final r in routes) {
      final res = await connection.execute(
        Sql.named('''
          INSERT INTO bus_routes (route_code, source_city, destination_city, source_state, destination_state, distance_km, estimated_duration_mins, is_popular)
          VALUES (@code, @from, @to, @sState, @dState, @dist, @dur, @pop)
          ON CONFLICT (route_code) DO UPDATE SET
            source_city = EXCLUDED.source_city,
            destination_city = EXCLUDED.destination_city,
            source_state = EXCLUDED.source_state,
            destination_state = EXCLUDED.destination_state,
            distance_km = EXCLUDED.distance_km,
            estimated_duration_mins = EXCLUDED.estimated_duration_mins,
            is_popular = EXCLUDED.is_popular
          RETURNING id;
        '''),
        parameters: {
          'code': r['code'],
          'from': r['from'],
          'to': r['to'],
          'sState': r['sState'],
          'dState': r['dState'],
          'dist': r['dist'],
          'dur': r['dur'],
          'pop': r['pop'],
        },
      );
      routeIdMap[r['code'] as String] = res.first[0] as int;
    }
    print('✅ ${routeIdMap.length} Bus Routes seeded.');

    // 6. Seed Trips for next 14 days
    print('📅 6. Generating Trips for the next 14 days...');
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);

    final tripSchedules = [
      {'rCode': 'RT-BLR-CHE', 'bCode': 'BUS-INTR-VOLVO9600', 'depHour': 22, 'depMin': 30, 'durMin': 360, 'fare': 950.00},
      {'rCode': 'RT-BLR-CHE', 'bCode': 'BUS-KPN-BENZ', 'depHour': 23, 'depMin': 15, 'durMin': 360, 'fare': 850.00},
      {'rCode': 'RT-BLR-CHE', 'bCode': 'BUS-SRS-VOLVO-B11R', 'depHour': 14, 'depMin': 0, 'durMin': 390, 'fare': 750.00},
      {'rCode': 'RT-BLR-CHE', 'bCode': 'BUS-GREEN-SEATER', 'depHour': 7, 'depMin': 0, 'durMin': 360, 'fare': 550.00},
      
      {'rCode': 'RT-CHE-BLR', 'bCode': 'BUS-INTR-VOLVO9600', 'depHour': 22, 'depMin': 45, 'durMin': 360, 'fare': 950.00},
      {'rCode': 'RT-CHE-BLR', 'bCode': 'BUS-KPN-BENZ', 'depHour': 23, 'depMin': 0, 'durMin': 360, 'fare': 850.00},

      {'rCode': 'RT-BLR-HYD', 'bCode': 'BUS-ORANGE-SCANIA', 'depHour': 21, 'depMin': 30, 'durMin': 510, 'fare': 1200.00},
      {'rCode': 'RT-BLR-HYD', 'bCode': 'BUS-VRL-I-SHIFT', 'depHour': 22, 'depMin': 15, 'durMin': 510, 'fare': 1350.00},
      {'rCode': 'RT-BLR-HYD', 'bCode': 'BUS-JABBAR-NONAC', 'depHour': 20, 'depMin': 0, 'durMin': 540, 'fare': 750.00},

      {'rCode': 'RT-HYD-BLR', 'bCode': 'BUS-ORANGE-SCANIA', 'depHour': 21, 'depMin': 45, 'durMin': 510, 'fare': 1200.00},
      {'rCode': 'RT-HYD-BLR', 'bCode': 'BUS-VRL-I-SHIFT', 'depHour': 22, 'depMin': 0, 'durMin': 510, 'fare': 1350.00},

      {'rCode': 'RT-MUM-PUN', 'bCode': 'BUS-ZING-ELECTRIC', 'depHour': 6, 'depMin': 30, 'durMin': 180, 'fare': 450.00},
      {'rCode': 'RT-MUM-PUN', 'bCode': 'BUS-GREEN-SEATER', 'depHour': 15, 'depMin': 0, 'durMin': 180, 'fare': 380.00},
      {'rCode': 'RT-MUM-PUN', 'bCode': 'BUS-INTR-VOLVO9600', 'depHour': 18, 'depMin': 30, 'durMin': 180, 'fare': 550.00},

      {'rCode': 'RT-PUN-MUM', 'bCode': 'BUS-ZING-ELECTRIC', 'depHour': 11, 'depMin': 0, 'durMin': 180, 'fare': 450.00},
      {'rCode': 'RT-PUN-MUM', 'bCode': 'BUS-INTR-VOLVO9600', 'depHour': 20, 'depMin': 0, 'durMin': 180, 'fare': 550.00},

      {'rCode': 'RT-BLR-GOA', 'bCode': 'BUS-VRL-I-SHIFT', 'depHour': 20, 'depMin': 0, 'durMin': 630, 'fare': 1450.00},
      {'rCode': 'RT-BLR-GOA', 'bCode': 'BUS-SRS-VOLVO-B11R', 'depHour': 21, 'depMin': 15, 'durMin': 630, 'fare': 1300.00},

      {'rCode': 'RT-DEL-JAI', 'bCode': 'BUS-ZING-ELECTRIC', 'depHour': 7, 'depMin': 0, 'durMin': 300, 'fare': 599.00},
      {'rCode': 'RT-DEL-JAI', 'bCode': 'BUS-INTR-VOLVO9600', 'depHour': 23, 'depMin': 0, 'durMin': 300, 'fare': 750.00},

      {'rCode': 'RT-CHE-CBE', 'bCode': 'BUS-KPN-BENZ', 'depHour': 22, 'depMin': 0, 'durMin': 480, 'fare': 900.00},

      {'rCode': 'RT-HYD-VIJ', 'bCode': 'BUS-ORANGE-SCANIA', 'depHour': 23, 'depMin': 30, 'durMin': 270, 'fare': 650.00},
    ];

    String formatTime(DateTime dt) {
      final hour = dt.hour;
      final minute = dt.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final mStr = minute.toString().padLeft(2, '0');
      return '${h12.toString().padLeft(2, '0')}:$mStr $period';
    }

    String formatDuration(int mins) {
      final h = mins ~/ 60;
      final m = mins % 60;
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }

    var totalTripsCount = 0;
    final tripIdMap = <String, int>{};

    for (var dayOffset = 0; dayOffset <= 14; dayOffset++) {
      final targetDate = today.add(Duration(days: dayOffset));
      final dateStr = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
      final dateCompact = "${targetDate.year}${targetDate.month.toString().padLeft(2, '0')}${targetDate.day.toString().padLeft(2, '0')}";

      for (var idx = 0; idx < tripSchedules.length; idx++) {
        final s = tripSchedules[idx];
        final rId = routeIdMap[s['rCode'] as String]!;
        final bId = busIdMap[s['bCode'] as String]!;
        final depHour = s['depHour'] as int;
        final depMin = s['depMin'] as int;
        final durMin = s['durMin'] as int;
        final baseFare = s['fare'] as double;

        final depTime = DateTime.utc(targetDate.year, targetDate.month, targetDate.day, depHour, depMin);
        final arrTime = depTime.add(Duration(minutes: durMin));
        final tripCode = "TRIP-${s['rCode']}-$dateCompact-${(idx + 1).toString().padLeft(2, '0')}";

        final res = await connection.execute(
          Sql.named('''
            INSERT INTO bus_trips (trip_code, bus_id, route_id, travel_date, departure_time, arrival_time, departure_time_formatted, arrival_time_formatted, duration_formatted, base_fare, status)
            VALUES (@code, @bId, @rId, @tDate::date, @depTime, @arrTime, @depFmt, @arrFmt, @durFmt, @fare, 'active')
            ON CONFLICT (trip_code) DO UPDATE SET
              departure_time = EXCLUDED.departure_time,
              arrival_time = EXCLUDED.arrival_time,
              departure_time_formatted = EXCLUDED.departure_time_formatted,
              arrival_time_formatted = EXCLUDED.arrival_time_formatted,
              duration_formatted = EXCLUDED.duration_formatted,
              base_fare = EXCLUDED.base_fare,
              status = EXCLUDED.status
            RETURNING id;
          '''),
          parameters: {
            'code': tripCode,
            'bId': bId,
            'rId': rId,
            'tDate': dateStr,
            'depTime': depTime,
            'arrTime': arrTime,
            'depFmt': formatTime(depTime),
            'arrFmt': formatTime(arrTime),
            'durFmt': formatDuration(durMin),
            'fare': baseFare,
          },
        );

        final tripId = res.first[0] as int;
        tripIdMap[tripCode] = tripId;
        totalTripsCount++;
      }
    }
    print('✅ $totalTripsCount Bus Trips seeded across 15 days.');

    // 7. Seed Boarding and Dropping Points for all Trips
    print('📍 7. Seeding Boarding & Dropping Points...');
    final cityBoardingPoints = {
      'Bengaluru': [
        {'name': 'Majestic - Anand Rao Circle', 'landmark': 'Near SRS Travels Office / Railway Subway', 'addr': 'Subhash Nagar, Anand Rao Circle, Bengaluru', 'phone': '+91 80 2287 1122', 'offset': 0, 'lat': 12.9774, 'lng': 77.5729},
        {'name': 'Kalasipalyam Bus Stand', 'landmark': 'Opp. KR Market Metro Gate', 'addr': 'Kalasipalyam Main Road, Bengaluru', 'phone': '+91 80 2670 4455', 'offset': 20, 'lat': 12.9610, 'lng': 77.5780},
        {'name': 'Shantinagar - TTMC Bus Station', 'landmark': 'Platform 3, Shantinagar Bus Stand', 'addr': 'Double Road, Shantinagar, Bengaluru', 'phone': '+91 80 2222 1010', 'offset': 35, 'lat': 12.9554, 'lng': 77.5925},
        {'name': 'Madiwala - Near Police Station', 'landmark': 'Opp. Total Mall / Petrol Pump', 'addr': 'Hosur Road, Madiwala, Bengaluru', 'phone': '+91 80 2553 9090', 'offset': 55, 'lat': 12.9226, 'lng': 77.6174},
        {'name': 'Silk Board Junction', 'landmark': 'Service Road Bus Stop near Flyover', 'addr': 'Outer Ring Road, Silk Board, Bengaluru', 'phone': '+91 80 2572 8888', 'offset': 70, 'lat': 12.9174, 'lng': 77.6238},
        {'name': 'Electronic City Toll Plaza', 'landmark': 'Near E-City Elevated Toll Exit', 'addr': 'Hosur Main Road, Electronic City Phase 1, Bengaluru', 'phone': '+91 80 2852 4433', 'offset': 90, 'lat': 12.8452, 'lng': 77.6602},
      ],
      'Chennai': [
        {'name': 'Koyambedu - Omni Bus Stand', 'landmark': 'Platform 6, Omni Bus Stand', 'addr': 'Koyambedu, Chennai', 'phone': '+91 44 2479 5555', 'offset': 0, 'lat': 13.0694, 'lng': 80.1948},
        {'name': 'Ashok Pillar - Metro Gate 2', 'landmark': 'Opposite Police Station', 'addr': 'Jawaharlal Nehru Salai, Ashok Nagar, Chennai', 'phone': '+91 44 2489 3322', 'offset': 15, 'lat': 13.0339, 'lng': 80.2119},
        {'name': 'Guindy - Kathipara Junction', 'landmark': 'Near Guindy Race Course Flyover', 'addr': 'GST Road, Guindy, Chennai', 'phone': '+91 44 2234 1100', 'offset': 30, 'lat': 13.0067, 'lng': 80.2026},
        {'name': 'Porur Toll Gate', 'landmark': 'Near Porur Signal & Toll Gate', 'addr': 'Mount Poonamallee High Rd, Chennai', 'phone': '+91 44 2476 8899', 'offset': 45, 'lat': 13.0382, 'lng': 80.1565},
        {'name': 'Tambaram - Sanatorium', 'landmark': 'Opposite MEPZ Bus Stop', 'addr': 'GST Road, Tambaram Sanatorium, Chennai', 'phone': '+91 44 2241 5566', 'offset': 65, 'lat': 12.9300, 'lng': 80.1245},
        {'name': 'Perungalathur - Bus Stand', 'landmark': 'Near Railway Station Footover', 'addr': 'GST Road, Perungalathur, Chennai', 'phone': '+91 44 2274 2211', 'offset': 80, 'lat': 12.8986, 'lng': 80.0984},
      ],
      'Hyderabad': [
        {'name': 'Ameerpet - Metro Pillar A1042', 'landmark': 'Opposite Big Bazaar', 'addr': 'Ameerpet Main Road, Hyderabad', 'phone': '+91 40 2373 1122', 'offset': 0, 'lat': 17.4375, 'lng': 78.4483},
        {'name': 'Lakdikapul - Near Telephone Bhavan', 'landmark': 'Below Lakdikapul Flyover', 'addr': 'Lakdikapul, Hyderabad', 'phone': '+91 40 2323 4455', 'offset': 20, 'lat': 17.4042, 'lng': 78.4619},
        {'name': 'Mehdipatnam - Pillar 45', 'landmark': 'Opp. Rythu Bazar', 'addr': 'PVNR Expressway Pillar 45, Mehdipatnam, Hyderabad', 'phone': '+91 40 2351 7788', 'offset': 35, 'lat': 17.3916, 'lng': 78.4402},
        {'name': 'Gachibowli - ORR Junction', 'landmark': 'Near Outer Ring Road Entrance', 'addr': 'Gachibowli, Hyderabad', 'phone': '+91 40 2300 9900', 'offset': 55, 'lat': 17.4401, 'lng': 78.3489},
        {'name': 'Shamshabad - Airport ORR Junction', 'landmark': 'Near Decathlon Outlet', 'addr': 'Shamshabad, Hyderabad', 'phone': '+91 40 2400 8822', 'offset': 80, 'lat': 17.2403, 'lng': 78.4294},
      ],
      'Mumbai': [
        {'name': 'Borivali (West) - Gokul Hotel', 'landmark': 'Near Chamunda Circle', 'addr': 'SV Road, Borivali West, Mumbai', 'phone': '+91 22 2891 1122', 'offset': 0, 'lat': 19.2307, 'lng': 72.8567},
        {'name': 'Andheri (East) - Bisleri Compound', 'landmark': 'Western Express Highway', 'addr': 'Andheri East, Mumbai', 'phone': '+91 22 2683 4455', 'offset': 25, 'lat': 19.1136, 'lng': 72.8697},
        {'name': 'Sion - Chunabhatti Bridge', 'landmark': 'Near Sion Railway Station Flyover', 'addr': 'Sion Circle, Mumbai', 'phone': '+91 22 2407 8899', 'offset': 50, 'lat': 19.0434, 'lng': 72.8634},
        {'name': 'Vashi - Old Toll Naka', 'landmark': 'Near Vashi Plaza / Flyover', 'addr': 'Sion-Panvel Highway, Vashi, Navi Mumbai', 'phone': '+91 22 2782 3344', 'offset': 75, 'lat': 19.0771, 'lng': 72.9986},
      ],
      'Pune': [
        {'name': 'Wakad - Ginger Hotel Bridge', 'landmark': 'Near Hinjawadi Flyover', 'addr': 'Mumbai-Bangalore Bypass, Wakad, Pune', 'phone': '+91 20 2770 1122', 'offset': 0, 'lat': 18.5987, 'lng': 73.7667},
        {'name': 'Shivajinagar - Bank of Maharashtra', 'landmark': 'Near Sancheti Hospital', 'addr': 'Shivajinagar, Pune', 'phone': '+91 20 2553 4455', 'offset': 30, 'lat': 18.5314, 'lng': 73.8446},
        {'name': 'Swargate - Laxmi Narayan Chowk', 'landmark': 'Near Swargate Bus Stand', 'addr': 'Swargate, Pune', 'phone': '+91 20 2444 8899', 'offset': 50, 'lat': 18.5018, 'lng': 73.8586},
      ],
      'Goa': [
        {'name': 'Mapusa Bus Stand', 'landmark': 'Near Kadamba Bus Terminus', 'addr': 'Mapusa, Goa', 'phone': '+91 832 225 1122', 'offset': 0, 'lat': 15.5937, 'lng': 73.8142},
        {'name': 'Panaji - KTC Central Bus Stand', 'landmark': 'Platform 1, Kadamba Bus Stand', 'addr': 'Patto Centre, Panaji, Goa', 'phone': '+91 832 243 4455', 'offset': 25, 'lat': 15.4989, 'lng': 73.8370},
        {'name': 'Margao - KTC Bus Station', 'landmark': 'Near Old Market Circle', 'addr': 'Margao, Goa', 'phone': '+91 832 271 8899', 'offset': 60, 'lat': 15.2832, 'lng': 73.9862},
      ],
      'Delhi': [
        {'name': 'Kashmiri Gate ISBT', 'landmark': 'Gate No. 2, Metro Station', 'addr': 'Inter State Bus Terminal, Kashmiri Gate, Delhi', 'phone': '+91 11 2386 1122', 'offset': 0, 'lat': 28.6675, 'lng': 77.2285},
        {'name': 'Dhaula Kuan - Metro Pillar 62', 'landmark': 'Near Army Hospital R&R', 'addr': 'Ring Road, Dhaula Kuan, New Delhi', 'phone': '+91 11 2568 4455', 'offset': 35, 'lat': 28.5918, 'lng': 77.1616},
        {'name': 'IFFCO Chowk - Gurgaon', 'landmark': 'Near Metro Station Exit Gate', 'addr': 'NH-48, Sector 29, Gurgaon', 'phone': '+91 124 238 8899', 'offset': 60, 'lat': 28.4722, 'lng': 77.0725},
      ],
      'Jaipur': [
        {'name': 'Sindhi Camp Bus Stand', 'landmark': 'Station Road, Near Metro Station', 'addr': 'Sindhi Camp, Jaipur', 'phone': '+91 141 220 1122', 'offset': 0, 'lat': 26.9239, 'lng': 75.7997},
        {'name': 'Narayan Singh Circle', 'landmark': 'Near City Palace Approach', 'addr': 'Tonk Road, Jaipur', 'phone': '+91 141 256 4455', 'offset': 20, 'lat': 26.9038, 'lng': 75.8122},
        {'name': '200 Feet Bypass - Ajmer Road', 'landmark': 'Near Kamla Nehru Nagar', 'addr': 'Ajmer Road Bypass, Jaipur', 'phone': '+91 141 281 8899', 'offset': 45, 'lat': 26.8856, 'lng': 75.7314},
      ],
      'Coimbatore': [
        {'name': 'Gandhipuram Central Bus Stand', 'landmark': 'Cross Cut Road Junction', 'addr': 'Gandhipuram, Coimbatore', 'phone': '+91 422 252 1122', 'offset': 0, 'lat': 11.0168, 'lng': 76.9675},
        {'name': 'Omni Bus Stand - Sathy Road', 'landmark': 'Near GP Signal', 'addr': 'Sathy Road, Coimbatore', 'phone': '+91 422 249 4455', 'offset': 15, 'lat': 11.0250, 'lng': 76.9740},
        {'name': 'KMCH - Avinashi Road', 'landmark': 'Opp. Kovai Medical Center Hospital', 'addr': 'Avinashi Road, Coimbatore', 'phone': '+91 422 262 8899', 'offset': 35, 'lat': 11.0478, 'lng': 77.0425},
      ],
      'Vijayawada': [
        {'name': 'Pandit Nehru Bus Station (PNBS)', 'landmark': 'Auto Stand Gate No. 3', 'addr': 'Tarapet, Vijayawada', 'phone': '+91 866 257 1122', 'offset': 0, 'lat': 16.5062, 'lng': 80.6480},
        {'name': 'Benz Circle - Near Jyothi Mall', 'landmark': 'Beside Tata Croma', 'addr': 'MG Road, Benz Circle, Vijayawada', 'phone': '+91 866 247 4455', 'offset': 20, 'lat': 16.5002, 'lng': 80.6558},
        {'name': 'Ramavarappadu Ring', 'landmark': 'Near Inner Ring Road Overbridge', 'addr': 'Ramavarappadu, Vijayawada', 'phone': '+91 866 284 8899', 'offset': 40, 'lat': 16.5342, 'lng': 80.6812},
      ]
    };

    await connection.execute('DELETE FROM boarding_points;');
    await connection.execute('DELETE FROM dropping_points;');

    final tripsRes = await connection.execute('''
      SELECT t.id, t.bus_id, t.departure_time, t.arrival_time, r.source_city, r.destination_city
      FROM bus_trips t
      JOIN bus_routes r ON t.route_id = r.id
    ''');

    for (final tr in tripsRes) {
      final tripId = tr[0] as int;
      final busId = tr[1] as int;
      final depTime = tr[2] as DateTime;
      final arrTime = tr[3] as DateTime;
      final sCity = tr[4] as String;
      final dCity = tr[5] as String;

      final sPoints = cityBoardingPoints[sCity] ?? [
        {'name': '$sCity Main Bus Terminal', 'landmark': 'Central Station', 'addr': '$sCity City Center', 'phone': '+91 99999 11111', 'offset': 0, 'lat': 12.9716, 'lng': 77.5946}
      ];

      final dPoints = cityBoardingPoints[dCity] ?? [
        {'name': '$dCity Central Dropping Hub', 'landmark': 'City Gate', 'addr': '$dCity City Gate', 'phone': '+91 99999 22222', 'offset': 0, 'lat': 13.0827, 'lng': 80.2707}
      ];

      var bOrder = 1;
      for (final bp in sPoints) {
        final pTime = depTime.add(Duration(minutes: bp['offset'] as int));
        await connection.execute(
          Sql.named('''
            INSERT INTO boarding_points (trip_id, bus_id, point_name, landmark, address, contact_number, departure_time, time_formatted, display_order, latitude, longitude)
            VALUES (@tId, @bId, @name, @lm, @addr, @ph, @pTime, @tFmt, @ord, @lat, @lng)
          '''),
          parameters: {
            'tId': tripId,
            'bId': busId,
            'name': bp['name'],
            'lm': bp['landmark'],
            'addr': bp['addr'],
            'ph': bp['phone'],
            'pTime': pTime,
            'tFmt': formatTime(pTime),
            'ord': bOrder++,
            'lat': bp['lat'],
            'lng': bp['lng'],
          },
        );
      }

      var dOrder = 1;
      for (final dp in dPoints) {
        final pTime = arrTime.add(Duration(minutes: dp['offset'] as int));
        await connection.execute(
          Sql.named('''
            INSERT INTO dropping_points (trip_id, bus_id, point_name, landmark, address, contact_number, arrival_time, time_formatted, display_order, latitude, longitude)
            VALUES (@tId, @bId, @name, @lm, @addr, @ph, @pTime, @tFmt, @ord, @lat, @lng)
          '''),
          parameters: {
            'tId': tripId,
            'bId': busId,
            'name': dp['name'],
            'lm': dp['landmark'],
            'addr': dp['addr'],
            'ph': dp['phone'],
            'pTime': pTime,
            'tFmt': formatTime(pTime),
            'ord': dOrder++,
            'lat': dp['lat'],
            'lng': dp['lng'],
          },
        );
      }
    }
    print('✅ Boarding and Dropping points populated for all trips.');

    // 8. Seed Bus Promos & Coupons
    print('🎟️  8. Seeding Bus Promo Codes...');
    final promos = [
      {
        'code': 'FIRSTBUS',
        'title': 'First Bus Booking Special',
        'desc': 'Get 15% instant discount up to ₹200 on your first bus journey with TicOne.',
        'type': 'percentage',
        'val': 15.00,
        'minAmt': 500.00,
        'maxAmt': 200.00,
      },
      {
        'code': 'TICBUS50',
        'title': 'Flat ₹50 Off',
        'desc': 'Save flat ₹50 on all AC and Non-AC bus bookings across India.',
        'type': 'flat',
        'val': 50.00,
        'minAmt': 400.00,
        'maxAmt': 50.00,
      },
      {
        'code': 'SUPERJOURNEY',
        'title': 'Super Journey ₹100 Off',
        'desc': 'Enjoy flat ₹100 instant discount on long-distance premium Volvo & Scania sleeper buses.',
        'type': 'flat',
        'val': 100.00,
        'minAmt': 800.00,
        'maxAmt': 100.00,
      },
      {
        'code': 'ROYALBUS',
        'title': 'TicOne Royal Pass Exclusive',
        'desc': 'Exclusive 20% discount up to ₹300 for TicOne Royal Pass members.',
        'type': 'percentage',
        'val': 20.00,
        'minAmt': 600.00,
        'maxAmt': 300.00,
      },
      {
        'code': 'FESTIVE25',
        'title': 'Festive Travel Bonanza',
        'desc': 'Celebrate the season with 25% off up to ₹250 on all intercity bus routes.',
        'type': 'percentage',
        'val': 25.00,
        'minAmt': 600.00,
        'maxAmt': 250.00,
      },
    ];

    for (final p in promos) {
      await connection.execute(
        Sql.named('''
          INSERT INTO bus_promos (promo_code, title, description, discount_type, discount_value, min_booking_amount, max_discount_amount, valid_from, valid_until, is_active)
          VALUES (@code, @title, @desc, @type, @val, @minAmt, @maxAmt, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '180 days', true)
          ON CONFLICT (promo_code) DO UPDATE SET
            title = EXCLUDED.title,
            description = EXCLUDED.description,
            discount_type = EXCLUDED.discount_type,
            discount_value = EXCLUDED.discount_value,
            min_booking_amount = EXCLUDED.min_booking_amount,
            max_discount_amount = EXCLUDED.max_discount_amount,
            is_active = EXCLUDED.is_active;
        '''),
        parameters: {
          'code': p['code'],
          'title': p['title'],
          'desc': p['desc'],
          'type': p['type'],
          'val': p['val'],
          'minAmt': p['minAmt'],
          'maxAmt': p['maxAmt'],
        },
      );
    }
    print('✅ ${promos.length} Bus Promos seeded.');

    // 9. Seed Sample Bus Bookings for Demo / Existing User testing
    print('🎫 9. Seeding Demo Bus Bookings...');
    final usersRes = await connection.execute('SELECT id, name, email, phone FROM login_auth ORDER BY id ASC LIMIT 1;');
    if (usersRes.isNotEmpty) {
      final uId = usersRes.first[0] as int;
      final uName = (usersRes.first[1] as String?) ?? 'John Doe';
      final uEmail = (usersRes.first[2] as String?) ?? 'johndoe@example.com';
      final uPhone = (usersRes.first[3] as String?) ?? '9876543210';

      final sampleTripRes = await connection.execute('SELECT id, bus_id, base_fare FROM bus_trips ORDER BY id ASC LIMIT 2;');
      if (sampleTripRes.isNotEmpty) {
        final sampleTripId = sampleTripRes.first[0] as int;
        final sampleBusId = sampleTripRes.first[1] as int;
        final baseFare = double.tryParse(sampleTripRes.first[2]?.toString() ?? '850') ?? 850.0;

        final existingBooking = await connection.execute(
          Sql.named("SELECT id FROM bus_bookings WHERE booking_code = 'TIC-BUS-2026-881290'"),
        );

        if (existingBooking.isEmpty) {
          final bpRes = await connection.execute(
            Sql.named('SELECT id FROM boarding_points WHERE trip_id = @tId ORDER BY display_order ASC LIMIT 1'),
            parameters: {'tId': sampleTripId},
          );
          final dpRes = await connection.execute(
            Sql.named('SELECT id FROM dropping_points WHERE trip_id = @tId ORDER BY display_order ASC LIMIT 1'),
            parameters: {'tId': sampleTripId},
          );

          final bpId = bpRes.isNotEmpty ? bpRes.first[0] as int : null;
          final dpId = dpRes.isNotEmpty ? dpRes.first[0] as int : null;

          final sampleSeatsRes = await connection.execute(
            Sql.named("SELECT id, seat_number, deck, seat_tier, price_multiplier FROM bus_seats WHERE bus_id = @bId AND seat_number IN ('L1', 'L2')"),
            parameters: {'bId': sampleBusId},
          );

          final s1Id = sampleSeatsRes.isNotEmpty ? sampleSeatsRes[0][0] as int : 1;
          final s1Num = sampleSeatsRes.isNotEmpty ? sampleSeatsRes[0][1] as String : 'L1';
          final s2Id = sampleSeatsRes.length > 1 ? sampleSeatsRes[1][0] as int : 2;
          final s2Num = sampleSeatsRes.length > 1 ? sampleSeatsRes[1][1] as String : 'L2';

          final seatFare = baseFare * 1.15;
          final subtotal = seatFare * 2;
          final tax = (subtotal * 0.05).roundToDouble();
          final convFee = 25.00;
          final total = subtotal + tax + convFee;

          final qrData = base64UrlEncode(utf8.encode(jsonEncode({
            'code': 'TIC-BUS-2026-881290',
            'pnr': 'PNR881290',
            'tripId': sampleTripId,
            'userId': uId,
            'seats': [s1Num, s2Num],
          })));

          final bkRes = await connection.execute(
            Sql.named('''
              INSERT INTO bus_bookings (
                booking_code, pnr_number, user_id, trip_id, bus_id, boarding_point_id, dropping_point_id,
                total_seats, base_fare_amount, tax_amount, convenience_fee, discount_amount, promo_code,
                total_amount, payment_status, booking_status, contact_email, contact_phone, qr_code_data
              ) VALUES (
                'TIC-BUS-2026-881290', 'PNR881290', @uId, @tId, @bId, @bpId, @dpId,
                2, @subtotal, @tax, @convFee, 0.00, NULL,
                @total, 'completed', 'confirmed', @email, @phone, @qr
              ) RETURNING id;
            '''),
            parameters: {
              'uId': uId,
              'tId': sampleTripId,
              'bId': sampleBusId,
              'bpId': bpId,
              'dpId': dpId,
              'subtotal': subtotal,
              'tax': tax,
              'convFee': convFee,
              'total': total,
              'email': uEmail,
              'phone': uPhone,
              'qr': qrData,
            },
          );

          final bkId = bkRes.first[0] as int;

          // Passengers
          await connection.execute(
            Sql.named('''
              INSERT INTO bus_booking_passengers (booking_id, seat_id, seat_number, passenger_name, age, gender, seat_fare, seat_tier)
              VALUES (@bkId, @sId, @sNum, @pName, 28, 'Male', @fare, 'Premium Berth')
            '''),
            parameters: {'bkId': bkId, 'sId': s1Id, 'sNum': s1Num, 'pName': uName, 'fare': seatFare},
          );
          await connection.execute(
            Sql.named('''
              INSERT INTO bus_booking_passengers (booking_id, seat_id, seat_number, passenger_name, age, gender, seat_fare, seat_tier)
              VALUES (@bkId, @sId, @sNum, 'Priya Sharma', 26, 'Female', @fare, 'Premium Berth')
            '''),
            parameters: {'bkId': bkId, 'sId': s2Id, 'sNum': s2Num, 'fare': seatFare},
          );

          // Seats
          await connection.execute(
            Sql.named('''
              INSERT INTO bus_booking_seats (booking_id, seat_id, seat_number, deck, tier_name, price)
              VALUES (@bkId, @s1Id, @s1Num, 'lower', 'Premium Berth', @fare),
                     (@bkId, @s2Id, @s2Num, 'lower', 'Premium Berth', @fare)
            '''),
            parameters: {'bkId': bkId, 's1Id': s1Id, 's1Num': s1Num, 's2Id': s2Id, 's2Num': s2Num, 'fare': seatFare},
          );

          // Payment record
          await connection.execute(
            Sql.named('''
              INSERT INTO bus_payments (payment_id, booking_id, user_id, amount, currency, payment_method, transaction_reference, status, verified_at)
              VALUES ('PAY-BUS-2026881290', @bkId, @uId, @total, 'INR', 'upi', 'UPI/20261004/TICONE881290', 'completed', CURRENT_TIMESTAMP)
            '''),
            parameters: {'bkId': bkId, 'uId': uId, 'total': total},
          );

          print('✅ Sample confirmed Bus Booking created (TIC-BUS-2026-881290 / PNR881290).');
        }
      }
    }

    print('🎉 ALL BUS BOOKING MIGRATIONS AND SEED DATA COMPLETED SUCCESSFULLY!');
  } catch (e, st) {
    print('❌ Bus Migration Error: $e');
    print(st);
    exit(1);
  } finally {
    await connection.close();
  }
}
