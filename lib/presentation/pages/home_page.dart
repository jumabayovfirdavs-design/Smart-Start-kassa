import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../domain/services/billing_service.dart';
import '../controllers/cash_controller.dart';
import '../controllers/period_controller.dart';
import '../controllers/reports_controller.dart';
import '../controllers/school_controller.dart';
import '../dialogs/class_dialog.dart';
import '../theme/app_theme.dart';
import '../widgets/class_card.dart';
import '../widgets/export_feedback.dart';
import '../widgets/collection_summary.dart';
import '../widgets/month_picker.dart';
import '../widgets/observe.dart';
import '../widgets/student_table.dart';
import 'class_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String query = '';
  final school = sl<SchoolController>();
  final period = sl<PeriodController>();
  final billing = sl<BillingService>();
  final reports = sl<ReportsController>();

  /// Sinflar grid: bir qatorda 4 ta (juda tor oynada 3 yoki 2 ta).
  Widget _classGrid(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final cols = box.maxWidth >= 808 ? 4 : (box.maxWidth >= 600 ? 3 : 2);
        final m = period.month;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols, crossAxisSpacing: 16, mainAxisSpacing: 16, mainAxisExtent: 222),
          children: [
            for (final c in school.classes)
              ClassCard(
                schoolClass: c,
                stats: billing.statsFor(school.studentsOf(c.id), m),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClassPage(classId: c.id))),
              ),
            AddClassCard(onTap: () => showClassDialog(context)),
          ],
        );
      });

  @override
  Widget build(BuildContext context) => Observe(
      on: [school, period, sl<CashController>()],
      builder: (context) {
        final m = period.month;
        return ListView(padding: pagePadding, children: [
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 16, runSpacing: 12, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Barcha sinflar', style: pageTitle),
              Text("Oylik to'lovlar holati", style: pageSubtitle),
            ]),
            const MonthPicker(),
            if (!period.isCurrent)
              OutlinedButton.icon(
                  onPressed: period.goToCurrent, icon: const Icon(Icons.today_outlined, size: 18), label: const Text('Hozirgi oy')),
            FilledButton.icon(onPressed: () => showClassDialog(context), icon: const Icon(Icons.add), label: const Text("Sinf qo'shish")),
            OutlinedButton.icon(
                onPressed: () => runExport(context, () => reports.exportMonthly(m)),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Oylik hisobot (Excel)')),
          ]),
          const SizedBox(height: 20),
          TextField(
              decoration: searchDecoration("O'quvchini qidirish (familiya, shartnoma, telefon)"),
              onChanged: (v) => setState(() => query = v)),
          const SizedBox(height: 16),
          if (query.trim().isNotEmpty)
            StudentTable(students: school.search(query).take(30).toList(), month: m, showClass: true)
          else
            _classGrid(context),
          const SizedBox(height: 24),
          CollectionSummary(stats: billing.statsFor(school.students, m), month: m),
        ]);
      });
}
