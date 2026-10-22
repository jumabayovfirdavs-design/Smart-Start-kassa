import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/cash_session.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/repositories.dart';
import '../mappers.dart';

/// Firestore'dagi bitta kolleksiyani EntityRepository sifatida ko'rsatadi.
///
/// Ishlash tartibi (UI va domain o'zgarmasligi uchun):
///  - [load] ilova ochilganda kolleksiyani BIR MARTA xotiraga (cache) o'qiydi;
///  - [all] sinxron — xotiradagi ro'yxatni qaytaradi (hisobotlar tez ishlaydi);
///  - [upsert] / [removeWhere] avval Firestore'ga yozadi, keyin xotirani yangilaydi.
abstract class FirestoreListRepository<T> implements EntityRepository<T> {
  FirestoreListRepository(this._col, {required this.decode, required this.encode, required this.idOf});

  final CollectionReference<Json> _col;
  final T Function(Json json) decode;
  final Json Function(T item) encode;
  final String Function(T item) idOf;

  /// Internet yo'q paytda Firestore yozuvni qurilmada navbatga qo'yadi va keyin yuboradi,
  /// lekin `await` server javobini kutib qotib qolmasligi uchun shu vaqtdan keyin davom etamiz.
  static const _ackTimeout = Duration(seconds: 4);
  static const _batchLimit = 400; // Firestore: bitta batch'da eng ko'pi 500 ta amal

  List<T> _items = [];

  Future<void> load() async {
    final snap = await _col.get();
    _items = snap.docs.map((d) => decode(d.data())).toList();
  }

  @override
  List<T> get all => List.unmodifiable(_items);

  @override
  Future<void> upsert(T item) async {
    await _commit(_col.doc(idOf(item)).set(encode(item)));
    final i = _items.indexWhere((e) => idOf(e) == idOf(item));
    if (i < 0) {
      _items.add(item);
    } else {
      _items[i] = item;
    }
  }

  @override
  Future<void> removeWhere(bool Function(T item) test) async {
    final doomed = _items.where(test).toList();
    if (doomed.isEmpty) return;
    for (var i = 0; i < doomed.length; i += _batchLimit) {
      final batch = _col.firestore.batch();
      for (final item in doomed.skip(i).take(_batchLimit)) {
        batch.delete(_col.doc(idOf(item)));
      }
      await _commit(batch.commit());
    }
    _items.removeWhere(test);
  }

  /// Ruxsat xatosi (permission-denied) kabi HAQIQIY xatolar yuqoriga chiqadi;
  /// faqat "javob kechikdi" (oflayn) holati xato hisoblanmaydi.
  Future<void> _commit(Future<void> write) async {
    try {
      await write.timeout(_ackTimeout);
    } on TimeoutException {
      // Oflayn: yozuv Firestore navbatida, ulanish tiklanganda yuboriladi.
    }
  }
}

class FirestoreClassRepository extends FirestoreListRepository<SchoolClass> implements ClassRepository {
  FirestoreClassRepository(super.col) : super(decode: classFromJson, encode: classToJson, idOf: _id);
  static String _id(SchoolClass c) => c.id;
}

class FirestoreStudentRepository extends FirestoreListRepository<Student> implements StudentRepository {
  FirestoreStudentRepository(super.col) : super(decode: studentFromJson, encode: studentToJson, idOf: _id);
  static String _id(Student s) => s.id;
}

class FirestorePaymentRepository extends FirestoreListRepository<Payment> implements PaymentRepository {
  FirestorePaymentRepository(super.col) : super(decode: paymentFromJson, encode: paymentToJson, idOf: _id);
  static String _id(Payment p) => p.id;
}

class FirestoreCashSessionRepository extends FirestoreListRepository<CashSession> implements CashSessionRepository {
  FirestoreCashSessionRepository(super.col) : super(decode: sessionFromJson, encode: sessionToJson, idOf: _id);
  static String _id(CashSession s) => s.id;
}
