import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../controllers/cash_controller.dart';

Future<void> showOpenCashDialog(BuildContext context) {
  final name = TextEditingController();
  return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
            title: const Text('Kassani ochish'),
            content: TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Kassir ismi')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bekor')),
              FilledButton(
                  onPressed: () async {
                    await sl<CashController>().open(name.text);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Ochish')),
            ],
          ));
}
