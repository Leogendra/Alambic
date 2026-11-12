import 'package:flutter/material.dart';

import 'alambic_colors.dart';

/// Material 3 themes built on the "hybride" tokens: DM Sans, accent #1447FF.
abstract final class AlambicTheme {
  static const String fontFamily = 'DM Sans';

  static ThemeData light() => _build(Brightness.light, AlambicColors.light);

  static ThemeData dark() => _build(Brightness.dark, AlambicColors.dark);

  static ThemeData _build(Brightness brightness, AlambicColors colors) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: colors.accent,
          brightness: brightness,
        ).copyWith(
          primary: colors.accent,
          onPrimary: Colors.white,
          surface: colors.background,
          onSurface: colors.textPrimary,
          onSurfaceVariant: colors.textSecondary,
          surfaceContainerLowest: colors.surface,
          surfaceContainerLow: colors.surface,
          surfaceContainer: colors.surface,
          outline: colors.border,
          outlineVariant: colors.divider,
          secondaryContainer: colors.accentTint,
          onSecondaryContainer: colors.accentText,
        );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],
    );
    return base.copyWith(
      textTheme: _textTheme(base.textTheme, colors),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.accentTint,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textTertiary,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.divider, space: 1),
      switchTheme: SwitchThemeData(
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.accent
              : colors.segmentBackground,
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, AlambicColors colors) =>
      base.apply(
        fontFamily: fontFamily,
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      );
}
