/// Preferences of the interface on this phone. They are not part of the
/// review data: they stay out of the export.
class InterfaceSettings {
  const InterfaceSettings({this.onboardingDone = false});

  /// Whether the welcome screens were gone through once.
  final bool onboardingDone;

  InterfaceSettings copyWith({bool? onboardingDone}) =>
      InterfaceSettings(onboardingDone: onboardingDone ?? this.onboardingDone);
}
