import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return execute();

    default:
      return Response.json(
        statusCode: 405,
        body: {
          'success': false,
          'message': 'Method not allowed',
        },
      );
  }
}

Future<Response> execute() async {
  final db = await Database.connect();

  try {
    final result = await db.execute(
      'SELECT id, name, price, created_at '
      'FROM products ORDER BY id',
    );

    final products = result.map((row) {
      return {
        'id': row[0],
        'name': row[1],
        'price': row[2],
        'createdAt': row[3].toString(),
      };
    }).toList();

    return Response.json(
      body: {
        'success': true,
        'data': products,
      },
    );
  } finally {
    await db.close();
  }
}
