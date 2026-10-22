import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/formatters.dart';
import '../../domain/entities/payment.dart';
import '../controllers/cash_controller.dart';
import '../controllers/period_controller.dart';
import '../controllers/reports_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/export_feedback.dart';
import '../widgets/metric_card.dart';
import '../widgets/month_picker.dart';
import '../widgets/observe.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final prefix = TextEditingController(text: isoDate(DateTime.now()));
  final reports = sl<ReportsController>();
  final period = sl<PeriodController>();

  @override
  Widget build(BuildContext context) => Observe(
      on: [sl<CashController>(), period],
      builder: (context) {
        final rows = reports.search(prefix.text);
        int sum(bool Function(Payment) t) => rows.where((d) => t(d.payment)).fold<int>(0, (a, d) => a + d.payment.amount);
        return ListView(padding: pagePadding, children: [
          const Text('Hisobotlar', style: pageTitle),
          const Text("Hisobotlar Excel (.xlsx) fayl bo'lib yuklanadi", style: pageSubtitle),
          const SizedBox(height: 20),
          Wrap(spacing: 14, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
            SizedBox(
                width: 340,
                child: TextField(
                    controller: prefix,
                    decoration: searchDecoration('Kun 2026-10-20 / Oy 2026-10 / Yil 2026')
                        .copyWith(prefixIcon: const Icon(Icons.event_outlined, color: AppColors.muted)),
                    onChanged: (_) => setState(() {}))),
            FilledButton.icon(
                onPressed: () => runExport(context, () => reports.exportPayments(prefix.text)),
                icon: const Icon(Icons.download_outlined),
                label: const Text("To'lovlar (Excel)")),
          ]),
          const SizedBox(height: 14),
          Wrap(spacing: 14, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
            const Text('Oylik hisobot:', style: TextStyle(fontWeight: FontWeight.w600)),
            const MonthPicker(),
            OutlinedButton.icon(
                onPressed: () => runExport(context, () => reports.exportMonthly(period.month)),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Sinflar va qarzdorlar (Excel)')),
          ]),
          const SizedBox(height: 18),
          Wrap(spacing: 14, runSpacing: 14, children: [
            MetricCard(title: 'Jami tushum', value: formatMoney(sum((_) => true)), color: AppColors.green, valueColor: AppColors.green),
            MetricCard(title: "To'lovlar soni", value: '${rows.length}'),
            for (final m in PaymentMethod.values) MetricCard(title: m.label, value: formatMoney(sum((p) => p.method == m)), color: AppColors.cyan),
          ]),
          const SizedBox(height: 20),
          rows.isEmpty
              ? const AppCard(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text("Bu davrda to'lov yo'q", style: pageSubtitle))))
              : AppCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(columns: const [
                          DataColumn(label: Text('SANA')),
                          DataColumn(label: Text('SOAT')),
                          DataColumn(label: Text("O'QUVCHI")),
                          DataColumn(label: Text('SINF')),
                          DataColumn(label: Text('OY UCHUN')),
                          DataColumn(label: Text('TUR')),
                          DataColumn(label: Text('SUMMA'), numeric: true),
                        ], rows: [
                          for (final d in rows)
                            DataRow(cells: [
                              DataCell(Text(formatDate(d.payment.paidAt))),
                              DataCell(Text(formatTime(d.payment.paidAt))),
                              DataCell(Text(d.studentName, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(d.className)),
                              DataCell(Text(d.payment.forMonth.label)),
                              DataCell(Text(d.payment.method.label)),
                              DataCell(Text(formatMoney(d.payment.amount), style: const TextStyle(fontWeight: FontWeight.w600))),
                            ])
                        ])),
                  ),
                ),
        ]);
      });
}
