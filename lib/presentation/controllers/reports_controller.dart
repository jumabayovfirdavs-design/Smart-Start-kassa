import '../../core/errors.dart';
import '../../core/formatters.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/reports.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/services/receipt_printer.dart';
import '../../domain/services/report_exporter.dart';
import '../../domain/usecases/build_daily_report.dart';
import '../../domain/usecases/build_debtors_report.dart';
import '../../domain/usecases/build_monthly_report.dart';
import '../../domain/value_objects/year_month.dart';

class ReportsController {
  ReportsController(this._daily, this._debtors, this._monthly, this._printer, this._exporter, this._payments, this._students, this._classes);
  final BuildDailyReport _daily;
  final BuildDebtorsReport _debtors;
  final BuildMonthlyReport _monthly;
  final ReceiptPrinter _printer;
  final ReportExporter _exporter;
  final PaymentRepository _payments;
  final StudentRepository _students;
  final ClassRepository _classes;

  // Faqat to'lov cheki printerga chiqadi
  Future<void> printReceipt(Payment p) => _printer.printPayment(details(p));

  // Qolgan hisobotlar Excel bo'lib yuklanadi (fayl yo'lini qaytaradi)
  Future<String> exportDay(DateTime day) => _exporter.exportDailyReport(_daily(day));
  Future<String> exportDebtors(SchoolClass c, YearMonth m, {required bool includeOld}) =>
      _exporter.exportDebtors(_debtors(c, m, includeOld: includeOld));
  Future<String> exportMonthly(YearMonth m) => _exporter.exportMonthly(_monthly(m));
  Future<String> exportPayments(String prefix) {
    final rows = search(prefix);
    if (rows.isEmpty) throw const DomainException("Bu davrda to'lov yo'q");
    return _exporter.exportPayments(title: prefix.trim().isEmpty ? 'Barcha davr' : prefix.trim(), rows: rows);
  }

  Future<void> reveal(String path) => _exporter.reveal(path);

  PaymentDetails details(Payment p) {
    final s = _students.all.where((x) => x.id == p.studentId).firstOrNull;
    final c = s == null ? null : _classes.all.where((x) => x.id == s.classId).firstOrNull;
    return PaymentDetails(p, s?.fullName ?? '?', s?.contract ?? '', c?.name ?? '');
  }

  /// prefix: "2026-10-20" (kun), "2026-10" (oy) yoki "2026" (yil)
  List<PaymentDetails> search(String prefix) => _payments.all
      .where((p) => isoDate(p.paidAt).startsWith(prefix.trim()))
      .map(details)
      .toList()
      .reversed
      .toList();
}
