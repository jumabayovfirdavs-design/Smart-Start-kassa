class PrinterInfo {
  const PrinterInfo(this.id, this.name);
  final String id;
  final String name;
}

/// Chek printerini tanlash va sinash (ISP: chop etishdan alohida shartnoma).
abstract interface class PrinterCatalog {
  Future<List<PrinterInfo>> available();
  String? get selectedId;
  Future<void> select(String? id);
  Future<void> printTest();
}
