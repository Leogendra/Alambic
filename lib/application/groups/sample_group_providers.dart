import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/samples/sample_group.dart';
import '../../domain/cards/bulk/bulk_card_draft.dart';
import '../cards/card_providers.dart';
import 'group_providers.dart';
import 'sample_group_service.dart';

final sampleGroupServiceProvider = Provider(
  (ref) => SampleGroupService(
    groups: ref.watch(groupServiceProvider),
    cards: ref.watch(cardServiceProvider),
    loadCards: (edition) => edition.sample.load(edition.languageCode),
  ),
);

/// The cards of a sample group in a language, shown before it is created.
final sampleCardsProvider =
    FutureProvider.family<List<BulkCardDraft>, SampleEdition>(
      (ref, edition) => ref.watch(sampleGroupServiceProvider).cards(edition),
    );
