import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/errors.dart';
import '../../core/formatters.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/reports.dart';
import '../../domain/entities/student.dart';
import '../../domain/services/billing_service.dart';
import '../controllers/cash_controller.dart';
import '../controllers/period_controller.dart';
import '../controllers/reports_controller.dart';
import '../widgets/observe.dart';
import 'open_cash_dialog.dart';

Future<void> showPayDialog(BuildContext context, Student student) async {
  final cash = sl<CashController>();
  if (!cash.isOpen) {
    await showOpenCashDialog(context);
    if (!cash.isOpen || !context.mounted) return;
  }
  final month = sl<PeriodController>().month;
  final options = sl<BillingService>().openMonths(student, month);
  if (options.isEmpty) return showMessage(context, "O'quvchi bu oydan keyin boshlanadi");
  await showDialog<void>(
      context: context, builder: (_) => _PayDialog(parent: context, student: student, options: options));
}

/// Chekni printerga yuboradi; xato bo'lsa, xabar ko'rsatadi (to'lov saqlanib qolgan bo'ladi).
Future<void> _printReceiptSafely(BuildContext ctx, Payment p) async {
  try {
    await sl<ReportsController>().printReceipt(p);
  } on DomainException catch (e) {
    if (ctx.mounted) showMessage(ctx, e.message);
  } catch (e) {
    if (ctx.mounted) showMessage(ctx, 'Chek chiqarilmadi: $e');
  }
}

class _PayDialog extends StatefulWidget {
  const _PayDialog({required this.parent, required this.student, required this.options});
  final BuildContext parent;
  final Student student;
  final List<MonthBalance> options;
  @override
  State<_PayDialog> createState() => _PayDialogState();
}

class _PayDialogState extends State<_PayDialog> {
  late MonthBalance selected = widget.options.last;
  PaymentMethod method = PaymentMethod.cash;
  bool autoPrint = true;
  late final amount = TextEditingController(text: _text(selected.remaining));

  String _text(int v) => v > 0 ? '$v' : '';

  void _part(int n) {
    final v = (widget.student.monthlyFee / n / 1000).ceil() * 1000;
    amount.text = '${selected.remaining > 0 && v > selected.remaining ? selected.remaining : v}';
  }

  Future<void> _submit() async {
    final parent = widget.parent;
    final shouldPrint = autoPrint;
    try {
      final p = await sl<CashController>().pay(
          widget.student, int.tryParse(amount.text.replaceAll(RegExp(r'\D'), '')) ?? 0, method, selected.month);
      if (!mounted) return;
      Navigator.pop(context);
      if (shouldPrint) await _printReceiptSafely(parent, p);
      if (parent.mounted) await _showReceipt(parent, p);
    } on DomainException catch (e) {
      if (mounted) showMessage(context, e.message);
    }
  }

  Future<void> _showReceipt(BuildContext ctx, Payment p) {
    final reports = sl<ReportsController>();
    final d = reports.details(p);
    return showDialog<void>(
        context: ctx,
        builder: (c) => AlertDialog(
              title: const Text("To'lov qabul qilindi"),
              content: Text("${d.studentName}\n${formatMoney(p.amount)} so'm - ${p.method.label}\n"
                  "${formatDate(p.paidAt)} ${formatTime(p.paidAt)}\n${p.forMonth.label} uchun"),
              actions: [
                TextButton(onPressed: () => _printReceiptSafely(ctx, p), child: const Text('🖨 Chekni qayta chiqarish')),
                FilledButton(onPressed: () => Navigator.pop(c), child: const Text('Yopish')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final billing = sl<BillingService>();
    final month = sl<PeriodController>().month;
    return AlertDialog(
      title: Text(widget.student.fullName),
      content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Oylik: ${formatMoney(widget.student.monthlyFee)}'),
            DropdownButton<MonthBalance>(
                isExpanded: true,
                value: selected,
                items: [
                  for (final o in widget.options)
                    DropdownMenuItem(
                        value: o,
                        child: Text('${o.month.label} - qolgan ${formatMoney(o.remaining)}'
                            '${o.month < month ? ' (eski qarz)' : ''}'))
                ],
                onChanged: (v) => setState(() {
                      selected = v!;
                      amount.text = _text(v.remaining);
                    })),
            TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Summa')),
            Wrap(spacing: 6, children: [
              ActionChip(label: const Text('Hammasi'), onPressed: () => amount.text = _text(selected.remaining)),
              for (final n in [2, 3, 4, 5]) ActionChip(label: Text('1/$n'), onPressed: () => _part(n)),
            ]),
            DropdownButton<PaymentMethod>(
                value: method,
                items: [for (final m in PaymentMethod.values) DropdownMenuItem(value: m, child: Text(m.label))],
                onChanged: (m) => setState(() => method = m!)),
            Row(children: [
              Checkbox(value: autoPrint, onChanged: (v) => setState(() => autoPrint = v ?? true)),
              const Text('Chek chiqarish (XPrinter 58 mm)'),
            ]),
            const Divider(),
            const Text("To'lovlar tarixi:", style: TextStyle(fontSize: 12)),
            for (final m in widget.options)
              for (final p in billing.paymentsFor(widget.student, m.month))
                Text('${formatDate(p.paidAt)} ${formatTime(p.paidAt)} - ${formatMoney(p.amount)} '
                    '(${p.method.label}) ${p.forMonth.label}', style: const TextStyle(fontSize: 12)),
          ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor')),
        FilledButton(onPressed: _submit, child: const Text("To'landi")),
      ],
    );
  }
}
