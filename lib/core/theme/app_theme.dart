import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const accent = Color(0xFF1F6F5C);
  static const warn = Color(0xFFC1652E);
  static const bad = Color(0xFFB23B3B);
  static const paper = Color(0xFFF6F7F5);
  static const ink = Color(0xFF14201F);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: paper,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
      ),
    );
  }
}
