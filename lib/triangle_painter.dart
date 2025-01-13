// triangle_painter.dart
import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint borderPaint = Paint()
      ..color = Colors.white // Set the border color to white
      ..style = PaintingStyle.stroke // Use stroke style for border
      ..strokeWidth = 2; // Set the border width

    Paint fillPaint = Paint()
      ..color = Colors.transparent // Set the fill color to transparent
      ..style = PaintingStyle.fill; // Set the fill style

    Path path = Path()
      ..moveTo(0, -10) // Move to the top point of the triangle
      ..lineTo(10, 10) // Draw line to the bottom right
      ..lineTo(-10, 10) // Draw line to the bottom left
      ..close(); // Close the path

    canvas.translate(size.width - 20, 0); // Position triangle at the top right

    // Draw the border
    canvas.drawPath(path, borderPaint);
    // Draw the fill (optional, as it's transparent)
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
