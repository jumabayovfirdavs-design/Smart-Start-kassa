import '../../core/errors.dart';
import '../../core/formatters.dart';
import '../repositories/pin_repository.dart';
import 'pin_hasher.dart';

/// Parol qoidalari: 4 xonali raqam, tuz (salt) bilan hash qilib saqlanadi.
class PinService {
  PinService(this._repo, this._hasher);
  final PinRepository _repo;
  final PinHasher _hasher;

  bool get hasPin => _repo.hash != null && _repo.salt != null;

  bool verify(String pin) {
    final h = _repo.hash, s = _repo.salt;
    return h != null && s != null && h == _hasher.hash(pin, s);
  }

  Future<void> setPin(String pin) async {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw const DomainException("Parol 4 ta raqamdan iborat bo'lishi kerak");
    }
    final salt = newId();
    await _repo.save(hash: _hasher.hash(pin, salt), salt: salt);
  }
}
