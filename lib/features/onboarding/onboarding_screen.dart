import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/sample_group_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/theme/alambic_theme.dart';
import '../../application/groups/sample_group_providers.dart';
import '../../application/onboarding/onboarding_providers.dart';
import '../../application/preferences/interface_settings_providers.dart';
import '../../data/samples/sample_group.dart';
import '../../l10n/generated/app_localizations.dart';
import 'distillation_page.dart';
import 'permissions_page.dart';
import 'sample_group_page.dart';
import 'welcome_page.dart';

/// The four welcome screens of the first launch: the principle, the
/// distillation, the notification permissions with the reminder time, and
/// the sample group.
/// Going through them, or skipping them from any screen, creates the sample
/// group, named in the language of the app, and opens the app for good. The
/// onboarding being shown once, so is the group created.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const int pageCount = 4;

  /// The sample group the onboarding presents and creates.
  static const SampleGroup sample = SampleGroup.capitals;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _page = 0;
  bool _isFinishing = false;

  void _next() => setState(() => _page++);

  void _back() => setState(() => _page--);

  /// The sample group in the language of the app.
  SampleEdition get _edition => (
    sample: OnboardingScreen.sample,
    languageCode: Localizations.localeOf(context).languageCode,
  );

  /// Creates the sample group, or finds the one a previous onboarding made,
  /// to be opened by the tabs when [openGroup].
  Future<void> _finish({required bool openGroup}) async {
    setState(() => _isFinishing = true);
    final groupId = await ref
        .read(sampleGroupServiceProvider)
        .createOrFind(_edition, name: editionGroupName(_edition));
    if (openGroup) {
      ref.read(firstGroupProvider.notifier).remember(groupId);
    }
    await ref.read(interfaceSettingsProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    // Read from the first screen, so that the next ones show them at once.
    final sampleCards = ref.watch(sampleCardsProvider(_edition)).value;
    return PopScope(
      // The system back goes to the previous screen, and leaves the app from
      // the first one.
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _back();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(
                onBack: _page == 0 ? null : _back,
                onSkip: _isFinishing ? null : () => _finish(openGroup: false),
              ),
              Expanded(
                child: switch (_page) {
                  0 => WelcomePage(onNext: _next),
                  1 => DistillationPage(
                    sampleCardCount: sampleCards?.length,
                    onNext: _next,
                  ),
                  2 => PermissionsPage(onNext: _next),
                  _ => SampleGroupPage(
                    name: editionGroupName(_edition),
                    cards: sampleCards,
                    onStart: _isFinishing
                        ? null
                        : () => _finish(openGroup: true),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Back" to the previous screen, absent on the first one, and "Skip".
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.onSkip});

  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 24, 12, 0),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            if (onBack != null)
              IconButton(
                onPressed: onBack,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                color: colors.textTertiary,
                icon: const Icon(Icons.chevron_left),
              ),
            const Spacer(),
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: colors.textSecondary,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(
                  fontFamily: AlambicTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(AppLocalizations.of(context).onboardingSkip),
            ),
          ],
        ),
      ),
    );
  }
}
