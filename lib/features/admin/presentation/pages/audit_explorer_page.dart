import 'package:flutter/material.dart';

import 'package:fashion_pos_enterprise/features/system/presentation/pages/audit_explorer_page.dart' as system;

/// Admin audit explorer — wraps system module AuditExplorerPage.
class AdminAuditExplorerPage extends StatelessWidget {
  const AdminAuditExplorerPage({super.key});

  @override
  Widget build(BuildContext context) => const system.AuditExplorerPage();
}
