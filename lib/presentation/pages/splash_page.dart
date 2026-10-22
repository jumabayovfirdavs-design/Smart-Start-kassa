import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../controllers/auth_controller.dart';
import '../widgets/edu_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2100), sl<AuthController>().finishSplash);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              gradient: RadialGradient(center: Alignment(-0.4, -0.7), radius: 1.4, colors: [Color(0xFF0C3B8F), Color(0xFF001A40)])),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (context, v, child) =>
                  Opacity(opacity: v.clamp(0.0, 1.0).toDouble(), child: Transform.scale(scale: 0.7 + 0.3 * v, child: child)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const EduLogo(size: 120),
                const SizedBox(height: 16),
                const Text('EduCore',
                    style: TextStyle(fontSize: 46, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                const SizedBox(height: 4),
                const Text("Maktab to'lovlarini boshqarish tizimi", style: TextStyle(fontSize: 15, color: Color(0xFF9DB6E0))),
                const SizedBox(height: 30),
                SizedBox(
                  width: 220,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1900),
                    builder: (context, v, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                          value: v, minHeight: 4, backgroundColor: const Color(0x22FFFFFF), color: const Color(0xFF38D0FF)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
}
