import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.post:
      return execute(context);

    // ignore: no_default_cases
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

Future<Response> execute(RequestContext context) async {
  final body = await context.request.json();

  final name = body['name'];
  final price = body['price'];

  if (name == null || price == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': 'name and price are required',
      },
    );
  }

  final db = await Database.connect();

  try {
    final result = await db.execute(
      Sql.named('''
          INSERT INTO products (name, price)
          VALUES (@name, @price)
          RETURNING id, name, price, created_at
        '''),
      parameters: {
        'name': name,
        'price': price,
      },
    );

    final row = result.first;

    return Response.json(
      statusCode: 201,
      body: {
        'success': true,
        'message': 'Product created successfully',
        'data': {
          'id': row[0],
          'name': row[1],
          'price': row[2],
          'createdAt': row[3].toString(),
        },
      },
    );
  } finally {
    await db.close();
  }
}
