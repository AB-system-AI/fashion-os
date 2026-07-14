import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';

/// Cross-module assets integration: accounting, manufacturing, analytics audit hooks.
class AssetIntegrationService {
  AssetIntegrationService({
    required DomainEventBus eventBus,
    required AuditService audit,
  })  : _eventBus = eventBus,
        _audit = audit;

  final DomainEventBus _eventBus;
  final AuditService _audit;

  void register() {
    _eventBus.subscribe(DomainEventTypes.assetDisposed, _onAssetDisposed);
    _eventBus.subscribe(DomainEventTypes.assetTransferred, _onAssetTransferred);
  }

  Future<void> _onAssetDisposed(DomainEvent event) async {
    if (event is! AssetDisposedEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.assetId,
      metadata: {
        'integration': 'accounting_analytics',
        'event': 'asset.disposed',
        'gainLoss': event.gainLoss,
        'proceeds': event.proceeds,
      },
    );
  }

  Future<void> _onAssetTransferred(DomainEvent event) async {
    if (event is! AssetTransferredEvent || event.tenantId == null) return;
    await _audit.log(
      action: AuditAction.update,
      entityType: 'integration',
      tenantId: event.tenantId,
      entityId: event.assetId,
      metadata: {
        'integration': 'manufacturing_analytics',
        'event': 'asset.transferred',
        'fromLocationId': event.fromLocationId,
        'toLocationId': event.toLocationId,
      },
    );
  }
}
