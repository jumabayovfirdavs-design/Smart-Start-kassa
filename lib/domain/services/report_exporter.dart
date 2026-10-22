import '../entities/reports.dart';

/// Hisobotlarni Excel (.xlsx) faylga yuklaydi. Har bir metod saqlangan fayl yo'lini qaytaradi.
abstract interface class ReportExporter {
  Future<String> exportPayments({required String title, required List<PaymentDetails> rows});
  Future<String> exportDailyReport(DailyReport report);
  Future<String> exportDebtors(DebtorsReport report);
  Future<String> exportMonthly(MonthlyReport report);
  Future<void> reveal(String path);
}
