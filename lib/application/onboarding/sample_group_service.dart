import '../../domain/cards/bulk/bulk_card_draft.dart';
import '../../domain/cards/bulk/bulk_card_parser.dart';
import '../cards/card_draft.dart';
import '../cards/card_service.dart';
import '../groups/group_service.dart';

/// The group of example cards created at the end of the onboarding, so that
/// the user has something to distill at once. It is an ordinary group
/// afterwards.
class SampleGroupService {
  const SampleGroupService({
    required this._groups,
    required this._cards,
    required this._loadCards,
  });

  final GroupService _groups;
  final CardService _cards;

  /// The text of the sample cards, one `front;back` line per card.
  final Future<String> Function() _loadCards;

  /// The cards of the group, in their queue order.
  Future<List<BulkCardDraft>> cards() async => BulkCardParser.parse(
    await _loadCards(),
    BulkCardParser.defaultSeparator,
  ).drafts;

  /// Creates the group named [name] with its cards, pending in their order;
  /// it follows the global preset, without the back nor a distillation.
  /// Returns the id of the group.
  Future<int> create(String name) async {
    final drafts = await cards();
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
