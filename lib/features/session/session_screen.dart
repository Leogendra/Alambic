import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Reviews [items] one by one: the prompt, "Show answer" (or a tap on the
/// card) to reveal the answer, then "Again" or "Correct". Ends on a summary.
class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({
    required this.items,
    this.isBonus = false,
    this.raisesMissedPending = false,
    super.key,
  });

  final List<SessionItem> items;

  /// A bonus session records the answers without moving any due date.
  final bool isBonus;

  /// "Review all" of a group: a pending card answered "Again" goes to the
  /// head of the queue, at once, so leaving the session keeps it there.
  final bool raisesMissedPending;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen>
    with SingleTickerProviderStateMixin {
  late final ReviewSession _session = ReviewSession(
    items: widget.items,
    isBonus: widget.isBonus,
    startedAt: ref.read(clockProvider)(),
  );
  late final AnimationController _revealController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  late final Animation<double> _revealProgress = CurvedAnimation(
    parent: _revealController,
    curve: Curves.easeOut,
  );
  bool _isRevealed = false;
  bool _isAnswering = false;

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

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
                      reveal: _revealProgress,
                      isBonus: widget.isBonus,
                    ),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: _buttons(item, strings),
        ),
      ],
    );
  }

  /// "Show answer", cross-faded into "Again" / "Correct" in the same space,
  /// so the card above does not move.
  Widget _buttons(SessionItem item, AppLocalizations strings) => SizedBox(
    height: AnswerButtons.height,
    child: AnimatedBuilder(
      animation: _revealProgress,
      builder: (context, _) => Stack(
        fit: StackFit.expand,
        children: [
          if (_revealProgress.value < 1)
            Opacity(
              opacity: 1 - _revealProgress.value,
              child: IgnorePointer(
                ignoring: _isRevealed,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _reveal,
                  child: Text(
                    strings.sessionShowAnswer,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          if (_isRevealed)
            Opacity(
              opacity: _revealProgress.value,
              child: AnswerButtons(
                cardId: item.cardId,
                isBonus: widget.isBonus,
                enabled: !_isAnswering,
                onAnswer: (outcome) => _answer(item, outcome),
              ),
            ),
        ],
      ),
    ),
  );

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
                // Laid on the page background, where the well token used by
                // the other tracks would vanish.
                backgroundColor: colors.border,
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

  /// Shows the answer with a light haptic tap; at once when the system asks
  /// for reduced motion.
  void _reveal() {
    if (!_isRevealed) {
      HapticFeedback.lightImpact();
      setState(() => _isRevealed = true);
      if (MediaQuery.disableAnimationsOf(context)) {
        _revealController.value = 1;
      } else {
        _revealController.forward();
      }
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
          raisesMissedPending: widget.raisesMissedPending,
        );
    if (mounted) {
      setState(() {
        _session.record(outcome);
        _isRevealed = false;
        _isAnswering = false;
      });
      // The next card shows unrevealed, without playing the reveal back.
      _revealController.value = 0;
    }
  }
}
