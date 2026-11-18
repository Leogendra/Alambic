import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_rhythm.dart';
import '../cards/card_providers.dart';
import '../clock.dart';
import '../scheduling/scheduling_providers.dart';
import '../time/minute_ticker.dart';
import 'distillation_progress.dart';
import 'distillation_service.dart';

final distillationServiceProvider = Provider(
  (ref) => DistillationService(
    distillations: ref.watch(distillationRepositoryProvider),
    cards: ref.watch(cardRepositoryProvider),
    settings: ref.watch(notificationSettingsRepositoryProvider),
    pauses: ref.watch(pauseRepositoryProvider),
    scheduler: ref.watch(reviewSchedulerProvider),
    calendar: ref.watch(schedulingCalendarProvider),
    clock: ref.watch(clockProvider),
    scheduleChangeListener: ref.watch(scheduleChangeListenerProvider),
  ),
);

final distillationRhythmProvider = Provider(
  (ref) => DistillationRhythm(ref.watch(schedulingCalendarProvider)),
);

/// Start of the global pause, `null` when it is off.
final globalPauseProvider = StreamProvider<DateTime?>(
  (ref) => ref.watch(pauseRepositoryProvider).watchGlobalPause(),
);

/// The distillations of the groups that activated one.
final distillationsProvider = StreamProvider<List<Distillation>>(
  (ref) => ref.watch(distillationRepositoryProvider).watchAll(),
);

/// Progress of every distillation; empty while loading.
final distillationProgressesProvider = Provider<List<DistillationProgress>>((
  ref,
) {
  final distillations = ref.watch(distillationsProvider).value;
  final cards = ref.watch(allCardsProvider).value;
  final now = ref.watch(currentMomentProvider).value;
  final globalPause = ref.watch(globalPauseProvider);
  if (distillations == null ||
      cards == null ||
      now == null ||
      !globalPause.hasValue) {
    return const [];
  }
  final rhythm = ref.watch(distillationRhythmProvider);
  return [
    for (final distillation in distillations)
      DistillationProgress.of(
        distillation,
        cards.where((card) => card.groupId == distillation.groupId).toList(),
        rhythm,
        now,
        globallyPaused: globalPause.value != null,
      ),
  ];
});

/// The distillation of a group, `null` until it is activated.
final groupDistillationProvider = Provider.family<DistillationProgress?, int>(
  (ref, groupId) => ref
      .watch(distillationProgressesProvider)
      .where((progress) => progress.groupId == groupId)
      .firstOrNull,
);
