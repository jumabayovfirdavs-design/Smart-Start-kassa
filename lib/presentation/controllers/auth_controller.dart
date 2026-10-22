import 'package:flutter/foundation.dart';

import '../../core/clock.dart';
import '../../core/errors.dart';
import '../../domain/services/pin_service.dart';

enum AuthPhase { splash, pin, app }

enum PinMode { login, verifyOld, create, confirm }

/// Splash -> parol -> ilova oqimini boshqaradi (UI holati; qoidalar PinService'da).
class AuthController extends ChangeNotifier {
  AuthController(this._pins, this._clock);
  final PinService _pins;
  final Clock _clock;

  AuthPhase phase = AuthPhase.splash;
  PinMode mode = PinMode.login;
  String? error;
  int shakes = 0; // har xatoda oshadi -> UI silkinish animatsiyasini qayta ishga tushiradi

  String _buf = '';
  String? _first;
  int _fails = 0;
  DateTime? _lockedUntil;
  bool _unlocked = false;
  bool _busy = false;

  int get entered => _buf.length;
  bool get canGoBack => _unlocked && mode != PinMode.login;

  String get title => switch (mode) {
        PinMode.login => 'Parolni kiriting',
        PinMode.verifyOld => 'Joriy parolni kiriting',
        PinMode.create => "Yangi parol o'rnating",
        PinMode.confirm => 'Parolni takrorlang',
      };

  String get hint => mode == PinMode.login ? 'EduCore · maktab kassa' : 'Parol 4 ta raqamdan iborat. Faqat shu kompyuterda saqlanadi';

  void finishSplash() {
    if (phase == AuthPhase.splash) _enter(_pins.hasPin ? PinMode.login : PinMode.create);
  }

  void lock() {
    _unlocked = false;
    _enter(_pins.hasPin ? PinMode.login : PinMode.create);
  }

  void startChangePin() => _enter(_pins.hasPin ? PinMode.verifyOld : PinMode.create);

  void cancel() {
    if (!_unlocked) return;
    phase = AuthPhase.app;
    notifyListeners();
  }

  void _enter(PinMode m) {
    mode = m;
    _buf = '';
    _first = null;
    error = null;
    phase = AuthPhase.pin;
    notifyListeners();
  }

  void backspace() {
    if (_busy || _buf.isEmpty) return;
    _buf = _buf.substring(0, _buf.length - 1);
    error = null;
    notifyListeners();
  }

  Future<void> press(String digit) async {
    if (_busy || _buf.length >= 4) return;
    final now = _clock.now();
    final until = _lockedUntil;
    if (until != null && now.isBefore(until)) {
      error = "Ko'p xato. ${until.difference(now).inSeconds + 1} soniyadan keyin urinib ko'ring";
      notifyListeners();
      return;
    }
    _buf += digit;
    error = null;
    notifyListeners();
    if (_buf.length < 4) return;

    _busy = true;
    await Future<void>.delayed(const Duration(milliseconds: 120)); // 4-nuqta ko'rinib turishi uchun
    final pin = _buf;
    switch (mode) {
      case PinMode.login:
      case PinMode.verifyOld:
        if (_pins.verify(pin)) {
          _fails = 0;
          if (mode == PinMode.login) {
            _unlock();
          } else {
            mode = PinMode.create;
            _buf = '';
          }
        } else {
          if (++_fails >= 5) {
            _fails = 0;
            _lockedUntil = _clock.now().add(const Duration(seconds: 30));
          }
          _fail("Parol noto'g'ri");
        }
      case PinMode.create:
        _first = pin;
        mode = PinMode.confirm;
        _buf = '';
      case PinMode.confirm:
        if (pin != _first) {
          mode = PinMode.create;
          _fail('Parollar mos kelmadi, qaytadan kiriting');
        } else {
          try {
            await _pins.setPin(pin);
            _unlock();
          } on DomainException catch (e) {
            mode = PinMode.create;
            _fail(e.message);
          }
        }
    }
    _busy = false;
    notifyListeners();
  }

  void _unlock() {
    _unlocked = true;
    _buf = '';
    error = null;
    phase = AuthPhase.app;
  }

  void _fail(String message) {
    shakes++;
    _buf = '';
    error = message;
  }
}
