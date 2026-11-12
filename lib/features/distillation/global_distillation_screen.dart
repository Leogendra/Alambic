import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/remanence_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/cards/card_providers.dart';
import '../../application/distillation/distillation_progress.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../application/distillation/distillation_refused.dart';
import '../../application/distillation/distillation_service.dart';
import '../../application/groups/group_providers.dart';
import '../../application/time/minute_ticker.dart';
import '../../domain/distillation/distillation_settings.dart';
import '../../l10n/generated/app_localizations.dart';
import 'distillation_labels.dart';
import 'distillation_launch_screen.dart';
import 'distillation_tile.dart';
import 'distillation_warning.dart';

/// "Global distillation", from Settings: launches it, or follows the one in
/// progress.
class GlobalDistillationScreen extends ConsumerStatefulWidget {
  const GlobalDistillationScreen({super.key});

  @override
  ConsumerState<GlobalDistillationScreen> createState() =>
      _GlobalDistillationScreenState();
}

class _GlobalDistillationScreenState
    extends ConsumerState<GlobalDistillationScreen> {
  DistillationSettings _settings = const DistillationSettings();
  bool _launching = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = RemanenceColors.of(context);
    final global = ref.watch(globalDistillationProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsGlobalDistillation)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              strings.globalDistillationIntro,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (global != null)
            ..._inProgress(strings, global)
          else
            ..._launchForm(strings, colors),
        ],
      ),
    );
  }

  List<Widget> _inProgress(
    AppLocalizations strings,
    DistillationProgress global,
  ) => [
    DistillationTile(progress: global),
    const SizedBox(height: 16),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        strings.globalDistillationInProgress,
        style: TextStyle(
          fontSize: 14,
          color: RemanenceColors.of(context).textSecondary,
        ),
      ),
    ),
  ];

  List<Widget> _launchForm(AppLocalizations strings, RemanenceColors colors) {
    final cards = ref.watch(allCardsProvider).value ?? [];
    final remaining = DistillationService.queueableGlobally(cards);
    final stopped = ref.watch(distillationProgressesProvider);
    final groupNames = {
      for (final summary in ref.watch(groupSummariesProvider))
        if (summary.group case final group?) group.id: group.name,
    };
    final names = {
      for (final progress in stopped) groupNames[progress.distillation.groupId],
    }.nonNulls.join(', ');
    return [
      DistillationWarning(
        [
          if (stopped.isNotEmpty)
            strings.globalDistillationStops(stopped.length, names),
          strings.globalDistillationBlocksGroups,
        ].join(' '),
      ),
      const SizedBox(height: 16),
      SectionLabel(strings.distillRhythm),
      DistillationRhythmPanel(
        settings: _settings,
        onChanged: (settings) => setState(() => _settings = settings),
      ),
      const SizedBox(height: 16),
      SurfacePanel(
        children: [
          PanelRow(
            title: strings.distillAvoidCollisions,
            subtitle: strings.distillAvoidCollisionsHint(
              _settings.cardsPerBatch,
            ),
            trailing: Switch(
              value: _settings.avoidCollisions,
              onChanged: (value) => setState(
                () => _settings = _settings.copyWith(avoidCollisions: value),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      Row(
        spacing: 10,
        children: [
          Icon(Icons.water_drop_outlined, size: 18, color: colors.accent),
          Expanded(
            child: Text(
              _estimate(strings, remaining),
              style: TextStyle(fontSize: 14, color: colors.textPrimary),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: remaining == 0 || _launching ? null : _launch,
        child: Text(strings.globalDistillationLaunch),
      ),
    ];
  }

  /// "212 to introduce · about 7 months at this rhythm".
  String _estimate(AppLocalizations strings, int remaining) {
    final now = ref.watch(currentMomentProvider).value;
    final rhythm = ref.watch(distillationRhythmProvider);
    if (now == null || remaining == 0) {
      return strings.distillRefusedNothing;
    }
    final today = rhythm.calendar.dayOf(now);
    final lastArrival = rhythm.lastArrival(
      remaining: remaining,
      cardsPerBatch: _settings.cardsPerBatch,
      everyDays: _settings.everyDays,
      firstDay: today,
    )!;
    final days = (lastArrival.difference(today).inHours / 24).round() + 1;
    return strings.globalDistillationEstimate(
      remaining,
      strings.approximateSpan(days),
    );
  }

  Future<void> _launch() async {
    final strings = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _launching = true);
    try {
      await ref.read(distillationServiceProvider).launchGlobal(_settings);
    } on DistillationRefused catch (refused) {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.distillRefusal(refused.reason))),
      );
    }
    if (mounted) {
      setState(() => _launching = false);
    }
  }
}
