import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'bootstrap.dart';
import 'firebase_options.dart';
import 'presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // Odatda: `flutterfire configure` hali ishga tushirilmagan.
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: StartupMessage(title: 'Firebase sozlanmagan', message: '$e'),
    ));
    return;
  }
  runApp(const Bootstrap());
}
