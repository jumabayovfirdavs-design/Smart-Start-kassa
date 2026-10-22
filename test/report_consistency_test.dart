import 'package:flutter_test/flutter_test.dart';
import 'package:smart_kassa/domain/entities/cash_session.dart';
import 'package:smart_kassa/domain/entities/payment.dart';
import 'package:smart_kassa/domain/entities/school_class.dart';
import 'package:smart_kassa/domain/entities/student.dart';
import 'package:smart_kassa/domain/repositories/repositories.dart';
import 'package:smart_kassa/domain/services/billing_service.dart';
import 'package:smart_kassa/domain/usecases/build_daily_report.dart';
import 'package:smart_kassa/domain/usecases/build_monthly_report.dart';
import 'package:smart_kassa/domain/value_objects/year_month.dart';

class _Repo<T> implements EntityRepository<T> {
  _Repo(this.items);
  final List<T> items;
  @override
  List<T> get all => items;
  @override
  Future<void> upsert(T item) async => items.add(item);
  @override
  Future<void> removeWhere(bool Function(T) test) async => items.removeWhere(test);
}

class _Classes extends _Repo<SchoolClass> implements ClassRepository {
  _Classes(super.items);
}

class _Students extends _Repo<Student> implements StudentRepository {
  _Students(super.items);
}

class _Payments extends _Repo<Payment> implements PaymentRepository {
  _Payments(super.items);
}

class _Sessions extends _Repo<CashSession> implements CashSessionRepository {
  _Sessions(super.items);
}

/// Ekran, to'lov oynasi, Excel va kunlik hisobot BIR XIL raqam chiqarishi kerak.
void main() {
  const aug = YearMonth(2026, 8), sep = YearMonth(2026, 9), oct = YearMonth(2026, 10);
  const klass = SchoolClass(id: 'c1', name: '5-A');
  final student = Student(
      id: 's1', classId: 'c1', contract: '1', fullName: 'Ali', fatherName: '', phone: '',
      monthlyFee: 100, startMonth: aug);
  Payment pay(String id, YearMonth forMonth, int amount, {String studentId = 's1'}) => Payment(
      id: id, studentId: studentId, amount: amount, method: PaymentMethod.cash,
      forMonth: forMonth, paidAt: DateTime(2026, 10, 20, 9), cashier: 'k');

  test("ortiqcha to'lov boshqa oyning qarzini yashirmaydi: to'lov oynasi == Excel/ekran", () {
    final billing = BillingService(_Payments([pay('p1', aug, 150)])); // avgustga ortiqcha, sentyabrga 0
    final dialogOld = billing.openMonths(student, oct).where((m) => m.month < oct).fold<int>(0, (a, m) => a + m.remaining);
    expect(dialogOld, 100);
    expect(billing.oldDebtOf(student, oct), dialogOld);
  });

  test("oylik hisobot: Kerak - To'langan + Ortiqcha = Qarz", () {
    final billing = BillingService(_Payments([pay('p1', aug, 150)]));
    final rep = BuildMonthlyReport(_Classes([klass]), _Students([student]), billing).call(aug);
    final c = rep.classRows.single;
    expect(c.paid - c.due + c.debt, 50); // Ortiqcha ustuni
    expect(c.due - c.paid + (c.paid - c.due + c.debt), c.debt);
  });

  test("kunlik hisobot: sinflar yig'indisi == JAMI (o'quvchisi topilmagan to'lov ham)", () {
    final payments = _Payments([pay('p1', oct, 100), pay('p2', oct, 70, studentId: 'gone')]);
    final rep = BuildDailyReport(_Classes([klass]), _Students([student]), payments, _Sessions([])).call(DateTime(2026, 10, 20));
    expect(rep.total, 170);
    expect(rep.groups.fold<int>(0, (a, g) => a + g.total), rep.total);
  });
}
