import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/preset_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/cards/card_draft.dart';
import '../../application/cards/card_providers.dart';
import '../../application/cards/draft_image.dart';
import '../../application/presets/preset_providers.dart';
import '../../data/data_providers.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../l10n/generated/app_localizations.dart';
import '../presets/preset_picker.dart';
import 'card_image.dart';
import 'group_field.dart';
import 'image_picking.dart';

/// Creates a card, or edits an existing one when [cardId] is given. Each face
/// takes a text, an image, or both; the card needs a group.
class CardEditorScreen extends ConsumerStatefulWidget {
  const CardEditorScreen({this.cardId, this.initialGroupId, super.key});

  final int? cardId;
  final int? initialGroupId;

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen> {
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  DraftImage? _frontImage;
  DraftImage? _backImage;
  late int? _groupId = widget.initialGroupId;
  int? _presetId;
  bool _isLoaded = false;

  bool get _isEditing => widget.cardId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadCard(widget.cardId!);
    } else {
      _isLoaded = true;
    }
  }

  Future<void> _loadCard(int cardId) async {
    final loaded = await ref
        .read(cardRepositoryProvider)
        .watchCard(cardId)
        .first;
    if (!mounted || loaded == null) {
      return;
    }
    setState(() {
      _frontController.text = loaded.frontText ?? '';
      _backController.text = loaded.backText ?? '';
      _frontImage = switch (loaded.frontImagePath) {
        final name? => StoredImage(name),
        null => null,
      };
      _backImage = switch (loaded.backImagePath) {
        final name? => StoredImage(name),
        null => null,
      };
      _groupId = loaded.groupId;
      _presetId = loaded.presetId;
      _isLoaded = true;
    });
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  CardDraft _draftIn(int groupId) => CardDraft(
    frontText: _frontController.text,
    backText: _backController.text,
    frontImage: _frontImage,
    backImage: _backImage,
    groupId: groupId,
    presetId: _presetId,
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: strings.commonClose,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? strings.cardEditorEditTitle : strings.cardEditorNewTitle,
        ),
        actions: [
          TextButton(
            onPressed: _isLoaded ? _save : null,
            child: Text(
              _isEditing ? strings.commonSave : strings.cardEditorCreate,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _faceField(
            strings,
            label: strings.cardFront,
            hint: strings.cardFrontHint,
            controller: _frontController,
            image: _frontImage,
            onImageChanged: (image) => setState(() => _frontImage = image),
          ),
          const SizedBox(height: 16),
          _faceField(
            strings,
            label: strings.cardBack,
            hint: strings.cardBackHint,
            controller: _backController,
            image: _backImage,
            onImageChanged: (image) => setState(() => _backImage = image),
          ),
          const SizedBox(height: 16),
          _classificationPanel(strings),
        ],
      ),
    );
  }

  /// The text of a face, then its image with a button to remove it, or a
  /// button to add one.
  Widget _faceField(
    AppLocalizations strings, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required DraftImage? image,
    required ValueChanged<DraftImage?> onImageChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: SectionLabel(label)),
          if (image == null)
            TextButton.icon(
              onPressed: () async {
                final path = await ref.read(imagePickingProvider).pick();
                if (path != null) {
                  onImageChanged(PickedImage(path));
                }
              },
              icon: const Icon(Icons.image_outlined, size: 20),
              label: Text(strings.cardAddImage),
            ),
        ],
      ),
      TextField(
        controller: controller,
        minLines: 2,
        maxLines: 6,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: hint),
        onChanged: (_) => setState(() {}),
      ),
      if (image != null)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            spacing: 10,
            children: [
              CardImage(
                image,
                width: 96,
                height: 64,
                fit: BoxFit.cover,
                radius: 8,
              ),
              IconButton.filledTonal(
                tooltip: strings.cardRemoveImage,
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => onImageChanged(null),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _classificationPanel(AppLocalizations strings) {
    final catalog = ref.watch(presetCatalogProvider).value;
    return SurfacePanel(
      children: [
        GroupField(
          groupId: _groupId,
          onChanged: (groupId) => setState(() => _groupId = groupId),
        ),
        if (catalog != null)
          PanelRow(
            title: strings.cardPreset,
            subtitle: _presetLabel(strings, catalog),
            trailing: Text(
              strings.commonChange,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AlambicColors.of(context).accentText,
              ),
            ),
            onTap: () => _choosePreset(catalog),
          ),
      ],
    );
  }

  String _presetLabel(AppLocalizations strings, PresetCatalog catalog) {
    final ownPreset = catalog.presetsById[_presetId];
    final groupId = _groupId;
    if (ownPreset != null) {
      return strings.presetName(ownPreset);
    } else if (groupId != null) {
      return strings.cardPresetInheritedFromGroup(
        strings.presetName(catalog.presetForGroup(groupId)),
      );
    } else {
      return strings.cardPresetInheritedGlobal(
        strings.presetName(catalog.globalPreset),
      );
    }
  }

  Future<void> _choosePreset(PresetCatalog catalog) async {
    final choice = await showPresetPicker(
      context,
      presets: catalog.presetsById.values.toList(),
      selectedPresetId: _presetId,
      inheritedPreset: switch (_groupId) {
        final groupId? => catalog.presetForGroup(groupId),
        null => catalog.globalPreset,
      },
    );
    if (choice != null) {
      setState(() => _presetId = choice.presetId);
    }
  }

  Future<void> _save() async {
    final strings = AppLocalizations.of(context);
    final groupId = _groupId;
    final draft = groupId == null ? null : _draftIn(groupId);
    if (draft == null || !draft.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            draft == null ? strings.cardGroupMissing : strings.cardIncomplete,
          ),
        ),
      );
      return;
    }
    final service = ref.read(cardServiceProvider);
    if (_isEditing) {
      await service.update(widget.cardId!, draft);
    } else {
      await service.create(draft);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
