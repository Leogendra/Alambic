import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/about/about_providers.dart';
import '../../application/preferences/interface_settings_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../presets/presets_screen.dart';
import 'backup_screen.dart';
import 'display_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'open_settings_screen.dart';

/// Settings tab: one row per category of settings, each opening its own
/// screen, then the "About" links and, in debug builds, the development tools.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
          child: Text(
            strings.settingsTitle,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
        ),
        SurfacePanel(
          children: [
            _category(
              context,
              Icons.notifications_outlined,
              strings.settingsNotifications,
              const NotificationSettingsScreen(),
            ),
            _category(
              context,
              Icons.tune,
              strings.settingsPresets,
              const PresetsScreen(),
            ),
            _category(
              context,
              Icons.palette_outlined,
              strings.settingsDisplay,
              const DisplaySettingsScreen(),
            ),
            _category(
              context,
              Icons.settings_backup_restore,
              strings.settingsBackup,
              const BackupScreen(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SectionLabel(strings.settingsAboutSection),
        SurfacePanel(
          children: [
            PanelRow(
              icon: Icons.code,
              title: strings.settingsGithub,
              trailing: const Icon(Icons.open_in_new),
              onTap: () => ref.read(appAboutProvider).openRepository(),
            ),
          ],
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 24),
          SectionLabel(strings.settingsDevelopmentSection),
          SurfacePanel(
            children: [
              PanelRow(
                icon: Icons.smartphone_outlined,
                title: strings.settingsReplayOnboarding,
                showsChevron: false,
                onTap: () => ref
                    .read(interfaceSettingsProvider.notifier)
                    .replayOnboarding(),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        const _Version(),
      ],
    );
  }

  Widget _category(
    BuildContext context,
    IconData icon,
    String title,
    Widget screen,
  ) => PanelRow(
    icon: icon,
    title: title,
    onTap: () => openSettingsScreen(context, screen),
  );
}

/// "Alambic v0.2.0", at the foot of the tab.
class _Version extends ConsumerWidget {
  const _Version();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).value;
    if (version == null) {
      return const SizedBox.shrink();
    }
    return Text(
      AppLocalizations.of(context).settingsVersion(version),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        color: AlambicColors.of(context).textSecondary,
      ),
    );
  }
}
