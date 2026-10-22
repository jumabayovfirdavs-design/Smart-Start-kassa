import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cash_controller.dart';
import '../dialogs/printer_dialog.dart';
import '../theme/app_theme.dart';
import '../widgets/edu_logo.dart';
import '../widgets/observe.dart';
import 'cash_page.dart';
import 'home_page.dart';
import 'reports_page.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  static const _pages = [HomePage(), CashPage(), ReportsPage()];
  static const _items = [
    (Icons.space_dashboard_outlined, 'Asosiy'),
    (Icons.point_of_sale, 'Kassa'),
    (Icons.bar_chart_rounded, 'Hisobot'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Row(children: [
          _Sidebar(index: index, items: _items, onSelect: (i) => setState(() => index = i)),
          Expanded(child: _pages[index]),
        ]),
      );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.index, required this.items, required this.onSelect});
  final int index;
  final List<(IconData, String)> items;
  final ValueChanged<int> onSelect;

  Widget _nav(IconData icon, String label, bool on, VoidCallback tap) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: tap,
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: on ? const LinearGradient(colors: [AppColors.primary, AppColors.cyan]) : null,
                boxShadow: on ? const [BoxShadow(color: Color(0x4406B6D4), blurRadius: 18, offset: Offset(0, 8))] : null,
              ),
              child: Row(children: [
                Icon(icon, size: 21, color: on ? Colors.white : const Color(0xFFA9B8D4)),
                const SizedBox(width: 12),
                Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: on ? Colors.white : const Color(0xFFA9B8D4))),
              ]),
            ),
          ),
        ),
      );

  Widget _footBtn(IconData icon, String label, VoidCallback tap) => Material(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: tap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(children: [
              Icon(icon, size: 18, color: const Color(0xFFDBE6FB)),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(color: Color(0xFFDBE6FB), fontSize: 13)),
            ]),
          ),
        ),
      );

  Future<void> _signOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hisobdan chiqasizmi?'),
        content: const Text("Ma'lumotlar bulutda saqlanadi. Qayta kirish uchun email va parol kerak bo'ladi."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Chiqish')),
        ],
      ),
    );
    if (ok == true) await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final cash = sl<CashController>();
    final auth = sl<AuthController>();
    return Container(
      width: 250,
      padding: const EdgeInsets.fromLTRB(14, 22, 14, 18),
      decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.navy, AppColors.navy2])),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 26),
          child: Row(children: [
            EduLogo(size: 40),
            SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('EduCore', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
              Text('Maktab kassa', style: TextStyle(color: Color(0xFF8EA8D6), fontSize: 11)),
            ]),
          ]),
        ),
        for (var i = 0; i < items.length; i++) _nav(items[i].$1, items[i].$2, i == index, () => onSelect(i)),
        const Spacer(),
        Observe(
          on: [cash],
          builder: (_) {
            final open = cash.isOpen;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: const Color(0x14FFFFFF), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: open ? const Color(0xFF4ADE80) : const Color(0xFFFB7185))),
                const SizedBox(width: 10),
                Text(open ? 'Kassa ochiq' : 'Kassa yopiq',
                    style: TextStyle(fontWeight: FontWeight.w600, color: open ? const Color(0xFF4ADE80) : const Color(0xFFFB7185))),
              ]),
            );
          },
        ),
        const SizedBox(height: 8),
        _footBtn(Icons.print_outlined, 'Chek printeri', () => showPrinterDialog(context)),
        const SizedBox(height: 6),
        _footBtn(Icons.settings_outlined, "Parolni o'zgartirish", auth.startChangePin),
        const SizedBox(height: 6),
        _footBtn(Icons.lock_outline, 'Qulflash', auth.lock),
        const SizedBox(height: 6),
        _footBtn(Icons.logout, 'Hisobdan chiqish', () => _signOut(context)),
      ]),
    );
  }
}
