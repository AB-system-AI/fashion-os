import 'package:fashion_pos_enterprise/core/business/domain/entities/tax_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/engines/tax_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaxEngine', () {
    late TaxEngine engine;

    setUp(() {
      engine = TaxEngine();
    });

    test('calculates exclusive VAT', () {
      final result = engine.calculate(
        TaxCalculationRequest(
          lineItems: [
            TaxableLineItem(lineId: 'l1', netAmount: Money.fromMajor(100)),
          ],
          taxGroup: TaxGroup(
            id: 'vat',
            name: 'Standard VAT',
            rates: [
              TaxRate(
                id: 'vat20',
                name: 'VAT 20%',
                rate: const Percentage(20),
                category: TaxCategory.vat,
                mode: TaxMode.exclusive,
              ),
            ],
          ),
        ),
      );

      final data = (result as Success<TaxCalculationResult>).data;
      expect(data.totalTax.majorUnits, 20);
      expect(data.grandTotal.majorUnits, 120);
    });

    test('calculates inclusive VAT', () {
      final result = engine.calculate(
        TaxCalculationRequest(
          lineItems: [
            TaxableLineItem(lineId: 'l1', netAmount: Money.fromMajor(120)),
          ],
          taxGroup: TaxGroup(
            id: 'vat',
            name: 'Standard VAT',
            rates: [
              TaxRate(
                id: 'vat20',
                name: 'VAT 20%',
                rate: const Percentage(20),
                category: TaxCategory.vat,
                mode: TaxMode.inclusive,
              ),
            ],
          ),
          defaultMode: TaxMode.inclusive,
        ),
      );

      final data = (result as Success<TaxCalculationResult>).data;
      expect(data.taxLines.first.taxableAmount.majorUnits, closeTo(100, 1));
      expect(data.grandTotal.majorUnits, 120);
    });

    test('rejects empty tax group', () {
      final result = engine.calculate(
        TaxCalculationRequest(
          lineItems: [
            TaxableLineItem(lineId: 'l1', netAmount: Money.fromMajor(100)),
          ],
          taxGroup: const TaxGroup(id: 'empty', name: 'Empty', rates: []),
        ),
      );
      expect(result.isFailure, isTrue);
    });
  });
}
