import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:tic_one_middleware/services/auth/auth_utils.dart';
import '../../routes/_middleware.dart';

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

void main() {
  group('middleware', () {
    late RequestContext context;
    late Request request;

    setUp(() {
      context = _MockRequestContext();
      request = _MockRequest();
      when(() => context.request).thenReturn(request);
    });

    test('handles OPTIONS request with CORS headers', () async {
      when(() => request.method).thenReturn(HttpMethod.options);
      when(() => request.uri).thenReturn(Uri.parse('http://localhost/test'));
      when(() => request.headers).thenReturn({});

      final handler = middleware((_) => Response());
      final response = await handler(context);

      expect(response.statusCode, equals(HttpStatus.noContent));
      expect(response.headers['Access-Control-Allow-Origin'], equals('*'));
    });

    void stubRequest(String path, {Map<String, String> headers = const {}}) {
      when(() => request.method).thenReturn(HttpMethod.get);
      when(() => request.uri).thenReturn(Uri.parse('http://localhost$path'));
      when(() => request.headers).thenReturn(headers);
    }

    FutureOr<Response> call(
      String path, {
      Map<String, String> headers = const {},
    }) {
      stubRequest(path, headers: headers);
      return middleware((_) => Response.json(body: {'ok': true}))(context);
    }

    final validToken = AuthUtils.createAccessToken(userId: 1, email: 'a@b.com');

    test('rejects protected route without token (401)', () async {
      for (final path in [
        '/home',
        '/movies',
        '/theaters',
        '/buses/search',
        '/promos/validate',
        '/bus-promos',
        '/wallet',
        '/api/admin/users',
      ]) {
        final response = await call(path);
        expect(response.statusCode, HttpStatus.unauthorized, reason: path);
      }
    });

    test('rejects malformed, tampered and non-access tokens', () async {
      for (final header in [
        'Bearer',
        'Bearer not.a.jwt',
        'Basic $validToken',
        'Bearer ${validToken}x',
      ]) {
        final response = await call(
          '/home',
          headers: {'authorization': header},
        );
        expect(response.statusCode, HttpStatus.unauthorized, reason: header);
      }
    });

    test('allows protected route with valid access token', () async {
      final response = await call(
        '/home',
        headers: {'authorization': 'Bearer $validToken'},
      );
      expect(response.statusCode, HttpStatus.ok);
      expect(response.headers['Access-Control-Allow-Origin'], equals('*'));
      expect(response.headers['Strict-Transport-Security'], isNotNull);
    });

    test('session endpoints stay public', () async {
      for (final path in [
        '/auth/login',
        '/auth/register',
        '/auth/refresh-token',
        '/auth/forgot-password',
        '/auth/logout',
        '/api/admin/auth/login',
        '/auth/login/',
      ]) {
        final response = await call(path);
        expect(response.statusCode, HttpStatus.ok, reason: path);
      }
    });

    test('redirects plain HTTP seen by the proxy to HTTPS', () async {
      final response = await call(
        '/home',
        headers: {
          'x-forwarded-proto': 'http',
          'host': 'api.example.com',
        },
      );
      expect(response.statusCode, HttpStatus.permanentRedirect);
      expect(response.headers['Location'], 'https://api.example.com/home');
    });
  });
}
