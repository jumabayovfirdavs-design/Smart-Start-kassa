import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/formatters.dart';
import '../../domain/entities/payment.dart';
import '../controllers/cash_controller.dart';
import '../controllers/reports_controller.dart';
import '../dialogs/open_cash_dialog.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/export_feedback.dart';
import '../widgets/metric_card.dart';
import '../widgets/observe.dart';

class CashPage extends StatelessWidget {
  const CashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cash = sl<CashController>();
    final reports = sl<ReportsController>();
    return Observe(
        on: [cash],
        builder: (context) {
          final now = DateTime.now();
          final today = reports.search(isoDate(now));
          int sum(bool Function(PaymentMethod) t) =>
              today.where((d) => t(d.payment.method)).fold<int>(0, (a, d) => a + d.payment.amount);
          final s = cash.session;
          final open = s != null;
          return ListView(padding: pagePadding, children: [
            const Text('Kassa', style: pageTitle),
            Text(formatDate(now), style: pageSubtitle),
            const SizedBox(height: 20),
            AppCard(
              child: Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: (open ? AppColors.green : AppColors.red).withAlpha(28), borderRadius: BorderRadius.circular(14)),
                  child: Icon(open ? Icons.lock_open_rounded : Icons.lock_outline_rounded, color: open ? AppColors.green : AppColors.red),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(open ? 'Kassa ochiq' : 'Kassa yopiq',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: open ? AppColors.green : AppColors.red)),
                  Text(open ? '${formatTime(s.openedAt)} da ochilgan · ${s.cashier}' : "To'lov qabul qilish uchun kassani oching",
                      style: pageSubtitle),
                ])),
                if (open)
                  FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.red),
                      onPressed: () async {
                        final closed = await cash.close();
                        if (!context.mounted) return;
                        await runExport(context, () => reports.exportDay(closed.openedAt));
                      },
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Kassani yopish va Excel hisobot'))
                else
                  FilledButton.icon(
                      onPressed: () => showOpenCashDialog(context), icon: const Icon(Icons.lock_open), label: const Text('Kassani ochish')),
              ]),
            ),
            if (open) ...[
              const SizedBox(height: 18),
              Wrap(spacing: 14, runSpacing: 14, children: [
                MetricCard(title: 'Bugungi jami', value: formatMoney(sum((_) => true)), color: AppColors.green, valueColor: AppColors.green),
                MetricCard(title: "To'lovlar soni", value: '${today.length}'),
                for (final m in PaymentMethod.values) MetricCard(title: m.label, value: formatMoney(sum((x) => x == m)), color: AppColors.cyan),
              ]),
            ],
            const SizedBox(height: 24),
            const Text('Yopilgan kassalar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: cash.closedSessions.isEmpty
                  ? const Padding(padding: EdgeInsets.all(20), child: Text('Hali yopilgan kassa yoq', style: pageSubtitle))
                  : Column(children: [
                      for (final c in cash.closedSessions)
                        ListTile(
                            leading: const Icon(Icons.receipt_long_outlined, color: AppColors.muted),
                            title: Text('${formatDate(c.openedAt)}  ${formatTime(c.openedAt)}-${formatTime(c.closedAt!)}  ·  ${c.cashier}',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text("${formatMoney(c.total)} so'm"),
                            trailing: OutlinedButton.icon(
                                onPressed: () => runExport(context, () => reports.exportDay(c.openedAt)),
                                icon: const Icon(Icons.download_outlined, size: 18),
                                label: const Text('Excel'))),
                    ]),
            ),
          ]);
        });
  }
}
