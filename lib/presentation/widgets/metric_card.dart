import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rangli yuqori chizig'li ko'rsatkich kartasi.
class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.title, required this.value, this.color = AppColors.primary, this.valueColor});
  final String title, value;
  final Color color;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 190,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: 4, color: color),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: valueColor ?? AppColors.text)),
                ]),
              ),
            ]),
          ),
        ),
      );
}
