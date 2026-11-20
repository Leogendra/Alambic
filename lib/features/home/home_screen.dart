import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../application/home/home_providers.dart';
import '../../application/time/minute_ticker.dart';
import '../../l10n/generated/app_localizations.dart';
import '../pauses/global_pause_dialog.dart';
import '../pauses/paused_banner.dart';
import 'home_timeline_view.dart';

/// Home tab: the timeline of the cards coming, from today on, and the
/// global pause.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(homeTimelineProvider);
    final now = ref.watch(currentMomentProvider).value;
    if (timeline == null || now == null) {
      return const SizedBox.shrink();
    }
    final pausedAt = ref.watch(globalPauseProvider).value;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
      children: [
        _header(context, ref, now, paused: pausedAt != null),
        if (pausedAt != null) ...[
          const SizedBox(height: 20),
          PausedBanner(
            since: pausedAt,
            onResume: () => ref.read(distillationServiceProvider).resumeAll(),
          ),
        ],
        const SizedBox(height: 20),
        HomeTimelineView(timeline: timeline),
      ],
    );
  }

  Widget _header(
    BuildContext context,
    WidgetRef ref,
    DateTime now, {
    required bool paused,
  }) {
    final strings = AppLocalizations.of(context);
    final date = DateFormat.MMMMEEEEd(strings.localeName).format(now);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                strings.homeTitle,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              Text(
                date[0].toUpperCase() + date.substring(1),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AlambicColors.of(context).textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (!paused)
          IconButton(
            tooltip: strings.pauseAllTooltip,
            icon: const Icon(Icons.pause),
            onPressed: () => confirmGlobalPause(context, ref),
          ),
      ],
    );
  }
}
