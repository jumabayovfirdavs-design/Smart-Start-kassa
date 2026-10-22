import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/errors.dart';
import '../../domain/services/printer_catalog.dart';

Future<void> showPrinterDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _PrinterDialog());

class _PrinterDialog extends StatefulWidget {
  const _PrinterDialog();
  @override
  State<_PrinterDialog> createState() => _PrinterDialogState();
}

class _PrinterDialogState extends State<_PrinterDialog> {
  final catalog = sl<PrinterCatalog>();
  late final Future<List<PrinterInfo>> _printers = catalog.available();
  String? selected;
  String? message;
  bool ok = false;

  @override
  void initState() {
    super.initState();
    selected = catalog.selectedId;
  }

  Future<void> _test() async {
    setState(() => message = null);
    try {
      await catalog.printTest();
      setState(() {
        ok = true;
        message = 'Test chek yuborildi';
      });
    } on DomainException catch (e) {
      setState(() {
        ok = false;
        message = e.message;
      });
    } catch (e) {
      setState(() {
        ok = false;
        message = 'Xato: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Chek printeri (XPrinter 58 mm)'),
        content: SizedBox(
          width: 440,
          child: FutureBuilder<List<PrinterInfo>>(
            future: _printers,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()));
              }
              if (snap.hasError) return Text('Printerlar ro\'yxatini olib bo\'lmadi: ${snap.error}');
              final list = snap.data ?? const <PrinterInfo>[];
              final value = list.any((p) => p.id == selected) ? selected : null;
              return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                DropdownButton<String?>(
                  isExpanded: true,
                  value: value,
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Avtomatik (XPrinter topilsa o\'zi tanlaydi)')),
                    for (final p in list) DropdownMenuItem<String?>(value: p.id, child: Text(p.name)),
                  ],
                  onChanged: (v) async {
                    await catalog.select(v);
                    setState(() => selected = v);
                  },
                ),
                if (list.isEmpty)
                  const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text("Windows'da printer topilmadi. Printer drayveri o'rnatilganini tekshiring.",
                          style: TextStyle(color: Colors.red, fontSize: 12))),
                if (message != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(message!, style: TextStyle(color: ok ? Colors.green : Colors.red, fontSize: 13))),
              ]);
            },
          ),
        ),
        actions: [
          TextButton(onPressed: _test, child: const Text('Test chek')),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Yopish')),
        ],
      );
}
