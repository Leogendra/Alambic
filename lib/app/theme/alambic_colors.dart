import 'package:flutter/material.dart';

/// Colour tokens of the "hybride" theme, beyond what [ColorScheme] carries.
@immutable
class AlambicColors extends ThemeExtension<AlambicColors> {
  const AlambicColors({
    required this.background,
    required this.surface,
    required this.border,
    required this.divider,
    required this.segmentBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentText,
    required this.accentTint,
    required this.againBackground,
    required this.againForeground,
  });

  static const AlambicColors light = AlambicColors(
    background: Color(0xFFF4F4F6),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE6E6EA),
    divider: Color(0xFFEFEFF2),
    segmentBackground: Color(0xFFE8E8EC),
    textPrimary: Color(0xFF0A0A0A),
    textSecondary: Color(0xFF5F5F66),
    textTertiary: Color(0xFF3A3A40),
    accent: Color(0xFF1447FF),
    accentText: Color(0xFF1447FF),
    accentTint: Color(0xFFE3E9FF),
    againBackground: Color(0xFFFFF1E6),
    againForeground: Color(0xFF9A3412),
  );

  static const AlambicColors dark = AlambicColors(
    background: Color(0xFF121212),
    surface: Color(0xFF1F1F23),
    border: Color(0xFF26262B),
    divider: Color(0xFF26262B),
    segmentBackground: Color(0xFF232327),
    textPrimary: Color(0xFFF2F2F2),
    textSecondary: Color(0xFFA1A1AA),
    textTertiary: Color(0xFFD4D4D8),
    accent: Color(0xFF1447FF),
    accentText: Color(0xFF8EA6FF),
    accentTint: Color(0xFF232A45),
    againBackground: Color(0xFF3A2416),
    againForeground: Color(0xFFFDBA74),
  );

  final Color background;
  final Color surface;
  final Color border;
  final Color divider;
  final Color segmentBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Filled accent (buttons, switches).
  final Color accent;

  /// Accent used as a text colour, lighter in dark mode for contrast.
  final Color accentText;
  final Color accentTint;

  /// Colours of the "Again" answer, also used for warnings.
  final Color againBackground;
  final Color againForeground;

  static AlambicColors of(BuildContext context) =>
      Theme.of(context).extension<AlambicColors>()!;

  @override
  AlambicColors copyWith() => this;

  @override
  AlambicColors lerp(AlambicColors? other, double t) {
    if (other == null) {
      return this;
    } else {
      return AlambicColors(
        background: Color.lerp(background, other.background, t)!,
        surface: Color.lerp(surface, other.surface, t)!,
        border: Color.lerp(border, other.border, t)!,
        divider: Color.lerp(divider, other.divider, t)!,
        segmentBackground: Color.lerp(
          segmentBackground,
          other.segmentBackground,
          t,
        )!,
        textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
        textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
        textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
        accent: Color.lerp(accent, other.accent, t)!,
        accentText: Color.lerp(accentText, other.accentText, t)!,
        accentTint: Color.lerp(accentTint, other.accentTint, t)!,
        againBackground: Color.lerp(againBackground, other.againBackground, t)!,
        againForeground: Color.lerp(againForeground, other.againForeground, t)!,
      );
    }
  }
}
