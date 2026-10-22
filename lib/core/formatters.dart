String _two(int n) => n.toString().padLeft(2, '0');

String formatMoney(num n) {
  var s = n.round().toString();
  final neg = s.startsWith('-');
  if (neg) s = s.substring(1);
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return (neg ? '-' : '') + b.toString();
}

String formatDate(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year}';
String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';
String isoDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

int _seq = 0;
String newId() => '${DateTime.now().microsecondsSinceEpoch}${_seq++}';
