import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mappers.dart';

/// Ilgari shu kompyuterda (SharedPreferences) saqlangan ma'lumotni Firestore'ga BIR MARTA ko'chiradi.
///
/// Xavfsizlik qoidalari:
///  - hisob uchun bir marta ishlaydi (belgi: `cloud_migrated_<uid>`);
///  - bulutda allaqachon ma'lumot bo'lsa (masalan boshqa qurilmadan) HECH NARSA YOZILMAYDI.
Future<void> migrateLocalDataOnce({
  required SharedPreferences prefs,
  required DocumentReference<Json> school,
  required String uid,
}) async {
  final flag = 'cloud_migrated_$uid';
  if (prefs.getBool(flag) == true) return;

  const collections = ['classes', 'students', 'payments', 'cash_sessions'];

  for (final name in collections) {
    final probe = await school.collection(name).limit(1).get();
    if (probe.docs.isNotEmpty) {
      await prefs.setBool(flag, true);
      return;
    }
  }

  for (final name in collections) {
    final raw = prefs.getString(name);
    if (raw == null) continue;
    final rows = (jsonDecode(raw) as List).cast<Json>();
    for (var i = 0; i < rows.length; i += 400) {
      final batch = school.firestore.batch();
      for (final row in rows.skip(i).take(400)) {
        batch.set(school.collection(name).doc(row['id'] as String), row);
      }
      await batch.commit();
    }
  }
  await prefs.setBool(flag, true);
}
