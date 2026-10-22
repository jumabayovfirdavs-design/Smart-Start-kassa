import 'dart:convert';

import '../../domain/repositories/repositories.dart';
import '../local/key_value_store.dart';
import '../mappers.dart';

/// Umumiy JSON-ro'yxat repozitoriyasi (DRY + OCP: yangi entity uchun faqat 3 metod yoziladi).
abstract class JsonListRepository<T> implements EntityRepository<T> {
  JsonListRepository(this._store, this._key);
  final KeyValueStore _store;
  final String _key;
  List<T> _items = [];

  T decode(Json json);
  Json encode(T item);
  String idOf(T item);

  Future<void> load() async {
    final raw = _store.read(_key);
    if (raw == null) return;
    _items = (jsonDecode(raw) as List).map((e) => decode(e as Json)).toList();
  }

  @override
  List<T> get all => List.unmodifiable(_items);

  @override
  Future<void> upsert(T item) async {
    final i = _items.indexWhere((e) => idOf(e) == idOf(item));
    if (i < 0) {
      _items.add(item);
    } else {
      _items[i] = item;
    }
    await _persist();
  }

  @override
  Future<void> removeWhere(bool Function(T item) test) async {
    _items.removeWhere(test);
    await _persist();
  }

  Future<void> _persist() => _store.write(_key, jsonEncode(_items.map(encode).toList()));
}
