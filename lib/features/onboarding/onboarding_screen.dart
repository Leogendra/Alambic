import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/onboarding/onboarding_providers.dart';
import '../../application/preferences/interface_settings_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'permissions_page.dart';
import 'sample_group_page.dart';
import 'welcome_page.dart';

/// The three welcome screens of the first launch: the principle, the
/// notification permissions with the reminder time, and the sample group.
/// Going through them, or skipping the last one, creates the sample group,
/// named in the language of the app, and opens the app for good. The
/// onboarding being shown once, so is the group created.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const int pageCount = 3;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _page = 0;
  bool _isFinishing = false;

  void _next() => setState(() => _page++);

  /// Creates the sample group, to be opened by the tabs when [openGroup].
  Future<void> _finish({required bool openGroup}) async {
    setState(() => _isFinishing = true);
    final groupId = await ref
        .read(sampleGroupServiceProvider)
        .create(AppLocalizations.of(context).sampleGroupName);
    if (openGroup) {
      ref.read(firstGroupProvider.notifier).remember(groupId);
    }
    await ref.read(interfaceSettingsProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageDots(current: _page),
          Expanded(
            child: switch (_page) {
              0 => WelcomePage(onNext: _next),
              1 => PermissionsPage(onNext: _next),
              _ => SampleGroupPage(
                onStart: _isFinishing ? null : () => _finish(openGroup: true),
                onSkip: _isFinishing ? null : () => _finish(openGroup: false),
              ),
            },
          ),
        ],
      ),
    ),
  );
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 6,
        children: [
          for (var index = 0; index < OnboardingScreen.pageCount; index++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: index == current ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: index == current
                    ? colors.accent
                    : colors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}
