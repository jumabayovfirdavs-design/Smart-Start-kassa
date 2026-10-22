import '../entities/reports.dart';

/// Faqat TO'LOV CHEKI printerga chiqariladi (58 mm). Hisobotlar Excel orqali yuklanadi.
abstract interface class ReceiptPrinter {
  Future<void> printPayment(PaymentDetails details);
}
