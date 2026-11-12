import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../data/repositories/card_with_directions.dart';
import '../clock.dart';
import '../distillation/distillation_providers.dart';
import '../scheduling/scheduling_providers.dart';
import 'card_service.dart';

final cardServiceProvider = Provider(
  (ref) => CardService(
    cards: ref.watch(cardRepositoryProvider),
    presets: ref.watch(presetRepositoryProvider),
    images: ref.watch(imageStoreProvider),
    scheduler: ref.watch(reviewSchedulerProvider),
    distillations: ref.watch(distillationServiceProvider),
    clock: ref.watch(clockProvider),
    scheduleChangeListener: ref.watch(scheduleChangeListenerProvider),
  ),
);

final cardProvider = StreamProvider.family<CardWithDirections?, int>(
  (ref, cardId) => ref.watch(cardRepositoryProvider).watchCard(cardId),
);

/// Cards of a group, or of "No group" for `null`.
final groupCardsProvider =
    StreamProvider.family<List<CardWithDirections>, int?>(
      (ref, groupId) =>
          ref.watch(cardRepositoryProvider).watchCardsOfGroup(groupId),
    );

final allCardsProvider = StreamProvider<List<CardWithDirections>>(
  (ref) => ref.watch(cardRepositoryProvider).watchAll(),
);

/// Cards whose front or back contains the searched text.
final cardSearchProvider =
    StreamProvider.family<List<CardWithDirections>, String>(
      (ref, text) => ref.watch(cardRepositoryProvider).watchSearch(text),
    );
