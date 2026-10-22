import '../../core/formatters.dart';

class CashSession {
  const CashSession({required this.id, required this.cashier, required this.openedAt, this.closedAt, this.total = 0});
  final String id;
  final String cashier;
  final DateTime openedAt;
  final DateTime? closedAt;
  final int total;

  bool isOpenOn(DateTime now) => closedAt == null && sameDay(openedAt, now);
  CashSession closedWith(DateTime at, int total) =>
      CashSession(id: id, cashier: cashier, openedAt: openedAt, closedAt: at, total: total);
}
