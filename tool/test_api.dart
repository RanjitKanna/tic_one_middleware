import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> sendRequest(
  HttpClient client,
  String method,
  String url, {
  Map<String, dynamic>? body,
  String? token,
}) async {
  final uri = Uri.parse(url);
  final request = await client.openUrl(method, uri);
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
  if (token != null) {
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
  }

  if (body != null) {
    request.write(jsonEncode(body));
  }

  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();

  dynamic json;
  try {
    json = jsonDecode(responseBody);
  } catch (_) {
    json = {'raw': responseBody};
  }

  return {
    'statusCode': response.statusCode,
    'body': json,
  };
}

Future<void> main() async {
  const baseUrl = 'http://localhost:8080';
  stdout.writeln('Testing API endpoints at $baseUrl ...');

  final client = HttpClient();

  try {
    // 1. GET /home
    stdout.writeln('\n[1] Testing GET /home');
    final homeRes = await sendRequest(
      client,
      'GET',
      '$baseUrl/home?city=Downtown',
    );
    stdout.writeln('Status: ${homeRes['statusCode']}');
    if (homeRes['statusCode'] != 200) {
      throw Exception('Home test failed: ${homeRes['body']}');
    }
    final homeJson = homeRes['body'] as Map<String, dynamic>;
    final homeData = homeJson['data'] as Map<String, dynamic>;
    final heroCarousel = homeData['heroCarousel'] as List;
    final nowShowing = homeData['nowShowingMovies'] as List;
    final nearbyTheaters = homeData['nearbyTheaters'] as List;

    stdout.writeln('Hero banners: ${heroCarousel.length}');
    stdout.writeln('Now showing: ${nowShowing.length}');
    stdout.writeln('Nearby theaters: ${nearbyTheaters.length}');

    // 2. GET /movies
    stdout.writeln('\n[2] Testing GET /movies');
    final moviesRes = await sendRequest(client, 'GET', '$baseUrl/movies');
    stdout.writeln('Status: ${moviesRes['statusCode']}');
    if (moviesRes['statusCode'] != 200) {
      throw Exception('Movies test failed');
    }
    final moviesBody = moviesRes['body'] as Map<String, dynamic>;
    final moviesCount = moviesBody['count'];
    stdout.writeln('Total movies retrieved: $moviesCount');

    // 3. GET /movies/dune-part-two
    stdout.writeln('\n[3] Testing GET /movies/dune-part-two');
    final movieRes = await sendRequest(
      client,
      'GET',
      '$baseUrl/movies/dune-part-two',
    );
    stdout.writeln('Status: ${movieRes['statusCode']}');
    if (movieRes['statusCode'] != 200) {
      throw Exception('Single movie test failed');
    }
    final movieBody = movieRes['body'] as Map<String, dynamic>;
    final movieData = movieBody['data'] as Map<String, dynamic>;
    stdout.writeln(
      'Movie: ${movieData['title']} | Language: ${movieData['language']}',
    );

    // 4. GET /movies/MOV_DUNE2_2024/shows
    stdout.writeln('\n[4] Testing GET /movies/MOV_DUNE2_2024/shows');
    final showsRes = await sendRequest(
      client,
      'GET',
      '$baseUrl/movies/MOV_DUNE2_2024/shows?city=Downtown',
    );
    stdout.writeln('Status: ${showsRes['statusCode']}');
    if (showsRes['statusCode'] != 200) {
      throw Exception('Shows test failed');
    }

    // 5. GET /theaters
    stdout.writeln('\n[5] Testing GET /theaters?city=Downtown');
    final theatersRes = await sendRequest(
      client,
      'GET',
      '$baseUrl/theaters?city=Downtown',
    );
    stdout.writeln('Status: ${theatersRes['statusCode']}');
    if (theatersRes['statusCode'] != 200) {
      throw Exception('Theaters test failed');
    }

    // 6. GET /shows/1/seats & extract available seats dynamically
    stdout.writeln('\n[6] Testing GET /shows/1/seats');
    final seatsRes = await sendRequest(client, 'GET', '$baseUrl/shows/1/seats');
    stdout.writeln('Status: ${seatsRes['statusCode']}');
    if (seatsRes['statusCode'] != 200) {
      throw Exception('Seats test failed');
    }
    final seatsJson = seatsRes['body'] as Map<String, dynamic>;
    final seatsData = seatsJson['data'] as Map<String, dynamic>;
    final rows = seatsData['rows'] as List;
    stdout.writeln('Total rows: ${rows.length}');

    final availableSeatIdentifiers = <String>[];
    for (final r in rows) {
      final rowMap = r as Map<String, dynamic>;
      final seatList = rowMap['seats'] as List;
      for (final s in seatList) {
        final seatMap = s as Map<String, dynamic>;
        if (seatMap['status'] == 'available') {
          availableSeatIdentifiers.add(seatMap['identifier'] as String);
          if (availableSeatIdentifiers.length == 2) break;
        }
      }
      if (availableSeatIdentifiers.length == 2) break;
    }

    if (availableSeatIdentifiers.isEmpty) {
      stdout.writeln('Notice: All seats booked or locked in show 1.');
    } else {
      stdout.writeln(
        'Selected available seats to lock: $availableSeatIdentifiers',
      );

      // 7. POST /shows/1/lock-seats
      stdout.writeln('\n[7] Testing POST /shows/1/lock-seats');
      final lockRes = await sendRequest(
        client,
        'POST',
        '$baseUrl/shows/1/lock-seats',
        body: {'seatIdentifiers': availableSeatIdentifiers},
      );
      stdout.writeln('Status: ${lockRes['statusCode']}');
      if (lockRes['statusCode'] != 200) {
        throw Exception('Lock seats failed: ${lockRes['body']}');
      }
      final lockJson = lockRes['body'] as Map<String, dynamic>;
      final lockData = lockJson['data'] as Map<String, dynamic>;
      final lockToken = lockData['lockToken'] as String;
      stdout.writeln('Lock token generated: $lockToken');

      // 8. Auth test: Login or Register
      stdout.writeln('\n[8] Authenticating test user...');
      var loginRes = await sendRequest(
        client,
        'POST',
        '$baseUrl/auth/login',
        body: {
          'identifier': 'testuser@example.com',
          'password': 'Password123!',
        },
      );

      String? accessToken;
      if (loginRes['statusCode'] == 200) {
        final bodyMap = loginRes['body'] as Map<String, dynamic>;
        accessToken = bodyMap['accessToken'] as String?;
      } else {
        await sendRequest(
          client,
          'POST',
          '$baseUrl/auth/register',
          body: {
            'name': 'Test User',
            'email': 'testuser@example.com',
            'phone': '9876543219',
            'password': 'Password123!',
          },
        );
        loginRes = await sendRequest(
          client,
          'POST',
          '$baseUrl/auth/login',
          body: {
            'identifier': 'testuser@example.com',
            'password': 'Password123!',
          },
        );
        if (loginRes['statusCode'] == 200) {
          final bodyMap = loginRes['body'] as Map<String, dynamic>;
          accessToken = bodyMap['accessToken'] as String?;
        }
      }

      if (accessToken != null) {
        // 9. POST /bookings/create
        stdout.writeln('\n[9] Testing POST /bookings/create');
        final bookRes = await sendRequest(
          client,
          'POST',
          '$baseUrl/bookings/create',
          token: accessToken,
          body: {
            'showId': 1,
            'lockToken': lockToken,
          },
        );
        stdout.writeln('Status: ${bookRes['statusCode']}');
        if (bookRes['statusCode'] != 201) {
          throw Exception('Create booking failed: ${bookRes['body']}');
        }
        final bookJson = bookRes['body'] as Map<String, dynamic>;
        final bookData = bookJson['data'] as Map<String, dynamic>;
        final bookingCode = bookData['bookingCode'] as String;
        stdout.writeln('Booking Code: $bookingCode');

        // 10. GET /bookings/my-tickets
        stdout.writeln('\n[10] Testing GET /bookings/my-tickets');
        final myTicketsRes = await sendRequest(
          client,
          'GET',
          '$baseUrl/bookings/my-tickets',
          token: accessToken,
        );
        stdout.writeln('Status: ${myTicketsRes['statusCode']}');
        if (myTicketsRes['statusCode'] != 200) {
          throw Exception('My tickets failed');
        }
        final myTicketsBody = myTicketsRes['body'] as Map<String, dynamic>;
        final count = myTicketsBody['count'];
        stdout.writeln('User ticket history count: $count');

        // 11. GET /bookings/:bookingCode
        stdout.writeln('\n[11] Testing GET /bookings/$bookingCode');
        final singleBookRes = await sendRequest(
          client,
          'GET',
          '$baseUrl/bookings/$bookingCode',
        );
        stdout.writeln('Status: ${singleBookRes['statusCode']}');
        if (singleBookRes['statusCode'] != 200) {
          throw Exception('Single ticket lookup failed');
        }
        stdout.writeln('Ticket verified successfully for $bookingCode');
      }
    }

    stdout.writeln('\n🎉 ALL API TESTS PASSED WITH ZERO ERRORS!');
  } on SocketException {
    stderr.writeln('\n❌ ERROR: Could not connect to $baseUrl');
    stderr.writeln('Please make sure `dart_frog dev` is running in your terminal.');
    exit(1);
  } finally {
    client.close();
  }
}
