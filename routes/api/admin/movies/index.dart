import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/admin/admin_movie_service.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return AdminMovieService.listMovies(context);
    case HttpMethod.post:
      return AdminMovieService.createMovie(context);
    default:
      return Response(statusCode: 405);
  }
}
