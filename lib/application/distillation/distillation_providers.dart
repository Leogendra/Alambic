import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_rhythm.dart';
import '../cards/card_providers.dart';
import '../clock.dart';
import '../presets/preset_providers.dart';
import '../scheduling/scheduling_providers.dart';
import '../time/minute_ticker.dart';
import 'distillation_progress.dart';
import 'distillation_service.dart';
import 'queue_service.dart';
import 'queue_standing.dart';

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
  if (distillations == null || cards == null) {
    return const [];
  }
  return [
    for (final distillation in distillations)
      DistillationProgress.of(
        distillation,
        cards.where((card) => card.groupId == distillation.groupId).toList(),
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

final queueServiceProvider = Provider(
  (ref) => QueueService(
    cards: ref.watch(cardRepositoryProvider),
    scheduleChangeListener: ref.watch(scheduleChangeListenerProvider),
  ),
);

/// Where a pending card stands in the queue of its group; `null` while
/// loading and once it is introduced.
final queueStandingProvider = Provider.family<QueueStanding?, int>((
  ref,
  cardId,
) {
  final card = ref.watch(cardProvider(cardId)).value;
  if (card == null || !card.isPending) {
    return null;
  }
  final groupCards = ref.watch(groupCardsProvider(card.groupId)).value;
  final distillations = ref.watch(distillationsProvider).value;
  final globalPause = ref.watch(globalPauseProvider);
  final catalog = ref.watch(presetCatalogProvider).value;
  final now = ref.watch(currentMomentProvider).value;
  if (groupCards == null ||
      distillations == null ||
      !globalPause.hasValue ||
      catalog == null ||
      now == null) {
    return null;
  }
  return QueueStanding.of(
    card,
    groupCards,
    distillation: distillations
        .where((distillation) => distillation.groupId == card.groupId)
        .firstOrNull,
    globallyPaused: globalPause.value != null,
    preset: catalog.presetForGroup(card.groupId),
    end: catalog.sequenceEndForGroup(card.groupId),
    rhythm: ref.watch(distillationRhythmProvider),
    now: now,
  );
});
