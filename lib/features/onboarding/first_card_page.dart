import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/cards/card_draft.dart';
import '../../application/cards/card_providers.dart';
import '../../application/groups/group_providers.dart';
import '../../application/onboarding/onboarding_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'onboarding_page.dart';

/// Third screen: a first group and its first card, which waits in the queue
/// of the group; the app then opens on the page of the group. It can be
/// skipped.
class FirstCardPage extends ConsumerStatefulWidget {
  const FirstCardPage({required this.onDone, super.key});

  final Future<void> Function() onDone;

  @override
  ConsumerState<FirstCardPage> createState() => _FirstCardPageState();
}

class _FirstCardPageState extends ConsumerState<FirstCardPage> {
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();

  bool get _canCreate =>
      _groupController.text.trim().isNotEmpty &&
      _frontController.text.trim().isNotEmpty &&
      _backController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _groupController.dispose();
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final groupId = await ref
        .read(groupServiceProvider)
        .create(_groupController.text);
    await ref
        .read(cardServiceProvider)
        .create(
          CardDraft(
            frontText: _frontController.text,
            backText: _backController.text,
            groupId: groupId,
            presetId: null,
          ),
        );
    ref.read(firstGroupProvider.notifier).remember(groupId);
    await widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return OnboardingPage(
      title: strings.onboardingFirstCardTitle,
      body: strings.onboardingFirstCardBody,
      actions: [
        FilledButton(
          onPressed: _canCreate ? _create : null,
          child: Text(strings.onboardingCreateCard),
        ),
        TextButton(
          onPressed: widget.onDone,
          child: Text(strings.onboardingSkip),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          _FaceField(
            controller: _groupController,
            label: strings.cardGroup,
            hint: strings.onboardingGroupHint,
            onChanged: () => setState(() {}),
          ),
          _FaceField(
            controller: _frontController,
            label: strings.cardFront,
            hint: strings.onboardingFrontHint,
            onChanged: () => setState(() {}),
          ),
          _FaceField(
            controller: _backController,
            label: strings.cardBack,
            hint: strings.onboardingBackHint,
            onChanged: () => setState(() {}),
          ),
        ],
      ),
    );
  }
}

class _FaceField extends StatelessWidget {
  const _FaceField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: (text) => onChanged(),
    textCapitalization: TextCapitalization.sentences,
    decoration: InputDecoration(labelText: label, hintText: hint),
  );
}
