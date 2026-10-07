// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/wallet/topup.dart' as wallet_topup;
import '../routes/wallet/royal-pass.dart' as wallet_royal_pass;
import '../routes/wallet/pay.dart' as wallet_pay;
import '../routes/wallet/index.dart' as wallet_index;
import '../routes/wallet/convert-points.dart' as wallet_convert_points;
import '../routes/theaters/index.dart' as theaters_index;
import '../routes/shows/[id]/seats.dart' as shows_$id_seats;
import '../routes/shows/[id]/lock-seats.dart' as shows_$id_lock_seats;
import '../routes/royal-pass/purchase.dart' as royal_pass_purchase;
import '../routes/royal-pass/index.dart' as royal_pass_index;
import '../routes/promos/validate.dart' as promos_validate;
import '../routes/promos/index.dart' as promos_index;
import '../routes/movies/index.dart' as movies_index;
import '../routes/movies/[id]/shows.dart' as movies_$id_shows;
import '../routes/movies/[id]/index.dart' as movies_$id_index;
import '../routes/home/index.dart' as home_index;
import '../routes/buses/search.dart' as buses_search;
import '../routes/buses/routes.dart' as buses_routes;
import '../routes/buses/recommend-seats.dart' as buses_recommend_seats;
import '../routes/buses/index.dart' as buses_index;
import '../routes/buses/cities.dart' as buses_cities;
import '../routes/buses/[busId]/seats.dart' as buses_$bus_id_seats;
import '../routes/buses/[busId]/recommend-seats.dart' as buses_$bus_id_recommend_seats;
import '../routes/buses/[busId]/index.dart' as buses_$bus_id_index;
import '../routes/buses/[busId]/hold-seats.dart' as buses_$bus_id_hold_seats;
import '../routes/buses/[busId]/dropping-points.dart' as buses_$bus_id_dropping_points;
import '../routes/buses/[busId]/boarding-points.dart' as buses_$bus_id_boarding_points;
import '../routes/bus-promos/validate.dart' as bus_promos_validate;
import '../routes/bus-promos/index.dart' as bus_promos_index;
import '../routes/bus-payments/verify.dart' as bus_payments_verify;
import '../routes/bus-payments/create.dart' as bus_payments_create;
import '../routes/bus-payments/[paymentId].dart' as bus_payments_$payment_id;
import '../routes/bus-bookings/index.dart' as bus_bookings_index;
import '../routes/bus-bookings/hold-seats.dart' as bus_bookings_hold_seats;
import '../routes/bus-bookings/[bookingId]/refund.dart' as bus_bookings_$booking_id_refund;
import '../routes/bus-bookings/[bookingId]/index.dart' as bus_bookings_$booking_id_index;
import '../routes/bus-bookings/[bookingId]/cancel.dart' as bus_bookings_$booking_id_cancel;
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
import '../routes/api/admin/users/index.dart' as api_admin_users_index;
import '../routes/api/admin/users/[id]/index.dart' as api_admin_users_$id_index;
import '../routes/api/admin/users/[id]/bookings.dart' as api_admin_users_$id_bookings;
import '../routes/api/admin/trips/index.dart' as api_admin_trips_index;
import '../routes/api/admin/trips/[id]/index.dart' as api_admin_trips_$id_index;
import '../routes/api/admin/theaters/index.dart' as api_admin_theaters_index;
import '../routes/api/admin/theaters/[id]/index.dart' as api_admin_theaters_$id_index;
import '../routes/api/admin/shows/index.dart' as api_admin_shows_index;
import '../routes/api/admin/shows/[id]/index.dart' as api_admin_shows_$id_index;
import '../routes/api/admin/seats/index.dart' as api_admin_seats_index;
import '../routes/api/admin/seats/batch.dart' as api_admin_seats_batch;
import '../routes/api/admin/seats/[id]/index.dart' as api_admin_seats_$id_index;
import '../routes/api/admin/screens/index.dart' as api_admin_screens_index;
import '../routes/api/admin/screens/[id]/index.dart' as api_admin_screens_$id_index;
import '../routes/api/admin/routes/index.dart' as api_admin_routes_index;
import '../routes/api/admin/routes/[id]/index.dart' as api_admin_routes_$id_index;
import '../routes/api/admin/refunds/index.dart' as api_admin_refunds_index;
import '../routes/api/admin/payments/index.dart' as api_admin_payments_index;
import '../routes/api/admin/movies/index.dart' as api_admin_movies_index;
import '../routes/api/admin/movies/[id]/index.dart' as api_admin_movies_$id_index;
import '../routes/api/admin/movie-bookings/index.dart' as api_admin_movie_bookings_index;
import '../routes/api/admin/movie-bookings/[id]/index.dart' as api_admin_movie_bookings_$id_index;
import '../routes/api/admin/movie-bookings/[id]/cancel.dart' as api_admin_movie_bookings_$id_cancel;
import '../routes/api/admin/dropping-points/index.dart' as api_admin_dropping_points_index;
import '../routes/api/admin/dashboard/index.dart' as api_admin_dashboard_index;
import '../routes/api/admin/cities/index.dart' as api_admin_cities_index;
import '../routes/api/admin/buses/index.dart' as api_admin_buses_index;
import '../routes/api/admin/buses/[id]/seats.dart' as api_admin_buses_$id_seats;
import '../routes/api/admin/buses/[id]/index.dart' as api_admin_buses_$id_index;
import '../routes/api/admin/bus-operators/index.dart' as api_admin_bus_operators_index;
import '../routes/api/admin/bus-operators/[id]/index.dart' as api_admin_bus_operators_$id_index;
import '../routes/api/admin/bus-bookings/index.dart' as api_admin_bus_bookings_index;
import '../routes/api/admin/bus-bookings/[id]/index.dart' as api_admin_bus_bookings_$id_index;
import '../routes/api/admin/bus-bookings/[id]/cancel.dart' as api_admin_bus_bookings_$id_cancel;
import '../routes/api/admin/boarding-points/index.dart' as api_admin_boarding_points_index;
import '../routes/api/admin/auth/me.dart' as api_admin_auth_me;
import '../routes/api/admin/auth/logout.dart' as api_admin_auth_logout;
import '../routes/api/admin/auth/login.dart' as api_admin_auth_login;
import '../routes/api/admin/audit-logs/index.dart' as api_admin_audit_logs_index;

import '../routes/_middleware.dart' as middleware;

void main() async {
  final address = InternetAddress.anyIPv4;
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
    ..mount('/royal-pass', (context) => buildRoyalPassHandler()(context))
    ..mount('/promos', (context) => buildPromosHandler()(context))
    ..mount('/movies', (context) => buildMoviesHandler()(context))
    ..mount('/movies/<id>', (context,id,) => buildMovies$idHandler(id,)(context))
    ..mount('/home', (context) => buildHomeHandler()(context))
    ..mount('/buses', (context) => buildBusesHandler()(context))
    ..mount('/buses/<busId>', (context,busId,) => buildBuses$busIdHandler(busId,)(context))
    ..mount('/bus-promos', (context) => buildBusPromosHandler()(context))
    ..mount('/bus-payments', (context) => buildBusPaymentsHandler()(context))
    ..mount('/bus-bookings', (context) => buildBusBookingsHandler()(context))
    ..mount('/bus-bookings/<bookingId>', (context,bookingId,) => buildBusBookings$bookingIdHandler(bookingId,)(context))
    ..mount('/bookings', (context) => buildBookingsHandler()(context))
    ..mount('/bookings/<bookingCode>', (context,bookingCode,) => buildBookings$bookingCodeHandler(bookingCode,)(context))
    ..mount('/auth/register', (context) => buildAuthRegisterHandler()(context))
    ..mount('/auth/refresh-token', (context) => buildAuthRefreshTokenHandler()(context))
    ..mount('/auth/profile', (context) => buildAuthProfileHandler()(context))
    ..mount('/auth/logout', (context) => buildAuthLogoutHandler()(context))
    ..mount('/auth/login', (context) => buildAuthLoginHandler()(context))
    ..mount('/auth/forgot-password', (context) => buildAuthForgotPasswordHandler()(context))
    ..mount('/api/admin/users', (context) => buildApiAdminUsersHandler()(context))
    ..mount('/api/admin/users/<id>', (context,id,) => buildApiAdminUsers$idHandler(id,)(context))
    ..mount('/api/admin/trips', (context) => buildApiAdminTripsHandler()(context))
    ..mount('/api/admin/trips/<id>', (context,id,) => buildApiAdminTrips$idHandler(id,)(context))
    ..mount('/api/admin/theaters', (context) => buildApiAdminTheatersHandler()(context))
    ..mount('/api/admin/theaters/<id>', (context,id,) => buildApiAdminTheaters$idHandler(id,)(context))
    ..mount('/api/admin/shows', (context) => buildApiAdminShowsHandler()(context))
    ..mount('/api/admin/shows/<id>', (context,id,) => buildApiAdminShows$idHandler(id,)(context))
    ..mount('/api/admin/seats', (context) => buildApiAdminSeatsHandler()(context))
    ..mount('/api/admin/seats/<id>', (context,id,) => buildApiAdminSeats$idHandler(id,)(context))
    ..mount('/api/admin/screens', (context) => buildApiAdminScreensHandler()(context))
    ..mount('/api/admin/screens/<id>', (context,id,) => buildApiAdminScreens$idHandler(id,)(context))
    ..mount('/', (context) => buildHandler()(context))
    ..mount('/<id>', (context,id,) => build$idHandler(id,)(context))
    ..mount('/api/admin/refunds', (context) => buildApiAdminRefundsHandler()(context))
    ..mount('/api/admin/payments', (context) => buildApiAdminPaymentsHandler()(context))
    ..mount('/api/admin/movies', (context) => buildApiAdminMoviesHandler()(context))
    ..mount('/api/admin/movies/<id>', (context,id,) => buildApiAdminMovies$idHandler(id,)(context))
    ..mount('/api/admin/movie-bookings', (context) => buildApiAdminMovieBookingsHandler()(context))
    ..mount('/api/admin/movie-bookings/<id>', (context,id,) => buildApiAdminMovieBookings$idHandler(id,)(context))
    ..mount('/api/admin/dropping-points', (context) => buildApiAdminDroppingPointsHandler()(context))
    ..mount('/api/admin/dashboard', (context) => buildApiAdminDashboardHandler()(context))
    ..mount('/api/admin/cities', (context) => buildApiAdminCitiesHandler()(context))
    ..mount('/api/admin/buses', (context) => buildApiAdminBusesHandler()(context))
    ..mount('/api/admin/buses/<id>', (context,id,) => buildApiAdminBuses$idHandler(id,)(context))
    ..mount('/api/admin/bus-operators', (context) => buildApiAdminBusOperatorsHandler()(context))
    ..mount('/api/admin/bus-operators/<id>', (context,id,) => buildApiAdminBusOperators$idHandler(id,)(context))
    ..mount('/api/admin/bus-bookings', (context) => buildApiAdminBusBookingsHandler()(context))
    ..mount('/api/admin/bus-bookings/<id>', (context,id,) => buildApiAdminBusBookings$idHandler(id,)(context))
    ..mount('/api/admin/boarding-points', (context) => buildApiAdminBoardingPointsHandler()(context))
    ..mount('/api/admin/auth', (context) => buildApiAdminAuthHandler()(context))
    ..mount('/api/admin/audit-logs', (context) => buildApiAdminAuditLogsHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildWalletHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/convert-points', (context) => wallet_convert_points.onRequest(context,))..all('/pay', (context) => wallet_pay.onRequest(context,))..all('/royal-pass', (context) => wallet_royal_pass.onRequest(context,))..all('/topup', (context) => wallet_topup.onRequest(context,))..all('/', (context) => wallet_index.onRequest(context,));
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

Handler buildRoyalPassHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/purchase', (context) => royal_pass_purchase.onRequest(context,))..all('/', (context) => royal_pass_index.onRequest(context,));
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
    ..all('/', (context) => movies_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildMovies$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/shows', (context) => movies_$id_shows.onRequest(context,id,))..all('/', (context) => movies_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildHomeHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => home_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildBusesHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/cities', (context) => buses_cities.onRequest(context,))..all('/recommend-seats', (context) => buses_recommend_seats.onRequest(context,))..all('/routes', (context) => buses_routes.onRequest(context,))..all('/search', (context) => buses_search.onRequest(context,))..all('/', (context) => buses_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildBuses$busIdHandler(String busId,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/boarding-points', (context) => buses_$bus_id_boarding_points.onRequest(context,busId,))..all('/dropping-points', (context) => buses_$bus_id_dropping_points.onRequest(context,busId,))..all('/hold-seats', (context) => buses_$bus_id_hold_seats.onRequest(context,busId,))..all('/recommend-seats', (context) => buses_$bus_id_recommend_seats.onRequest(context,busId,))..all('/seats', (context) => buses_$bus_id_seats.onRequest(context,busId,))..all('/', (context) => buses_$bus_id_index.onRequest(context,busId,));
  return pipeline.addHandler(router);
}

Handler buildBusPromosHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/validate', (context) => bus_promos_validate.onRequest(context,))..all('/', (context) => bus_promos_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildBusPaymentsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/create', (context) => bus_payments_create.onRequest(context,))..all('/verify', (context) => bus_payments_verify.onRequest(context,))..all('/<paymentId>', (context,paymentId,) => bus_payments_$payment_id.onRequest(context,paymentId,));
  return pipeline.addHandler(router);
}

Handler buildBusBookingsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/hold-seats', (context) => bus_bookings_hold_seats.onRequest(context,))..all('/', (context) => bus_bookings_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildBusBookings$bookingIdHandler(String bookingId,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/cancel', (context) => bus_bookings_$booking_id_cancel.onRequest(context,bookingId,))..all('/refund', (context) => bus_bookings_$booking_id_refund.onRequest(context,bookingId,))..all('/', (context) => bus_bookings_$booking_id_index.onRequest(context,bookingId,));
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

Handler buildApiAdminUsersHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_users_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminUsers$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/bookings', (context) => api_admin_users_$id_bookings.onRequest(context,id,))..all('/', (context) => api_admin_users_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminTripsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_trips_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminTrips$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_trips_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminTheatersHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_theaters_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminTheaters$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_theaters_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminShowsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_shows_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminShows$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_shows_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminSeatsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/batch', (context) => api_admin_seats_batch.onRequest(context,))..all('/', (context) => api_admin_seats_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminSeats$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_seats_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminScreensHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_screens_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminScreens$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_screens_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/api/admin/routes', (context) => api_admin_routes_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler build$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_routes_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminRefundsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_refunds_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminPaymentsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_payments_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminMoviesHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_movies_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminMovies$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_movies_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminMovieBookingsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_movie_bookings_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminMovieBookings$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/cancel', (context) => api_admin_movie_bookings_$id_cancel.onRequest(context,id,))..all('/', (context) => api_admin_movie_bookings_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminDroppingPointsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_dropping_points_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminDashboardHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_dashboard_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminCitiesHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_cities_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminBusesHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_buses_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminBuses$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/seats', (context) => api_admin_buses_$id_seats.onRequest(context,id,))..all('/', (context) => api_admin_buses_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminBusOperatorsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_bus_operators_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminBusOperators$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_bus_operators_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminBusBookingsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_bus_bookings_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminBusBookings$idHandler(String id,) {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/cancel', (context) => api_admin_bus_bookings_$id_cancel.onRequest(context,id,))..all('/', (context) => api_admin_bus_bookings_$id_index.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminBoardingPointsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_boarding_points_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminAuthHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/login', (context) => api_admin_auth_login.onRequest(context,))..all('/logout', (context) => api_admin_auth_logout.onRequest(context,))..all('/me', (context) => api_admin_auth_me.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiAdminAuditLogsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_admin_audit_logs_index.onRequest(context,));
  return pipeline.addHandler(router);
}

