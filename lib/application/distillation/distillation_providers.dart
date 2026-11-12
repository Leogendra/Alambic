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
    presets: ref.watch(presetRepositoryProvider),
    scheduler: ref.watch(reviewSchedulerProvider),
    calendar: ref.watch(schedulingCalendarProvider),
    clock: ref.watch(clockProvider),
    scheduleChangeListener: ref.watch(scheduleChangeListenerProvider),
  ),
);

final distillationRhythmProvider = Provider(
  (ref) => DistillationRhythm(ref.watch(schedulingCalendarProvider)),
);

/// Distillations in progress, running or paused, in launch order.
final distillationsProvider = StreamProvider<List<Distillation>>(
  (ref) => ref.watch(distillationRepositoryProvider).watchAll(),
);

/// Progress of every distillation in progress; empty while loading.
final distillationProgressesProvider = Provider<List<DistillationProgress>>((
  ref,
) {
  final distillations = ref.watch(distillationsProvider).value;
  final cards = ref.watch(allCardsProvider).value;
  final now = ref.watch(currentMomentProvider).value;
  if (distillations == null || cards == null || now == null) {
    return const [];
  }
  final rhythm = ref.watch(distillationRhythmProvider);
  final today = rhythm.calendar.dayOf(now);
  return [
    for (final distillation in distillations)
      DistillationProgress.of(distillation, cards, rhythm, today),
  ];
});

/// Distillations of a group, front → back first.
final groupDistillationsProvider =
    Provider.family<List<DistillationProgress>, int>(
      (ref, groupId) =>
          ref
              .watch(distillationProgressesProvider)
              .where((progress) => progress.distillation.groupId == groupId)
              .toList()
            ..sort(
              (first, second) => first.distillation.sense!.index.compareTo(
                second.distillation.sense!.index,
              ),
            ),
    );

/// The global distillation, when one is in progress.
final globalDistillationProvider = Provider<DistillationProgress?>(
  (ref) => ref
      .watch(distillationProgressesProvider)
      .where((progress) => progress.distillation.isGlobal)
      .firstOrNull,
);
