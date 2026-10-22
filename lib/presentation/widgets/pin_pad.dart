import 'package:flutter/material.dart';

/// Raqamli klaviatura (1-9, 0, o'chirish).
class PinPad extends StatelessWidget {
  const PinPad({super.key, required this.onDigit, required this.onBackspace});
  final void Function(String digit) onDigit;
  final VoidCallback onBackspace;

  Widget _key(Widget child, VoidCallback? onTap, {bool ghost = false}) => Padding(
        padding: const EdgeInsets.all(7),
        child: Material(
          color: ghost ? Colors.transparent : Colors.white,
          elevation: ghost ? 0 : 2,
          shadowColor: const Color(0x440F1B33),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: SizedBox(width: 84, height: 70, child: Center(child: child)),
          ),
        ),
      );

  Widget _digit(String d) =>
      _key(Text(d, style: const TextStyle(fontSize: 26, color: Color(0xFF1E293B))), () => onDigit(d));

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        for (final r in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9']
        ])
          Row(mainAxisSize: MainAxisSize.min, children: [for (final d in r) _digit(d)]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          _key(const Icon(Icons.lock_outline, color: Color(0xFFB6C0CF)), null, ghost: true),
          _digit('0'),
          _key(const Icon(Icons.backspace_outlined, color: Color(0xFF64748B)), onBackspace, ghost: true),
        ]),
      ]);
}
