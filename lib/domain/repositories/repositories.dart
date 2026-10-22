import '../entities/cash_session.dart';
import '../entities/payment.dart';
import '../entities/school_class.dart';
import '../entities/student.dart';

/// Umumiy repozitoriya shartnomasi (ISP: faqat kerakli metodlar).
abstract interface class EntityRepository<T> {
  List<T> get all;
  Future<void> upsert(T item);
  Future<void> removeWhere(bool Function(T item) test);
}

abstract interface class ClassRepository implements EntityRepository<SchoolClass> {}

abstract interface class StudentRepository implements EntityRepository<Student> {}

abstract interface class PaymentRepository implements EntityRepository<Payment> {}

abstract interface class CashSessionRepository implements EntityRepository<CashSession> {}
