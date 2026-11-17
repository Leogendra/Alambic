import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// The field a typed answer is written in, in place of "Show answer", with
/// "Reveal" to show the answer without typing it. A blank answer is not
/// submitted.
class TypedAnswerField extends StatefulWidget {
  const TypedAnswerField({
    required this.enabled,
    required this.onSubmit,
    required this.onReveal,
    super.key,
  });

  final bool enabled;
  final ValueChanged<String> onSubmit;
  final VoidCallback onReveal;

  @override
  State<TypedAnswerField> createState() => _TypedAnswerFieldState();
}

class _TypedAnswerFieldState extends State<TypedAnswerField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: strings.typedAnswerField,
              suffixIcon: IconButton(
                tooltip: strings.sessionSubmitAnswer,
                icon: const Icon(Icons.send),
                onPressed: widget.enabled ? _submit : null,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: widget.enabled ? widget.onReveal : null,
          child: Text(
            strings.sessionReveal,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  void _submit() {
    final typed = _controller.text.trim();
    if (typed.isNotEmpty) {
      widget.onSubmit(typed);
    }
  }
}
