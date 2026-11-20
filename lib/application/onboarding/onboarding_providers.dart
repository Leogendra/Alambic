import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/samples/bundled_sample_cards.dart';
import '../../domain/cards/bulk/bulk_card_draft.dart';
import '../cards/card_providers.dart';
import '../groups/group_providers.dart';
import 'first_group_controller.dart';
import 'sample_group_service.dart';

final firstGroupProvider = NotifierProvider<FirstGroupController, int?>(
  FirstGroupController.new,
);

final sampleGroupServiceProvider = Provider(
  (ref) => SampleGroupService(
    groups: ref.watch(groupServiceProvider),
    cards: ref.watch(cardServiceProvider),
    loadCards: BundledSampleCards.load,
  ),
);

/// The cards of the sample group in a language, shown before it is created.
final sampleCardsProvider = FutureProvider.family<List<BulkCardDraft>, String>(
  (ref, languageCode) =>
      ref.watch(sampleGroupServiceProvider).cards(languageCode),
);
