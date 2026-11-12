import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_rhythm.dart';
import '../clock.dart';
import '../scheduling/scheduling_providers.dart';
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
