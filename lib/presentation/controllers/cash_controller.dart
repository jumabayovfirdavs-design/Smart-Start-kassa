import 'package:flutter/foundation.dart';

import '../../domain/entities/cash_session.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/services/cash_desk.dart';
import '../../domain/usecases/register_payment.dart';
import '../../domain/value_objects/year_month.dart';

class CashController extends ChangeNotifier {
  CashController(this._desk, this._register, this._sessions);
  final CashDesk _desk;
  final RegisterPayment _register;
  final CashSessionRepository _sessions;

  CashSession? get session => _desk.current;
  bool get isOpen => session != null;
  List<CashSession> get closedSessions => _sessions.all.where((s) => s.closedAt != null).toList().reversed.toList();

  Future<void> open(String cashier) async {
    await _desk.open(cashier);
    notifyListeners();
  }

  Future<CashSession> close() async {
    final s = await _desk.close();
    notifyListeners();
    return s;
  }

  Future<Payment> pay(Student s, int amount, PaymentMethod method, YearMonth forMonth) async {
    final p = await _register(student: s, amount: amount, method: method, forMonth: forMonth);
    notifyListeners();
    return p;
  }
}
