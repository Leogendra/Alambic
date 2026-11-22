import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/pull_to_reveal.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../application/home/home_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../pauses/paused_banner.dart';
import 'home_timeline_view.dart';
import 'learned_counter.dart';

/// Home tab: the timeline of the cards coming, from today on, and the banner
/// of the global pause, which is started from Settings. Pulling the timeline
/// down uncovers the number of cards learned so far.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(homeTimelineProvider);
    if (timeline == null) {
      return const SizedBox.shrink();
    }
    final pausedAt = ref.watch(globalPauseProvider).value;
    return PullToReveal(
      revealed: LearnedCounter(count: timeline.learnedCount),
      revealedHeight: MediaQuery.textScalerOf(context)
          .scale(LearnedCounter.height),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
      children: [
        Text(
          AppLocalizations.of(context).homeTitle,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        if (pausedAt != null) ...[
          const SizedBox(height: 20),
          PausedBanner(
            since: pausedAt,
            onResume: () => ref.read(distillationServiceProvider).resumeAll(),
          ),
        ],
        const SizedBox(height: 22),
        HomeTimelineView(timeline: timeline),
      ],
    );
  }
}
