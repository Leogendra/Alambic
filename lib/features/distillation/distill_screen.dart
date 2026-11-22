import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/date_labels.dart';
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
import '../../application/presets/preset_providers.dart';
import '../../application/time/minute_ticker.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_queue.dart';
import '../../domain/distillation/distillation_settings.dart';
import '../../l10n/generated/app_localizations.dart';
import 'distillation_preset_section.dart';

/// "Distill": settings of the distillation of a group, with an estimate of
/// the last arrival of its queue. Activates the distillation, or adjusts it
/// when [currentSettings] are given; it is then paused and resumed here, at
/// once, without "Save".
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
    final distillation = widget.isAdjusting
        ? ref.watch(groupDistillationProvider(widget.groupId))?.distillation
        : null;
    final pausedAt = distillation?.pausedAt;
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
          _prioritizePanel(strings),
          const SizedBox(height: 16),
          DistillationPresetSection(groupId: widget.groupId),
          if (widget.isAdjusting) ...[
            const SizedBox(height: 16),
            _pauseButton(strings, colors, pausedAt),
          ],
          const SizedBox(height: 24),
          _footer(strings, colors, cards, distillation),
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

  Widget _prioritizePanel(AppLocalizations strings) => SurfacePanel(
    children: [
      PanelRow(
        title: strings.distillPrioritizeReviews,
        subtitle: strings.distillPrioritizeReviewsHint,
        trailing: Switch(
          value: _settings.prioritizeReviews,
          onChanged: (value) => _update(
            (settings) => settings.copyWith(prioritizeReviews: value),
          ),
        ),
      ),
    ],
  );

  /// Pause or resume, applied at once, with what a pause does.
  Widget _pauseButton(
    AppLocalizations strings,
    AlambicColors colors,
    DateTime? pausedAt,
  ) {
    final service = ref.read(distillationServiceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: colors.surface,
            foregroundColor: colors.accentText,
            side: BorderSide(color: colors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: Icon(pausedAt == null ? Icons.pause : Icons.play_arrow),
          label: Text(
            pausedAt == null ? strings.distillPause : strings.pauseResume,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          onPressed: () => pausedAt == null
              ? service.pause(widget.groupId)
              : service.resume(widget.groupId),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            pausedAt == null
                ? strings.distillPauseHint
                : strings.distillPausedHint(strings.longDate(pausedAt)),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// The estimate of the last arrival with the settings picked, or the
  /// waiting cards while paused on its own or globally.
  Widget _footer(
    AppLocalizations strings,
    AlambicColors colors,
    List<Flashcard> cards,
    Distillation? distillation,
  ) {
    final remaining = DistillationQueue.remaining(cards);
    final paused =
        (distillation?.isPaused ?? false) ||
        ref.watch(globalPauseProvider).value != null;
    final arrivals = paused ? null : _arrivals(cards, distillation);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          spacing: 10,
          children: [
            Icon(Icons.water_drop_outlined, size: 18, color: colors.accent),
            Expanded(
              child: Text.rich(
                paused
                    ? TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${strings.distillationWaiting(remaining)} · ',
                          ),
                          TextSpan(
                            text: strings.distillPausedTag,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      )
                    : TextSpan(text: _estimate(strings, remaining, arrivals)),
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

  /// The estimate line: empty while the data loads, then the last arrival,
  /// or the delay when it is out of the forecast.
  String _estimate(
    AppLocalizations strings,
    int remaining,
    Map<DateTime, int>? arrivals,
  ) {
    if (arrivals == null) {
      return '';
    } else if (remaining == 0) {
      return strings.distillNothing;
    } else if (arrivals.values.fold(0, (sum, count) => sum + count) <
        remaining) {
      return strings.distillEstimateFar(remaining);
    } else {
      return strings.distillEstimate(
        remaining,
        strings.longDate(arrivals.keys.last),
      );
    }
  }

  /// Arrivals with the settings being picked, `null` while the data loads.
  /// The first batch comes out today on activation; once adjusted, the day
  /// after the last one.
  Map<DateTime, int>? _arrivals(
    List<Flashcard> cards,
    Distillation? distillation,
  ) {
    final now = ref.watch(currentMomentProvider).value;
    final catalog = ref.watch(presetCatalogProvider).value;
    if (now == null || catalog == null) {
      return null;
    }
    final rhythm = ref.watch(distillationRhythmProvider);
    final today = rhythm.calendar.dayOf(now);
    return rhythm.forecast(
      _settings,
      cards,
      preset: catalog.presetForGroup(widget.groupId),
      end: catalog.sequenceEndForGroup(widget.groupId),
      firstDay: distillation == null
          ? today
          : rhythm.nextIntroductionDay(
              distillation.withSettings(_settings),
              today,
            ),
      now: now,
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

/// "N cards a day", as a stepper.
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
      ],
    );
  }
}
