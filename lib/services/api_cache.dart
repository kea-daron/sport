class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.ttl,
  }) : timestamp = DateTime.now();

  bool get isExpired {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

class ApiCache {
  static final ApiCache _instance = ApiCache._internal();
  final Map<String, CacheEntry> _cache = {};

  factory ApiCache() {
    return _instance;
  }

  ApiCache._internal();

  void set<T>(String key, T data, {Duration ttl = const Duration(minutes: 5)}) {
    _cache[key] = CacheEntry(data: data, ttl: ttl);
  }

  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) {
      return null;
    }

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  T? peek<T>(String key) {
    final entry = _cache[key];
    if (entry == null) {
      return null;
    }

    return entry.data as T?;
  }

  void clear() {
    _cache.clear();
  }

  void remove(String key) {
    _cache.remove(key);
  }
}
