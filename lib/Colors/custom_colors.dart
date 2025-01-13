import 'package:flutter/material.dart';

class CustomColors {
  // Define color constants here
  static const Color backgroundLight = Color(0xFFFFFFFF); // Light gray
  static const Color backgroundDark = Color(0xFF303030); // Dark gray
  static const Color backgroundPrimary = Color(0xFAFAFAFA); // Light blue
  // static const Color backgroundPrimary = Color(0xFFD9E0F8); // Light blue
  static const Color backgroundtext = Color(0xFFA700AF); // Light blue
  static const Color backgroundtextLight =
      Color.fromARGB(12, 166, 0, 175); // Light blue
  static const Color backgroundButtonCancel = Color(0xFFE03B3B);
  static const Color stars = Color(0xFFFFB800);
  // Define gradient color sets if needed
  static const List<Color> gradientPrimary = [
    Color(0xFF00BCD4), // Light Blue
    Color(0xFF009688) // Teal
  ];

  // You can also add methods for gradient definitions if needed
  static LinearGradient gradientPrimaryGradient() {
    return LinearGradient(
      colors: gradientPrimary,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
