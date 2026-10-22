import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/errors.dart';
import '../controllers/reports_controller.dart';

/// Excel yuklashni ishga tushiradi va natijani xabar (SnackBar) bilan ko'rsatadi.
Future<void> runExport(BuildContext context, Future<String> Function() action) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final path = await action();
    messenger.showSnackBar(SnackBar(
      duration: const Duration(seconds: 10),
      content: Text('Excel yuklandi: $path'),
      action: SnackBarAction(label: 'Papkani ochish', onPressed: () => sl<ReportsController>().reveal(path)),
    ));
  } on DomainException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Excel yuklanmadi: $e')));
  }
}
