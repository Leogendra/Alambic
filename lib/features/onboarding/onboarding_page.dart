import 'package:flutter/material.dart';

import '../../app/theme/alambic_colors.dart';

/// Layout shared by the welcome screens: a title, a short text, the content
/// of the screen, and its buttons at the bottom.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    required this.title,
    required this.body,
    required this.actions,
    this.child,
    super.key,
  });

  final String title;
  final String body;
  final Widget? child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.45,
                    color: colors.textSecondary,
                  ),
                ),
                if (child != null) ...[const SizedBox(height: 28), child!],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: actions,
          ),
        ],
      ),
    );
  }
}
