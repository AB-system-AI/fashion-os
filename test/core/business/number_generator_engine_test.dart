import 'package:fashion_pos_enterprise/core/business/contracts/sequence_store.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberGeneratorEngine', () {
    late NumberGeneratorEngine engine;

    setUp(() {
      engine = NumberGeneratorEngine(InMemorySequenceStore());
    });

    test('generates sequential invoice numbers', () async {
      final first = await engine.next(
        type: DocumentNumberType.invoice,
        tenantId: 't1',
        at: DateTime.utc(2026, 7, 11),
      );
      final second = await engine.next(
        type: DocumentNumberType.invoice,
        tenantId: 't1',
        at: DateTime.utc(2026, 7, 11),
      );

      expect((first as Success).data.sequence, 1);
      expect((second as Success).data.sequence, 2);
      expect((first as Success).data.value, startsWith('INV-20260711'));
    });

    test('generates customer number without date', () async {
      final result = await engine.next(
        type: DocumentNumberType.customer,
        tenantId: 't1',
      );
      expect((result as Success).data.value, startsWith('CUS-'));
      expect((result as Success).data.value.contains('2026'), isFalse);
    });
  });
}
