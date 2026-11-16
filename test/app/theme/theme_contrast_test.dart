import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/app/theme/alambic_colors.dart';

/// WCAG contrast ratio between two opaque colours, from 1 to 21.
double contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

/// One rule of SPECS.md "Thème et contraste": [foreground] laid on
/// [background] keeps at least [minimum].
typedef ContrastRule = ({
  String name,
  Color Function(AlambicColors) foreground,
  Color Function(AlambicColors) background,
  double minimum,
});

final List<ContrastRule> rules = [
  for (final (name, background) in <(String, Color Function(AlambicColors))>[
    ('background', (colors) => colors.background),
    ('surface', (colors) => colors.surface),
    ('surfaceRaised', (colors) => colors.surfaceRaised),
    ('well', (colors) => colors.well),
  ])
    (
      name: 'textPrimary on $name',
      foreground: (colors) => colors.textPrimary,
      background: background,
      minimum: 7,
    ),
  for (final (name, background) in <(String, Color Function(AlambicColors))>[
    ('background', (colors) => colors.background),
    ('surface', (colors) => colors.surface),
    ('well', (colors) => colors.well),
  ])
    (
      name: 'textSecondary on $name',
      foreground: (colors) => colors.textSecondary,
      background: background,
      minimum: 4.5,
    ),
  (
    name: 'textTertiary on surface',
    foreground: (colors) => colors.textTertiary,
    background: (colors) => colors.surface,
    minimum: 4.5,
  ),
  for (final (name, background) in <(String, Color Function(AlambicColors))>[
    ('background', (colors) => colors.background),
    ('surface', (colors) => colors.surface),
  ])
    (
      name: 'accentText on $name',
      foreground: (colors) => colors.accentText,
      background: background,
      minimum: 4.5,
    ),
  (
    name: 'accentText on accentTint',
    foreground: (colors) => colors.accentText,
    background: (colors) => colors.accentTint,
    minimum: 4.5,
  ),
  (
    name: 'onAccent on accent (filled button)',
    foreground: (colors) => colors.onAccent,
    background: (colors) => colors.accent,
    minimum: 4.5,
  ),
  (
    name: 'againForeground on againBackground (filled button)',
    foreground: (colors) => colors.againForeground,
    background: (colors) => colors.againBackground,
    minimum: 4.5,
  ),
  (
    name: 'accent on surface',
    foreground: (colors) => colors.accent,
    background: (colors) => colors.surface,
    minimum: 3,
  ),
  (
    name: 'surface on background',
    foreground: (colors) => colors.surface,
    background: (colors) => colors.background,
    minimum: 1.15,
  ),
  (
    name: 'border on surface',
    foreground: (colors) => colors.border,
    background: (colors) => colors.surface,
    minimum: 1.3,
  ),
  (
    name: 'surfaceRaised on well (selected segment)',
    foreground: (colors) => colors.surfaceRaised,
    background: (colors) => colors.well,
    minimum: 1.4,
  ),
];

void main() {
  test('contrast ratio follows the WCAG formula', () {
    expect(
      contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21, 0.01),
    );
    expect(contrastRatio(const Color(0xFF777777), const Color(0xFF777777)), 1);
  });

  for (final (themeName, colors) in [
    ('light', AlambicColors.light),
    ('dark', AlambicColors.dark),
  ]) {
    group('$themeName theme', () {
      for (final rule in rules) {
        test('${rule.name} keeps ${rule.minimum}:1', () {
          final ratio = contrastRatio(
            rule.foreground(colors),
            rule.background(colors),
          );
          expect(
            ratio,
            greaterThanOrEqualTo(rule.minimum),
            reason: '${rule.name} is ${ratio.toStringAsFixed(2)}:1',
          );
        });
      }
    });
  }
}
