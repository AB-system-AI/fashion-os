import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DomainEventBus', () {
    test('delivers events to subscribers', () {
      final bus = DomainEventBus();
      final received = <SaleCompletedEvent>[];

      bus.subscribe(DomainEventTypes.saleCompleted, (event) {
        received.add(event as SaleCompletedEvent);
      });

      bus.publish(
        SaleCompletedEvent(
          eventId: 'e1',
          occurredAt: DateTime.utc(2026, 7, 11),
          saleId: 'sale1',
          grandTotalMinor: 10000,
          currencyCode: 'USD',
        ),
      );

      expect(received, hasLength(1));
      expect(received.first.saleId, 'sale1');
    });

    test('unsubscribe stops delivery', () {
      final bus = DomainEventBus();
      var count = 0;
      void handler(DomainEvent event) => count++;

      bus.subscribe(DomainEventTypes.stockChanged, handler);
      bus.publish(
        StockChangedEvent(
          eventId: 'e1',
          occurredAt: DateTime.utc(2026, 7, 11),
          variantId: 'v1',
          warehouseId: 'w1',
          quantityBefore: 10,
          quantityAfter: 8,
          movementType: 'sale',
        ),
      );
      bus.unsubscribe(DomainEventTypes.stockChanged, handler);
      bus.publish(
        StockChangedEvent(
          eventId: 'e2',
          occurredAt: DateTime.utc(2026, 7, 11),
          variantId: 'v1',
          warehouseId: 'w1',
          quantityBefore: 8,
          quantityAfter: 6,
          movementType: 'sale',
        ),
      );

      expect(count, 1);
    });
  });
}
