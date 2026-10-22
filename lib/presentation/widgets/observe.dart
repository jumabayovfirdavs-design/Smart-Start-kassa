import 'package:flutter/material.dart';

/// Bir nechta controller'ni kuzatib, o'zgarganda qayta chizadi.
class Observe extends StatelessWidget {
  const Observe({super.key, required this.on, required this.builder});
  final List<Listenable> on;
  final WidgetBuilder builder;
  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: Listenable.merge(on), builder: (c, _) => builder(c));
}

void showMessage(BuildContext c, String text) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(text)));
