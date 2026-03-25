import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF060B13);
  static const backgroundAlt = Color(0xFF09111D);
  static const surface = Color(0xFF0E1725);
  static const surfaceAlt = Color(0xFF132034);
  static const panel = Color(0xFF0C1421);
  static const primary = Color(0xFF12D27C);
  static const secondary = Color(0xFF7C9BFF);
  static const accent = Color(0xFF00D1FF);

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      secondary: secondary,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: Colors.white.withValues(alpha: 0.08),
      splashFactory: InkSparkle.splashFactory,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, height: 1.08),
        headlineSmall: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, height: 1.12),
        titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        titleSmall: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 15, height: 1.45),
        bodyMedium: TextStyle(fontSize: 14, height: 1.45),
        bodySmall: TextStyle(fontSize: 12.5, height: 1.4),
        labelLarge: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        labelSmall: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
      ).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primary),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        selectedColor: primary.withValues(alpha: 0.18),
        disabledColor: surfaceAlt,
        secondarySelectedColor: primary.withValues(alpha: 0.18),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        labelStyle: const TextStyle(color: Colors.white),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.18),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final isSelected = states.contains(MaterialState.selected);
          return TextStyle(
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.white70,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        useIndicator: true,
        indicatorColor: primary.withValues(alpha: 0.16),
        selectedIconTheme: const IconThemeData(color: primary),
        selectedLabelTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        unselectedIconTheme: const IconThemeData(color: Colors.white60),
        unselectedLabelTextStyle: const TextStyle(
          color: Colors.white60,
          fontWeight: FontWeight.w600,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.14),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceAlt,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: panel,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
