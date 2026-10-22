import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF001A40);
  static const navy2 = Color(0xFF05285F);
  static const primary = Color(0xFF2563EB);
  static const cyan = Color(0xFF06B6D4);
  static const bg = Color(0xFFEEF2F8);
  static const text = Color(0xFF0F1B33);
  static const muted = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const green = Color(0xFF16A34A);
  static const red = Color(0xFFDC2626);
  static const orange = Color(0xFFD97706);
}

const pageTitle = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.text, letterSpacing: -0.4);
const pageSubtitle = TextStyle(fontSize: 13, color: AppColors.muted);
const pagePadding = EdgeInsets.fromLTRB(32, 28, 32, 40);

InputDecoration searchDecoration(String hint) => InputDecoration(
      prefixIcon: const Icon(Icons.search, color: AppColors.muted),
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.6)),
    );

ThemeData buildTheme() {
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
  const pad = EdgeInsets.symmetric(horizontal: 18, vertical: 14);
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light),
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Segoe UI',
    fontFamilyFallback: const ['Roboto', 'Arial'],
    dividerColor: AppColors.border,
    filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(padding: pad, shape: shape, textStyle: const TextStyle(fontWeight: FontWeight.w600))),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            padding: pad, shape: shape, side: const BorderSide(color: AppColors.border), foregroundColor: AppColors.text,
            backgroundColor: Colors.white, textStyle: const TextStyle(fontWeight: FontWeight.w600))),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: shape)),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(Color(0xFFF8FAFC)),
      headingTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.4),
      dataTextStyle: TextStyle(fontSize: 14, color: AppColors.text),
      dataRowMinHeight: 52,
      dataRowMaxHeight: double.infinity,
      dividerThickness: 1,
      horizontalMargin: 18,
      columnSpacing: 28,
    ),
  );
}
