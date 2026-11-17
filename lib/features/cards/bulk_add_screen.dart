import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layout/bottom_action_area.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/cards/card_draft.dart';
import '../../application/cards/card_providers.dart';
import '../../domain/cards/bulk/bulk_card_parser.dart';
import '../../domain/cards/bulk/bulk_line_error.dart';
import '../../domain/cards/bulk/bulk_line_error_kind.dart';
import '../../domain/cards/bulk/bulk_parse_result.dart';
import '../../l10n/generated/app_localizations.dart';
import 'group_field.dart';

/// Pastes "front ; back" lines to create many cards in a group at once. The
/// group is the one the user came from, and can be changed or created here.
class BulkAddScreen extends ConsumerStatefulWidget {
  const BulkAddScreen({required this.initialGroupId, super.key});

  final int initialGroupId;

  @override
  ConsumerState<BulkAddScreen> createState() => _BulkAddScreenState();
}

class _BulkAddScreenState extends ConsumerState<BulkAddScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _separatorController = TextEditingController(
    text: BulkCardParser.defaultSeparator,
  );
  late int _groupId = widget.initialGroupId;

  @override
  void dispose() {
    _textController.dispose();
    _separatorController.dispose();
    super.dispose();
  }

  BulkParseResult get _result =>
      BulkCardParser.parse(_textController.text, _separatorController.text);

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: Text(strings.bulkTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              children: [
                _settingsPanel(strings),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  minLines: 8,
                  maxLines: 16,
                  decoration: InputDecoration(hintText: strings.bulkTextHint),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _report(strings, result),
              ],
            ),
          ),
          BottomActionArea(
            child: FilledButton(
              onPressed: result.drafts.isEmpty ? null : () => _add(result),
              child: Text(strings.bulkAddButton(result.drafts.length)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsPanel(AppLocalizations strings) => SurfacePanel(
    children: [
      GroupField(
        groupId: _groupId,
        onChanged: (groupId) => setState(() => _groupId = groupId),
      ),
      PanelRow(
        title: strings.bulkSeparator,
        subtitle: strings.bulkSeparatorHint,
        trailing: SizedBox(
          width: 64,
          child: TextField(
            controller: _separatorController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ),
    ],
  );

  Widget _report(AppLocalizations strings, BulkParseResult result) {
    final colors = AlambicColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        SectionLabel(strings.bulkReady(result.drafts.length)),
        for (final error in result.errors)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              _errorText(strings, error),
              style: TextStyle(fontSize: 13, color: colors.againForeground),
            ),
          ),
      ],
    );
  }

  String _errorText(AppLocalizations strings, BulkLineError error) =>
      switch (error.kind) {
        BulkLineErrorKind.missingSeparator => strings.bulkErrorMissingSeparator(
          error.lineNumber,
          _separatorController.text,
        ),
        BulkLineErrorKind.emptyFace => strings.bulkErrorEmptyFace(
          error.lineNumber,
        ),
      };

  Future<void> _add(BulkParseResult result) async {
    final strings = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final count = await ref.read(cardServiceProvider).createAll([
      for (final draft in result.drafts)
        CardDraft(
          frontText: draft.front,
          backText: draft.back,
          groupId: _groupId,
        ),
    ]);
    messenger.showSnackBar(SnackBar(content: Text(strings.bulkAdded(count))));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
