import 'package:equatable/equatable.dart';

/// Base class for all domain events — modules communicate via events only.
abstract class DomainEvent extends Equatable {
  const DomainEvent({
    required this.eventId,
    required this.occurredAt,
    this.tenantId,
    this.storeId,
    this.correlationId,
  });

  final String eventId;
  final DateTime occurredAt;
  final String? tenantId;
  final String? storeId;
  final String? correlationId;

  String get eventType;

  @override
  List<Object?> get props => [eventId, eventType, occurredAt, tenantId, storeId];
}

/// In-process domain event bus for decoupled module communication.
class DomainEventBus {
  DomainEventBus();

  final Map<String, List<void Function(DomainEvent event)>> _handlers = {};
  final List<DomainEvent> _history = [];
  final int _maxHistory = 500;

  void subscribe(String eventType, void Function(DomainEvent event) handler) {
    _handlers.putIfAbsent(eventType, () => []).add(handler);
  }

  void subscribeAll(void Function(DomainEvent event) handler) {
    subscribe('*', handler);
  }

  void unsubscribe(String eventType, void Function(DomainEvent event) handler) {
    _handlers[eventType]?.remove(handler);
  }

  void publish(DomainEvent event) {
    _history.add(event);
    if (_history.length > _maxHistory) _history.removeAt(0);

    final typeHandlers = _handlers[event.eventType] ?? [];
    final allHandlers = _handlers['*'] ?? [];
    for (final handler in [...typeHandlers, ...allHandlers]) {
      handler(event);
    }
  }

  List<DomainEvent> history({String? eventType, int limit = 50}) {
    final filtered = eventType == null
        ? _history
        : _history.where((e) => e.eventType == eventType);
    return filtered.toList().reversed.take(limit).toList().reversed.toList();
  }

  void clear() {
    _handlers.clear();
    _history.clear();
  }
}
