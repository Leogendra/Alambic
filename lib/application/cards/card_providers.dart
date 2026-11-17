import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../domain/cards/flashcard.dart';
import '../clock.dart';
import '../scheduling/scheduling_providers.dart';
import 'card_service.dart';

final cardServiceProvider = Provider(
  (ref) => CardService(
    cards: ref.watch(cardRepositoryProvider),
    images: ref.watch(imageStoreProvider),
    clock: ref.watch(clockProvider),
    scheduleChangeListener: ref.watch(scheduleChangeListenerProvider),
  ),
);

final cardProvider = StreamProvider.family<Flashcard?, int>(
  (ref, cardId) => ref.watch(cardRepositoryProvider).watchCard(cardId),
);

/// Cards of a group, in creation order.
final groupCardsProvider = StreamProvider.family<List<Flashcard>, int>(
  (ref, groupId) =>
      ref.watch(cardRepositoryProvider).watchCardsOfGroup(groupId),
);

final allCardsProvider = StreamProvider<List<Flashcard>>(
  (ref) => ref.watch(cardRepositoryProvider).watchAll(),
);

/// Cards whose front or back contains the searched text.
final cardSearchProvider = StreamProvider.family<List<Flashcard>, String>(
  (ref, text) => ref.watch(cardRepositoryProvider).watchSearch(text),
);
