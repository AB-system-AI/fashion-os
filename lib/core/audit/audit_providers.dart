import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';

final auditServiceProvider = Provider<AuditService>((ref) => AuditService());
