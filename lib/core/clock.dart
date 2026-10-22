/// Vaqtni abstraksiya qilamiz: testda soxta vaqt berish mumkin (DIP).
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();
  @override
  DateTime now() => DateTime.now();
}
