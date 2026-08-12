import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const double panelRadius = 20;
  static const double cardRadius = 16;
  static const double tileRadius = 12;
  static const double controlRadius = 10;
  static const double hairlineWidth = 1;

  static Color workspaceBackground(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFFF4F5F7)
        : const Color(0xFF111315);
  }

  static Color sidebarBackground(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFFF9FAFB)
        : const Color(0xFF17191C);
  }

  static Color panelBackground(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF1B1D20);
  }

  static Color subtleSurface(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFFF7F8FA)
        : const Color(0xFF22252A);
  }

  static Color selectedSurface(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFFE8F2FF)
        : const Color(0xFF15304B);
  }

  static Color subtleBorder(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFFE1E4EA)
        : const Color(0xFF31363D);
  }

  static List<BoxShadow> panelShadow(ColorScheme colorScheme) {
    if (colorScheme.brightness == Brightness.dark) {
      return const [];
    }
    return [
      BoxShadow(
        color: colorScheme.shadow.withValues(alpha: 0.04),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static final light = _buildTheme(
    ColorScheme.fromSeed(
      seedColor: const Color(0xFF0A84FF),
      brightness: Brightness.light,
    ),
  );

  static final dark = _buildTheme(
    ColorScheme.fromSeed(
      seedColor: const Color(0xFF64B5F6),
      brightness: Brightness.dark,
    ),
  );

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: workspaceBackground(colorScheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: workspaceBackground(colorScheme),
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: panelBackground(colorScheme),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: subtleBorder(colorScheme)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: subtleBorder(colorScheme),
        thickness: hairlineWidth,
        space: 1,
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: sidebarBackground(colorScheme),
        indicatorColor: selectedSurface(colorScheme),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tileRadius),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tileRadius),
        ),
        selectedColor: colorScheme.primary,
        selectedTileColor: selectedSurface(colorScheme),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: subtleBorder(colorScheme)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panelBackground(colorScheme),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tileRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tileRadius),
          borderSide: BorderSide(color: subtleBorder(colorScheme)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tileRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
