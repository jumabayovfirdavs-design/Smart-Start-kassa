import 'package:flutter/material.dart';

import 'core/di/injector.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/shell.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'EduCore',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const AuthGate());
}

/// Splash -> parol -> asosiy ilova.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = sl<AuthController>();
    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (auth.phase) {
          AuthPhase.splash => const SplashPage(key: ValueKey('splash')),
          AuthPhase.pin => const LoginPage(key: ValueKey('pin')),
          AuthPhase.app => const Shell(key: ValueKey('app')),
        },
      ),
    );
  }
}
