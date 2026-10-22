import '../value_objects/year_month.dart';

enum PaymentMethod {
  cash('Naqd'),
  card('Karta'),
  click('Click');

  const PaymentMethod(this.label);
  final String label;
}

class Payment {
  const Payment({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.method,
    required this.forMonth,
    required this.paidAt,
    required this.cashier,
  });
  final String id;
  final String studentId;
  final int amount;
  final PaymentMethod method;
  final YearMonth forMonth; // qaysi oy uchun to'langan
  final DateTime paidAt; // qachon (sana + soat)
  final String cashier;
}
