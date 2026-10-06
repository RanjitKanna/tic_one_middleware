// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/wallet/topup.dart' as wallet_topup;
import '../routes/wallet/pay.dart' as wallet_pay;
import '../routes/wallet/index.dart' as wallet_index;
import '../routes/theaters/index.dart' as theaters_index;
import '../routes/shows/[id]/seats.dart' as shows_$id_seats;
import '../routes/shows/[id]/lock-seats.dart' as shows_$id_lock_seats;
import '../routes/promos/validate.dart' as promos_validate;
import '../routes/promos/index.dart' as promos_index;
import '../routes/movies/index.dart' as movies_index;
import '../routes/movies/[slug].dart' as movies_$slug;
import '../routes/movies/[id]/shows.dart' as movies_$id_shows;
import '../routes/home/index.dart' as home_index;
import '../routes/bookings/upcoming.dart' as bookings_upcoming;
import '../routes/bookings/past.dart' as bookings_past;
import '../routes/bookings/my-tickets.dart' as bookings_my_tickets;
import '../routes/bookings/create.dart' as bookings_create;
import '../routes/bookings/cancelled.dart' as bookings_cancelled;
import '../routes/bookings/cancel.dart' as bookings_cancel;
import '../routes/bookings/[bookingCode]/index.dart' as bookings_$booking_code_index;
import '../routes/bookings/[bookingCode]/cancel.dart' as bookings_$booking_code_cancel;
import '../routes/auth/register/index.dart' as auth_register_index;
import '../routes/auth/refresh-token/index.dart' as auth_refresh_token_index;
import '../routes/auth/profile/index.dart' as auth_profile_index;
import '../routes/auth/logout/index.dart' as auth_logout_index;
import '../routes/auth/login/index.dart' as auth_login_index;
import '../routes/auth/forgot-password/index.dart' as auth_forgot_password_index;

import '../routes/_middleware.dart' as middleware;

void main() async {
  final address = InternetAddress.anyIPv6;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  createServer(address, port);
}

Future<HttpServer> createServer(InternetAddress address, int port) async {
  final handler = Cascade().add(buildRootHandler()).handler;
  final server = await serve(handler, address, port);
  print('\x1B[92m✓\x1B[0m Running on http://${server.address.host}:${server.port}');
  return server;
}

Handler buildRootHandler() {
  final pipeline = const Pipeline().addMiddleware(middleware.middleware);
  final router = Router()
    ..mount('/wallet', (context) => buildWalletHandler()(context))
    ..mount('/theaters', (context) => buildTheatersHandler()(context))
    ..mount('/shows/<id>', (context,id,) => buildShows$idHandler(id,)(context))
    ..mount('/promos', (context) => buildPromosHandler()(context))
    ..mount('/movies', (context) => buildMoviesHandler()(context))
    ..mount('/movies/<id>', (context,id,) => buildMovies$idHandler(id,)(context))
    ..mount('/home', (context) => buildHomeHandler()(context))
    ..mount('/bookings', (context) => buildBookingsHandler()(context))
    ..mount('/bookings/<bookingCode>', (context,bookingCode,) => buildBookings$bookingCodeHandler(bookingCode,)(context))
    ..mount('/auth/register', (context) => buildAuthRegisterHandler()(context))
    ..mount('/auth/refresh-token', (context) => buildAuthRefreshTokenHandler()(context))
    ..mount('/auth/profile', (context) => buildAuthProfileHandler()(context))
    ..mount('/auth/logout', (context) => buildAuthLogoutHandler()(context))
    ..mount('/auth/login', (context) => buildAuthLoginHandler()(context))
    ..mount('/auth/forgot-password', (context) => buildAuthForgotPasswordHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildWalletHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/pay', (context) => wallet_pay.onRequest(context,))..all('/topup', (context) => wallet_topup.onRequest(context,))..all('/', (context) => wallet_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildTheatersHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => theaters_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildShows$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/lock-seats', (context) => shows_$id_lock_seats.onRequest(context,id,))..all('/seats', (context) => shows_$id_seats.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildPromosHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/validate', (context) => promos_validate.onRequest(context,))..all('/', (context) => promos_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildMoviesHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/<slug>', (context,slug,) => movies_$slug.onRequest(context,slug,))..all('/', (context) => movies_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildMovies$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/shows', (context) => movies_$id_shows.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildHomeHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => home_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildBookingsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/cancel', (context) => bookings_cancel.onRequest(context,))..all('/cancelled', (context) => bookings_cancelled.onRequest(context,))..all('/create', (context) => bookings_create.onRequest(context,))..all('/my-tickets', (context) => bookings_my_tickets.onRequest(context,))..all('/past', (context) => bookings_past.onRequest(context,))..all('/upcoming', (context) => bookings_upcoming.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildBookings$bookingCodeHandler(String bookingCode,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/cancel', (context) => bookings_$booking_code_cancel.onRequest(context,bookingCode,))..all('/', (context) => bookings_$booking_code_index.onRequest(context,bookingCode,));
  return pipeline.addHandler(router);
}

Handler buildAuthRegisterHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => auth_register_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAuthRefreshTokenHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => auth_refresh_token_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAuthProfileHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => auth_profile_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAuthLogoutHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => auth_logout_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAuthLoginHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => auth_login_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAuthForgotPasswordHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => auth_forgot_password_index.onRequest(context,));
  return pipeline.addHandler(router);
}

