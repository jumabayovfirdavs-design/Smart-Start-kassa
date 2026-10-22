import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../domain/entities/reports.dart';
import '../theme/app_theme.dart';
import 'metric_card.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid(this.stats, {super.key});
  final MonthStats stats;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 14, runSpacing: 14, children: [
        MetricCard(title: "O'quvchilar", value: '${stats.students}'),
        MetricCard(title: "To'laganlar", value: '${stats.fullyPaid} / ${stats.students}', color: AppColors.green, valueColor: AppColors.green),
        MetricCard(title: "To'lanishi kerak", value: formatMoney(stats.due), color: AppColors.muted),
        MetricCard(title: "To'langan", value: formatMoney(stats.paid), color: const Color(0xFF22C55E), valueColor: AppColors.green),
        MetricCard(title: 'Qarz (shu oy)', value: formatMoney(stats.debt), color: const Color(0xFFEF4444), valueColor: AppColors.red),
        MetricCard(title: 'Eski qarz', value: formatMoney(stats.oldDebt), color: const Color(0xFFF59E0B), valueColor: AppColors.orange),
      ]);
}
