import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../domain/entities/reports.dart';
import '../../domain/entities/school_class.dart';
import '../theme/app_theme.dart';
import 'status_pill.dart';

/// Home sahifadagi grid kartasi: sinf nomi, holati va shu oy hisob-kitobi.
class ClassCard extends StatelessWidget {
  const ClassCard({super.key, required this.schoolClass, required this.stats, required this.onTap});
  final SchoolClass schoolClass;
  final MonthStats stats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = schoolClass, s = stats;
    final ratio = s.due == 0 ? 0.0 : (s.paid / s.due).clamp(0.0, 1.0).toDouble();
    final StatusPill pill = s.due == 0
        ? const StatusPill("Hisob yo'q", AppColors.muted)
        : s.debt == 0
            ? const StatusPill("To'landi", AppColors.green)
            : s.paid == 0
                ? const StatusPill("To'lanmadi", AppColors.red)
                : const StatusPill('Qisman', AppColors.orange);

    Widget line(String label, String value, Color color) => Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ]),
        );

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0F0F1B33), blurRadius: 20, offset: Offset(0, 8))]),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3))),
                pill,
              ]),
              const SizedBox(height: 2),
              Text(c.teacher.isEmpty ? "Sinf rahbari kiritilmagan" : c.teacher,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.groups_2_outlined, size: 16, color: AppColors.muted),
                const SizedBox(width: 4),
                Text("${s.students} o'quvchi", style: const TextStyle(fontSize: 12)),
                const Spacer(),
                Text("${s.fullyPaid}/${s.students} to'lagan", style: const TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                      value: ratio, minHeight: 8, backgroundColor: AppColors.red.withAlpha(35), color: AppColors.green)),
              const SizedBox(height: 8),
              line('Kerak', formatMoney(s.due), AppColors.text),
              line("To'langan", formatMoney(s.paid), AppColors.green),
              line('Qarz', formatMoney(s.debt), s.debt > 0 ? AppColors.red : AppColors.muted),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Gridning oxiridagi "+ Sinf qo'shish" kartasi.
class AddClassCard extends StatelessWidget {
  const AddClassCard({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFFF8FBFF),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFBFD3F5), width: 1.4)),
        child: InkWell(
          onTap: onTap,
          child: const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.add, color: Colors.white, size: 28)),
              SizedBox(height: 10),
              Text("Sinf qo'shish", style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
          ),
        ),
      );
}
