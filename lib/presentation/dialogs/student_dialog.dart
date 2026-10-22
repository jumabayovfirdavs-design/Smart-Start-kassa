import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../domain/value_objects/year_month.dart';
import '../controllers/period_controller.dart';
import '../controllers/school_controller.dart';
import '../widgets/observe.dart';

Future<void> showStudentDialog(BuildContext context, String classId) {
  final f = List.generate(5, (_) => TextEditingController());
  final start = TextEditingController(text: sl<PeriodController>().month.key);
  const labels = ['Shartnoma raqami', 'Familiya Ism', 'Otasining ismi', 'Telefon', "Oylik to'lov summasi"];
  return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
            title: const Text("Yangi o'quvchi"),
            content: SizedBox(
                width: 380,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  for (var i = 0; i < 5; i++)
                    TextField(
                        controller: f[i],
                        decoration: InputDecoration(labelText: labels[i]),
                        keyboardType: i == 4 ? TextInputType.number : null),
                  TextField(controller: start, decoration: const InputDecoration(labelText: 'Boshlanish oyi (YYYY-MM)')),
                ])),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bekor')),
              FilledButton(
                  onPressed: () async {
                    final fee = int.tryParse(f[4].text.replaceAll(RegExp(r'\D'), '')) ?? 0;
                    if (f[1].text.trim().isEmpty || fee <= 0) {
                      return showMessage(ctx, "Ism va summani kiriting");
                    }
                    await sl<SchoolController>().addStudent(
                        classId: classId, contract: f[0].text.trim(), fullName: f[1].text.trim(),
                        fatherName: f[2].text.trim(), phone: f[3].text.trim(), monthlyFee: fee,
                        start: YearMonth.tryParse(start.text) ?? sl<PeriodController>().month);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text("Qo'shish")),
            ],
          ));
}
