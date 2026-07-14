import 'package:fashion_pos_enterprise/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestModule implements FashionModule {
  _TestModule(this._descriptor);

  final ModuleDescriptor _descriptor;

  @override
  ModuleDescriptor get descriptor => _descriptor;

  @override
  Future<void> onRegister() async {}

  @override
  Future<void> onActivate() async {}

  @override
  Future<void> onDeactivate() async {}
}

void main() {
  test('core modules include auth and pos', () {
    final ids = ModuleRegistry.instance.coreModules.map((m) => m.id).toList();
    expect(ids, contains('auth'));
    expect(ids, contains('pos'));
    expect(ids, contains('products'));
  });

  test('register validates dependencies', () async {
    final registry = ModuleRegistry.instance;
    final module = _TestModule(
      const ModuleDescriptor(
        id: 'test_invalid',
        name: 'Test',
        routePrefix: '/test',
        dependencies: ['nonexistent_module'],
      ),
    );
    expect(() => registry.register(module), throwsStateError);
  });

  test('isEnabled returns true for core modules', () {
    expect(ModuleRegistry.instance.isEnabled('auth'), isTrue);
    expect(ModuleRegistry.instance.isEnabled('ai'), isTrue);
  });
}
