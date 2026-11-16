import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../data/repositories/review_repository.dart';
import '../../domain/reviews/review_record.dart';
import '../cards/card_providers.dart';
import '../clock.dart';
import '../scheduling/scheduling_providers.dart';
import '../time/minute_ticker.dart';
import 'answer_preview.dart';
import 'due_item.dart';
import 'due_queue.dart';
import 'review_service.dart';

final reviewRepositoryProvider = Provider(
  (ref) => ReviewRepository(ref.watch(databaseProvider)),
);

final reviewServiceProvider = Provider(
  (ref) => ReviewService(
    cards: ref.watch(cardRepositoryProvider),
    presets: ref.watch(presetRepositoryProvider),
    reviews: ref.watch(reviewRepositoryProvider),
    scheduler: ref.watch(reviewSchedulerProvider),
    duePolicy: ref.watch(duePolicyProvider),
    clock: ref.watch(clockProvider),
    scheduleChangeListener: ref.watch(scheduleChangeListenerProvider),
  ),
);

/// Every card to review now, earliest due first; empty while loading.
final dueItemsProvider = Provider<List<DueItem>>((ref) {
  final cards = ref.watch(allCardsProvider).value;
  final now = ref.watch(currentMomentProvider).value;
  if (cards == null || now == null) {
    return const [];
  } else {
    return DueQueue(ref.watch(duePolicyProvider)).build(cards, now);
  }
});

/// Effect of each answer on a card, for the answer buttons.
final answerPreviewProvider = FutureProvider.autoDispose
    .family<AnswerPreview, ({int cardId, bool asBonus})>(
      (ref, request) => ref
          .watch(reviewServiceProvider)
          .preview(request.cardId, asBonus: request.asBonus),
    );

/// History of a card, most recent first.
final cardHistoryProvider = StreamProvider.family<List<ReviewRecord>, int>(
  (ref, cardId) => ref.watch(reviewRepositoryProvider).watchHistory(cardId),
);
