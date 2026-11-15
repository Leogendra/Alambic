import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/cards/card_draft.dart';
import '../../application/cards/card_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'onboarding_page.dart';

/// Third screen: a first card, outside any group, started at once so that
/// the first notification comes today. It can be skipped.
class FirstCardPage extends ConsumerStatefulWidget {
  const FirstCardPage({required this.onDone, super.key});

  final Future<void> Function() onDone;

  @override
  ConsumerState<FirstCardPage> createState() => _FirstCardPageState();
}

class _FirstCardPageState extends ConsumerState<FirstCardPage> {
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();

  bool get _canCreate =>
      _frontController.text.trim().isNotEmpty &&
      _backController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final service = ref.read(cardServiceProvider);
    final cardId = await service.create(
      CardDraft(
        frontText: _frontController.text,
        backText: _backController.text,
        groupId: null,
        presetId: null,
        alsoReverse: false,
      ),
    );
    await service.startCard(cardId);
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
