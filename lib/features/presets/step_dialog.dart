import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/interval_labels.dart';
import '../../domain/presets/interval_unit.dart';
import '../../domain/presets/preset_interval.dart';
import '../../l10n/generated/app_localizations.dart';

/// Asks for a new step of a sequence: an amount and a unit.
Future<PresetInterval?> showStepDialog(BuildContext context) =>
    showDialog<PresetInterval>(
      context: context,
      builder: (context) => const _StepDialog(),
    );

class _StepDialog extends StatefulWidget {
  const _StepDialog();

  @override
  State<_StepDialog> createState() => _StepDialogState();
}

class _StepDialogState extends State<_StepDialog> {
  /// A step is at least an hour: shorter ones only exist in shipped presets.
  static final List<IntervalUnit> _units = [
    for (final unit in IntervalUnit.values)
      if (unit != IntervalUnit.minute) unit,
  ];

  final TextEditingController _amountController = TextEditingController(
    text: '1',
  );
  IntervalUnit _unit = IntervalUnit.day;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int? get _amount {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      return null;
    } else {
      return amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(strings.presetEditorStepDialogTitle),
      content: Row(
        spacing: 12,
        children: [
          SizedBox(
            width: 80,
            child: TextField(
              controller: _amountController,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: strings.presetEditorStepAmount,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: DropdownButtonFormField<IntervalUnit>(
              initialValue: _unit,
              decoration: InputDecoration(
                labelText: strings.presetEditorStepUnit,
              ),
              items: [
                for (final unit in _units)
                  DropdownMenuItem(
                    value: unit,
                    child: Text(strings.intervalUnitName(unit)),
                  ),
              ],
              onChanged: (unit) => setState(() => _unit = unit ?? _unit),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.commonCancel),
        ),
        TextButton(
          onPressed: _amount == null
              ? null
              : () =>
                    Navigator.of(context).pop(PresetInterval(_amount!, _unit)),
          child: Text(strings.commonAdd),
        ),
      ],
    );
  }
}
