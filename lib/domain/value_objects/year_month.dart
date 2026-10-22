const uzMonths = [
  'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
  'Iyul', 'Avgust', 'Sentyabr', 'Oktyabr', 'Noyabr', 'Dekabr'
];

/// Yil+oy qiymat obyekti (immutable). "2026-10" kabi satrlar bilan ishlashni yo'qotadi.
class YearMonth implements Comparable<YearMonth> {
  const YearMonth(this.year, this.month);
  factory YearMonth.fromDate(DateTime d) => YearMonth(d.year, d.month);
  factory YearMonth.parse(String s) => YearMonth(int.parse(s.substring(0, 4)), int.parse(s.substring(5, 7)));
  static final _re = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');
  static YearMonth? tryParse(String s) => _re.hasMatch(s.trim()) ? YearMonth.parse(s.trim()) : null;

  final int year;
  final int month;

  YearMonth shift(int n) {
    final i = year * 12 + (month - 1) + n;
    return YearMonth(i ~/ 12, i % 12 + 1);
  }

  YearMonth next() => shift(1);
  String get key => '$year-${month.toString().padLeft(2, '0')}';
  String get label => '${uzMonths[month - 1]} $year';

  @override
  int compareTo(YearMonth o) => (year * 12 + month) - (o.year * 12 + o.month);
  bool operator <(YearMonth o) => compareTo(o) < 0;
  bool operator <=(YearMonth o) => compareTo(o) <= 0;
  bool operator >(YearMonth o) => compareTo(o) > 0;
  bool operator >=(YearMonth o) => compareTo(o) >= 0;
  @override
  bool operator ==(Object o) => o is YearMonth && o.year == year && o.month == month;
  @override
  int get hashCode => Object.hash(year, month);
  @override
  String toString() => key;
}
