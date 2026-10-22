import 'package:flutter/material.dart';

/// EduCore logotipi: gradientli lenta "E" (CustomPaint, rasm fayli kerak emas).
class EduLogo extends StatelessWidget {
  const EduLogo({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: CustomPaint(painter: _LogoPainter()));
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 72, size.height / 72);
    const box = Rect.fromLTWH(0, 0, 72, 72);
    final light = const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF5EE1FF), Color(0xFF1A6CF0)])
        .createShader(box);
    final dark = const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A7BFF), Color(0xFF0F45B8)])
        .createShader(box);
    Path poly(List<Offset> p) => Path()..addPolygon(p, true);

    canvas.drawPath(poly(const [Offset(9, 17), Offset(25, 8), Offset(25, 57), Offset(9, 66)]), Paint()..shader = dark);
    canvas.drawPath(poly(const [Offset(25, 8), Offset(63, 8), Offset(59, 19), Offset(25, 19)]), Paint()..shader = light);
    canvas.drawPath(poly(const [Offset(25, 30), Offset(55, 30), Offset(51, 41), Offset(25, 41)]), Paint()..shader = light);
    canvas.drawPath(poly(const [Offset(25, 52), Offset(63, 52), Offset(59, 63), Offset(25, 63)]), Paint()..shader = light);
    canvas.drawPath(poly(const [Offset(25, 19), Offset(9, 17), Offset(25, 8)]), Paint()..color = const Color(0x8C0B3A9C));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
