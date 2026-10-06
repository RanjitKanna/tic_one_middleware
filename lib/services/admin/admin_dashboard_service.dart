import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/admin/admin_auth_service.dart';

class AdminDashboardService {
  static Future<Response> getStats(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Unauthorized: Admin privileges required'},
      );
    }

    final conn = await openDatabaseConnection();
    try {
      // 1. Total users
      final userCountRes = await conn.execute(
        "SELECT COUNT(*), COUNT(CASE WHEN is_active = true THEN 1 END) FROM login_auth WHERE is_deleted = false OR is_deleted IS NULL;",
      );
      final totalUsers = int.parse(userCountRes.first[0].toString());
      final activeUsers = int.parse(userCountRes.first[1].toString());

      // 2. Movie Bookings & Revenue
      final movieBookingRes = await conn.execute('''
        SELECT 
          COUNT(*),
          COALESCE(SUM(CASE WHEN booking_status != 'cancelled' THEN total_amount ELSE 0 END), 0),
          COUNT(CASE WHEN booking_status = 'cancelled' THEN 1 END),
          COUNT(CASE WHEN created_at >= CURRENT_DATE THEN 1 END),
          COUNT(CASE WHEN payment_status = 'pending' THEN 1 END)
        FROM bookings;
      ''');
      final totalMovieBookings = int.parse(movieBookingRes.first[0].toString());
      final movieRevenue = double.parse(movieBookingRes.first[1].toString());
      final movieCancelled = int.parse(movieBookingRes.first[2].toString());
      final todayMovieBookings = int.parse(movieBookingRes.first[3].toString());
      final pendingMoviePayments = int.parse(movieBookingRes.first[4].toString());

      // 3. Bus Bookings & Revenue
      final busBookingRes = await conn.execute('''
        SELECT 
          COUNT(*),
          COALESCE(SUM(CASE WHEN booking_status != 'cancelled' THEN total_amount ELSE 0 END), 0),
          COUNT(CASE WHEN booking_status = 'cancelled' THEN 1 END),
          COUNT(CASE WHEN created_at >= CURRENT_DATE THEN 1 END),
          COUNT(CASE WHEN payment_status = 'pending' THEN 1 END)
        FROM bus_bookings;
      ''');
      final totalBusBookings = int.parse(busBookingRes.first[0].toString());
      final busRevenue = double.parse(busBookingRes.first[1].toString());
      final busCancelled = int.parse(busBookingRes.first[2].toString());
      final todayBusBookings = int.parse(busBookingRes.first[3].toString());
      final pendingBusPayments = int.parse(busBookingRes.first[4].toString());

      // 4. Upcoming Shows
      final showsRes = await conn.execute('''
        SELECT COUNT(*) 
        FROM shows 
        WHERE show_time >= CURRENT_TIMESTAMP AND (is_deleted = false OR is_deleted IS NULL);
      ''');
      final upcomingShows = int.parse(showsRes.first[0].toString());

      // 5. Upcoming Bus Trips
      final tripsRes = await conn.execute('''
        SELECT COUNT(*) 
        FROM bus_trips 
        WHERE departure_time >= CURRENT_TIMESTAMP AND (is_deleted = false OR is_deleted IS NULL);
      ''');
      final upcomingBusTrips = int.parse(tripsRes.first[0].toString());

      // 6. Active Seat Holds
      final movieLocksRes = await conn.execute(
        "SELECT COUNT(*) FROM seat_locks WHERE expires_at > CURRENT_TIMESTAMP;",
      );
      final busLocksRes = await conn.execute(
        "SELECT COUNT(*) FROM bus_seat_locks WHERE expires_at > CURRENT_TIMESTAMP;",
      );
      final activeSeatHolds = int.parse(movieLocksRes.first[0].toString()) +
          int.parse(busLocksRes.first[0].toString());

      // 7. Last 7 Days Revenue Trend
      final trendRes = await conn.execute('''
        WITH dates AS (
          SELECT generate_series(CURRENT_DATE - INTERVAL '6 days', CURRENT_DATE, INTERVAL '1 day')::date AS d
        )
        SELECT 
          d.d::text,
          COALESCE((
            SELECT SUM(total_amount) 
            FROM bookings 
            WHERE created_at::date = d.d AND booking_status != 'cancelled'
          ), 0) AS movie_rev,
          COALESCE((
            SELECT SUM(total_amount) 
            FROM bus_bookings 
            WHERE created_at::date = d.d AND booking_status != 'cancelled'
          ), 0) AS bus_rev
        FROM dates d
        ORDER BY d.d ASC;
      ''');

      final revenueTrend = trendRes.map((r) => {
        'date': r[0].toString(),
        'movieRevenue': double.parse(r[1].toString()),
        'busRevenue': double.parse(r[2].toString()),
        'total': double.parse(r[1].toString()) + double.parse(r[2].toString()),
      }).toList();

      // 8. Recent 5 Movie Bookings
      final recentMovieRes = await conn.execute('''
        SELECT b.booking_code, u.name, m.title, b.total_seats, b.total_amount, b.booking_status, b.created_at
        FROM bookings b
        JOIN login_auth u ON b.user_id = u.id
        JOIN shows s ON b.show_id = s.id
        JOIN movies m ON s.movie_id = m.id
        ORDER BY b.created_at DESC
        LIMIT 5;
      ''');
      final recentMovieBookings = recentMovieRes.map((r) => {
        'bookingCode': r[0],
        'userName': r[1],
        'itemTitle': r[2],
        'type': 'movie',
        'seats': r[3],
        'amount': double.parse(r[4].toString()),
        'status': r[5],
        'createdAt': (r[6] as DateTime).toIso8601String(),
      }).toList();

      // 9. Recent 5 Bus Bookings
      final recentBusRes = await conn.execute('''
        SELECT b.booking_code, u.name, (r.source_city || ' -> ' || r.destination_city), b.total_seats, b.total_amount, b.booking_status, b.created_at
        FROM bus_bookings b
        JOIN login_auth u ON b.user_id = u.id
        JOIN bus_trips t ON b.trip_id = t.id
        JOIN bus_routes r ON t.route_id = r.id
        ORDER BY b.created_at DESC
        LIMIT 5;
      ''');
      final recentBusBookings = recentBusRes.map((r) => {
        'bookingCode': r[0],
        'userName': r[1],
        'itemTitle': r[2],
        'type': 'bus',
        'seats': r[3],
        'amount': double.parse(r[4].toString()),
        'status': r[5],
        'createdAt': (r[6] as DateTime).toIso8601String(),
      }).toList();

      // Combine and sort recent activities
      final recentActivity = [...recentMovieBookings, ...recentBusBookings]
        ..sort((a, b) => b['createdAt'].toString().compareTo(a['createdAt'].toString()));

      return Response.json(
        body: {
          'kpis': {
            'totalUsers': totalUsers,
            'activeUsers': activeUsers,
            'totalMovieBookings': totalMovieBookings,
            'totalBusBookings': totalBusBookings,
            'todayBookings': todayMovieBookings + todayBusBookings,
            'upcomingShows': upcomingShows,
            'upcomingBusTrips': upcomingBusTrips,
            'totalRevenue': movieRevenue + busRevenue,
            'movieRevenue': movieRevenue,
            'busRevenue': busRevenue,
            'cancelledBookings': movieCancelled + busCancelled,
            'pendingPayments': pendingMoviePayments + pendingBusPayments,
            'activeSeatHolds': activeSeatHolds,
          },
          'revenueTrend': revenueTrend,
          'recentActivity': recentActivity.take(8).toList(),
        },
      );
    } finally {
      await conn.close();
    }
  }
}
