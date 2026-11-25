import '../../data/samples/sample_group.dart';
import '../../domain/cards/bulk/bulk_card_draft.dart';
import '../../domain/cards/bulk/bulk_card_parser.dart';
import '../cards/card_draft.dart';
import '../cards/card_service.dart';
import 'group_service.dart';

/// Creates the groups of example cards shipped with the app, at the end of
/// the onboarding or from "New" in the Groups tab. Such a group is an
/// ordinary group afterwards.
class SampleGroupService {
  const SampleGroupService({
    required this._groups,
    required this._cards,
    required this._loadCards,
  });

  final GroupService _groups;
  final CardService _cards;

  /// The text of the cards of an edition, one `front;back` line per card.
  final Future<String> Function(SampleEdition edition) _loadCards;

  /// The cards of [edition], in their queue order.
  Future<List<BulkCardDraft>> cards(SampleEdition edition) async =>
      BulkCardParser.parse(
        await _loadCards(edition),
        BulkCardParser.defaultSeparator,
      ).drafts;

  /// Creates the group [name] with the cards of [edition], pending in their
  /// order; it follows the global preset, without the back nor a
  /// distillation. A group already named [name] is returned as it is instead
  /// of being created again, so that asking twice makes no duplicate.
  /// Returns the id of the group.
  Future<int> createOrFind(
    SampleEdition edition, {
    required String name,
  }) async {
    final existingId = await _groups.findIdByName(name);
    if (existingId != null) {
      return existingId;
    }
    final drafts = await cards(edition);
    final groupId = await _groups.create(name);
    await _cards.createAll([
      for (final draft in drafts)
        CardDraft(
          frontText: draft.front,
          backText: draft.back,
          groupId: groupId,
        ),
    ]);
    return groupId;
  }
}
