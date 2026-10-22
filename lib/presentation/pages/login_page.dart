import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/di/injector.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/edu_logo.dart';
import '../widgets/observe.dart';
import '../widgets/pin_pad.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  KeyEventResult _onKey(AuthController a, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final ch = e.character;
    if (ch != null && RegExp(r'^\d$').hasMatch(ch)) {
      a.press(ch);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.backspace) {
      a.backspace();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.escape) {
      a.cancel();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _dots(AuthController a) => TweenAnimationBuilder<double>(
        key: ValueKey(a.shakes),
        tween: Tween<double>(begin: a.shakes == 0 ? 0.0 : 1.0, end: 0.0),
        duration: const Duration(milliseconds: 420),
        builder: (context, v, child) => Transform.translate(offset: Offset(math.sin(v * math.pi * 6) * 10 * v, 0), child: child),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < 4; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < a.entered ? AppColors.primary : Colors.transparent,
                border: Border.all(
                    color: i < a.entered ? AppColors.primary : (a.error != null ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1)), width: 2),
              ),
            ),
        ]),
      );

  Widget _card(AuthController a) => Container(
        width: 380,
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x6600122E), blurRadius: 60, offset: Offset(0, 28))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(a.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(height: 20),
          _dots(a),
          SizedBox(
            height: 38,
            child: Center(
                child: Text(a.error ?? '',
                    textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13))),
          ),
          PinPad(onDigit: a.press, onBackspace: a.backspace),
          const SizedBox(height: 12),
          Text(a.hint, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ]),
      );

  Widget _brand(bool wide) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          EduLogo(size: wide ? 150 : 90),
          const SizedBox(height: 16),
          Text('EduCore', style: TextStyle(fontSize: wide ? 64 : 40, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text("Maktab to'lovlarini boshqarish tizimi", style: TextStyle(fontSize: wide ? 18 : 14, color: const Color(0xFFBCD0EF))),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final auth = sl<AuthController>();
    return Observe(
      on: [auth],
      builder: (context) => Scaffold(
        body: Focus(
          autofocus: true,
          onKeyEvent: (_, e) => _onKey(auth, e),
          child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0A2A5E), Color(0xFF1F5296), Color(0xFF2B6CB0)])),
            child: Stack(children: [
              LayoutBuilder(builder: (context, c) {
                final wide = c.maxWidth >= 900;
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: wide
                        ? Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_brand(true), _card(auth)])
                        : Column(mainAxisSize: MainAxisSize.min, children: [_brand(false), const SizedBox(height: 28), _card(auth)]),
                  ),
                );
              }),
              if (auth.canGoBack)
                Positioned(
                  left: 22,
                  top: 22,
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xAAFFFFFF), width: 2)),
                    child: IconButton(
                        iconSize: 26, color: Colors.white, tooltip: 'Orqaga', icon: const Icon(Icons.arrow_back), onPressed: auth.cancel),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
