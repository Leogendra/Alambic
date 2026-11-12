import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/formatting/preset_labels.dart';
import '../../app/theme/remanence_colors.dart';
import '../../app/widgets/count_stepper.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/segment_option.dart';
import '../../app/widgets/segmented_choice.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/cards/card_providers.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../application/distillation/distillation_refused.dart';
import '../../application/distillation/distillation_service.dart';
import '../../application/groups/group_providers.dart';
import '../../application/time/minute_ticker.dart';
import '../../domain/cards/direction_sense.dart';
import '../../domain/distillation/distillation_order.dart';
import '../../domain/distillation/distillation_settings.dart';
import '../../l10n/generated/app_localizations.dart';
import 'distillation_labels.dart';
import 'distillation_tile.dart';
import 'distillation_warning.dart';

/// "Distill": settings of a new distillation of a group, with an estimate of
/// its last arrival.
class DistillationLaunchScreen extends ConsumerStatefulWidget {
  const DistillationLaunchScreen({required this.groupId, super.key});

  final int groupId;

  @override
  ConsumerState<DistillationLaunchScreen> createState() =>
      _DistillationLaunchScreenState();
}

class _DistillationLaunchScreenState
    extends ConsumerState<DistillationLaunchScreen> {
  DistillationSettings _settings = const DistillationSettings();
  DirectionSense? _chosenSense;
  bool _launching = false;

  void _update(DistillationSettings Function(DistillationSettings) change) =>
      setState(() => _settings = change(_settings));

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = RemanenceColors.of(context);
    final summary = ref.watch(groupSummaryProvider(widget.groupId));
    final cards = ref.watch(groupCardsProvider(widget.groupId)).value ?? [];
    final taken = {
      for (final progress in ref.watch(
        groupDistillationsProvider(widget.groupId),
      ))
        progress.distillation.sense,
    };
    final sense =
        _chosenSense ??
        DirectionSense.values.firstWhere(
          (sense) => !taken.contains(sense),
          orElse: () => DirectionSense.frontToBack,
        );
    final global = ref.watch(globalDistillationProvider);
    final remaining = taken.contains(sense)
        ? 0
        : DistillationService.queueableInGroup(cards, sense);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.distillTitle),
            if (summary?.group case final group?)
              Text(
                group.name,
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          if (summary != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                strings.distillIntro(
                  strings.presetScheduleLabel(summary.preset),
                  summary.preset.name,
                ),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: colors.textSecondary,
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (global != null) ...[
            DistillationWarning(strings.distillBlockedByGlobal),
            const SizedBox(height: 16),
            DistillationTile(progress: global),
          ] else ...[
            SectionLabel(strings.distillSense),
            SegmentedChoice<DirectionSense>(
              options: [
                for (final option in DirectionSense.values)
                  SegmentOption(
                    option,
                    strings.directionName(option),
                    enabled: !taken.contains(option),
                  ),
              ],
              selected: sense,
              onSelected: (value) => setState(() => _chosenSense = value),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Text(
                taken.contains(sense)
                    ? strings.distillSenseTaken
                    : strings.distillSenseCount(remaining),
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            ..._rhythmSection(strings),
            const SizedBox(height: 16),
            SectionLabel(strings.distillOrder),
            SegmentedChoice<DistillationOrder>(
              options: [
                SegmentOption(
                  DistillationOrder.groupOrder,
                  strings.distillOrderGroup,
                ),
                SegmentOption(
                  DistillationOrder.random,
                  strings.distillOrderRandom,
                ),
              ],
              selected: _settings.order,
              onSelected: (value) =>
                  _update((settings) => settings.copyWith(order: value)),
            ),
            const SizedBox(height: 16),
            _collisionsPanel(strings),
            const SizedBox(height: 24),
            _footer(strings, colors, remaining, onLaunch: () => _launch(sense)),
          ],
        ],
      ),
    );
  }

  List<Widget> _rhythmSection(AppLocalizations strings) => [
    SectionLabel(strings.distillRhythm),
    DistillationRhythmPanel(
      settings: _settings,
      onChanged: (settings) => setState(() => _settings = settings),
    ),
  ];

  Widget _collisionsPanel(AppLocalizations strings) => SurfacePanel(
    children: [
      PanelRow(
        title: strings.distillAvoidCollisions,
        subtitle: strings.distillAvoidCollisionsHint(_settings.cardsPerBatch),
        trailing: Switch(
          value: _settings.avoidCollisions,
          onChanged: (value) =>
              _update((settings) => settings.copyWith(avoidCollisions: value)),
        ),
      ),
    ],
  );

  Widget _footer(
    AppLocalizations strings,
    RemanenceColors colors,
    int remaining, {
    required VoidCallback onLaunch,
  }) {
    final now = ref.watch(currentMomentProvider).value;
    final rhythm = ref.watch(distillationRhythmProvider);
    final lastArrival = now == null
        ? null
        : rhythm.lastArrival(
            remaining: remaining,
            cardsPerBatch: _settings.cardsPerBatch,
            everyDays: _settings.everyDays,
            firstDay: rhythm.calendar.dayOf(now),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          spacing: 10,
          children: [
            Icon(Icons.water_drop_outlined, size: 18, color: colors.accent),
            Expanded(
              child: Text(
                lastArrival == null
                    ? strings.distillNothing
                    : strings.distillEstimate(
                        remaining,
                        strings.longDate(lastArrival),
                      ),
                style: TextStyle(fontSize: 14, color: colors.textPrimary),
              ),
            ),
          ],
        ),
        FilledButton(
          onPressed: remaining == 0 || _launching ? null : onLaunch,
          child: Text(strings.distillLaunch),
        ),
      ],
    );
  }

  Future<void> _launch(DirectionSense sense) async {
    final strings = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _launching = true);
    try {
      await ref
          .read(distillationServiceProvider)
          .launchForGroup(widget.groupId, sense, _settings);
      navigator.pop();
    } on DistillationRefused catch (refused) {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.distillRefusal(refused.reason))),
      );
      if (mounted) {
        setState(() => _launching = false);
      }
    }
  }
}

/// "N cards every X days", as two steppers.
class DistillationRhythmPanel extends StatelessWidget {
  const DistillationRhythmPanel({
    required this.settings,
    required this.onChanged,
    super.key,
  });

  final DistillationSettings settings;
  final ValueChanged<DistillationSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SurfacePanel(
      children: [
        PanelRow(
          title: strings.distillCards,
          trailing: CountStepper(
            value: settings.cardsPerBatch,
            label: '${settings.cardsPerBatch}',
            decreaseTooltip: strings.distillFewerCards,
            increaseTooltip: strings.distillMoreCards,
            onChanged: (value) =>
                onChanged(settings.copyWith(cardsPerBatch: value)),
          ),
        ),
        PanelRow(
          title: strings.distillEvery,
          trailing: CountStepper(
            value: settings.everyDays,
            label: strings.distillDays(settings.everyDays),
            decreaseTooltip: strings.distillFewerDays,
            increaseTooltip: strings.distillMoreDays,
            onChanged: (value) =>
                onChanged(settings.copyWith(everyDays: value)),
          ),
        ),
      ],
    );
  }
}
