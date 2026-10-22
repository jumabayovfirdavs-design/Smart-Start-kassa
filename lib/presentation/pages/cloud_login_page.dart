import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/edu_logo.dart';

/// Firebase hisobiga kirish (email + parol). Bir marta kiriladi, keyin sessiya eslab qolinadi.
/// Ichki 4 xonali PIN bundan alohida: u kassani qulflash uchun.
class CloudLoginPage extends StatefulWidget {
  const CloudLoginPage({super.key});
  @override
  State<CloudLoginPage> createState() => _CloudLoginPageState();
}

class _CloudLoginPageState extends State<CloudLoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  bool _hidden = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email va parolni kiriting');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      if (_register) {
        await auth.createUserWithEmailAndPassword(email: email, password: password);
      } else {
        await auth.signInWithEmailAndPassword(email: email, password: password);
      }
      // Muvaffaqiyatli bo'lsa Bootstrap o'zi keyingi ekranga o'tkazadi.
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = _message(e.code));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _message(String code) => switch (code) {
        'invalid-email' => "Email manzili noto'g'ri yozilgan",
        'user-not-found' || 'wrong-password' || 'invalid-credential' => "Email yoki parol noto'g'ri",
        'user-disabled' => "Bu hisob o'chirib qo'yilgan",
        'email-already-in-use' => "Bu email bilan hisob allaqachon bor — \"Kirish\" ni tanlang",
        'weak-password' => "Parol juda oddiy (kamida 6 ta belgi)",
        'operation-not-allowed' => "Firebase Console'da Email/Password yoqilmagan",
        'too-many-requests' => "Juda ko'p urinish. Birozdan keyin qayta urinib ko'ring",
        'network-request-failed' => "Internet yo'q. Ulanishni tekshiring",
        _ => 'Xatolik: $code',
      };

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.navy, AppColors.navy2])),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 400,
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 26),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Center(child: EduLogo(size: 64)),
                const SizedBox(height: 16),
                Text(_register ? 'Hisob yaratish' : 'Hisobga kirish',
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
                const SizedBox(height: 4),
                const Text("Ma'lumotlar bulutda saqlanadi", textAlign: TextAlign.center, style: pageSubtitle),
                const SizedBox(height: 22),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline), border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: _hidden,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _busy ? null : _submit(),
                  decoration: InputDecoration(
                    labelText: 'Parol',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                        icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _hidden = !_hidden)),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
                ],
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                      : Text(_register ? 'Hisob yaratish' : 'Kirish'),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: _busy ? null : () => setState(() {
                        _register = !_register;
                        _error = null;
                      }),
                  child: Text(_register ? 'Hisobim bor — Kirish' : "Hisob yo'q — Yaratish"),
                ),
              ]),
            ),
          ),
        ),
      );
}
