/// Descriptor for an application module (feature boundary).
class ModuleDescriptor {
  const ModuleDescriptor({
    required this.id,
    required this.name,
    required this.routePrefix,
    this.dependencies = const [],
    this.permissions = const [],
    this.enabled = true,
  });

  final String id;
  final String name;
  final String routePrefix;
  final List<String> dependencies;
  final List<String> permissions;
  final bool enabled;
}

/// Extension contract for vertical-specific business logic.
abstract class FashionModule {
  ModuleDescriptor get descriptor;

  Future<void> onRegister();

  Future<void> onActivate();

  Future<void> onDeactivate();
}

/// Central registry for independent application modules.
class ModuleRegistry {
  ModuleRegistry._();
  static final ModuleRegistry instance = ModuleRegistry._();

  final Map<String, FashionModule> _modules = {};
  final List<ModuleDescriptor> _coreModules = const [
    ModuleDescriptor(id: 'auth', name: 'Authentication', routePrefix: '/auth'),
    ModuleDescriptor(id: 'dashboard', name: 'Dashboard', routePrefix: '/dashboard'),
    ModuleDescriptor(id: 'products', name: 'Products', routePrefix: '/products'),
    ModuleDescriptor(id: 'inventory', name: 'Inventory', routePrefix: '/inventory'),
    ModuleDescriptor(id: 'pos', name: 'POS', routePrefix: '/pos'),
    ModuleDescriptor(id: 'customers', name: 'Customers', routePrefix: '/customers'),
    ModuleDescriptor(id: 'suppliers', name: 'Suppliers', routePrefix: '/suppliers'),
    ModuleDescriptor(id: 'purchasing', name: 'Purchasing', routePrefix: '/purchasing'),
    ModuleDescriptor(id: 'accounting', name: 'Accounting', routePrefix: '/accounting'),
    ModuleDescriptor(id: 'expenses', name: 'Expenses', routePrefix: '/expenses'),
    ModuleDescriptor(id: 'reports', name: 'Reports', routePrefix: '/reports'),
    ModuleDescriptor(id: 'notifications', name: 'Notifications', routePrefix: '/notifications'),
    ModuleDescriptor(id: 'settings', name: 'Settings', routePrefix: '/settings'),
    ModuleDescriptor(id: 'ai', name: 'AI', routePrefix: '/ai'),
  ];

  List<ModuleDescriptor> get coreModules => List.unmodifiable(_coreModules);

  List<ModuleDescriptor> get allDescriptors => [
        ..._coreModules,
        ..._modules.values.map((m) => m.descriptor),
      ];

  Future<void> register(FashionModule module) async {
    _validateDependencies(module.descriptor);
    _modules[module.descriptor.id] = module;
    await module.onRegister();
  }

  Future<void> activate(String moduleId) async {
    final module = _modules[moduleId];
    if (module == null) {
      throw StateError('Module not registered: $moduleId');
    }
    await module.onActivate();
  }

  FashionModule? get(String moduleId) => _modules[moduleId];

  bool isEnabled(String moduleId) {
    final custom = _modules[moduleId];
    if (custom != null) return custom.descriptor.enabled;
    return _coreModules.any((m) => m.id == moduleId && m.enabled);
  }

  void _validateDependencies(ModuleDescriptor descriptor) {
    for (final dep in descriptor.dependencies) {
      final exists = _coreModules.any((m) => m.id == dep) || _modules.containsKey(dep);
      if (!exists) {
        throw StateError('Module ${descriptor.id} depends on unknown module: $dep');
      }
    }
  }
}
