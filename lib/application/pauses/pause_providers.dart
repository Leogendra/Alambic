import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../domain/pauses/pause_shift.dart';
import '../../domain/pauses/pauses.dart';
import '../clock.dart';
import '../scheduling/scheduling_providers.dart';
import 'pause_service.dart';

/// The global pause and the paused groups.
final pausesProvider = StreamProvider<Pauses>(
  (ref) => ref.watch(pauseRepositoryProvider).watchPauses(),
);

final pauseServiceProvider = Provider(
  (ref) => PauseService(
    pauses: ref.watch(pauseRepositoryProvider),
    cards: ref.watch(cardRepositoryProvider),
    shift: PauseShift(ref.watch(schedulingCalendarProvider)),
    clock: ref.watch(clockProvider),
    scheduleChangeListener: ref.watch(scheduleChangeListenerProvider),
  ),
);
