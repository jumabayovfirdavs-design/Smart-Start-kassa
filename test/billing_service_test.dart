import 'package:flutter_test/flutter_test.dart';
import 'package:smart_kassa/domain/entities/payment.dart';
import 'package:smart_kassa/domain/entities/student.dart';
import 'package:smart_kassa/domain/repositories/repositories.dart';
import 'package:smart_kassa/domain/services/billing_service.dart';
import 'package:smart_kassa/domain/value_objects/year_month.dart';

/// Soxta (in-memory) repozitoriya: DIP tufayli bazasiz test qilish mumkin.
class FakePaymentRepository implements PaymentRepository {
  final items = <Payment>[];
  @override
  List<Payment> get all => items;
  @override
  Future<void> upsert(Payment p) async => items.add(p);
  @override
  Future<void> removeWhere(bool Function(Payment) t) async => items.removeWhere(t);
}

void main() {
  const oct = YearMonth(2026, 10);
  final student = Student(
      id: 's1', classId: 'c1', contract: '1', fullName: 'Test', fatherName: '', phone: '',
      monthlyFee: 2500000, startMonth: const YearMonth(2026, 8));

  test("bo'lib to'langan summa qarzni kamaytiradi", () async {
    final repo = FakePaymentRepository();
    final billing = BillingService(repo);
    await repo.upsert(Payment(
        id: 'p1', studentId: 's1', amount: 1000000, method: PaymentMethod.cash, forMonth: oct,
        paidAt: DateTime(2026, 10, 20), cashier: 'k'));
    expect(billing.debtOf(student, oct), 1500000);
  });

  test("eski qarz oldingi oylardan yig'iladi", () {
    final billing = BillingService(FakePaymentRepository());
    expect(billing.oldDebtOf(student, oct), 5000000); // avgust + sentyabr
  });

  test('ketgan oydan boshlab qarz yozilmaydi', () {
    final left = student.withEndMonth(oct);
    expect(BillingService(FakePaymentRepository()).dueOf(left, oct), 0);
  });
}
