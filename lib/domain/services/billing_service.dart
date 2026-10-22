import '../entities/payment.dart';
import '../entities/reports.dart';
import '../entities/student.dart';
import '../repositories/repositories.dart';
import '../value_objects/year_month.dart';

/// Hisob-kitob qoidalari: kerak / to'langan / qarz / eski qarz.
class BillingService {
  BillingService(this._payments);
  final PaymentRepository _payments;

  int dueOf(Student s, YearMonth m) => s.isActiveIn(m) ? s.monthlyFee : 0;

  List<Payment> paymentsFor(Student s, YearMonth m) =>
      _payments.all.where((p) => p.studentId == s.id && p.forMonth == m).toList();

  int paidFor(Student s, YearMonth m) => paymentsFor(s, m).fold<int>(0, (a, p) => a + p.amount);

  int debtOf(Student s, YearMonth m) {
    final d = dueOf(s, m) - paidFor(s, m);
    return d > 0 ? d : 0;
  }

  /// Tanlangan oydan OLDINGI oylardagi to'lanmagan qarz.
  /// Har oy ALOHIDA hisoblanadi (debtOf va openMonths bilan bir xil qoida): bir oyga ortiqcha
  /// to'langan summa boshqa oyning qarzini kamaytirmaydi. Aks holda ekran, to'lov oynasi
  /// va Excel turli raqam ko'rsatadi.
  int oldDebtOf(Student s, YearMonth m) {
    var t = 0;
    for (var k = s.startMonth; k < m; k = k.next()) {
      t += debtOf(s, k);
    }
    return t;
  }

  /// To'lov oynasi uchun: qarzi bor oylar (+ tanlangan oyning o'zi).
  List<MonthBalance> openMonths(Student s, YearMonth upTo) {
    final result = <MonthBalance>[];
    for (var k = s.startMonth; k <= upTo; k = k.next()) {
      final left = dueOf(s, k) - paidFor(s, k);
      if (left > 0 || k == upTo) result.add(MonthBalance(k, left > 0 ? left : 0));
    }
    return result;
  }

  MonthStats statsFor(Iterable<Student> students, YearMonth m) {
    var n = 0, pc = 0, due = 0, paid = 0, debt = 0, old = 0;
    for (final s in students) {
      n++;
      final d = dueOf(s, m), p = paidFor(s, m);
      due += d;
      paid += p;
      debt += debtOf(s, m);
      old += oldDebtOf(s, m);
      if (d > 0 && p >= d) pc++;
    }
    return MonthStats(students: n, fullyPaid: pc, due: due, paid: paid, debt: debt, oldDebt: old);
  }
}
