import 'package:flutter/material.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/surface_panel.dart';
import '../../l10n/generated/app_localizations.dart';

/// "En pause depuis le 12 nov." with a "Reprendre" button, at the top of Home
/// during the global pause.
class PausedBanner extends StatelessWidget {
  const PausedBanner({required this.since, required this.onResume, super.key});

  final DateTime since;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Icon(Icons.pause_circle_outline, color: colors.accent),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        strings.pausedSince(strings.shortDate(since)),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        strings.pausedHint,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            FilledButton.tonal(
              onPressed: onResume,
              child: Text(strings.pauseResume),
            ),
          ],
        ),
      ],
    );
  }
}
