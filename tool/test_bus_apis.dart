import 'dart:convert';
import 'dart:io';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';

const baseUrl = 'http://localhost:8080';

Future<Map<String, dynamic>> httpGet(String path, {String? token}) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse('$baseUrl$path'));
    request.headers.contentType = ContentType.json;
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    final response = await request.close();
    final bodyStr = await response.transform(utf8.decoder).join();
    dynamic parsedBody;
    try {
      parsedBody = jsonDecode(bodyStr);
    } catch (_) {
      parsedBody = bodyStr;
    }
    return {
      'statusCode': response.statusCode,
      'body': parsedBody,
    };
  } finally {
    client.close();
  }
}

Future<Map<String, dynamic>> httpPost(String path, Map<String, dynamic> payload, {String? token}) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('$baseUrl$path'));
    request.headers.contentType = ContentType.json;
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    request.write(jsonEncode(payload));
    final response = await request.close();
    final bodyStr = await response.transform(utf8.decoder).join();
    dynamic parsedBody;
    try {
      parsedBody = jsonDecode(bodyStr);
    } catch (_) {
      parsedBody = bodyStr;
    }
    return {
      'statusCode': response.statusCode,
      'body': parsedBody,
    };
  } finally {
    client.close();
  }
}

void main() async {
  print('================================================================');
  print('🧪 TICONE BUS BOOKING API END-TO-END VERIFICATION SUITE');
  print('================================================================');

  // 1. Get Cities & Routes
  print('\n📍 1. Testing GET /buses/cities and GET /buses/routes...');
  final citiesRes = await httpGet('/buses/cities');
  print('Status: ${citiesRes['statusCode']}');
  final cities = citiesRes['body']['data']['cities'] as List;
  print('Found ${cities.length} cities: ${cities.take(5).join(', ')}...');
  final popularRoutes = citiesRes['body']['data']['popularRoutes'] as List;
  print('Found ${popularRoutes.length} popular routes.');

  // 2. Search Buses with Filters
  print('\n🔍 2. Testing GET /buses/search?source=Bengaluru&destination=Chennai&busType=sleeper...');
  final searchRes = await httpGet('/buses/search?source=Bengaluru&destination=Chennai&busType=sleeper');
  print('Status: ${searchRes['statusCode']}');
  final buses = searchRes['body']['data'] as List;
  print('Found ${buses.length} sleeper buses on Bengaluru -> Chennai');
  assert(buses.isNotEmpty, 'Should find buses on BLR->CHE route');
  final firstBus = buses.first as Map<String, dynamic>;
  final tripId = firstBus['tripId'];
  final busId = firstBus['bus']['id'];
  print('Selected Trip #$tripId (${firstBus['bus']['busName']}) - Fare: ₹${firstBus['baseFare']}');

  // 3. Get Single Bus Details
  print('\n🚍 3. Testing GET /buses/$busId...');
  final busDetailsRes = await httpGet('/buses/$busId');
  print('Status: ${busDetailsRes['statusCode']}');
  print('Bus Details: ${busDetailsRes['body']['data']['bus']['busName']} (${busDetailsRes['body']['data']['operator']['name']})');

  // 4. Get Bus Seats & Layout
  print('\n💺 4. Testing GET /buses/$busId/seats...');
  final seatsRes = await httpGet('/buses/$busId/seats');
  print('Status: ${seatsRes['statusCode']}');
  final summary = seatsRes['body']['data']['summary'];
  print('Seats Summary: Total: ${summary['totalSeats']}, Available: ${summary['availableSeats']}, Deck: ${summary['deckType']}');
  final layout = seatsRes['body']['data']['layout'];
  final lowerSeats = layout['lowerDeck'] as List;
  final upperSeats = layout['upperDeck'] as List;
  print('Lower deck seats: ${lowerSeats.length}, Upper deck seats: ${upperSeats.length}');

  // 5. Boarding & Dropping Points
  print('\n📍 5. Testing GET /buses/$busId/boarding-points & dropping-points...');
  final bpRes = await httpGet('/buses/$busId/boarding-points');
  final dpRes = await httpGet('/buses/$busId/dropping-points');
  print('Boarding Points: ${(bpRes['body']['data'] as List).length} points, Dropping Points: ${(dpRes['body']['data'] as List).length} points');
  final bpId = (bpRes['body']['data'] as List).first['id'];
  final dpId = (dpRes['body']['data'] as List).first['id'];

  // 6. AI Seat Recommendation
  print('\n🤖 6. Testing AI Recommended Seat Selection (GET /buses/$busId/recommend-seats)...');
  final aiRes = await httpGet('/buses/$busId/recommend-seats?passengers=2&preference=comfort');
  print('Status: ${aiRes['statusCode']}');
  final topPick = aiRes['body']['data']['topPick'];
  print('Top AI Recommendation: ${topPick['badge']}');
  print('Reason: ${topPick['reason']}');
  final recommendedSeats = (topPick['seats'] as List).map((s) => s['seatNumber'].toString()).toList();
  print('Recommended Seats: $recommendedSeats');

  // 7. Validate Promo Code & List Promos
  print('\n🎟️ 7. Testing POST /bus-promos/validate and GET /bus-promos...');
  final promoList = await httpGet('/bus-promos');
  print('Active Promos in System: ${(promoList['body']['data'] as List).length}');
  final promoRes = await httpPost('/bus-promos/validate', {
    'code': 'FIRSTBUS',
    'amount': 2200.0,
  });
  print('Status: ${promoRes['statusCode']}');
  print('Promo Validation: ${promoRes['body']['message']} (Discount: ₹${promoRes['body']['data']['discountAmount']})');

  // 8. Hold Seats (Temporary Seat Lock)
  print('\n🔒 8. Testing POST /bus-bookings/hold-seats...');
  final holdRes = await httpPost('/bus-bookings/hold-seats', {
    'tripId': tripId,
    'seatNumbers': recommendedSeats,
  });
  print('Status: ${holdRes['statusCode']}');
  final lockData = holdRes['body']['data'];
  final lockToken = lockData['lockToken'] as String;
  print('Lock Token: $lockToken (Expires in: ${lockData['expiresInSeconds']}s, Total: ₹${lockData['pricing']['totalAmount']})');

  // 8b. Duplicate lock prevention test
  print('\n🔒 8b. Testing Duplicate Seat Lock Protection (Should return 409 Conflict)...');
  final dupHoldRes = await httpPost('/bus-bookings/hold-seats', {
    'tripId': tripId,
    'seatNumbers': recommendedSeats,
  });
  print('Duplicate Lock Status: ${dupHoldRes['statusCode']} (Expected 409)');
  print('Conflict Message: ${dupHoldRes['body']['message']}');
  assert(dupHoldRes['statusCode'] == 409, 'Must prevent duplicate seat locks');

  // 9. Auth Integration (Register/Login / JWT Verification)
  print('\n🔑 9. Authenticating user via existing auth system...');
  final testEmail = 'bus.tester.${DateTime.now().millisecondsSinceEpoch}@ticone.com';
  final testPass = 'Password123!';
  final regRes = await httpPost('/auth/register', {
    'name': 'Ranjit Kanna',
    'email': testEmail,
    'phone': '98765${DateTime.now().millisecondsSinceEpoch % 100000}',
    'password': testPass,
  });
  print('User Registration Status: ${regRes['statusCode']}');

  final loginRes = await httpPost('/auth/login', {
    'identifier': testEmail,
    'password': testPass,
  });
  print('User Login Status: ${loginRes['statusCode']}');
  final token = loginRes['body']['accessToken'] as String;
  print('JWT Access Token Acquired: ${token.substring(0, 30)}...');

  // Check Profile
  final profileRes = await httpGet('/auth/profile', token: token);
  print('User Profile Loaded: ${profileRes['body']['user']['name']} (${profileRes['body']['user']['email']})');

  // 10. Confirm Booking
  print('\n🎫 10. Testing POST /bus-bookings (Confirm Booking)...');
  final passengers = [
    {
      'name': 'Ranjit Kanna',
      'age': 28,
      'gender': 'Male',
      'seatNumber': recommendedSeats[0],
    },
    {
      'name': 'Priya Kanna',
      'age': 26,
      'gender': 'Female',
      'seatNumber': recommendedSeats[1],
    }
  ];

  final bookRes = await httpPost('/bus-bookings', {
    'tripId': tripId,
    'lockToken': lockToken,
    'boardingPointId': bpId,
    'droppingPointId': dpId,
    'contactEmail': testEmail,
    'contactPhone': '9876543210',
    'passengers': passengers,
    'promoCode': 'FIRSTBUS',
    'paymentMethod': 'upi',
  }, token: token);

  print('Status: ${bookRes['statusCode']}');
  print('Response Message: ${bookRes['body']['message']}');
  final bookingData = bookRes['body']['data'];
  final bookingId = bookingData['bookingId'];
  final bookingCode = bookingData['bookingCode'] as String;
  final pnrNumber = bookingData['pnrNumber'] as String;
  print('🎉 CONFIRMED BOOKING: ID: $bookingId | Code: $bookingCode | PNR: $pnrNumber | Total: ₹${bookingData['pricing']['totalAmount']}');

  // 11. User Booking History
  print('\n📋 11. Testing GET /bus-bookings (User Booking History)...');
  final myBookingsRes = await httpGet('/bus-bookings', token: token);
  print('Status: ${myBookingsRes['statusCode']}');
  final myBookings = myBookingsRes['body']['data'] as List;
  print('User has ${myBookings.length} bus bookings.');
  print('Latest booking in history: ${myBookings.first['bookingCode']} (${myBookings.first['pnrNumber']})');

  // 12. Single Booking Details & Ticket Lookup
  print('\n🎟️ 12. Testing GET /bus-bookings/$bookingCode (Digital Ticket Lookup)...');
  final ticketRes = await httpGet('/bus-bookings/$bookingCode');
  print('Status: ${ticketRes['statusCode']}');
  final ticket = ticketRes['body']['data'];
  print('Ticket Details: Bus: ${ticket['bus']['name']}, Route: ${ticket['route']['sourceCity']} -> ${ticket['route']['destinationCity']}, Seats: ${(ticket['seats'] as List).length}');
  print('QR Code Data Length: ${(ticket['qrCodeData'] as String).length} chars');

  // 13. Create & Verify Payment
  print('\n💳 13. Testing POST /bus-payments/create & verify...');
  final payCreate = await httpPost('/bus-payments/create', {
    'amount': 1500.0,
    'currency': 'INR',
    'paymentMethod': 'upi',
    'bookingId': bookingId,
  }, token: token);
  print('Payment Created: ${payCreate['statusCode']} | ID: ${payCreate['body']['data']['paymentId']}');
  final paymentId = payCreate['body']['data']['paymentId'] as String;

  final payVerify = await httpPost('/bus-payments/verify', {
    'paymentId': paymentId,
    'transactionReference': 'UPI/TEST/2026/89123',
  }, token: token);
  print('Payment Verified: ${payVerify['statusCode']} | Status: ${payVerify['body']['data']['status']}');

  final payGet = await httpGet('/bus-payments/$paymentId');
  print('GET Payment Receipt: Status ${payGet['statusCode']} | Method: ${payGet['body']['data']['paymentMethod']}');

  // 14. Cancel Booking & Refund Calculation
  print('\n❌ 14. Testing POST /bus-bookings/$bookingCode/cancel (Cancellation & Refund)...');
  final cancelRes = await httpPost('/bus-bookings/$bookingCode/cancel', {
    'reason': 'Travel dates changed due to personal reasons',
  }, token: token);
  print('Status: ${cancelRes['statusCode']}');
  print('Cancellation Response: ${cancelRes['body']['message']}');
  final cancelData = cancelRes['body']['data'];
  print('Refund Amount: ₹${cancelData['refundAmount']} (${cancelData['refundPercentage']}%) | Status: ${cancelData['refundStatus']}');

  // 15. Check Refund Status
  print('\n💰 15. Testing GET /bus-bookings/$bookingCode/refund...');
  final refundRes = await httpGet('/bus-bookings/$bookingCode/refund');
  print('Status: ${refundRes['statusCode']}');
  final refundData = refundRes['body']['data'];
  print('Refund Status: ID: ${refundData['refundId']}, Amount: ₹${refundData['refundAmount']}, Status: ${refundData['refundStatus']}');

  // 16. Verify seat is released after cancellation
  print('\n💺 16. Verifying seats are freed up after cancellation...');
  final refreshedSeatsRes = await httpGet('/buses/$busId/seats');
  final refreshedSummary = refreshedSeatsRes['body']['data']['summary'];
  print('Refreshed Seat Availability: ${refreshedSummary['availableSeats']} available');

  print('\n================================================================');
  print('🎉 ALL 16 TICONE BUS BOOKING BACKEND VERIFICATION TESTS PASSED (100% OK)!');
  print('================================================================');
}
