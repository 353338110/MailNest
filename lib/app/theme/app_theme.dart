import 'package:flutter/material.dart';

abstract final class AppTheme {
  static final light = _buildTheme(
    ColorScheme.fromSeed(
      seedColor: const Color(0xFF16697A),
      brightness: Brightness.light,
    ),
  );

  static final dark = _buildTheme(
    ColorScheme.fromSeed(
      seedColor: const Color(0xFF6CB7C8),
      brightness: Brightness.dark,
    ),
  );

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
