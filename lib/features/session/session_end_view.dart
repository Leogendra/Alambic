import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/reviews/review_session.dart';
import '../../l10n/generated/app_localizations.dart';
import 'session_launcher.dart';

/// Summary of a finished session, with the bonus review of missed cards.
class SessionEndView extends ConsumerWidget {
  const SessionEndView({
    required this.session,
    required this.finishedAt,
    super.key,
  });

  final ReviewSession session;
  final DateTime finishedAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final missed = session.missedItems;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.sessionFinished,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            strings.sessionSummary(
              session.items.length,
              _duration(strings, finishedAt.difference(session.startedAt)),
            ),
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            spacing: 10,
            children: [
              _stat(context, session.correctCount, strings.sessionCorrectLabel),
              _stat(context, session.againCount, strings.sessionAgainLabel),
            ],
          ),
          const Spacer(),
          if (missed.isNotEmpty) ...[
            OutlinedButton(
              onPressed: () => replaceWithBonusSession(context, ref, [
                for (final item in missed) item.cardId,
              ]),
              child: Text(strings.sessionReviewMissed(missed.length)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
              child: Text(
                strings.sessionBonusHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
            ),
          ],
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.sessionBackHome),
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, int value, String label) {
    final colors = AlambicColors.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _duration(AppLocalizations strings, Duration duration) {
    final seconds = duration.inSeconds % 60;
    if (duration.inMinutes == 0) {
      return strings.durationSeconds(seconds);
    } else {
      return strings.durationMinutesSeconds(
        duration.inMinutes,
        seconds.toString().padLeft(2, '0'),
      );
    }
  }
}
