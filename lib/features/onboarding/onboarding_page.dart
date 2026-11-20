import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import 'onboarding_screen.dart';

/// Layout shared by the welcome screens: an illustration, a title, a short
/// text and the content of the screen, centred in the height, then the
/// position of the screen and its button at the bottom. The text waits for
/// what it depends on when [body] is `null`.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    required this.step,
    required this.title,
    required this.body,
    required this.action,
    this.illustration,
    this.child,
    super.key,
  });

  /// Position of the screen among the welcome screens, from 0.
  final int step;
  final String title;
  final String? body;
  final Widget? illustration;
  final Widget? child;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 32,
                    children: [
                      ?illustration,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 12,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                              letterSpacing: -0.68,
                            ),
                          ),
                          if (body case final body?)
                            Text(
                              body,
                              style: TextStyle(
                                fontSize: 17,
                                height: 1.45,
                                color: colors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      ?child,
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _PageDots(current: step),
          const SizedBox(height: 24),
          action,
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        for (var index = 0; index < OnboardingScreen.pageCount; index++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: index == current ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: index == current ? colors.accent : colors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

/// The frame of an illustration: a [title] in capitals, the drawing and a
/// [hint] under it.
class IllustrationCard extends StatelessWidget {
  const IllustrationCard({
    required this.title,
    required this.hint,
    required this.child,
    super.key,
  });

  final String title;
  final String hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 18,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              color: colors.textSecondary,
            ),
          ),
          child,
          Text(
            hint,
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
