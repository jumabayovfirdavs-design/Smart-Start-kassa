import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../domain/entities/school_class.dart';
import '../controllers/school_controller.dart';

Future<void> showClassDialog(BuildContext context, [SchoolClass? existing]) {
  final name = TextEditingController(text: existing?.name ?? '');
  final teacher = TextEditingController(text: existing?.teacher ?? '');
  final phone = TextEditingController(text: existing?.teacherPhone ?? '');
  return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
            title: Text(existing == null ? 'Yangi sinf' : "Sinf ma'lumoti"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Sinf nomi')),
              TextField(controller: teacher, decoration: const InputDecoration(labelText: 'Sinf rahbari')),
              TextField(controller: phone, decoration: const InputDecoration(labelText: 'Rahbar telefoni')),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bekor')),
              FilledButton(
                  onPressed: () async {
                    if (name.text.trim().isEmpty) return;
                    await sl<SchoolController>().saveClass(
                        existing: existing, name: name.text.trim(), teacher: teacher.text.trim(), phone: phone.text.trim());
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Saqlash')),
            ],
          ));
}
