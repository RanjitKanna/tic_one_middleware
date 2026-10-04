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

  static int _toInt(dynamic val, [int def = 0]) {
    if (val == null) return def;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? def;
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

  /// Ensure tables exist for user cinepoints and royal pass
  static Future<void> _ensureTables(Connection connection) async {
    try {
      await connection.execute('''
        CREATE TABLE IF NOT EXISTS user_royal_pass (
          id SERIAL PRIMARY KEY,
          user_id INT NOT NULL UNIQUE REFERENCES login_auth(id) ON DELETE CASCADE,
          membership_status VARCHAR(50) NOT NULL DEFAULT 'FREE_USER',
          plan_name VARCHAR(100) NOT NULL DEFAULT 'TicOne Royal Pass',
          price NUMERIC(10, 2) NOT NULL DEFAULT 600.00,
          start_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          expiry_date TIMESTAMP NOT NULL,
          is_active BOOLEAN NOT NULL DEFAULT TRUE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      ''');

      await connection.execute('''
        CREATE TABLE IF NOT EXISTS user_cinepoints (
          id SERIAL PRIMARY KEY,
          user_id INT NOT NULL UNIQUE,
          points INT DEFAULT 0,
          total_earned INT DEFAULT 0,
          total_redeemed INT DEFAULT 0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      ''');

      await connection.execute('''
        CREATE TABLE IF NOT EXISTS cinepoint_transactions (
          id SERIAL PRIMARY KEY,
          user_id INT NOT NULL,
          points INT NOT NULL,
          type VARCHAR(20) NOT NULL,
          title VARCHAR(150) NOT NULL,
          reference_id VARCHAR(100),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      ''');
    } catch (e) {
      AppLogger.warning('WalletService', 'Error ensuring tables: $e');
    }
  }

  /// Award CinePoints to a user (5 CinePoints per ticket booked)
  static Future<int> awardPoints(
    Connection connection,
    int userId,
    int pointsEarned,
    String title,
    String referenceId,
  ) async {
    if (pointsEarned <= 0) return 0;
    try {
      await _ensureTables(connection);

      await connection.execute(
        Sql.named('''
          INSERT INTO user_cinepoints (user_id, points, total_earned, total_redeemed)
          VALUES (@userId, @points, @points, 0)
          ON CONFLICT (user_id) DO UPDATE 
          SET points = user_cinepoints.points + @points,
              total_earned = user_cinepoints.total_earned + @points,
              updated_at = CURRENT_TIMESTAMP
        '''),
        parameters: {
          'userId': userId,
          'points': pointsEarned,
        },
      );

      await connection.execute(
        Sql.named('''
          INSERT INTO cinepoint_transactions (user_id, points, type, title, reference_id)
          VALUES (@userId, @points, 'earned', @title, @refId)
        '''),
        parameters: {
          'userId': userId,
          'points': pointsEarned,
          'title': title,
          'refId': referenceId,
        },
      );

      final ptsRes = await connection.execute(
        Sql.named('SELECT points FROM user_cinepoints WHERE user_id = @userId LIMIT 1'),
        parameters: {'userId': userId},
      );

      return ptsRes.isNotEmpty ? _toInt(ptsRes.first[0]) : pointsEarned;
    } catch (e) {
      AppLogger.warning('WalletService', 'Error awarding cinepoints: $e');
      return 0;
    }
  }

  /// Get CinePoints balance for a user
  static Future<int> getUserPoints(Connection connection, int userId) async {
    try {
      await _ensureTables(connection);
      final res = await connection.execute(
        Sql.named('SELECT points FROM user_cinepoints WHERE user_id = @userId LIMIT 1'),
        parameters: {'userId': userId},
      );
      if (res.isNotEmpty) {
        return _toInt(res.first[0]);
      }
    } catch (e) {
      AppLogger.warning('WalletService', 'Error getting user points: $e');
    }
    return 0;
  }

  /// Get Royal Pass / Premium User Membership Details for a User
  static Future<Map<String, dynamic>> getRoyalPass(Connection connection, int userId) async {
    try {
      await _ensureTables(connection);
      final res = await connection.execute(
        Sql.named('''
          SELECT membership_status, plan_name, price, start_date, expiry_date, is_active
          FROM user_royal_pass
          WHERE user_id = @userId
          LIMIT 1
        '''),
        parameters: {'userId': userId},
      );

      if (res.isEmpty) {
        return {
          'status': 'FREE_USER',
          'membershipStatus': 'FREE_USER',
          'planName': 'TicOne Royal Pass',
          'price': 600.00,
          'startDate': null,
          'expiryDate': null,
          'isActive': false,
          'isExpired': false,
          'daysRemaining': 0,
          'discountPercentage': 20.0,
        };
      }

      final row = res.first;
      final rawStatus = row[0]?.toString() ?? 'FREE_USER';
      final planName = row[1]?.toString() ?? 'TicOne Royal Pass';
      final price = _toDouble(row[2], 600.00);
      final startDate = row[3] is DateTime ? (row[3] as DateTime) : (row[3] != null ? DateTime.tryParse(row[3].toString()) : null);
      final expiryDate = row[4] is DateTime ? (row[4] as DateTime) : (row[4] != null ? DateTime.tryParse(row[4].toString()) : null);
      final isActiveRaw = (row[5] as bool?) ?? true;

      final now = DateTime.now();
      final isExpired = expiryDate == null || expiryDate.isBefore(now);
      final isPremium = rawStatus == 'PREMIUM_USER' && isActiveRaw && !isExpired;

      final daysRemaining = (isPremium && expiryDate != null)
          ? expiryDate.difference(now).inDays.clamp(0, 365)
          : 0;

      return {
        'status': isPremium ? 'PREMIUM_USER' : 'FREE_USER',
        'membershipStatus': isPremium ? 'PREMIUM_USER' : 'FREE_USER',
        'planName': planName,
        'price': price,
        'startDate': startDate?.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'isActive': isPremium,
        'isExpired': isExpired,
        'daysRemaining': daysRemaining,
        'discountPercentage': 20.0,
      };
    } catch (e) {
      AppLogger.warning('WalletService', 'Error fetching royal pass: $e');
      return {
        'status': 'FREE_USER',
        'membershipStatus': 'FREE_USER',
        'planName': 'TicOne Royal Pass',
        'price': 600.00,
        'startDate': null,
        'expiryDate': null,
        'isActive': false,
        'isExpired': false,
        'daysRemaining': 0,
        'discountPercentage': 20.0,
      };
    }
  }

  /// GET /wallet
  static Future<Response> getWallet(RequestContext context) async {
    int? userId = _extractUserId(context);

    final connection = await openDatabaseConnection();
    try {
      await _ensureTables(connection);

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
          userId = firstUser.isNotEmpty ? firstUser.first[0] as int : 1;
        }
      }

      var walletRes = await connection.execute(
        Sql.named('''
          SELECT id, balance, currency, is_active 
          FROM wallets 
          WHERE user_id = @userId 
          LIMIT 1
        '''),
        parameters: {'userId': userId},
      );

      if (walletRes.isEmpty) {
        walletRes = await connection.execute(
          Sql.named('''
            INSERT INTO wallets (user_id, balance, currency, is_active)
            VALUES (@userId, 0.00, 'INR', true)
            RETURNING id, balance, currency, is_active
          '''),
          parameters: {'userId': userId},
        );
      }

      final walletRow = walletRes.first;
      final walletId = walletRow[0] as int;
      final balance = _toDouble(walletRow[1]);
      final currency = walletRow[2]?.toString() ?? 'INR';
      final isActive = walletRow[3] as bool? ?? true;

      // Fetch user's CinePoints
      final cinepoints = await getUserPoints(connection, userId);
      final royalPass = await getRoyalPass(connection, userId);

      final txRes = await connection.execute(
        Sql.named('''
          SELECT id, title, amount, type, reference_id, created_at 
          FROM wallet_transactions 
          WHERE wallet_id = @walletId 
          ORDER BY id DESC 
          LIMIT 20
        '''),
        parameters: {'walletId': walletId},
      );

      final transactions = txRes.map((tx) {
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
            'cinepoints': cinepoints,
            'cinepointsBalance': cinepoints,
            'conversionRate': 0.5,
            'recentTransactions': transactions,
            'royalPass': royalPass,
            'membership': royalPass,
          },
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

  /// GET /wallet/royal-pass or /royal-pass/status
  static Future<Response> getRoyalPassStatus(RequestContext context) async {
    int? userId = _extractUserId(context);
    final connection = await openDatabaseConnection();
    try {
      if (userId == null) {
        final firstUser = await connection.execute(
          Sql.named('SELECT id FROM login_auth ORDER BY id ASC LIMIT 1'),
        );
        userId = firstUser.isNotEmpty ? firstUser.first[0] as int : 1;
      }

      final royalPass = await getRoyalPass(connection, userId);
      return Response.json(
        body: {
          'status': 'success',
          'data': royalPass,
        },
      );
    } catch (e, st) {
      AppLogger.error('WalletService', 'Error in getRoyalPassStatus: $e', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to retrieve Royal Pass status: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  /// POST /wallet/royal-pass or /wallet (purchase_royal_pass)
  static Future<Response> purchaseRoyalPass(RequestContext context) async {
    int? userId = _extractUserId(context);
    const royalPassPrice = 600.00;
    final connection = await openDatabaseConnection();

    try {
      await _ensureTables(connection);

      if (userId == null) {
        final defaultUser = await connection.execute(
          Sql.named('''
            SELECT user_id FROM wallets 
            WHERE balance >= 600 
            ORDER BY id DESC LIMIT 1
          '''),
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

      // 1. Fetch user wallet balance
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

      // 2. Validate sufficient wallet balance
      if (currentBalance < royalPassPrice) {
        final needed = royalPassPrice - currentBalance;
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'status': 'error',
            'message': 'Insufficient TicOne Wallet balance (₹${currentBalance.toStringAsFixed(2)}). TicOne Royal Pass requires ₹600.00. Please top up ₹${needed.toStringAsFixed(2)} to upgrade.',
            'requiredAmount': royalPassPrice,
            'currentBalance': currentBalance,
            'shortfall': needed,
          },
        );
      }

      // 3. Deduct ₹600 from wallet
      final newBalance = currentBalance - royalPassPrice;
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

      // 4. Log wallet transaction
      final txRef = 'ROYALPASS_${DateTime.now().millisecondsSinceEpoch}';
      final txRes = await connection.execute(
        Sql.named('''
          INSERT INTO wallet_transactions (wallet_id, amount, type, title, reference_id)
          VALUES (@walletId, @amount, 'debit', 'TicOne Royal Pass (1-Year Premium Membership)', @refId)
          RETURNING id
        '''),
        parameters: {
          'walletId': walletId,
          'amount': royalPassPrice,
          'refId': txRef,
        },
      );
      final txId = txRes.isNotEmpty ? txRes.first[0] : DateTime.now().millisecondsSinceEpoch;

      // 5. Calculate new start and expiry date (1 year = 365 days)
      final existingPass = await connection.execute(
        Sql.named('SELECT expiry_date FROM user_royal_pass WHERE user_id = @userId LIMIT 1'),
        parameters: {'userId': userId},
      );

      final now = DateTime.now();
      DateTime startDate = now;
      DateTime expiryDate = now.add(const Duration(days: 365));

      if (existingPass.isNotEmpty && existingPass.first[0] != null) {
        final curExpiry = existingPass.first[0] is DateTime
            ? (existingPass.first[0] as DateTime)
            : DateTime.tryParse(existingPass.first[0].toString());
        if (curExpiry != null && curExpiry.isAfter(now)) {
          expiryDate = curExpiry.add(const Duration(days: 365));
        }
      }

      // 6. Save Royal Pass / Premium User membership in database
      await connection.execute(
        Sql.named('''
          INSERT INTO user_royal_pass (
            user_id, membership_status, plan_name, price, start_date, expiry_date, is_active, updated_at
          )
          VALUES (
            @userId, 'PREMIUM_USER', 'TicOne Royal Pass', 600.00, @startDate, @expiryDate, true, CURRENT_TIMESTAMP
          )
          ON CONFLICT (user_id) DO UPDATE 
          SET membership_status = 'PREMIUM_USER',
              plan_name = 'TicOne Royal Pass',
              price = 600.00,
              start_date = @startDate,
              expiry_date = @expiryDate,
              is_active = true,
              updated_at = CURRENT_TIMESTAMP
        '''),
        parameters: {
          'userId': userId,
          'startDate': startDate,
          'expiryDate': expiryDate,
        },
      );

      AppLogger.info('WalletService', 'User $userId upgraded to PREMIUM_USER with Royal Pass valid until $expiryDate');

      return Response.json(
        body: {
          'status': 'success',
          'message': 'Congratulations! Your TicOne Royal Pass 1-Year Premium Membership is now activated.',
          'data': {
            'success': true,
            'membershipStatus': 'PREMIUM_USER',
            'status': 'PREMIUM_USER',
            'planName': 'TicOne Royal Pass',
            'price': 600.00,
            'startDate': startDate.toIso8601String(),
            'expiryDate': expiryDate.toIso8601String(),
            'isActive': true,
            'isExpired': false,
            'daysRemaining': expiryDate.difference(now).inDays.clamp(0, 365),
            'discountPercentage': 20.0,
            'remainingWalletBalance': newBalance,
            'walletBalance': newBalance,
            'transactionId': 'TXN_$txId',
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('WalletService', 'Error in purchaseRoyalPass: $e', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Failed to process Royal Pass upgrade: $e'},
      );
    } finally {
      await connection.close();
    }
  }

  /// POST /wallet/convert-points
  static Future<Response> convertPoints(RequestContext context, [Map<String, dynamic>? parsedBody]) async {
    int? userId = _extractUserId(context);
    final body = parsedBody ?? await AuthUtils.readJson(context);
    if (body == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Request body must be valid JSON'},
      );
    }

    final pointsToConvert = _toInt(body['points']);
    if (pointsToConvert <= 0) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Points amount must be greater than 0'},
      );
    }

    final connection = await openDatabaseConnection();
    try {
      await _ensureTables(connection);

      if (userId == null) {
        final firstUser = await connection.execute(
          Sql.named('SELECT id FROM login_auth ORDER BY id ASC LIMIT 1'),
        );
        userId = firstUser.isNotEmpty ? firstUser.first[0] as int : 1;
      }

      final userPts = await getUserPoints(connection, userId);
      if (userPts < pointsToConvert) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'status': 'error',
            'message': 'Insufficient CinePoints ($userPts Pts available, tried to redeem $pointsToConvert Pts)',
          },
        );
      }

      final addedAmount = pointsToConvert * 0.50;

      await connection.execute(
        Sql.named('''
          UPDATE user_cinepoints 
          SET points = points - @pts,
              total_redeemed = total_redeemed + @pts,
              updated_at = CURRENT_TIMESTAMP
          WHERE user_id = @userId
        '''),
        parameters: {
          'pts': pointsToConvert,
          'userId': userId,
        },
      );

      await connection.execute(
        Sql.named('''
          INSERT INTO cinepoint_transactions (user_id, points, type, title, reference_id)
          VALUES (@userId, @pts, 'redeemed', @title, @refId)
        '''),
        parameters: {
          'userId': userId,
          'pts': pointsToConvert,
          'title': 'Redeemed for TicOne Wallet Cash (₹${addedAmount.toStringAsFixed(2)})',
          'refId': 'RED_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      final newPoints = userPts - pointsToConvert;

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
      final newBalance = currentBalance + addedAmount;

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
          VALUES (@walletId, @amount, 'credit', @title, @refId)
          RETURNING id
        '''),
        parameters: {
          'walletId': walletId,
          'amount': addedAmount,
          'title': 'CinePoints Redemption ($pointsToConvert Pts)',
          'refId': 'PTS_RED_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      final txId = txRes.isNotEmpty ? txRes.first[0] : DateTime.now().millisecondsSinceEpoch;

      return Response.json(
        body: {
          'status': 'success',
          'data': {
            'success': true,
            'message': 'Successfully converted $pointsToConvert CinePoints to ₹${addedAmount.toStringAsFixed(2)} in TicOne Wallet!',
            'convertedPoints': pointsToConvert,
            'addedAmount': addedAmount,
            'remainingPoints': newPoints,
            'newBalance': newBalance,
            'walletBalance': newBalance,
            'transactionId': 'TXN_$txId',
          },
        },
      );
    } catch (e, st) {
      AppLogger.error('WalletService', 'Error in convertPoints: $e', error: e, stackTrace: st);
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'status': 'error', 'message': 'Points conversion failed: $e'},
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

    if (body['action'] == 'purchase_royal_pass' ||
        body['action'] == 'royal_pass' ||
        body['plan'] == 'royal_pass' ||
        body['bookingReference'] == 'ROYALPASS') {
      return purchaseRoyalPass(context);
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

    if (body['action'] == 'purchase_royal_pass' ||
        body['action'] == 'royal_pass' ||
        body['plan'] == 'royal_pass' ||
        body['royal_pass'] == true) {
      return purchaseRoyalPass(context);
    }

    if (body['points'] != null || body['action'] == 'convert_points') {
      return convertPoints(context, body);
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
