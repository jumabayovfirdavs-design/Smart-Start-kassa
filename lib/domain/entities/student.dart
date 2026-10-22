import '../value_objects/year_month.dart';

class Student {
  const Student({
    required this.id,
    required this.classId,
    required this.contract,
    required this.fullName,
    required this.fatherName,
    required this.phone,
    required this.monthlyFee,
    required this.startMonth,
    this.endMonth,
  });
  final String id;
  final String classId;
  final String contract;
  final String fullName;
  final String fatherName;
  final String phone;
  final int monthlyFee;
  final YearMonth startMonth;
  final YearMonth? endMonth; // ketgan oy (shu oydan boshlab qarz yozilmaydi)

  bool get hasLeft => endMonth != null;

  /// Biznes qoidasi: o'quvchi shu oyda to'lov qilishi shartmi?
  bool isActiveIn(YearMonth m) => m >= startMonth && (endMonth == null || m < endMonth!);

  Student withEndMonth(YearMonth? end) => Student(
      id: id, classId: classId, contract: contract, fullName: fullName, fatherName: fatherName,
      phone: phone, monthlyFee: monthlyFee, startMonth: startMonth, endMonth: end);
}
