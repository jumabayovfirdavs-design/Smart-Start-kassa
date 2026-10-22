import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../controllers/period_controller.dart';
import '../theme/app_theme.dart';
import 'observe.dart';

class MonthPicker extends StatelessWidget {
  const MonthPicker({super.key});
  @override
  Widget build(BuildContext context) {
    final period = sl<PeriodController>();
    return Observe(
        on: [period],
        builder: (_) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  value: period.month,
                  borderRadius: BorderRadius.circular(12),
                  icon: const Icon(Icons.expand_more, color: AppColors.muted),
                  items: [for (final m in period.choices) DropdownMenuItem(value: m, child: Text(m.label))],
                  onChanged: (m) => period.select(m!),
                ),
              ),
            ));
  }
}
