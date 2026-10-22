import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../domain/services/billing_service.dart';
import '../controllers/cash_controller.dart';
import '../controllers/period_controller.dart';
import '../controllers/reports_controller.dart';
import '../controllers/school_controller.dart';
import '../dialogs/class_dialog.dart';
import '../dialogs/student_dialog.dart';
import '../theme/app_theme.dart';
import '../widgets/export_feedback.dart';
import '../widgets/month_picker.dart';
import '../widgets/observe.dart';
import '../widgets/stats_grid.dart';
import '../widgets/student_table.dart';

class ClassPage extends StatefulWidget {
  const ClassPage({super.key, required this.classId});
  final String classId;
  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  String query = '';
  final school = sl<SchoolController>();
  final period = sl<PeriodController>();
  final reports = sl<ReportsController>();

  @override
  Widget build(BuildContext context) => Observe(
      on: [school, period, sl<CashController>()],
      builder: (context) {
        final c = school.classById(widget.classId);
        if (c == null) return const Scaffold();
        final m = period.month;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.text,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            shape: const Border(bottom: BorderSide(color: AppColors.border)),
            title: Text('${c.name} sinf', style: const TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              const MonthPicker(),
              const SizedBox(width: 8),
              TextButton.icon(onPressed: () => showClassDialog(context, c), icon: const Icon(Icons.edit_outlined, size: 18), label: const Text('Rahbar')),
              TextButton.icon(
                  onPressed: () => runExport(context, () => reports.exportDebtors(c, m, includeOld: false)),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Shu oy qarzdorlari (Excel)')),
              TextButton.icon(
                  onPressed: () => runExport(context, () => reports.exportDebtors(c, m, includeOld: true)),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Umumiy qarzdorlar (Excel)')),
              IconButton(
                  tooltip: "Sinfni o'chirish",
                  icon: const Icon(Icons.delete_outline, color: AppColors.red),
                  onPressed: () async {
                    await school.removeClass(c.id);
                    if (context.mounted) Navigator.pop(context);
                  }),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
              onPressed: () => showStudentDialog(context, c.id),
              icon: const Icon(Icons.add),
              label: const Text("O'quvchi qo'shish")),
          body: ListView(padding: pagePadding, children: [
            if (c.teacher.isNotEmpty || c.teacherPhone.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(children: [
                    const Icon(Icons.person_outline, size: 18, color: AppColors.muted),
                    const SizedBox(width: 6),
                    Text('${c.teacher}  ${c.teacherPhone}', style: pageSubtitle),
                  ])),
            StatsGrid(sl<BillingService>().statsFor(school.studentsOf(c.id), m)),
            const SizedBox(height: 20),
            TextField(decoration: searchDecoration('Shu sinfdan qidirish...'), onChanged: (v) => setState(() => query = v)),
            const SizedBox(height: 16),
            StudentTable(students: school.search(query, classId: c.id), month: m),
            const SizedBox(height: 80),
          ]),
        );
      });
}
