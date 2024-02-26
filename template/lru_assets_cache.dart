import 'dart:async';

final class AssetsCache {
  AssetsCache._();

  static AssetsCache instance = AssetsCache._();

  final _cache = LruCache<String, dynamic>();

  Future<T> putIfAbsent<T>(
      String key, bool cache, FutureOr<(T, int)> Function() ifAbsent) async {
    if (!cache) {
      return (await ifAbsent()).$1;
    }
    return _cache.putIfAbsent(key, ifAbsent).then((value) => value as T);
  }

  void evict(String key) {
    _cache.evict(key);
  }

  void clear() {
    _cache.clear();
  }
}

class LruCache<K, V> {
  LruCache({int countLimit = 100, int totalCostLimit = 1024 * 1024 * 50})
      : _countLimit = countLimit,
        _totalCostLimit = totalCostLimit;

  int get countLimit => _countLimit;
  int get totalCostLimit => _totalCostLimit;

  set countLimit(int value) {
    _countLimit = value;
    _checkLimit();
  }

  set totalCostLimit(int value) {
    _totalCostLimit = value;
    _checkLimit();
  }

  final Map<K, V> _map = {};
  final Map<K, int> _costMap = {};
  final List<K> _keys = [];
  int _totalCost = 0;
  int _countLimit;
  int _totalCostLimit;

  Future<V> putIfAbsent(K key, FutureOr<(V, int)> Function() ifAbsent) async {
    if (_map.containsKey(key)) {
      _keys.remove(key);
      _keys.add(key);
      return _map[key]!;
    }

    final (value, cost) = await ifAbsent();
    _map[key] = value;
    _costMap[key] = cost;
    _keys.add(key);
    _checkLimit();
    return value;
  }

  void clear() {
    _map.clear();
  }

  void evict(K key) {
    _map.remove(key);
    _costMap.remove(key);
    _keys.remove(key);
  }

  void _checkLimit() {
    while (_map.length > countLimit || _totalCost > totalCostLimit) {
      final key = _keys.removeAt(0);
      final cost = _costMap.remove(key) ?? 0;
      _map.remove(key);
      _totalCost -= cost;
    }
  }
}




// class PolicyBasedAssetCache extends AssetsCache {
//   PolicyBasedAssetCache._() : super._();

//   T putIfAbsent<T>(
//     String key,
//     AssetsCachePolicy policy,
//     T Function() ifAbsent,
//   ) {
//     if (policy == AssetsCachePolicy.none) {
//       return ifAbsent();
//     }
//     return super.putIfAbsent(key, ifAbsent);
//   }
// }



// enum AssetsCachePolicy {
//   none,
//   weak,
//   short,
//   long,
//   permanent;
// }

