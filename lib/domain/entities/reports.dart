import '../value_objects/year_month.dart';
import 'payment.dart';
import 'school_class.dart';
import 'student.dart';

class MonthStats {
  const MonthStats({this.students = 0, this.fullyPaid = 0, this.due = 0, this.paid = 0, this.debt = 0, this.oldDebt = 0});
  final int students, fullyPaid, due, paid, debt, oldDebt;
}

class MonthBalance {
  const MonthBalance(this.month, this.remaining);
  final YearMonth month;
  final int remaining;
}

class PaymentDetails {
  const PaymentDetails(this.payment, this.studentName, this.contract, this.className);
  final Payment payment;
  final String studentName, contract, className;
}

class StudentPaid {
  const StudentPaid(this.name, this.amount);
  final String name;
  final int amount;
}

class ClassPayments {
  const ClassPayments(this.schoolClass, this.rows);
  final SchoolClass schoolClass;
  final List<StudentPaid> rows;
  int get total => rows.fold<int>(0, (a, r) => a + r.amount);
}

class DailyReport {
  const DailyReport({
    required this.day, required this.cashier, required this.openedAt, required this.closedAt,
    required this.groups, required this.byMethod, required this.total, required this.paymentsCount,
  });
  final DateTime day;
  final String cashier;
  final DateTime? openedAt, closedAt;
  final List<ClassPayments> groups;
  final Map<PaymentMethod, int> byMethod;
  final int total, paymentsCount;
  int get studentsCount => groups.fold<int>(0, (a, g) => a + g.rows.length);
}

class DebtorRow {
  const DebtorRow(this.student, this.current, this.old);
  final Student student;
  final int current, old;
}

class DebtorsReport {
  const DebtorsReport(this.schoolClass, this.month, this.includeOld, this.rows);
  final SchoolClass schoolClass;
  final YearMonth month;
  final bool includeOld;
  final List<DebtorRow> rows;
  int amountOf(DebtorRow r) => includeOld ? r.current + r.old : r.current;
  int get total => rows.fold<int>(0, (a, r) => a + amountOf(r));
}

class ClassMonthRow {
  const ClassMonthRow({
    required this.className, required this.teacher, required this.students, required this.fullyPaid,
    required this.due, required this.paid, required this.debt, required this.oldDebt,
  });
  final String className, teacher;
  final int students, fullyPaid, due, paid, debt, oldDebt;
}

class StudentMonthRow {
  const StudentMonthRow({
    required this.className, required this.contract, required this.fullName, required this.fatherName,
    required this.phone, required this.monthlyFee, required this.due, required this.paid,
    required this.debt, required this.oldDebt, required this.status,
  });
  final String className, contract, fullName, fatherName, phone, status;
  final int monthlyFee, due, paid, debt, oldDebt;
}

class MonthlyReport {
  const MonthlyReport(this.month, this.classRows, this.studentRows);
  final YearMonth month;
  final List<ClassMonthRow> classRows;
  final List<StudentMonthRow> studentRows;
  int get students => classRows.fold<int>(0, (a, r) => a + r.students);
  int get fullyPaid => classRows.fold<int>(0, (a, r) => a + r.fullyPaid);
  int get due => classRows.fold<int>(0, (a, r) => a + r.due);
  int get paid => classRows.fold<int>(0, (a, r) => a + r.paid);
  int get debt => classRows.fold<int>(0, (a, r) => a + r.debt);
  int get oldDebt => classRows.fold<int>(0, (a, r) => a + r.oldDebt);
}
