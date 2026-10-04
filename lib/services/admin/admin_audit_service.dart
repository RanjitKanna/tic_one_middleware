import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tic_one_middleware/database.dart';
import 'package:tic_one_middleware/services/admin/admin_auth_service.dart';

class AdminAuditService {
  static Future<Response> listLogs(RequestContext context) async {
    final admin = await AdminAuthService.authenticateAdmin(context);
    if (admin == null) return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

    final params = context.request.uri.queryParameters;
    final page = int.tryParse(params['page'] ?? '1') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '30') ?? 30;
    final offset = (page - 1) * limit;
    final action = params['action']?.trim() ?? '';
    final entityType = params['entityType']?.trim() ?? '';

    final conn = await openDatabaseConnection();
    try {
      final whereClauses = <String>["1=1"];
      final sqlParams = <String, dynamic>{'limit': limit, 'offset': offset};

      if (action.isNotEmpty && action != 'all') {
        whereClauses.add("action = @action");
        sqlParams['action'] = action;
      }
      if (entityType.isNotEmpty && entityType != 'all') {
        whereClauses.add("entity_type = @entityType");
        sqlParams['entityType'] = entityType;
      }

      final whereSql = whereClauses.join(' AND ');

      final countRes = await conn.execute(
        Sql.named('SELECT COUNT(*) FROM audit_logs WHERE $whereSql'),
        parameters: sqlParams,
      );
      final total = int.parse(countRes.first[0].toString());

      final res = await conn.execute(
        Sql.named('''
          SELECT id, admin_id, admin_email, action, entity_type, entity_id, details, created_at
          FROM audit_logs
          WHERE $whereSql
          ORDER BY created_at DESC
          LIMIT @limit OFFSET @offset
        '''),
        parameters: sqlParams,
      );

      final logs = res.map((r) {
        dynamic details = r[6];
        if (details is String) {
          try {
            details = jsonDecode(details);
          } catch (_) {}
        }
        return {
          'id': r[0],
          'adminId': r[1],
          'adminEmail': r[2],
          'action': r[3],
          'entityType': r[4],
          'entityId': r[5],
          'details': details,
          'createdAt': (r[7] as DateTime).toIso8601String(),
        };
      }).toList();

      return Response.json(
        body: {
          'logs': logs,
          'pagination': {
            'page': page,
            'limit': limit,
            'total': total,
            'totalPages': (total / limit).ceil(),
          },
        },
      );
    } finally {
      await conn.close();
    }
  }
}
