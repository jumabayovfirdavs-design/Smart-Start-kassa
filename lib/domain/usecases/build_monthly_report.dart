import '../entities/reports.dart';
import '../repositories/repositories.dart';
import '../services/billing_service.dart';
import '../value_objects/year_month.dart';

/// Tanlangan oy bo'yicha: sinflar jadvali va har bir o'quvchi holati.
class BuildMonthlyReport {
  BuildMonthlyReport(this._classes, this._students, this._billing);
  final ClassRepository _classes;
  final StudentRepository _students;
  final BillingService _billing;

  MonthlyReport call(YearMonth m) {
    final classRows = <ClassMonthRow>[];
    final studentRows = <StudentMonthRow>[];
    for (final c in _classes.all) {
      final list = _students.all.where((s) => s.classId == c.id).toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName));
      final st = _billing.statsFor(list, m);
      classRows.add(ClassMonthRow(
          className: c.name, teacher: c.teacher, students: st.students, fullyPaid: st.fullyPaid,
          due: st.due, paid: st.paid, debt: st.debt, oldDebt: st.oldDebt));
      for (final s in list) {
        final due = _billing.dueOf(s, m), paid = _billing.paidFor(s, m);
        final status = due == 0 ? (paid > 0 ? "Ortiqcha to'lov" : "Hisob yo'q") : paid >= due ? "To'landi" : paid == 0 ? "To'lanmadi" : 'Qisman';
        studentRows.add(StudentMonthRow(
            className: c.name, contract: s.contract, fullName: s.fullName, fatherName: s.fatherName,
            phone: s.phone, monthlyFee: s.monthlyFee, due: due, paid: paid,
            debt: _billing.debtOf(s, m), oldDebt: _billing.oldDebtOf(s, m), status: status));
      }
    }
    return MonthlyReport(m, classRows, studentRows);
  }
}
