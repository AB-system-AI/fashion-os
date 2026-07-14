import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/admin/administration_engine.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/value_objects/admin_value_objects.dart';

void main() {
  test('organization validation passes for valid input', () {
    final engine = AdministrationEngine();
    final result = engine.validateOrganization(const OrganizationInput(name: 'Acme Corp', code: 'ACME'));
    expect(result.isValid, isTrue);
  });

  test('config validation requires keys', () {
    final engine = AdministrationEngine();
    final result = engine.validateConfig({}, requiredKeys: ['timezone', 'locale']);
    expect(result.isValid, isFalse);
    expect(result.errors.length, 2);
  });

  test('feature flag defaults to false when missing', () {
    final engine = AdministrationEngine();
    expect(engine.isFeatureEnabled(flagKey: 'beta', flags: const {}), isFalse);
    expect(engine.isFeatureEnabled(flagKey: 'beta', flags: const {'beta': true}), isTrue);
  });
}
