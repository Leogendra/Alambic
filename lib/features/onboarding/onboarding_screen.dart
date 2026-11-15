import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';

import '../../application/preferences/interface_settings_providers.dart';
import 'first_card_page.dart';
import 'permissions_page.dart';
import 'welcome_page.dart';

/// The three welcome screens of the first launch: the principle, the
/// notification permissions with the reminder time, and the first card.
/// Going through them, or skipping the last one, opens the app for good.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const int pageCount = 3;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _page = 0;

  void _next() => setState(() => _page++);

  Future<void> _finish() =>
      ref.read(interfaceSettingsProvider.notifier).completeOnboarding();

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
              _ => FirstCardPage(onDone: _finish),
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
