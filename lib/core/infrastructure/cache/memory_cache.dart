/// In-memory LRU cache for repository hot paths.
class MemoryCache<K, V> {
  MemoryCache({this.maxEntries = 500, this.maxBytes = 64 * 1024 * 1024});

  final int maxEntries;
  final int maxBytes;
  final Map<K, _CacheEntry<V>> _entries = {};
  final List<K> _order = [];
  int _currentBytes = 0;

  V? get(K key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (entry.expiresAt != null && DateTime.now().isAfter(entry.expiresAt!)) {
      remove(key);
      return null;
    }
    _touch(key);
    return entry.value;
  }

  void set(K key, V value, {Duration? ttl, int byteSize = 0}) {
    if (_entries.containsKey(key)) {
      _currentBytes -= _entries[key]!.byteSize;
      _order.remove(key);
    }
    while ((_entries.length >= maxEntries || _currentBytes + byteSize > maxBytes) && _order.isNotEmpty) {
      final oldest = _order.removeAt(0);
      _currentBytes -= _entries[oldest]?.byteSize ?? 0;
      _entries.remove(oldest);
    }
    _entries[key] = _CacheEntry(
      value: value,
      expiresAt: ttl == null ? null : DateTime.now().add(ttl),
      byteSize: byteSize,
    );
    _currentBytes += byteSize;
    _touch(key);
  }

  void remove(K key) {
    _currentBytes -= _entries[key]?.byteSize ?? 0;
    _entries.remove(key);
    _order.remove(key);
  }

  void clear() {
    _entries.clear();
    _order.clear();
    _currentBytes = 0;
  }

  void _touch(K key) {
    _order.remove(key);
    _order.add(key);
  }
}

class _CacheEntry<V> {
  _CacheEntry({required this.value, this.expiresAt, this.byteSize = 0});
  final V value;
  final DateTime? expiresAt;
  final int byteSize;
}
