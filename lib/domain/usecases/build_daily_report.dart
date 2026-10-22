import '../../core/formatters.dart';
import '../entities/payment.dart';
import '../entities/reports.dart';
import '../entities/school_class.dart';
import '../repositories/repositories.dart';

class BuildDailyReport {
  BuildDailyReport(this._classes, this._students, this._payments, this._sessions);
  final ClassRepository _classes;
  final StudentRepository _students;
  final PaymentRepository _payments;
  final CashSessionRepository _sessions;

  DailyReport call(DateTime day) {
    final pays = _payments.all.where((p) => sameDay(p.paidAt, day)).toList();
    final session = _sessions.all.where((s) => sameDay(s.openedAt, day)).lastOrNull;
    final byId = {for (final s in _students.all) s.id: s};
    final groups = <ClassPayments>[];
    for (final c in _classes.all) {
      final perStudent = <String, int>{};
      for (final p in pays) {
        final s = byId[p.studentId];
        if (s == null || s.classId != c.id) continue;
        perStudent[s.id] = (perStudent[s.id] ?? 0) + p.amount;
      }
      if (perStudent.isEmpty) continue;
      groups.add(ClassPayments(c, [for (final e in perStudent.entries) StudentPaid(byId[e.key]!.fullName, e.value)]));
    }
    // O'quvchisi/sinfi topilmagan to'lovlar yo'qolib, JAMI bilan nomuvofiq bo'lib qolmasin.
    final known = {for (final c in _classes.all) c.id};
    final orphan = <String, int>{};
    for (final p in pays) {
      final s = byId[p.studentId];
      if (s == null || !known.contains(s.classId)) orphan[p.studentId] = (orphan[p.studentId] ?? 0) + p.amount;
    }
    if (orphan.isNotEmpty) {
      groups.add(ClassPayments(const SchoolClass(id: '?', name: "Noma'lum"),
          [for (final e in orphan.entries) StudentPaid("Noma'lum o'quvchi", e.value)]));
    }
    return DailyReport(
      day: day,
      cashier: session?.cashier ?? '',
      openedAt: session?.openedAt,
      closedAt: session?.closedAt,
      groups: groups,
      byMethod: {
        for (final m in PaymentMethod.values) m: pays.where((p) => p.method == m).fold<int>(0, (a, p) => a + p.amount)
      },
      total: pays.fold<int>(0, (a, p) => a + p.amount),
      paymentsCount: pays.length,
    );
  }
}
