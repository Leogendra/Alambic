import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The sample group, which the app opens once the onboarding is over when
/// it ended on "Start"; `null` when it was skipped, and once the group was
/// opened.
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
