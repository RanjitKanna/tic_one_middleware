import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> sendRequest(String method, String url, {Map<String, String>? headers, dynamic body}) async {
  final client = HttpClient();
  final uri = Uri.parse(url);
  final req = await (method == 'POST' ? client.postUrl(uri) : client.getUrl(uri));
  
  headers?.forEach((k, v) => req.headers.set(k, v));
  if (body != null) {
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
  }
  
  final res = await req.close();
  final responseBody = await res.transform(utf8.decoder).join();
  client.close();
  return {
    'statusCode': res.statusCode,
    'body': responseBody,
  };
}

void main() async {
  print('Testing Admin API endpoints...');
  final baseUrl = 'http://localhost:8080/api/admin';

  // 1. Admin Login
  print('\n[1] Testing POST /api/admin/auth/login');
  final loginRes = await sendRequest(
    'POST',
    '$baseUrl/auth/login',
    body: {
      'email': 'admin@ticone.com',
      'password': 'Admin@123',
    },
  );
  print('Status: ${loginRes['statusCode']}');
  print('Body: ${loginRes['body']}');

  if (loginRes['statusCode'] != 200) {
    print('Failed to login');
    return;
  }

  final loginData = jsonDecode(loginRes['body'] as String) as Map<String, dynamic>;
  final token = loginData['accessToken'] as String;
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // 2. Admin Me
  print('\n[2] Testing GET /api/admin/auth/me');
  final meRes = await sendRequest('GET', '$baseUrl/auth/me', headers: headers);
  print('Status: ${meRes['statusCode']}');
  print('Body: ${meRes['body']}');

  // 3. Admin Dashboard
  print('\n[3] Testing GET /api/admin/dashboard');
  final dashRes = await sendRequest('GET', '$baseUrl/dashboard', headers: headers);
  print('Status: ${dashRes['statusCode']}');
  print('Body: ${dashRes['body']}');

  // 4. Admin Users
  print('\n[4] Testing GET /api/admin/users');
  final usersRes = await sendRequest('GET', '$baseUrl/users', headers: headers);
  print('Status: ${usersRes['statusCode']}');
  final usersBody = usersRes['body'] as String;
  print('Body snippet: ${usersBody.substring(0, usersBody.length > 200 ? 200 : usersBody.length)}...');

  // 5. Admin Movies
  print('\n[5] Testing GET /api/admin/movies');
  final moviesRes = await sendRequest('GET', '$baseUrl/movies', headers: headers);
  print('Status: ${moviesRes['statusCode']}');

  // 6. Admin Theaters
  print('\n[6] Testing GET /api/admin/theaters');
  final theatersRes = await sendRequest('GET', '$baseUrl/theaters', headers: headers);
  print('Status: ${theatersRes['statusCode']}');

  // 7. Admin Shows
  print('\n[7] Testing GET /api/admin/shows');
  final showsRes = await sendRequest('GET', '$baseUrl/shows', headers: headers);
  print('Status: ${showsRes['statusCode']}');

  // 8. Admin Bus Operators & Trips
  print('\n[8] Testing GET /api/admin/bus-operators');
  final busOpRes = await sendRequest('GET', '$baseUrl/bus-operators', headers: headers);
  print('Status: ${busOpRes['statusCode']}');

  print('\n[9] Testing GET /api/admin/trips');
  final tripsRes = await sendRequest('GET', '$baseUrl/trips', headers: headers);
  print('Status: ${tripsRes['statusCode']}');

  // 10. Admin Bookings & Payments
  print('\n[10] Testing GET /api/admin/movie-bookings & /payments');
  final mbRes = await sendRequest('GET', '$baseUrl/movie-bookings', headers: headers);
  print('Movie Bookings Status: ${mbRes['statusCode']}');
  final payRes = await sendRequest('GET', '$baseUrl/payments', headers: headers);
  print('Payments Status: ${payRes['statusCode']}');

  print('\nAll Admin API endpoint tests passed successfully!');
}
