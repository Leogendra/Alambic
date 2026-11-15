import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/preferences/interface_settings_providers.dart';
import '../../data/preferences/language_choice.dart';
import '../../data/preferences/theme_choice.dart';
import '../../l10n/generated/app_localizations.dart';
import 'choice_dialog.dart';

/// Language and theme of the app. Both apply at once, and the language also
/// applies to the notifications.
class DisplayPanel extends ConsumerWidget {
  const DisplayPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final settings = ref.watch(interfaceSettingsProvider);
    final controller = ref.read(interfaceSettingsProvider.notifier);
    final languages = _languageLabels(strings);
    final themes = _themeLabels(strings);
    final valueStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AlambicColors.of(context).accentText,
    );
    return SurfacePanel(
      children: [
        PanelRow(
          title: strings.settingsLanguage,
          trailing: Text(languages[settings.language]!, style: valueStyle),
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
          trailing: Text(themes[settings.theme]!, style: valueStyle),
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
