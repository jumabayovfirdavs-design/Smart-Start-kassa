import 'dart:convert';
import 'dart:typed_data';

/// Kichik, tashqi paketsiz .xlsx (Excel) yozuvchi.
///
/// `excel` paketi `pdf` paketi bilan (xml versiyasi bo'yicha) mos kelmagani uchun
/// o'rniga shu fayl ishlatiladi: faqat Dart'ning o'zi kerak.
/// Qo'llab-quvvatlaydi: bir nechta varaq, son va matn, ustun kengligi, 3 xil uslub.

/// Hujayra uslubi. Tartib `styles.xml` dagi cellXfs bilan bir xil bo'lishi SHART.
enum XStyle { none, bold, title, head }

class XlsxBook {
  XlsxBook(String firstSheetName) {
    sheet(firstSheetName);
  }

  final List<XlsxSheet> _sheets = [];

  XlsxSheet get first => _sheets.first;

  /// Yangi varaq qo'shadi (nomi takrorlansa, mavjudini qaytaradi).
  XlsxSheet sheet(String name) {
    final clean = _sheetName(name);
    for (final s in _sheets) {
      if (s.name == clean) return s;
    }
    final s = XlsxSheet._(clean);
    _sheets.add(s);
    return s;
  }

  /// Excel varaq nomi: eng ko'pi 31 belgi, `[]:*?/\` bo'lmasin.
  static String _sheetName(String n) {
    var s = n.replaceAll(RegExp(r'[\[\]:*?/\\]'), '-').trim();
    if (s.isEmpty) s = 'Sheet';
    return s.length > 31 ? s.substring(0, 31) : s;
  }

  Uint8List encode() {
    final zip = _Zip();
    final n = _sheets.length;

    final overrides = StringBuffer();
    for (var i = 1; i <= n; i++) {
      overrides.write('<Override PartName="/xl/worksheets/sheet$i.xml" '
          'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>');
    }
    zip.add(
        '[Content_Types].xml',
        '$_decl<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
        '$overrides'
        '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
        '</Types>');

    zip.add(
        '_rels/.rels',
        '$_decl<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
        '</Relationships>');

    final sheetsXml = StringBuffer();
    final relsXml = StringBuffer();
    for (var i = 0; i < n; i++) {
      sheetsXml.write('<sheet name="${_esc(_sheets[i].name)}" sheetId="${i + 1}" r:id="rId${i + 1}"/>');
      relsXml.write('<Relationship Id="rId${i + 1}" '
          'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet${i + 1}.xml"/>');
    }
    relsXml.write('<Relationship Id="rId${n + 1}" '
        'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>');

    zip.add(
        'xl/workbook.xml',
        '$_decl<workbook xmlns="$_ns" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
        '<sheets>$sheetsXml</sheets></workbook>');
    zip.add(
        'xl/_rels/workbook.xml.rels',
        '$_decl<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">$relsXml</Relationships>');
    zip.add('xl/styles.xml', _stylesXml);
    for (var i = 0; i < n; i++) {
      zip.add('xl/worksheets/sheet${i + 1}.xml', _sheets[i]._xml());
    }
    return zip.finish();
  }

  static const _decl = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
  static const _ns = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main';

  // cellXfs tartibi XStyle.index bilan mos: 0 oddiy, 1 qalin, 2 sarlavha (14pt), 3 jadval boshi (qalin + ko'k fon)
  static const _stylesXml = '$_decl<styleSheet xmlns="$_ns">'
      '<fonts count="3">'
      '<font><sz val="11"/><name val="Calibri"/></font>'
      '<font><b/><sz val="11"/><name val="Calibri"/></font>'
      '<font><b/><sz val="14"/><name val="Calibri"/></font>'
      '</fonts>'
      '<fills count="3">'
      '<fill><patternFill patternType="none"/></fill>'
      '<fill><patternFill patternType="gray125"/></fill>'
      '<fill><patternFill patternType="solid"><fgColor rgb="FFDBEAFE"/><bgColor indexed="64"/></patternFill></fill>'
      '</fills>'
      '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
      '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
      '<cellXfs count="4">'
      '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
      '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
      '<xf numFmtId="0" fontId="2" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
      '<xf numFmtId="0" fontId="1" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1"/>'
      '</cellXfs>'
      '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
      '</styleSheet>';
}

class XlsxSheet {
  XlsxSheet._(this.name);
  final String name;
  final Map<int, Map<int, _Cell>> _rows = {};
  final Map<int, double> _widths = {};

  /// [row] va [col] 0 dan boshlanadi. [value]: int, double yoki matn (null = bo'sh).
  void set(int row, int col, Object? value, [XStyle style = XStyle.none]) {
    (_rows[row] ??= {})[col] = _Cell(value, style);
  }

  void setColumnWidth(int col, double width) => _widths[col] = width;

  String _xml() {
    final b = StringBuffer(XlsxBook._decl)..write('<worksheet xmlns="${XlsxBook._ns}">');
    if (_widths.isNotEmpty) {
      b.write('<cols>');
      for (final c in _widths.keys.toList()..sort()) {
        b.write('<col min="${c + 1}" max="${c + 1}" width="${_widths[c]}" customWidth="1"/>');
      }
      b.write('</cols>');
    }
    b.write('<sheetData>');
    for (final r in _rows.keys.toList()..sort()) {
      b.write('<row r="${r + 1}">');
      final cells = _rows[r]!;
      for (final c in cells.keys.toList()..sort()) {
        final cell = cells[c]!;
        final ref = '${_colName(c)}${r + 1}';
        final s = cell.style == XStyle.none ? '' : ' s="${cell.style.index}"';
        final v = cell.value;
        if (v is int || (v is double && v.isFinite)) {
          b.write('<c r="$ref"$s><v>$v</v></c>');
        } else {
          final text = v?.toString() ?? '';
          if (text.isEmpty) {
            if (s.isNotEmpty) b.write('<c r="$ref"$s/>');
          } else {
            b.write('<c r="$ref"$s t="inlineStr"><is><t xml:space="preserve">${_esc(text)}</t></is></c>');
          }
        }
      }
      b.write('</row>');
    }
    b.write('</sheetData></worksheet>');
    return b.toString();
  }

  static String _colName(int index) {
    var i = index + 1;
    var s = '';
    while (i > 0) {
      final m = (i - 1) % 26;
      s = String.fromCharCode(65 + m) + s;
      i = (i - 1) ~/ 26;
    }
    return s;
  }
}

class _Cell {
  const _Cell(this.value, this.style);
  final Object? value;
  final XStyle style;
}

/// XML uchun maxsus belgilarni almashtiradi va XML'da ruxsat etilmagan boshqaruv belgilarini olib tashlaydi.
String _esc(String s) {
  final b = StringBuffer();
  for (final r in s.runes) {
    if (r < 0x20 && r != 0x09 && r != 0x0A && r != 0x0D) continue;
    switch (r) {
      case 0x26:
        b.write('&amp;');
      case 0x3C:
        b.write('&lt;');
      case 0x3E:
        b.write('&gt;');
      case 0x22:
        b.write('&quot;');
      case 0x27:
        b.write('&apos;');
      default:
        b.writeCharCode(r);
    }
  }
  return b.toString();
}

/// Siqilmagan ("stored") ZIP konteyner. Hisobotlar kichik, shuning uchun siqish shart emas.
class _Zip {
  final _out = BytesBuilder();
  final _central = BytesBuilder();
  int _count = 0;

  void add(String name, String text) {
    final nameBytes = utf8.encode(name);
    final data = utf8.encode(text);
    final crc = _crc32(data);
    final offset = _out.length;

    _out
      ..add(_u32(0x04034b50))
      ..add(_u16(20))
      ..add(_u16(0x0800)) // fayl nomlari UTF-8
      ..add(_u16(0)) // usul: siqilmagan
      ..add(_u16(0)) // vaqt
      ..add(_u16(0x21)) // sana: 1980-01-01
      ..add(_u32(crc))
      ..add(_u32(data.length))
      ..add(_u32(data.length))
      ..add(_u16(nameBytes.length))
      ..add(_u16(0))
      ..add(nameBytes)
      ..add(data);

    _central
      ..add(_u32(0x02014b50))
      ..add(_u16(20))
      ..add(_u16(20))
      ..add(_u16(0x0800))
      ..add(_u16(0))
      ..add(_u16(0))
      ..add(_u16(0x21))
      ..add(_u32(crc))
      ..add(_u32(data.length))
      ..add(_u32(data.length))
      ..add(_u16(nameBytes.length))
      ..add(_u16(0))
      ..add(_u16(0))
      ..add(_u16(0))
      ..add(_u16(0))
      ..add(_u32(0))
      ..add(_u32(offset))
      ..add(nameBytes);
    _count++;
  }

  Uint8List finish() {
    final cdOffset = _out.length;
    final cd = _central.toBytes();
    _out
      ..add(cd)
      ..add(_u32(0x06054b50))
      ..add(_u16(0))
      ..add(_u16(0))
      ..add(_u16(_count))
      ..add(_u16(_count))
      ..add(_u32(cd.length))
      ..add(_u32(cdOffset))
      ..add(_u16(0));
    return _out.toBytes();
  }

  static Uint8List _u16(int v) {
    final d = ByteData(2)..setUint16(0, v, Endian.little);
    return d.buffer.asUint8List();
  }

  static Uint8List _u32(int v) {
    final d = ByteData(4)..setUint32(0, v, Endian.little);
    return d.buffer.asUint8List();
  }

  static final List<int> _table = () {
    final t = List<int>.filled(256, 0);
    for (var n = 0; n < 256; n++) {
      var c = n;
      for (var k = 0; k < 8; k++) {
        c = (c & 1) != 0 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1);
      }
      t[n] = c;
    }
    return t;
  }();

  static int _crc32(List<int> bytes) {
    var c = 0xFFFFFFFF;
    for (final b in bytes) {
      c = _table[(c ^ b) & 0xFF] ^ (c >> 8);
    }
    return c ^ 0xFFFFFFFF;
  }
}
