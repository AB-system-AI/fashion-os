import 'package:fashion_pos_enterprise/core/business/engines/hr/hr_engine.dart';
import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/repositories/hr_repositories.dart';

/// Subscribes to POS events for shift validation and commission hooks.
class HrIntegrationService {
  HrIntegrationService({
    required DomainEventBus eventBus,
    required EmployeeRepository employeeRepository,
    required HREngine engine,
  })  : _eventBus = eventBus,
        _employees = employeeRepository,
        _engine = engine;

  final DomainEventBus _eventBus;
  final EmployeeRepository _employees;
  final HREngine _engine;

  void register() {
    _eventBus.subscribe(DomainEventTypes.saleCompleted, _onSaleCompleted);
    _eventBus.subscribe(DomainEventTypes.saleCreated, _onSaleCreated);
  }

  Future<void> _onSaleCompleted(DomainEvent event) async {
    if (event is! SaleCompletedEvent || event.tenantId == null) return;
    // Commission auto-record requires cashier employeeId on sale — wired via POS extension
  }

  Future<void> _onSaleCreated(DomainEvent event) async {
    if (event is! SaleCreatedEvent || event.tenantId == null) return;
    final employee = await _employees.getById(event.employeeId, tenantId: event.tenantId!);
    if (employee == null) return;
    _engine.validateEmployeeAvailable(employee, event.occurredAt);
  }
}
