import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injector.dart';
import 'presentation/pages/cloud_login_page.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/widgets/edu_logo.dart';

/// Firebase kirish holatiga qarab ekranni tanlaydi:
///   kirilmagan -> email/parol sahifasi;
///   kirilgan   -> shu hisobning ma'lumotlarini Firestore'dan yuklab -> [App] (PIN -> asosiy ilova).
class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});
  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  StreamSubscription<User?>? _sub;
  bool _resolved = false;
  User? _user;
  Future<void>? _ready;

  @override
  void initState() {
    super.initState();
    _sub = FirebaseAuth.instance.authStateChanges().listen(_onUser);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onUser(User? user) {
    setState(() {
      final changed = user?.uid != _user?.uid;
      _resolved = true;
      _user = user;
      if (user == null) {
        _ready = null;
      } else if (changed || _ready == null) {
        _ready = _prepare(user.uid);
      }
    });
  }

  Future<void> _prepare(String uid) async {
    await resetDependencies(); // oldingi hisobdan qolgan obyektlarni tozalaydi
    await configureDependencies(uid: uid);
  }

  Widget _shell(Widget home) => MaterialApp(title: 'EduCore', debugShowCheckedModeBanner: false, theme: buildTheme(), home: home);

  @override
  Widget build(BuildContext context) {
    if (!_resolved) return _shell(const _Splash());
    final user = _user;
    if (user == null) return _shell(const CloudLoginPage());
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snap) {
        if (snap.hasError) {
          return _shell(StartupMessage(
            title: "Ma'lumotlarni yuklab bo'lmadi",
            message: '${snap.error}',
            actionLabel: 'Qayta urinish',
            onAction: () => setState(() => _ready = _prepare(user.uid)),
            secondaryLabel: 'Hisobdan chiqish',
            onSecondary: FirebaseAuth.instance.signOut,
          ));
        }
        if (snap.connectionState != ConnectionState.done) return _shell(const _Splash(text: "Ma'lumotlar yuklanmoqda…"));
        return const App();
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({this.text});
  final String? text;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.navy,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const EduLogo(size: 72),
            const SizedBox(height: 24),
            const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white)),
            if (text != null) ...[
              const SizedBox(height: 16),
              Text(text!, style: const TextStyle(color: Color(0xFFA9B8D4))),
            ],
          ]),
        ),
      );
}

/// Xato yoki sozlanmagan holat uchun oddiy ekran.
class StartupMessage extends StatelessWidget {
  const StartupMessage({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });
  final String title, message;
  final String? actionLabel, secondaryLabel;
  final VoidCallback? onAction;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.muted),
                const SizedBox(height: 14),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
                const SizedBox(height: 10),
                SelectableText(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 20),
                if (actionLabel != null) FilledButton(onPressed: onAction, child: Text(actionLabel!)),
                if (secondaryLabel != null) ...[
                  const SizedBox(height: 8),
                  TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
                ],
              ]),
            ),
          ),
        ),
      );
}
