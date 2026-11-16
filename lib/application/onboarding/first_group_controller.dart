import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The group created on the last onboarding screen, which the app opens once
/// the onboarding is over; `null` when the screen was skipped, and once the
/// group was opened.
class FirstGroupController extends Notifier<int?> {
  @override
  int? build() => null;

  void remember(int groupId) => state = groupId;

  /// The group to open, forgotten so that it opens only once.
  int? take() {
    final groupId = state;
    state = null;
    return groupId;
  }
}
