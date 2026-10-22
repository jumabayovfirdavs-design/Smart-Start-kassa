import '../../domain/repositories/pin_repository.dart';
import '../local/key_value_store.dart';

class PinRepositoryImpl implements PinRepository {
  PinRepositoryImpl(this._store);
  final KeyValueStore _store;

  @override
  String? get hash => _store.read('pin_hash');
  @override
  String? get salt => _store.read('pin_salt');

  @override
  Future<void> save({required String hash, required String salt}) async {
    await _store.write('pin_salt', salt);
    await _store.write('pin_hash', hash);
  }
}
