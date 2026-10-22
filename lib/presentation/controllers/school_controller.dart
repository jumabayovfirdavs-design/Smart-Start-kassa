import 'package:flutter/foundation.dart';

import '../../core/formatters.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/value_objects/year_month.dart';

class SchoolController extends ChangeNotifier {
  SchoolController(this._classes, this._students, this._payments);
  final ClassRepository _classes;
  final StudentRepository _students;
  final PaymentRepository _payments;

  List<SchoolClass> get classes => _classes.all;
  List<Student> get students => _students.all;
  SchoolClass? classById(String id) => classes.where((c) => c.id == id).firstOrNull;
  List<Student> studentsOf(String classId) => students.where((s) => s.classId == classId).toList();

  List<Student> search(String q, {String? classId}) {
    final t = q.trim().toLowerCase();
    return students
        .where((s) => classId == null || s.classId == classId)
        .where((s) => t.isEmpty || '${s.fullName} ${s.fatherName} ${s.contract} ${s.phone}'.toLowerCase().contains(t))
        .toList();
  }

  Future<void> saveClass({SchoolClass? existing, required String name, String teacher = '', String phone = ''}) async {
    final c = existing?.copyWith(name: name, teacher: teacher, teacherPhone: phone) ??
        SchoolClass(id: newId(), name: name, teacher: teacher, teacherPhone: phone);
    await _classes.upsert(c);
    notifyListeners();
  }

  Future<void> removeClass(String id) async {
    final ids = studentsOf(id).map((s) => s.id).toSet();
    await _payments.removeWhere((p) => ids.contains(p.studentId));
    await _students.removeWhere((s) => s.classId == id);
    await _classes.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> addStudent({
    required String classId, required String contract, required String fullName,
    required String fatherName, required String phone, required int monthlyFee, required YearMonth start,
  }) async {
    await _students.upsert(Student(
        id: newId(), classId: classId, contract: contract, fullName: fullName,
        fatherName: fatherName, phone: phone, monthlyFee: monthlyFee, startMonth: start));
    notifyListeners();
  }

  Future<void> toggleLeft(Student s, YearMonth month) async {
    await _students.upsert(s.withEndMonth(s.hasLeft ? null : month));
    notifyListeners();
  }

  Future<void> removeStudent(String id) async {
    await _payments.removeWhere((p) => p.studentId == id);
    await _students.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}
