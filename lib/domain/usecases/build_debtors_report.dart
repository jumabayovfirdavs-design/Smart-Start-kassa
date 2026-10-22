import '../entities/reports.dart';
import '../entities/school_class.dart';
import '../repositories/repositories.dart';
import '../services/billing_service.dart';
import '../value_objects/year_month.dart';

class BuildDebtorsReport {
  BuildDebtorsReport(this._students, this._billing);
  final StudentRepository _students;
  final BillingService _billing;

  DebtorsReport call(SchoolClass c, YearMonth m, {required bool includeOld}) {
    final rows = <DebtorRow>[];
    for (final s in _students.all.where((s) => s.classId == c.id)) {
      final cur = _billing.debtOf(s, m), old = _billing.oldDebtOf(s, m);
      if (includeOld ? cur + old > 0 : cur > 0) rows.add(DebtorRow(s, cur, old));
    }
    return DebtorsReport(c, m, includeOld, rows);
  }
}
