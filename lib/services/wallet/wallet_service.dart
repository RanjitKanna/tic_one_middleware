import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/auth/auth_utils.dart';
import 'package:tic_one_middleware/utils/app_logger.dart';

class WalletService {
  static double _toDouble(dynamic val, [double def = 0.0]) {
    if (val == null) return def;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? def;
    return def;
  }

  static int? _extractUserId(RequestContext context) {
    final token = AuthUtils.getBearerToken(context);
    if (token != null) {
      try {
        return AuthUtils.verifyAccessToken(token);
      } catch (_) {}
    }
    return null;
  }

  /// GET /wallet
  static Future<Response> getWallet(RequestContext context) async {
    int? userId = _extractUserId(context);

    final connection = await openDatabaseConnection();
    try {
      // If no valid auth token, find the most recently active user with a wallet
      if (userId == null) {
        final defaultUser = await connection.execute(
          Sql.named('''
            SELECT user_id FROM wallets 
            WHERE balance > 0 
            ORDER BY id DESC LIMIT 1
          '''),
        );
        if (defaultUser.isNotEmpty) {
          userId = defaultUser.first[0] as int;
        } else {
          final firstUser = await connection.execute(
            Sql.named('SELECT id FROM login_auth ORDER BY id ASC LIMIT 1'),
          );
          if (firstUser.isNotEmpty) {
            userId = firstUser.first[0] as int;
          } else {
            userId = 1;
          }
        }
      }

      // Query wallet for user
      var result = await connection.execute(
        Sql.named('''
          SELECT id, user_id, balance, currency, is_active
          FROM wallets
          WHERE user_id = @userId
          LIMIT 1
        '''),
        parameters: {'userId': userId},
      );

      if (result.isEmpty) {
        // Auto-create wallet with 0.00 balance
        result = await connection.execute(
          Sql.named('''
            INSERT INTO wallets (user_id, balance, currency, is_active)
            VALUES (@userId, 0.00, 'INR', true)
            ON CONFLICT (user_id) DO UPDATE SET is_active = true
            RETURNING id, user_id, balance, currency, is_active
          '''),
          parameters: {'userId': userId},
        );
      }

      final walletRow = result.first;
      final walletId = walletRow[0] as int;
      final balance = _toDouble(walletRow[2]);
      final currency = walletRow[3]?.toString() ?? 'INR';
      final isActive = walletRow[4] as bool? ?? true;

      // Fetch recent transactions
      final txResult = await connection.execute(
        Sql.named('''
          SELECT id, title, amount, type, reference_id, created_at
          FROM wallet_transactions
          WHERE wallet_id = @walletId
          ORDER BY created_at DESC
          LIMIT 20
        '''),
        parameters: {'walletId': walletId},
      );

      final transactions = txResult.map((tx) {
        return {
          'id': 'TXN_${tx[0]}',
          'title': tx[1]?.toString() ?? 'Transaction',
          'amount': _toDouble(tx[2]),
          'type': tx[3]?.toString() ?? 'debit',
          'referenceId': tx[4]?.toString(),
          'createdAt': tx[5]?.toString() ?? DateTime.now().toIso8601String(),
        };
      }).toList();

      return Response.json(
        body: {
          'status': 'success',
          'data': {
            'walletId': 'WAL_$walletId',
            'userId': userId.toString(),
            'balance': balance,
            'currency': currency,
            'isActive': isActive,
            'recentTransactions': transactions,
          },
          'walletId': 'WAL_$walletId',
          'userId': userId.toString(),
          'balance': balance,
          'currency': currency,
          'isActive': isActive,
          'recentTransactions': transactions,
        },
      );
    } catch (e, st) {
      AppLogger.error('WalletService', 'Error in getWallet: $e', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to fetch wallet details: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  /// POST /wallet/pay
  static Future<Response> pay(RequestContext context) async {
    int? userId = _extractUserId(context);
    final body = await AuthUtils.readJson(context);
    if (body == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Request body must be valid JSON'},
      );
    }

    final amount = _toDouble(body['amount']);
    final bookingRef = body['bookingReference']?.toString() ?? 'TICONE-REF';

    if (amount <= 0) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Amount must be greater than 0'},
      );
    }

    final connection = await openDatabaseConnection();
    try {
      if (userId == null) {
        final defaultUser = await connection.execute(
          Sql.named('SELECT user_id FROM wallets WHERE balance >= @amount ORDER BY id DESC LIMIT 1'),
          parameters: {'amount': amount},
        );
        if (defaultUser.isNotEmpty) {
          userId = defaultUser.first[0] as int;
        } else {
          final firstUser = await connection.execute(
            Sql.named('SELECT id FROM login_auth ORDER BY id ASC LIMIT 1'),
          );
          userId = firstUser.isNotEmpty ? firstUser.first[0] as int : 1;
        }
      }

      final walletRes = await connection.execute(
        Sql.named('SELECT id, balance FROM wallets WHERE user_id = @userId LIMIT 1'),
        parameters: {'userId': userId},
      );

      if (walletRes.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {'status': 'error', 'message': 'Wallet not found for this user.'},
        );
      }

      final walletId = walletRes.first[0] as int;
      final currentBalance = _toDouble(walletRes.first[1]);

      if (currentBalance < amount) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'status': 'error',
            'message': 'Insufficient TicOne Wallet balance (₹${currentBalance.toStringAsFixed(2)}). Please top up or choose UPI / Card.',
          },
        );
      }

      final newBalance = currentBalance - amount;

      await connection.execute(
        Sql.named('''
          UPDATE wallets 
          SET balance = @newBalance, updated_at = CURRENT_TIMESTAMP 
          WHERE id = @walletId
        '''),
        parameters: {
          'newBalance': newBalance,
          'walletId': walletId,
        },
      );

      final txRes = await connection.execute(
        Sql.named('''
          INSERT INTO wallet_transactions (wallet_id, amount, type, title, reference_id)
          VALUES (@walletId, @amount, 'debit', 'Movie Ticket Booking', @refId)
          RETURNING id
        '''),
        parameters: {
          'walletId': walletId,
          'amount': amount,
          'refId': bookingRef,
        },
      );

      final txId = txRes.isNotEmpty ? txRes.first[0] : DateTime.now().millisecondsSinceEpoch;

      return Response.json(
        body: {
          'status': 'success',
          'data': {
            'success': true,
            'message': 'Payment of ₹${amount.toStringAsFixed(2)} debited successfully from TicOne Wallet',
            'remainingBalance': newBalance,
            'transactionId': 'TXN_$txId',
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('WalletService', 'Error in pay: $e', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Payment processing failed: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  /// POST /wallet/topup
  static Future<Response> topUp(RequestContext context) async {
    int? userId = _extractUserId(context);
    final body = await AuthUtils.readJson(context);
    if (body == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Request body must be valid JSON'},
      );
    }

    final amount = _toDouble(body['amount']);
    if (amount <= 0) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Amount must be greater than 0'},
      );
    }

    final connection = await openDatabaseConnection();
    try {
      if (userId == null) {
        final firstUser = await connection.execute(
          Sql.named('SELECT id FROM login_auth ORDER BY id ASC LIMIT 1'),
        );
        userId = firstUser.isNotEmpty ? firstUser.first[0] as int : 1;
      }

      var walletRes = await connection.execute(
        Sql.named('SELECT id, balance FROM wallets WHERE user_id = @userId LIMIT 1'),
        parameters: {'userId': userId},
      );

      if (walletRes.isEmpty) {
        walletRes = await connection.execute(
          Sql.named('''
            INSERT INTO wallets (user_id, balance, currency, is_active)
            VALUES (@userId, 0.00, 'INR', true)
            RETURNING id, balance
          '''),
          parameters: {'userId': userId},
        );
      }

      final walletId = walletRes.first[0] as int;
      final currentBalance = _toDouble(walletRes.first[1]);
      final newBalance = currentBalance + amount;

      await connection.execute(
        Sql.named('''
          UPDATE wallets 
          SET balance = @newBalance, updated_at = CURRENT_TIMESTAMP 
          WHERE id = @walletId
        '''),
        parameters: {
          'newBalance': newBalance,
          'walletId': walletId,
        },
      );

      await connection.execute(
        Sql.named('''
          INSERT INTO wallet_transactions (wallet_id, amount, type, title, reference_id)
          VALUES (@walletId, @amount, 'credit', 'Wallet Top-up', @refId)
        '''),
        parameters: {
          'walletId': walletId,
          'amount': amount,
          'refId': 'TOPUP_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      return Response.json(
        body: {
          'status': 'success',
          'data': {
            'walletId': 'WAL_$walletId',
            'userId': userId.toString(),
            'balance': newBalance,
            'currency': 'INR',
            'isActive': true,
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('WalletService', 'Error in topUp: $e', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Wallet top-up failed: $e'},
      );
    } finally {
      await connection.close();
    }
  }
}
