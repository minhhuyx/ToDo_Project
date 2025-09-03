import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF18A5A7);
  static const Color accent = Color(0xFFBFFFC7);

  static const LinearGradient tealToGreen = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}