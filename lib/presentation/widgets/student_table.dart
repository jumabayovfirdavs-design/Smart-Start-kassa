import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/formatters.dart';
import '../../domain/entities/student.dart';
import '../../domain/services/billing_service.dart';
import '../../domain/value_objects/year_month.dart';
import '../controllers/school_controller.dart';
import '../dialogs/pay_dialog.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';
import 'status_pill.dart';

class StudentTable extends StatelessWidget {
  const StudentTable({super.key, required this.students, required this.month, this.showClass = false});
  final List<Student> students;
  final YearMonth month;
  final bool showClass;

  @override
  Widget build(BuildContext context) {
    final billing = sl<BillingService>();
    final school = sl<SchoolController>();
    const small = TextStyle(fontSize: 11, color: AppColors.muted);

    DataRow row(Student s) {
      final due = billing.dueOf(s, month), paid = billing.paidFor(s, month), debt = billing.debtOf(s, month);
      return DataRow(cells: [
        DataCell(Text(s.contract)),
        DataCell(Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.fullName, style: TextStyle(fontWeight: FontWeight.w600, color: s.hasLeft ? AppColors.red : AppColors.text)),
          if (showClass) Text(school.classById(s.classId)?.name ?? '', style: small),
          if (s.hasLeft) Text('${s.endMonth!.label} dan ketgan', style: const TextStyle(fontSize: 11, color: AppColors.red)),
        ])),
        DataCell(Text(s.fatherName)),
        DataCell(Text(s.phone)),
        DataCell(Text(formatMoney(s.monthlyFee))),
        DataCell(Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(formatMoney(paid), style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w600)),
          for (final p in billing.paymentsFor(s, month))
            Text('${formatDate(p.paidAt)} ${formatTime(p.paidAt)} · ${p.method.label} · ${formatMoney(p.amount)}', style: small),
        ])),
        DataCell(Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(formatMoney(debt), style: TextStyle(color: debt > 0 ? AppColors.red : AppColors.muted, fontWeight: FontWeight.w600)),
          if (due > 0)
            paid == 0
                ? const StatusPill("to'lanmadi", AppColors.red)
                : debt > 0
                    ? const StatusPill('qisman', AppColors.orange)
                    : const StatusPill("to'landi", AppColors.green),
        ])),
        DataCell(Text(formatMoney(billing.oldDebtOf(s, month)), style: const TextStyle(color: AppColors.orange))),
        DataCell(Row(children: [
          FilledButton(onPressed: () => showPayDialog(context, s), child: const Text("To'lov")),
          const SizedBox(width: 4),
          TextButton(onPressed: () => school.toggleLeft(s, month), child: Text(s.hasLeft ? 'Qaytdi' : 'Ketdi')),
          IconButton(
              tooltip: "O'chirish",
              icon: const Icon(Icons.delete_outline, color: AppColors.muted),
              onPressed: () => school.removeStudent(s.id)),
        ])),
      ]);
    }

    if (students.isEmpty) {
      return const AppCard(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: Text("O'quvchi topilmadi", style: TextStyle(color: AppColors.muted)))));
    }
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(columns: const [
              DataColumn(label: Text('SHARTNOMA')),
              DataColumn(label: Text("O'QUVCHI")),
              DataColumn(label: Text('OTASI')),
              DataColumn(label: Text('TELEFON')),
              DataColumn(label: Text('OYLIK'), numeric: true),
              DataColumn(label: Text("TO'LANGAN"), numeric: true),
              DataColumn(label: Text('QARZ'), numeric: true),
              DataColumn(label: Text('ESKI QARZ'), numeric: true),
              DataColumn(label: Text('')),
            ], rows: [for (final s in students) row(s)])),
      ),
    );
  }
}
