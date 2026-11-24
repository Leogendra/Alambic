import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/due_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/reviews/review_providers.dart';
import '../../domain/reviews/review_outcome.dart';
import '../../domain/reviews/review_record.dart';
import 'card_status_formatter.dart';

/// When a card was last answered "Correct" and last "Again", bonus reviews
/// included: "3 d ago", "today" or "never".
class LastAnswers extends ConsumerWidget {
  const LastAnswers({required this.cardId, required this.formatter, super.key});

  final int cardId;
  final CardStatusFormatter formatter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = formatter.strings;
    final colors = AlambicColors.of(context);
    final history = ref.watch(cardHistoryProvider(cardId)).value ?? const [];
    return SurfacePanel(
      children: [
        _row(
          Icons.check_circle_outline,
          colors.accentText,
          strings.cardSheetLastCorrect,
          _last(history, ReviewOutcome.correct),
          colors,
        ),
        _row(
          Icons.replay,
          colors.againForeground,
          strings.cardSheetLastAgain,
          _last(history, ReviewOutcome.again),
          colors,
        ),
      ],
    );
  }

  /// The most recent answer of [outcome]; [history] is most recent first.
  String _last(List<ReviewRecord> history, ReviewOutcome outcome) {
    final last = history
        .where((record) => record.outcome == outcome)
        .firstOrNull;
    return last == null
        ? formatter.strings.cardSheetNever
        : formatter.strings.agoLabelOf(
            last.reviewedAt,
            now: formatter.now,
            calendar: formatter.calendar,
          );
  }

  Widget _row(
    IconData icon,
    Color iconColor,
    String label,
    String value,
    AlambicColors colors,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      spacing: 12,
      children: [
        Icon(icon, size: 20, color: iconColor),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
      ],
    ),
  );
}
