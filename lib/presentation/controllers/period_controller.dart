import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/clock.dart';
import '../../domain/value_objects/year_month.dart';

/// Tanlangan oy. Haqiqiy (joriy) oyni kuzatadi: oy almashganda o'zi yangilanadi.
class PeriodController extends ChangeNotifier {
  PeriodController(Clock clock)
      : _clock = clock,
        _current = YearMonth.fromDate(clock.now()),
        _month = YearMonth.fromDate(clock.now()) {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _syncWithClock());
  }
  final Clock _clock;
  YearMonth _current;
  YearMonth _month;
  Timer? _timer;

  YearMonth get month => _month;
  YearMonth get current => _current;
  bool get isCurrent => _month == _current;
  List<YearMonth> get choices => List.generate(13, (i) => _current.shift(i - 6));

  void select(YearMonth m) {
    _month = m;
    notifyListeners();
  }

  void goToCurrent() => select(_current);

  void _syncWithClock() {
    final real = YearMonth.fromDate(_clock.now());
    if (real == _current) return;
    final wasFollowing = _month == _current; // foydalanuvchi joriy oyni ko'rib turgan bo'lsa, yangi oyga o'tadi
    _current = real;
    if (wasFollowing) _month = real;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
