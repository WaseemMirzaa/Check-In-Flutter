import 'package:flutter/material.dart';

class CustomShape extends CustomPainter {
  final Color bgcolor;
  CustomShape({required this.bgcolor});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgcolor;
    var path = Path();
    path.lineTo(-10, 0);
    path.lineTo(0, -10);
    path.lineTo(5, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
