import '../../core/clock.dart';
import '../../core/errors.dart';
import '../../core/formatters.dart';
import '../entities/cash_session.dart';
import '../repositories/repositories.dart';

/// Kassa smenasi hayot sikli: ochish -> to'lov qabul qilish -> yopish.
class CashDesk {
  CashDesk(this._sessions, this._payments, this._clock);
  final CashSessionRepository _sessions;
  final PaymentRepository _payments;
  final Clock _clock;

  CashSession? get current {
    final now = _clock.now();
    return _sessions.all.where((s) => s.isOpenOn(now)).lastOrNull;
  }

  CashSession requireOpen() => current ?? (throw const DomainException('Avval kassani oching'));

  Future<CashSession> open(String cashier) async {
    if (current != null) throw const DomainException('Kassa allaqachon ochiq');
    final s = CashSession(
        id: newId(), cashier: cashier.trim().isEmpty ? 'Kassir' : cashier.trim(), openedAt: _clock.now());
    await _sessions.upsert(s);
    return s;
  }

  Future<CashSession> close() async {
    final s = requireOpen();
    final now = _clock.now();
    final total = _payments.all.where((p) => sameDay(p.paidAt, now)).fold<int>(0, (a, p) => a + p.amount);
    final closed = s.closedWith(now, total);
    await _sessions.upsert(closed);
    return closed;
  }
}
