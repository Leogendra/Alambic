import 'package:material_ui/material_ui.dart';

/// Colour tokens of the "flat hybrid" theme, beyond what [ColorScheme]
/// carries. Depth comes from steps of colour and 1 px borders, never from
/// shadows; the contrast rules they must keep are checked by
/// `test/app/theme/theme_contrast_test.dart`.
@immutable
class AlambicColors extends ThemeExtension<AlambicColors> {
  const AlambicColors({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.well,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.onAccent,
    required this.accentText,
    required this.accentTint,
    required this.againBackground,
    required this.againForeground,
  });

  static const AlambicColors light = AlambicColors(
    background: Color(0xFFEDEEF1),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    well: Color(0xFFD5D7DD),
    border: Color(0xFFD8D9DF),
    divider: Color(0xFFEFEFF2),
    textPrimary: Color(0xFF0A0A0A),
    textSecondary: Color(0xFF56565D),
    textTertiary: Color(0xFF3A3A40),
    accent: Color(0xFF1052D5),
    onAccent: Color(0xFFFFFFFF),
    accentText: Color(0xFF1052D5),
    accentTint: Color(0xFFE3E9FF),
    againBackground: Color(0xFFFFF1E6),
    againForeground: Color(0xFF9A3412),
  );

  static const AlambicColors dark = AlambicColors(
    background: Color(0xFF08090B),
    surface: Color(0xFF1B1D24),
    surfaceRaised: Color(0xFF30333D),
    well: Color(0xFF0E0F13),
    border: Color(0xFF30333C),
    divider: Color(0xFF262930),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFFA4A7B0),
    textTertiary: Color(0xFFD5D7DD),
    accent: Color(0xFF2E6BF0),
    onAccent: Color(0xFFFFFFFF),
    accentText: Color(0xFF8EA6FF),
    accentTint: Color(0xFF1A2A5C),
    againBackground: Color(0xFF4A2710),
    againForeground: Color(0xFFFDBA74),
  );

  /// Background of the pages.
  final Color background;

  /// Cards, tiles, sheets: anything laid on the background.
  final Color surface;

  /// The selected segment of a segmented control, badges.
  final Color surfaceRaised;

  /// Hollows darker than the surface: segmented control tracks, input
  /// fields, progress bar tracks.
  final Color well;

  /// 1 px outline of a surface.
  final Color border;

  /// Separator inside a surface.
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Filled accent (buttons, switches, progress bars).
  final Color accent;

  /// Text and icons laid on [accent].
  final Color onAccent;

  /// Accent used as a text or outline colour, lighter in dark mode for
  /// contrast.
  final Color accentText;

  /// Background of a selected choice.
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
        surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
        well: Color.lerp(well, other.well, t)!,
        border: Color.lerp(border, other.border, t)!,
        divider: Color.lerp(divider, other.divider, t)!,
        textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
        textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
        textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
        accent: Color.lerp(accent, other.accent, t)!,
        onAccent: Color.lerp(onAccent, other.onAccent, t)!,
        accentText: Color.lerp(accentText, other.accentText, t)!,
        accentTint: Color.lerp(accentTint, other.accentTint, t)!,
        againBackground: Color.lerp(againBackground, other.againBackground, t)!,
        againForeground: Color.lerp(againForeground, other.againForeground, t)!,
      );
    }
  }
}
