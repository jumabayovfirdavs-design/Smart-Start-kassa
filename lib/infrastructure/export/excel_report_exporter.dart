import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/clock.dart';
import '../../core/formatters.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/reports.dart';
import '../../domain/services/report_exporter.dart';
import 'xlsx_writer.dart';

/// Hisobotlarni Excel (.xlsx) qiladi va Yuklamalar (Downloads) ichidagi
/// "EduCore hisobotlar" papkasiga saqlaydi.
class ExcelReportExporter implements ReportExporter {
  ExcelReportExporter(this._clock);
  final Clock _clock;

  static const _head = XStyle.head;
  static const _bold = XStyle.bold;
  static const _title = XStyle.title;

  // ---------- hisobotlar ----------
  @override
  Future<String> exportPayments({required String title, required List<PaymentDetails> rows}) async {
    final b = _Book("To'lovlar");
    final s = b.first;
    var r = b.write(s, 0, ["EduCore - To'lovlar hisoboti ($title)"], _title);
    r = b.write(s, r, ["Sana va Soat - to'lov QILINGAN vaqt. 'Oy uchun' - to'lov qaysi oy hisobiga yozilgani."]);
    r = b.write(s, r, ['№', 'Sana', 'Soat', "O'quvchi", 'Sinf', 'Shartnoma', 'Oy uchun', "To'lov turi", "Summa (so'm)", 'Kassir'], _head);
    var i = 1, total = 0;
    for (final d in rows) {
      final p = d.payment;
      r = b.write(s, r, [i++, formatDate(p.paidAt), formatTime(p.paidAt), d.studentName, d.className, d.contract, p.forMonth.label, p.method.label, p.amount, p.cashier]);
      total += p.amount;
    }
    b.write(s, r, ['', '', '', '', '', '', '', 'JAMI', total, ''], _bold);
    b.widths(s, [6, 12, 8, 30, 12, 12, 18, 12, 16, 16]);

    // Xulosa varag'i: oylar, turlar va sinflar bo'yicha
    final x = b.sheet('Xulosa');
    var xr = b.write(x, 0, ["Oylar bo'yicha (to'lov qilingan oy)"], _title);
    xr = b.write(x, xr, ['Oy', "Summa (so'm)", "To'lovlar soni"], _head);
    final byMonth = <String, List<int>>{}, byMethod = <PaymentMethod, int>{}, byClass = <String, int>{};
    for (final d in rows) {
      final p = d.payment;
      final k = '${p.paidAt.year}-${p.paidAt.month.toString().padLeft(2, '0')}';
      final m = byMonth.putIfAbsent(k, () => [0, 0]);
      m[0] += p.amount;
      m[1] += 1;
      byMethod[p.method] = (byMethod[p.method] ?? 0) + p.amount;
      byClass[d.className] = (byClass[d.className] ?? 0) + p.amount;
    }
    for (final k in byMonth.keys.toList()..sort()) {
      xr = b.write(x, xr, [k, byMonth[k]![0], byMonth[k]![1]]);
    }
    xr += 1;
    xr = b.write(x, xr, ["To'lov turlari bo'yicha"], _title);
    xr = b.write(x, xr, ['Tur', "Summa (so'm)"], _head);
    for (final e in byMethod.entries) {
      xr = b.write(x, xr, [e.key.label, e.value]);
    }
    xr += 1;
    xr = b.write(x, xr, ["Sinflar bo'yicha"], _title);
    xr = b.write(x, xr, ['Sinf', "Summa (so'm)"], _head);
    for (final e in byClass.entries) {
      xr = b.write(x, xr, [e.key, e.value]);
    }
    b.widths(x, [22, 18, 16]);
    return _save(b, 'tolovlar');
  }

  @override
  Future<String> exportDailyReport(DailyReport rep) async {
    final b = _Book('Kunlik hisobot');
    final s = b.first;
    var r = b.write(s, 0, ['EduCore - Kunlik kassa hisoboti'], _title);
    r = b.write(s, r, ['Sana', formatDate(rep.day)]);
    r = b.write(s, r, ['Kassir', rep.cashier]);
    r = b.write(s, r, ['Ochilgan', rep.openedAt == null ? '' : formatTime(rep.openedAt!), 'Yopilgan', rep.closedAt == null ? '' : formatTime(rep.closedAt!)]);
    r++;
    r = b.write(s, r, ['Sinf', '№', "O'quvchi", "Summa (so'm)"], _head);
    for (final g in rep.groups) {
      var i = 1;
      for (final row in g.rows) {
        r = b.write(s, r, [g.schoolClass.name, i++, row.name, row.amount]);
      }
      r = b.write(s, r, ['', '', '${g.schoolClass.name} jami', g.total], _bold);
    }
    r++;
    r = b.write(s, r, ["To'lov turlari bo'yicha"], _bold);
    for (final e in rep.byMethod.entries) {
      r = b.write(s, r, ['', '', e.key.label, e.value]);
    }
    r = b.write(s, r, ['', '', 'JAMI', rep.total], _bold);
    r = b.write(s, r, ['', '', "To'laganlar (o'quvchi)", rep.studentsCount]);
    b.write(s, r, ['', '', "To'lovlar soni", rep.paymentsCount]);
    b.widths(s, [16, 6, 34, 18]);
    return _save(b, 'kassa-hisobot');
  }

  @override
  Future<String> exportDebtors(DebtorsReport rep) async {
    final b = _Book('Qarzdorlar');
    final s = b.first;
    var r = b.write(s, 0, ['EduCore - Qarzdorlar (${rep.schoolClass.name} sinf)'], _title);
    r = b.write(s, r, [rep.includeOld ? 'Umumiy (${rep.month.label} gacha)' : rep.month.label, 'Sana', formatDate(_clock.now())]);
    r++;
    r = b.write(s, r, rep.includeOld
        ? ['№', "O'quvchi", 'Otasi', 'Telefon', 'Shu oy qarzi', 'Eski qarz', 'Jami qarz']
        : ['№', "O'quvchi", 'Otasi', 'Telefon', 'Qarz'], _head);
    var i = 1, cur = 0, old = 0;
    for (final d in rep.rows) {
      cur += d.current;
      old += d.old;
      r = b.write(s, r, rep.includeOld
          ? [i++, d.student.fullName, d.student.fatherName, d.student.phone, d.current, d.old, d.current + d.old]
          : [i++, d.student.fullName, d.student.fatherName, d.student.phone, d.current]);
    }
    b.write(s, r, rep.includeOld ? ['', 'JAMI', '', '', cur, old, cur + old] : ['', 'JAMI', '', '', cur], _bold);
    b.widths(s, [6, 30, 24, 16, 16, 16, 16]);
    return _save(b, 'qarzdorlar-${rep.schoolClass.name}');
  }

  @override
  Future<String> exportMonthly(MonthlyReport rep) async {
    final b = _Book('Sinflar');
    final s = b.first;
    var r = b.write(s, 0, ['EduCore - Oylik hisobot: ${rep.month.label}'], _title);
    r = b.write(s, r, ["To'langan - aynan shu OY UCHUN qilingan to'lovlar (qachon to'langanidan qat'iy nazar). Kassa tushumi (Kunlik va To'lovlar hisoboti) esa to'lov SANASI bo'yicha."]);
    r = b.write(s, r, ["Qoida: Kerak - To'langan + Ortiqcha = Qarz. Eski qarz har oy alohida hisoblanadi."]);
    r++;
    r = b.write(s, r, ['Sinf', 'Sinf rahbari', "O'quvchi", "To'lagan", "Kerak (so'm)", "To'langan", 'Ortiqcha', 'Qarz', 'Eski qarz'], _head);
    for (final c in rep.classRows) {
      r = b.write(s, r, [c.className, c.teacher, c.students, c.fullyPaid, c.due, c.paid, c.paid - c.due + c.debt, c.debt, c.oldDebt]);
    }
    b.write(s, r, ['JAMI', '', rep.students, rep.fullyPaid, rep.due, rep.paid, rep.paid - rep.due + rep.debt, rep.debt, rep.oldDebt], _bold);
    b.widths(s, [12, 24, 10, 10, 16, 16, 14, 16, 16]);

    final t = b.sheet("O'quvchilar");
    var tr = b.write(t, 0, ['Sinf', 'Shartnoma', "O'quvchi", 'Otasi', 'Telefon', 'Oylik', 'Kerak', "To'langan", 'Ortiqcha', 'Qarz', 'Eski qarz', 'Holat'], _head);
    for (final x in rep.studentRows) {
      tr = b.write(t, tr, [x.className, x.contract, x.fullName, x.fatherName, x.phone, x.monthlyFee, x.due, x.paid, x.paid - x.due + x.debt, x.debt, x.oldDebt, x.status]);
    }
    b.widths(t, [10, 12, 30, 24, 16, 14, 14, 14, 14, 14, 14, 16]);
    return _save(b, 'oylik-${rep.month.key}');
  }

  // ---------- saqlash ----------
  Future<String> _save(_Book b, String base) async {
    final bytes = b.encode();
    final dir = await _folder();
    final n = _clock.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final safe = base.replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '-');
    final file = File('${dir.path}${Platform.pathSeparator}$safe-${isoDate(n)}-${two(n.hour)}${two(n.minute)}${two(n.second)}.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<Directory> _folder() async {
    final base = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}${Platform.pathSeparator}EduCore hisobotlar');
    await d.create(recursive: true);
    return d;
  }

  @override
  Future<void> reveal(String path) async {
    if (Platform.isWindows) {
      await Process.run('explorer.exe', ['/select,', path]);
    } else if (Platform.isMacOS) {
      await Process.run('open', ['-R', path]);
    } else {
      await Process.run('xdg-open', [File(path).parent.path]);
    }
  }
}

/// Varaqlarga qator yozish uchun kichik yordamchi (XlsxBook ustida).
class _Book {
  _Book(String firstName) : _x = XlsxBook(firstName);
  final XlsxBook _x;

  XlsxSheet get first => _x.first;
  XlsxSheet sheet(String name) => _x.sheet(name);
  List<int> encode() => _x.encode();

  /// Qator yozadi va keyingi qator raqamini qaytaradi.
  int write(XlsxSheet s, int row, List<Object?> values, [XStyle style = XStyle.none]) {
    for (var c = 0; c < values.length; c++) {
      s.set(row, c, values[c], style);
    }
    return row + 1;
  }

  void widths(XlsxSheet s, List<double> w) {
    for (var i = 0; i < w.length; i++) {
      s.setColumnWidth(i, w[i]);
    }
  }
}
