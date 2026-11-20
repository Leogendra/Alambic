import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'alambic_colors.dart';

/// Material 3 themes built on the "flat hybrid" tokens: DM Sans, flat
/// surfaces with 1 px borders, no shadow.
abstract final class AlambicTheme {
  static const String fontFamily = 'DM Sans';

  static ThemeData light() => _build(Brightness.light, AlambicColors.light);

  static ThemeData dark() => _build(Brightness.dark, AlambicColors.dark);

  /// The app draws edge to edge: both system bars are transparent, their
  /// icons dark on the light theme and light on the dark one.
  static SystemUiOverlayStyle systemOverlayStyle(Brightness brightness) {
    final iconBrightness = brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: iconBrightness,
      statusBarBrightness: brightness,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: iconBrightness,
      systemNavigationBarContrastEnforced: false,
    );
  }

  static ThemeData _build(Brightness brightness, AlambicColors colors) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: _colorScheme(brightness, colors),
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],
    );
    return base.copyWith(
      textTheme: _textTheme(base.textTheme, colors),
      appBarTheme: _appBarTheme(brightness, colors),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: _filledButtonTheme(colors),
      // Text and outlined buttons write in the accent: the text shade keeps
      // 4.5:1 where the filled shade would not on a dark background.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.accentText),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.accentText,
          side: BorderSide(color: colors.border),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(colors),
      dividerTheme: DividerThemeData(color: colors.divider, space: 1),
      switchTheme: _switchTheme(colors),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.well,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: _outlinedShape(colors, 24),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: colors.border),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: _outlinedShape(colors, 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceRaised,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: colors.textPrimary,
        ),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: _outlinedShape(colors, 14),
      ),
    );
  }

  static ColorScheme _colorScheme(
    Brightness brightness,
    AlambicColors colors,
  ) => ColorScheme.fromSeed(seedColor: colors.accent, brightness: brightness)
      .copyWith(
        primary: colors.accent,
        onPrimary: colors.onAccent,
        surface: colors.background,
        onSurface: colors.textPrimary,
        onSurfaceVariant: colors.textSecondary,
        surfaceContainerLowest: colors.surface,
        surfaceContainerLow: colors.surface,
        surfaceContainer: colors.surface,
        surfaceContainerHigh: colors.surface,
        surfaceContainerHighest: colors.surfaceRaised,
        outline: colors.border,
        outlineVariant: colors.divider,
        secondaryContainer: colors.accentTint,
        onSecondaryContainer: colors.accentText,
        shadow: Colors.transparent,
      );

  static RoundedRectangleBorder _outlinedShape(
    AlambicColors colors,
    double radius,
  ) => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
    side: BorderSide(color: colors.border),
  );

  static AppBarTheme _appBarTheme(
    Brightness brightness,
    AlambicColors colors,
  ) => AppBarTheme(
    systemOverlayStyle: systemOverlayStyle(brightness),
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
  );

  static FilledButtonThemeData _filledButtonTheme(AlambicColors colors) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
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
      );

  static InputDecorationTheme _inputDecorationTheme(AlambicColors colors) {
    OutlineInputBorder outline(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.well,
      hintStyle: TextStyle(color: colors.textSecondary),
      border: outline(colors.border),
      enabledBorder: outline(colors.border),
      focusedBorder: outline(colors.accentText),
    );
  }

  static SwitchThemeData _switchTheme(AlambicColors colors) => SwitchThemeData(
    thumbColor: WidgetStatePropertyAll(colors.onAccent),
    trackColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.selected) ? colors.accent : colors.well,
    ),
    trackOutlineColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.transparent
          : colors.border,
    ),
  );

  static TextTheme _textTheme(TextTheme base, AlambicColors colors) =>
      base.apply(
        fontFamily: fontFamily,
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      );
}
