import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/notifications/notification_providers.dart';
import '../../application/notifications/notification_target.dart';
import '../../application/reviews/review_providers.dart';
import 'session_screen.dart';

/// Opens a session on [cardIds], due or not: answering a card that is not
/// due is a bonus review. The asked face of each card is drawn now. Does
/// nothing when there is no card. [raisesMissedPending] is for "Review all"
/// of a group (see [SessionScreen.raisesMissedPending]).
Future<void> openSession(
  BuildContext context,
  WidgetRef ref,
  Iterable<int> cardIds, {
  bool raisesMissedPending = false,
}) async {
  final navigator = Navigator.of(context);
  final items = await ref.read(sessionItemFactoryProvider).itemsFor(cardIds);
  if (items.isNotEmpty) {
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (context) => SessionScreen(
          items: items,
          raisesMissedPending: raisesMissedPending,
        ),
      ),
    );
  }
}

/// Opens the session of a touched notification above the root screen,
/// closing the screens opened on it. Does nothing when no card is left to
/// review.
Future<void> openNotificationSession(
  BuildContext context,
  WidgetRef ref,
  NotificationTarget target,
) async {
  final navigator = Navigator.of(context);
  final items = await ref.read(notificationSessionProvider).itemsFor(target);
  if (items.isNotEmpty) {
    navigator.popUntil((route) => route.isFirst);
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (context) => SessionScreen(items: items),
      ),
    );
  }
}

/// Replaces the current session by a bonus one on [cardIds], for "Review the
/// missed cards": their asked face is drawn again.
Future<void> replaceWithBonusSession(
  BuildContext context,
  WidgetRef ref,
  Iterable<int> cardIds,
) async {
  final navigator = Navigator.of(context);
  final items = await ref.read(sessionItemFactoryProvider).itemsFor(cardIds);
  await navigator.pushReplacement(
    MaterialPageRoute<void>(
      builder: (context) => SessionScreen(items: items, isBonus: true),
    ),
  );
}
