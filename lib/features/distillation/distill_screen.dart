import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/formatting/preset_labels.dart';
import '../../app/formatting/reminder_settings_labels.dart';
import '../../app/layout/scroll_padding.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/count_stepper.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/cards/card_providers.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../application/groups/group_providers.dart';
import '../../application/notifications/guard_providers.dart';
import '../../application/time/minute_ticker.dart';
import '../../domain/distillation/distillation_queue.dart';
import '../../domain/distillation/distillation_settings.dart';
import '../../l10n/generated/app_localizations.dart';

/// "Distill": settings of the distillation of a group, with an estimate of
/// the last arrival of its queue. Activates the distillation, or adjusts it
/// when [currentSettings] are given.
class DistillScreen extends ConsumerStatefulWidget {
  const DistillScreen({required this.groupId, this.currentSettings, super.key});

  final int groupId;

  /// Settings of the distillation already active; `null` to activate one.
  final DistillationSettings? currentSettings;

  bool get isAdjusting => currentSettings != null;

  @override
  ConsumerState<DistillScreen> createState() => _DistillScreenState();
}

class _DistillScreenState extends ConsumerState<DistillScreen> {
  late DistillationSettings _settings =
      widget.currentSettings ?? const DistillationSettings();
  bool _saving = false;

  void _update(DistillationSettings Function(DistillationSettings) change) =>
      setState(() => _settings = change(_settings));

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final summary = ref.watch(groupSummaryProvider(widget.groupId));
    final reminders = ref.watch(reminderSettingsProvider).value;
    final cards = ref.watch(groupCardsProvider(widget.groupId)).value ?? [];
    final remaining = DistillationQueue.remaining(cards);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isAdjusting
                  ? strings.distillAdjustTitle
                  : strings.distillTitle,
            ),
            if (summary?.group case final group?)
              Text(
                group.name,
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
          ],
        ),
      ),
      body: ListView(
        padding: scrollPadding(
          context,
          const EdgeInsets.fromLTRB(20, 4, 20, 24),
        ),
        children: [
          if (summary != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                strings.distillIntro(
                  reminders == null ? '' : strings.scheduleLabel(reminders),
                  strings.presetName(summary.preset),
                ),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: colors.textSecondary,
                ),
              ),
            ),
          const SizedBox(height: 16),
          ..._rhythmSection(strings),
          const SizedBox(height: 16),
          _collisionsPanel(strings),
          const SizedBox(height: 24),
          _footer(strings, colors, remaining),
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
    AlambicColors colors,
    int remaining,
  ) {
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
          onPressed: _saving ? null : _save,
          child: Text(
            widget.isAdjusting ? strings.commonSave : strings.distillActivate,
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final service = ref.read(distillationServiceProvider);
    setState(() => _saving = true);
    if (widget.isAdjusting) {
      await service.adjust(widget.groupId, _settings);
    } else {
      await service.activate(widget.groupId, _settings);
    }
    navigator.pop();
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
