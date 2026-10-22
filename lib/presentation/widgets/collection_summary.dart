import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../domain/entities/reports.dart';
import '../../domain/value_objects/year_month.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';

/// Shu oy bo'yicha: qancha undirilishi kerak, qancha undirildi, qancha qarz.
/// Ma'lumotlar o'zgarishi bilan real vaqtda yangilanadi (Observe orqali).
class CollectionSummary extends StatelessWidget {
  const CollectionSummary({super.key, required this.stats, required this.month});
  final MonthStats stats;
  final YearMonth month;

  Widget _big(IconData icon, String title, String value, String sub, Color color) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: color.withAlpha(16), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withAlpha(60))),
        child: Row(children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text("$value so'm", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.4))),
            Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ])),
        ]),
      );

  Widget _chip(String label, String value, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('$label: ', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final ratio = stats.due == 0 ? 0.0 : (stats.paid / stats.due).clamp(0.0, 1.0).toDouble();
    final percent = (ratio * 100).round();
    final allPaid = stats.due > 0 && stats.debt == 0;
    final tiles = [
      _big(Icons.account_balance_wallet_outlined, 'UNDIRILISHI KERAK', formatMoney(stats.due), '${month.label} uchun hisoblangan', AppColors.primary),
      _big(Icons.check_circle_outline, 'UNDIRILDI', formatMoney(stats.paid), "$percent% to'langan", AppColors.green),
      _big(Icons.error_outline, 'QARZ', formatMoney(stats.debt), allPaid ? "Hammasi to'langan ✓" : 'Hali undirilmagan', AppColors.red),
    ];
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text('${month.label} - undirish holati', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
          Text('$percent%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.green)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: ratio, minHeight: 12, backgroundColor: AppColors.red.withAlpha(40), color: AppColors.green)),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) => c.maxWidth >= 820
              ? Row(children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(width: 14),
                    Expanded(child: tiles[i]),
                  ]
                ])
              : Column(children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    tiles[i],
                  ]
                ]),
        ),
        const SizedBox(height: 16),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _chip("O'quvchilar", '${stats.students}', AppColors.text),
          _chip("To'laganlar", '${stats.fullyPaid} / ${stats.students}', AppColors.green),
          _chip('Eski qarz (alohida)', formatMoney(stats.oldDebt), AppColors.orange),
        ]),
      ]),
    );
  }
}
