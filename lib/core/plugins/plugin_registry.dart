/// Isolated plugin contract for vertical extensions.
abstract class FashionPlugin {
  PluginDescriptor get descriptor;

  Future<void> initialize(PluginContext context);

  Future<void> dispose();
}

class PluginDescriptor {
  const PluginDescriptor({
    required this.id,
    required this.name,
    required this.version,
    this.targetVerticals = const [],
    this.permissions = const [],
  });

  final String id;
  final String name;
  final String version;
  final List<String> targetVerticals;
  final List<String> permissions;
}

/// Sandboxed runtime context passed to plugins.
class PluginContext {
  const PluginContext({
    required this.tenantId,
    required this.storeId,
    required this.eventBus,
  });

  final String? tenantId;
  final String? storeId;
  final PluginEventBus eventBus;
}

/// Lightweight in-process event bus for plugin isolation.
class PluginEventBus {
  final Map<String, List<void Function(Map<String, dynamic> payload)>> _listeners = {};

  void subscribe(String event, void Function(Map<String, dynamic> payload) handler) {
    _listeners.putIfAbsent(event, () => []).add(handler);
  }

  void publish(String event, [Map<String, dynamic> payload = const {}]) {
    final handlers = _listeners[event];
    if (handlers == null) return;
    for (final handler in List.of(handlers)) {
      handler(payload);
    }
  }

  void unsubscribe(String event, void Function(Map<String, dynamic> payload) handler) {
    _listeners[event]?.remove(handler);
  }
}

/// Registry and lifecycle manager for isolated plugins.
class PluginRegistry {
  PluginRegistry._();
  static final PluginRegistry instance = PluginRegistry._();

  final Map<String, FashionPlugin> _plugins = {};
  final PluginEventBus eventBus = PluginEventBus();

  List<PluginDescriptor> get descriptors =>
      _plugins.values.map((p) => p.descriptor).toList();

  Future<void> register(FashionPlugin plugin, PluginContext context) async {
    if (_plugins.containsKey(plugin.descriptor.id)) {
      throw StateError('Plugin already registered: ${plugin.descriptor.id}');
    }
    _validateIsolation(plugin);
    await plugin.initialize(context);
    _plugins[plugin.descriptor.id] = plugin;
  }

  Future<void> unregister(String pluginId) async {
    final plugin = _plugins.remove(pluginId);
    await plugin?.dispose();
  }

  FashionPlugin? get(String pluginId) => _plugins[pluginId];

  bool isRegistered(String pluginId) => _plugins.containsKey(pluginId);

  void _validateIsolation(FashionPlugin plugin) {
    for (final permission in plugin.descriptor.permissions) {
      if (!_allowedPermissions.contains(permission)) {
        throw StateError(
          'Plugin ${plugin.descriptor.id} requested disallowed permission: $permission',
        );
      }
    }
  }

  static const Set<String> _allowedPermissions = {
    'products.read',
    'products.write',
    'inventory.read',
    'inventory.write',
    'sales.read',
    'sales.write',
    'customers.read',
    'reports.read',
    'settings.read',
  };
}

/// Built-in plugin slots for future verticals.
abstract final class PluginSlots {
  static const pharmacy = 'plugin_pharmacy';
  static const supermarket = 'plugin_supermarket';
  static const electronics = 'plugin_electronics';
  static const restaurant = 'plugin_restaurant';
  static const cafe = 'plugin_cafe';
  static const beauty = 'plugin_beauty';
  static const warehouse = 'plugin_warehouse';
  static const ecommerce = 'plugin_ecommerce';
}
