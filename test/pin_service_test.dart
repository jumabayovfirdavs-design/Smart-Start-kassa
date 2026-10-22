import 'package:flutter_test/flutter_test.dart';
import 'package:smart_kassa/core/errors.dart';
import 'package:smart_kassa/domain/repositories/pin_repository.dart';
import 'package:smart_kassa/domain/services/pin_hasher.dart';
import 'package:smart_kassa/domain/services/pin_service.dart';

class FakePinRepository implements PinRepository {
  String? _h, _s;
  @override
  String? get hash => _h;
  @override
  String? get salt => _s;
  @override
  Future<void> save({required String hash, required String salt}) async {
    _h = hash;
    _s = salt;
  }
}

class FakeHasher implements PinHasher {
  @override
  String hash(String pin, String salt) => '$salt|$pin';
}

void main() {
  test("parol o'rnatilgach tekshiriladi", () async {
    final s = PinService(FakePinRepository(), FakeHasher());
    expect(s.hasPin, isFalse);
    await s.setPin('1234');
    expect(s.hasPin, isTrue);
    expect(s.verify('1234'), isTrue);
    expect(s.verify('1111'), isFalse);
  });

  test('4 xonali bolmagan parol rad etiladi', () {
    final s = PinService(FakePinRepository(), FakeHasher());
    expect(() => s.setPin('12'), throwsA(isA<DomainException>()));
  });
}
