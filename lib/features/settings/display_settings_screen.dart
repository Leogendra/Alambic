import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/panel_row.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/preferences/interface_settings_providers.dart';
import '../../data/preferences/language_choice.dart';
import '../../data/preferences/theme_choice.dart';
import '../../l10n/generated/app_localizations.dart';
import 'choice_dialog.dart';
import 'settings_page.dart';

/// Language and theme of the app. Both apply at once, and the language also
/// applies to the notifications.
class DisplaySettingsScreen extends ConsumerWidget {
  const DisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final settings = ref.watch(interfaceSettingsProvider);
    final controller = ref.read(interfaceSettingsProvider.notifier);
    final languages = _languageLabels(strings);
    final themes = _themeLabels(strings);
    return SettingsPage(
      title: strings.settingsDisplay,
      children: [
        SurfacePanel(
          children: [
            PanelRow(
              title: strings.settingsLanguage,
              value: languages[settings.language],
              onTap: () async {
                final choice = await showChoiceDialog(
                  context,
                  title: strings.settingsLanguage,
                  options: languages,
                  selected: settings.language,
                );
                if (choice != null) {
                  await controller.setLanguage(choice);
                }
              },
            ),
            PanelRow(
              title: strings.settingsTheme,
              value: themes[settings.theme],
              onTap: () async {
                final choice = await showChoiceDialog(
                  context,
                  title: strings.settingsTheme,
                  options: themes,
                  selected: settings.theme,
                );
                if (choice != null) {
                  await controller.setTheme(choice);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Map<LanguageChoice, String> _languageLabels(AppLocalizations strings) => {
    LanguageChoice.system: strings.languageSystem,
    LanguageChoice.french: strings.languageFrench,
    LanguageChoice.english: strings.languageEnglish,
  };

  Map<ThemeChoice, String> _themeLabels(AppLocalizations strings) => {
    ThemeChoice.system: strings.themeSystem,
    ThemeChoice.light: strings.themeLight,
    ThemeChoice.dark: strings.themeDark,
  };
}
