import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/cloud/firestore_list_repository.dart';
import '../../data/cloud/local_to_cloud_migration.dart';
import '../../data/local/key_value_store.dart';
import '../../data/repositories/pin_repository_impl.dart';
import '../../domain/repositories/pin_repository.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/services/billing_service.dart';
import '../../domain/services/cash_desk.dart';
import '../../domain/services/pin_hasher.dart';
import '../../domain/services/pin_service.dart';
import '../../domain/services/printer_catalog.dart';
import '../../domain/services/receipt_printer.dart';
import '../../domain/services/report_exporter.dart';
import '../../domain/usecases/build_daily_report.dart';
import '../../domain/usecases/build_debtors_report.dart';
import '../../domain/usecases/build_monthly_report.dart';
import '../../domain/usecases/register_payment.dart';
import '../../infrastructure/export/excel_report_exporter.dart';
import '../../infrastructure/printing/xprinter_receipt_printer.dart';
import '../../infrastructure/security/sha256_pin_hasher.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/cash_controller.dart';
import '../../presentation/controllers/period_controller.dart';
import '../../presentation/controllers/reports_controller.dart';
import '../../presentation/controllers/school_controller.dart';
import '../clock.dart';

final sl = GetIt.instance;

/// Composition root: barcha bog'liqliklar FAQAT shu yerda yig'iladi.
///
/// Ma'lumotlar (sinflar, o'quvchilar, to'lovlar, smenalar) Firestore'da: `schools/{uid}/...`.
/// PAROL (PIN) va printer tanlovi esa shu qurilmada (SharedPreferences) qoladi.
Future<void> configureDependencies({required String uid}) async {
  final prefs = await SharedPreferences.getInstance();
  final store = SharedPrefsStore(prefs);
  final school = FirebaseFirestore.instance.collection('schools').doc(uid);

  await migrateLocalDataOnce(prefs: prefs, school: school, uid: uid);

  final classes = FirestoreClassRepository(school.collection('classes'));
  final students = FirestoreStudentRepository(school.collection('students'));
  final payments = FirestorePaymentRepository(school.collection('payments'));
  final sessions = FirestoreCashSessionRepository(school.collection('cash_sessions'));
  await Future.wait([classes.load(), students.load(), payments.load(), sessions.load()]);
  final xprinter = XprinterReceiptPrinter(store);

  sl
    ..registerSingleton<Clock>(const SystemClock())
    ..registerSingleton<ClassRepository>(classes)
    ..registerSingleton<StudentRepository>(students)
    ..registerSingleton<PaymentRepository>(payments)
    ..registerSingleton<CashSessionRepository>(sessions)
    ..registerSingleton<PinRepository>(PinRepositoryImpl(store))
    ..registerSingleton<PinHasher>(const Sha256PinHasher())
    ..registerSingleton<PinService>(PinService(sl<PinRepository>(), sl<PinHasher>()))
    ..registerSingleton<ReceiptPrinter>(xprinter)
    ..registerSingleton<PrinterCatalog>(xprinter)
    ..registerSingleton<ReportExporter>(ExcelReportExporter(sl<Clock>()))
    ..registerSingleton<BillingService>(BillingService(payments))
    ..registerSingleton<CashDesk>(CashDesk(sessions, payments, sl<Clock>()))
    ..registerSingleton<RegisterPayment>(RegisterPayment(payments, sl<CashDesk>(), sl<Clock>()))
    ..registerSingleton<BuildDailyReport>(BuildDailyReport(classes, students, payments, sessions))
    ..registerSingleton<BuildDebtorsReport>(BuildDebtorsReport(students, sl<BillingService>()))
    ..registerSingleton<BuildMonthlyReport>(BuildMonthlyReport(classes, students, sl<BillingService>()))
    ..registerSingleton<PeriodController>(PeriodController(sl<Clock>()))
    ..registerSingleton<SchoolController>(SchoolController(classes, students, payments))
    ..registerSingleton<CashController>(CashController(sl<CashDesk>(), sl<RegisterPayment>(), sessions))
    ..registerSingleton<AuthController>(AuthController(sl<PinService>(), sl<Clock>()))
    ..registerSingleton<ReportsController>(ReportsController(
        sl<BuildDailyReport>(), sl<BuildDebtorsReport>(), sl<BuildMonthlyReport>(), sl<ReceiptPrinter>(),
        sl<ReportExporter>(), payments, students, classes));
}

/// Hisobdan chiqilganda (yoki boshqa hisobga o'tilganda) eski obyektlarni tozalaydi.
Future<void> resetDependencies() => sl.reset();
