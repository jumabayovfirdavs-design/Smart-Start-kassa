import 'package:flutter_test/flutter_test.dart';
import 'package:smart_kassa/domain/entities/payment.dart';
import 'package:smart_kassa/domain/entities/school_class.dart';
import 'package:smart_kassa/domain/entities/student.dart';
import 'package:smart_kassa/domain/repositories/repositories.dart';
import 'package:smart_kassa/domain/services/billing_service.dart';
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

void main() {
  test("oylik hisobot: to'langan, qisman va to'lanmagan holatlar", () {
    const oct = YearMonth(2026, 10);
    Student st(String id, String name) => Student(
        id: id, classId: 'c1', contract: id, fullName: name, fatherName: '', phone: '',
        monthlyFee: 1000000, startMonth: oct);
    final payments = _Payments([
      Payment(id: 'p1', studentId: 'a', amount: 1000000, method: PaymentMethod.cash, forMonth: oct, paidAt: DateTime(2026, 10, 5), cashier: 'k'),
      Payment(id: 'p2', studentId: 'b', amount: 400000, method: PaymentMethod.card, forMonth: oct, paidAt: DateTime(2026, 10, 6), cashier: 'k'),
    ]);
    final report = BuildMonthlyReport(
            _Classes([const SchoolClass(id: 'c1', name: '1-A')]),
            _Students([st('a', 'Ali'), st('b', 'Bobur'), st('c', 'Vali')]),
            BillingService(payments))
        .call(oct);
    expect(report.due, 3000000);
    expect(report.paid, 1400000);
    expect(report.debt, 1600000);
    expect(report.studentRows.map((r) => r.status).toList(), ["To'landi", 'Qisman', "To'lanmadi"]);
  });
}
