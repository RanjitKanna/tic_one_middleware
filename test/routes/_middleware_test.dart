import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/_middleware.dart';

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

void main() {
  group('middlewaree', () {
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

      final handler = middleware((_) => Response());
      final response = await handler(context);

      expect(response.statusCode, equals(HttpStatus.noContent));
      expect(response.headers['Access-Control-Allow-Origin'], equals('*'));
    });

    test('adds CORS headers to standard response', () async {
      when(() => request.method).thenReturn(HttpMethod.get);
      when(() => request.uri).thenReturn(Uri.parse('http://localhost/test'));

      final handler = middleware((_) => Response.json(body: {'ok': true}));
      final response = await handler(context);

      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.headers['Access-Control-Allow-Origin'], equals('*'));
    });
  });
}
