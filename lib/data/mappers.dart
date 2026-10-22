import '../domain/entities/cash_session.dart';
import '../domain/entities/payment.dart';
import '../domain/entities/school_class.dart';
import '../domain/entities/student.dart';
import '../domain/value_objects/year_month.dart';

typedef Json = Map<String, dynamic>;

SchoolClass classFromJson(Json j) => SchoolClass(
    id: j['id'] as String, name: j['name'] as String,
    teacher: (j['teacher'] ?? '') as String, teacherPhone: (j['teacherPhone'] ?? '') as String);
Json classToJson(SchoolClass c) => {'id': c.id, 'name': c.name, 'teacher': c.teacher, 'teacherPhone': c.teacherPhone};

Student studentFromJson(Json j) => Student(
    id: j['id'] as String, classId: j['classId'] as String, contract: (j['contract'] ?? '') as String,
    fullName: j['fullName'] as String, fatherName: (j['fatherName'] ?? '') as String,
    phone: (j['phone'] ?? '') as String, monthlyFee: j['monthlyFee'] as int,
    startMonth: YearMonth.parse(j['startMonth'] as String),
    endMonth: j['endMonth'] == null ? null : YearMonth.parse(j['endMonth'] as String));
Json studentToJson(Student s) => {
      'id': s.id, 'classId': s.classId, 'contract': s.contract, 'fullName': s.fullName,
      'fatherName': s.fatherName, 'phone': s.phone, 'monthlyFee': s.monthlyFee,
      'startMonth': s.startMonth.key, 'endMonth': s.endMonth?.key
    };

Payment paymentFromJson(Json j) => Payment(
    id: j['id'] as String, studentId: j['studentId'] as String, amount: j['amount'] as int,
    method: PaymentMethod.values.byName(j['method'] as String),
    forMonth: YearMonth.parse(j['forMonth'] as String),
    paidAt: DateTime.parse(j['paidAt'] as String), cashier: (j['cashier'] ?? '') as String);
Json paymentToJson(Payment p) => {
      'id': p.id, 'studentId': p.studentId, 'amount': p.amount, 'method': p.method.name,
      'forMonth': p.forMonth.key, 'paidAt': p.paidAt.toIso8601String(), 'cashier': p.cashier
    };

CashSession sessionFromJson(Json j) => CashSession(
    id: j['id'] as String, cashier: j['cashier'] as String, openedAt: DateTime.parse(j['openedAt'] as String),
    closedAt: j['closedAt'] == null ? null : DateTime.parse(j['closedAt'] as String), total: (j['total'] ?? 0) as int);
Json sessionToJson(CashSession s) => {
      'id': s.id, 'cashier': s.cashier, 'openedAt': s.openedAt.toIso8601String(),
      'closedAt': s.closedAt?.toIso8601String(), 'total': s.total
    };
