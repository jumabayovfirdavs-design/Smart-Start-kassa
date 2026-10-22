import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/errors.dart';
import '../../core/formatters.dart';
import '../../data/local/key_value_store.dart';
import '../../domain/entities/reports.dart';
import '../../domain/services/printer_catalog.dart';
import '../../domain/services/receipt_printer.dart';

/// XPrinter (58 mm) uchun to'lov cheki. Tanlangan printerga dialogsiz, bir bosishda chiqaradi.
/// Printer tanlanmagan bo'lsa, nomi "XPrinter / XP-58" ga o'xshash printerni o'zi topadi;
/// topilmasa, oddiy Windows chop etish oynasini ochadi.
class XprinterReceiptPrinter implements ReceiptPrinter, PrinterCatalog {
  XprinterReceiptPrinter(this._store);
  final KeyValueStore _store;
  static const _key = 'receipt_printer';

  // 58 mm rulon: qog'oz 58 mm, bosiladigan kenglik ~48 mm.
  static final _roll = PdfPageFormat(58 * PdfPageFormat.mm, double.infinity,
      marginLeft: 5 * PdfPageFormat.mm, marginRight: 5 * PdfPageFormat.mm,
      marginTop: 3 * PdfPageFormat.mm, marginBottom: 8 * PdfPageFormat.mm);

  static final _xprinterName = RegExp(r'x[\s-]?printer|xp[\s-]?58|pos[\s-]?58', caseSensitive: false);

  // ---------- PrinterCatalog ----------
  @override
  Future<List<PrinterInfo>> available() async =>
      (await Printing.listPrinters()).map((p) => PrinterInfo(p.url, p.name)).toList();

  @override
  String? get selectedId {
    final v = _store.read(_key);
    return (v == null || v.isEmpty) ? null : v;
  }

  @override
  Future<void> select(String? id) => _store.write(_key, id ?? '');

  @override
  Future<void> printTest() async {
    final doc = await _document();
    doc.addPage(pw.Page(
        pageFormat: _roll,
        build: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
              _center('EduCore', size: 14, bold: true),
              _center('TEST CHEK', size: 11, bold: true),
              _dash(),
              _center("Printer to'g'ri ishlayapti", size: 9),
              _center(formatDate(DateTime.now()) + ' ' + formatTime(DateTime.now()), size: 9),
            ])));
    await _send(await doc.save(), 'EduCore test');
  }

  // ---------- ReceiptPrinter ----------
  @override
  Future<void> printPayment(PaymentDetails d) async {
    final p = d.payment;
    final doc = await _document();
    doc.addPage(pw.Page(
        pageFormat: _roll,
        build: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
              _center('EduCore', size: 15, bold: true),
              _center("TO'LOV CHEKI", size: 10, bold: true),
              _dash(),
              _row('Sana', formatDate(p.paidAt)),
              _row('Vaqt', formatTime(p.paidAt)),
              _dash(),
              _row("O'quvchi", d.studentName),
              _row('Sinf', d.className),
              _row('Shartnoma', d.contract),
              _row('Oy uchun', p.forMonth.label),
              _row("To'lov turi", p.method.label),
              _dash(),
              pw.SizedBox(height: 2),
              _center('SUMMA', size: 9),
              _center("${formatMoney(p.amount)} so'm", size: 15, bold: true),
              pw.SizedBox(height: 2),
              _dash(),
              _row('Kassir', p.cashier),
              pw.SizedBox(height: 6),
              _center('Rahmat!', size: 10),
            ])));
    await _send(await doc.save(), "EduCore to'lov cheki");
  }

  // ---------- ichki yordamchilar ----------
  Future<Printer?> _resolve() async {
    final list = await Printing.listPrinters();
    if (list.isEmpty) return null;
    final id = selectedId;
    if (id != null) {
      for (final p in list) {
        if (p.url == id) return p;
      }
    }
    for (final p in list) {
      if (_xprinterName.hasMatch(p.name)) return p;
    }
    return null; // topilmadi -> oddiy chop etish oynasi
  }

  Future<void> _send(Uint8List bytes, String name) async {
    final printer = await _resolve();
    if (printer == null) {
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: name, format: _roll);
      return;
    }
    final ok = await Printing.directPrintPdf(printer: printer, onLayout: (_) async => bytes, name: name, format: _roll);
    if (!ok) {
      throw const DomainException("Chek printerga yuborilmadi. Printer yoqilgani, ulanganini va to'g'ri tanlanganini tekshiring");
    }
  }

  static pw.ThemeData? _theme;
  static bool _themeTried = false;

  /// Windows'dagi Arial shrifti: o'zbekcha ʻ va kirill harflari to'g'ri chiqishi uchun.
  Future<pw.Document> _document() async {
    if (!_themeTried) {
      _themeTried = true;
      try {
        final dir = '${Platform.environment['WINDIR'] ?? r'C:\Windows'}\\Fonts';
        final regular = await File('$dir\\arial.ttf').readAsBytes();
        final bold = await File('$dir\\arialbd.ttf').readAsBytes();
        _theme = pw.ThemeData.withFont(base: pw.Font.ttf(ByteData.sublistView(regular)), bold: pw.Font.ttf(ByteData.sublistView(bold)));
      } catch (_) {
        _theme = null; // standart shrift
      }
    }
    return pw.Document(theme: _theme);
  }

  pw.Widget _center(String t, {double size = 9, bool bold = false}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Text(t,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: size, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)));

  pw.Widget _dash() => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Divider(height: 1, thickness: 0.6, borderStyle: pw.BorderStyle.dashed));

  pw.Widget _row(String a, String b) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(a, style: const pw.TextStyle(fontSize: 8.5)),
        pw.SizedBox(width: 6),
        pw.Expanded(child: pw.Text(b, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
      ]));
}
