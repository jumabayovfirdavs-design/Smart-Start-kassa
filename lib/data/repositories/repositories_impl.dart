import '../../domain/entities/cash_session.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/repositories.dart';
import '../local/key_value_store.dart';
import '../mappers.dart';
import 'json_list_repository.dart';

class ClassRepositoryImpl extends JsonListRepository<SchoolClass> implements ClassRepository {
  ClassRepositoryImpl(KeyValueStore s) : super(s, 'classes');
  @override
  SchoolClass decode(Json j) => classFromJson(j);
  @override
  Json encode(SchoolClass i) => classToJson(i);
  @override
  String idOf(SchoolClass i) => i.id;
}

class StudentRepositoryImpl extends JsonListRepository<Student> implements StudentRepository {
  StudentRepositoryImpl(KeyValueStore s) : super(s, 'students');
  @override
  Student decode(Json j) => studentFromJson(j);
  @override
  Json encode(Student i) => studentToJson(i);
  @override
  String idOf(Student i) => i.id;
}

class PaymentRepositoryImpl extends JsonListRepository<Payment> implements PaymentRepository {
  PaymentRepositoryImpl(KeyValueStore s) : super(s, 'payments');
  @override
  Payment decode(Json j) => paymentFromJson(j);
  @override
  Json encode(Payment i) => paymentToJson(i);
  @override
  String idOf(Payment i) => i.id;
}

class CashSessionRepositoryImpl extends JsonListRepository<CashSession> implements CashSessionRepository {
  CashSessionRepositoryImpl(KeyValueStore s) : super(s, 'cash_sessions');
  @override
  CashSession decode(Json j) => sessionFromJson(j);
  @override
  Json encode(CashSession i) => sessionToJson(i);
  @override
  String idOf(CashSession i) => i.id;
}
