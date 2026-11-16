import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/cards/card_providers.dart';
import '../../application/clock.dart';
import '../../application/reviews/review_providers.dart';
import '../../application/reviews/review_session.dart';
import '../../application/reviews/session_item.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/reviews/review_source.dart';
import '../../l10n/generated/app_localizations.dart';
import 'answer_buttons.dart';
import 'session_card_view.dart';
import 'session_end_view.dart';

/// Reviews [items] one by one: the prompt, a tap to reveal the answer, then
/// "Correct" or "Again". Ends on a summary.
class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({required this.items, this.isBonus = false, super.key});

  final List<SessionItem> items;

  /// A bonus session records the answers without moving any due date.
  final bool isBonus;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  late final ReviewSession _session = ReviewSession(
    items: widget.items,
    isBonus: widget.isBonus,
    startedAt: ref.read(clockProvider)(),
  );
  bool _isRevealed = false;
  bool _isAnswering = false;

  @override
  Widget build(BuildContext context) {
    final current = _session.current;
    return Scaffold(
      body: SafeArea(
        child: current == null
            ? SessionEndView(
                session: _session,
                finishedAt: ref.read(clockProvider)(),
              )
            : _question(current),
      ),
    );
  }

  Widget _question(SessionItem item) {
    final strings = AppLocalizations.of(context);
    final card = ref.watch(cardProvider(item.cardId)).value;
    return Column(
      children: [
        _header(strings),
        Expanded(
          child: card == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: GestureDetector(
                    onTap: _reveal,
                    child: SessionCardView(
                      card: card,
                      askedSide: item.askedSide,
                      isRevealed: _isRevealed,
                      isBonus: widget.isBonus,
                    ),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: _isRevealed
              ? AnswerButtons(
                  cardId: item.cardId,
                  isBonus: widget.isBonus,
                  enabled: !_isAnswering,
                  onAnswer: (outcome) => _answer(item, outcome),
                )
              : FilledButton(
                  onPressed: _reveal,
                  child: Text(strings.sessionShowAnswer),
                ),
        ),
      ],
    );
  }

  Widget _header(AppLocalizations strings) {
    final colors = AlambicColors.of(context);
    final total = _session.items.length;
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            tooltip: strings.sessionQuit,
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : _session.position / total,
                minHeight: 6,
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              strings.sessionProgress(_session.position + 1, total),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _reveal() {
    if (!_isRevealed) {
      setState(() => _isRevealed = true);
    }
  }

  Future<void> _answer(SessionItem item, ReviewOutcome outcome) async {
    setState(() => _isAnswering = true);
    await ref
        .read(reviewServiceProvider)
        .answer(
          item.cardId,
          outcome,
          source: ReviewSource.session,
          forceBonus: widget.isBonus,
        );
    if (mounted) {
      setState(() {
        _session.record(outcome);
        _isRevealed = false;
        _isAnswering = false;
      });
    }
  }
}
