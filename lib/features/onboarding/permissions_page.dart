import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/notifications/guard_providers.dart';
import '../../application/notifications/notification_providers.dart';
import '../../domain/notifications/reminder_settings.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../l10n/generated/app_localizations.dart';
import 'onboarding_page.dart';

/// Third screen: a card notification as it arrives, the time of the
/// reminders, a button showing such a notification at once, and the button
/// asking for the right to post notifications, then for exact alarms.
///
/// Exact alarms are allowed from a system settings page, opened only while
/// they are refused; the screen moves on without waiting for the user to
/// come back from it. A time picked is written at once into the schedule of
/// the app, so that "Skip" keeps it.
class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage> {
  ClockTime _time = ReminderSettings.defaults.fixedTime;
  bool _isAsking = false;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _time.hour, minute: _time.minute),
    );
    if (picked == null) {
      return;
    }
    final time = ClockTime(picked.hour, picked.minute);
    setState(() => _time = time);
    await ref.read(notificationSettingsServiceProvider).setFixedTime(time);
  }

  /// Asks for notifications first, where needed: without them, the test
  /// shows nothing.
  Future<void> _sendTest() async {
    final strings = AppLocalizations.of(context);
    final presenter = ref.read(notificationPresenterProvider);
    if (await presenter.requestPermission()) {
      await presenter.showTestPrompt(
        groupName: strings.onboardingSampleGroupName,
        question: strings.onboardingNotificationQuestion,
      );
    }
  }

  Future<void> _allow() async {
    setState(() => _isAsking = true);
    await ref.read(notificationPresenterProvider).requestPermission();
    final alarms = ref.read(alarmSchedulerProvider);
    if (!await alarms.canScheduleExact()) {
      await alarms.requestExactPermission();
    }
    if (mounted) {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return OnboardingPage(
      step: 2,
      title: strings.onboardingPermissionsTitle,
      body: strings.onboardingPermissionsBody,
      action: FilledButton(
        onPressed: _isAsking ? null : _allow,
        child: Text(strings.onboardingAllowNotifications),
      ),
      illustration: const _NotificationPreview(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 32,
        children: [
          _ActionRow(
            icon: Icons.schedule,
            title: strings.onboardingTime,
            hint: strings.onboardingTimeHint,
            value: '$_time',
            onTap: _pickTime,
          ),
          _ActionRow(
            title: strings.onboardingTestNotification,
            hint: strings.onboardingTestNotificationHint,
            onTap: _sendTest,
          ),
        ],
      ),
    );
  }
}

/// A card notification: the app and the group, the question, and the
/// buttons that answer it.
class _NotificationPreview extends StatelessWidget {
  const _NotificationPreview();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final actionStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: colors.accentText,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            spacing: 8,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.accent,
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size.square(14),
                    painter: _DropsPainter(colors.onAccent),
                  ),
                ),
              ),
              Text(
                strings.onboardingNotificationSource,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),
          Text(
            strings.onboardingNotificationQuestion,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              spacing: 20,
              children: [
                Text(strings.reviewCorrect, style: actionStyle),
                Text(strings.reviewAgain, style: actionStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The mark of the app: four drops on a line, growing and darkening.
class _DropsPainter extends CustomPainter {
  const _DropsPainter(this.color);

  final Color color;

  /// Centre, radius and opacity of each drop, on a 84 unit square.
  static const _drops = [
    (6.75, 4.5, 0.2),
    (19.75, 6.5, 0.4),
    (39.75, 9.0, 0.7),
    (69.75, 12.0, 1.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 84;
    for (final (x, radius, opacity) in _drops) {
      canvas.drawCircle(
        Offset(x * scale, size.height / 2),
        radius * scale,
        Paint()..color = color.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_DropsPainter oldDelegate) => oldDelegate.color != color;
}

/// A tappable row: an optional [icon], a [title] over its [hint], and an
/// optional [value] at the end.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.hint,
    required this.onTap,
    this.icon,
    this.value,
  });

  final IconData? icon;
  final String title;
  final String hint;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            spacing: 14,
            children: [
              if (icon case final icon?)
                Icon(icon, size: 22, color: colors.textTertiary),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (value case final value?)
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.accentText,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
