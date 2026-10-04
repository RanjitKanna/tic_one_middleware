import 'package:dart_frog/dart_frog.dart';
import 'package:tic_one_middleware/services/admin/admin_movie_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return AdminMovieService.getMovie(context, id);
    case HttpMethod.put:
    case HttpMethod.patch:
      return AdminMovieService.updateMovie(context, id);
    case HttpMethod.delete:
      return AdminMovieService.deleteMovie(context, id);
    default:
      return Response(statusCode: 405);
  }
}
