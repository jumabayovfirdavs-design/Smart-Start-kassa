import '../../core/clock.dart';
import '../../core/errors.dart';
import '../../core/formatters.dart';
import '../entities/payment.dart';
import '../entities/student.dart';
import '../repositories/repositories.dart';
import '../services/cash_desk.dart';
import '../value_objects/year_month.dart';

class RegisterPayment {
  RegisterPayment(this._payments, this._desk, this._clock);
  final PaymentRepository _payments;
  final CashDesk _desk;
  final Clock _clock;

  Future<Payment> call({
    required Student student,
    required int amount,
    required PaymentMethod method,
    required YearMonth forMonth,
  }) async {
    if (amount <= 0) throw const DomainException('Summani kiriting');
    final session = _desk.requireOpen();
    final p = Payment(
        id: newId(), studentId: student.id, amount: amount, method: method,
        forMonth: forMonth, paidAt: _clock.now(), cashier: session.cashier);
    await _payments.upsert(p);
    return p;
  }
}
