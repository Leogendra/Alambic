import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/app/shell/main_shell.dart';
import 'package:alambic/application/notifications/notification_providers.dart';
import 'package:alambic/application/preferences/interface_settings_providers.dart';
import 'package:alambic/application/reviews/session_item.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/preferences/interface_settings.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/data/repositories/preset_repository.dart';
import 'package:alambic/domain/cards/card_side.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/features/cards/bulk_add_screen.dart';
import 'package:alambic/features/cards/card_editor_screen.dart';
import 'package:alambic/features/cards/card_sheet_screen.dart';
import 'package:alambic/features/cards/group_picker.dart';
import 'package:alambic/features/cards/review_soon_sheet.dart';
import 'package:alambic/features/distillation/distill_screen.dart';
import 'package:alambic/features/groups/group_detail_screen.dart';
import 'package:alambic/features/groups/group_settings_screen.dart';
import 'package:alambic/features/onboarding/onboarding_screen.dart';
import 'package:alambic/features/presets/preset_editor_screen.dart';
import 'package:alambic/features/presets/preset_picker.dart';
import 'package:alambic/features/presets/presets_screen.dart';
import 'package:alambic/features/session/session_screen.dart';
import 'package:alambic/features/settings/notification_guards_screen.dart';

import '../support/fake_interface_settings_store.dart';
import '../support/fake_notifications.dart';
import '../support/fixed_clock.dart';
import '../support/golden_harness.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';

/// Height of the status bar and of a three-button navigation bar, the
/// tallest of the two navigation modes.
const double statusBarHeight = 32;
const double navigationBarHeight = 48;

/// Pumps [screen] at phone size under a status bar and a navigation bar.
Future<void> pumpUnderSystemBars(
  WidgetTester tester,
  Widget screen, {
  required List<Override> overrides,
}) async {
  const padding = FakeViewPadding(
    top: statusBarHeight,
    bottom: navigationBarHeight,
  );
  tester.view.padding = padding;
  tester.view.viewPadding = padding;
  await pumpGolden(tester, screen, overrides: overrides);
}

/// Checks that no text and no tappable element shows under a system bar.
///
/// Elements outside any list are checked as they are. A list may scroll
/// under the bars, but its first element must show below the status bar at
/// the top of the list, and its last element above the navigation bar at
/// the end of the list.
Future<void> expectClearOfSystemBars(WidgetTester tester) async {
  final size = tester.view.physicalSize / tester.view.devicePixelRatio;
  final statusBar = Rect.fromLTWH(0, 0, size.width, statusBarHeight);
  final navigationBar = Rect.fromLTWH(
    0,
    size.height - navigationBarHeight,
    size.width,
    navigationBarHeight,
  );
  _expectNoneUnder(tester, [statusBar, navigationBar], inList: null);
  for (final list in _verticalLists(tester)) {
    list.position.jumpTo(list.position.minScrollExtent);
    await tester.pumpAndSettle();
    _expectNoneUnder(tester, [statusBar], inList: list);
    list.position.jumpTo(list.position.maxScrollExtent);
    await tester.pumpAndSettle();
    _expectNoneUnder(tester, [navigationBar], inList: list);
  }
}

List<ScrollableState> _verticalLists(WidgetTester tester) => [
  for (final state in tester.stateList<ScrollableState>(
    find.byType(Scrollable),
  ))
    if (state.position.axis == Axis.vertical) state,
];

/// Checks the texts and tappable elements whose closest list is [inList]
/// (none for `null`) against [bars].
void _expectNoneUnder(
  WidgetTester tester,
  List<Rect> bars, {
  required ScrollableState? inList,
}) {
  final elements = find
      .byWidgetPredicate(_isTextOrTappable)
      .evaluate()
      .where((element) => Scrollable.maybeOf(element) == inList);
  for (final element in elements) {
    final visible = _visibleRect(element, inList);
    if (visible == null) {
      continue;
    }
    for (final bar in bars) {
      expect(
        visible.overlaps(bar),
        isFalse,
        reason: '${_describe(element.widget)} at $visible is under $bar',
      );
    }
  }
}

bool _isTextOrTappable(Widget widget) => switch (widget) {
  RichText() || EditableText() || Switch() => true,
  InkResponse(:final onTap) || GestureDetector(:final onTap) => onTap != null,
  _ => false,
};

/// The part of [element] on screen: clipped by its list, `null` when it is
/// scrolled out of view or has no size.
Rect? _visibleRect(Element element, ScrollableState? list) {
  final box = element.renderObject;
  if (box is! RenderBox || !box.hasSize || box.size.isEmpty) {
    return null;
  }
  var rect = MatrixUtils.transformRect(
    box.getTransformTo(null),
    Offset.zero & box.size,
  );
  final viewport = list?.context.findRenderObject();
  if (viewport is RenderBox) {
    rect = rect.intersect(
      MatrixUtils.transformRect(
        viewport.getTransformTo(null),
        Offset.zero & viewport.size,
      ),
    );
  }
  return rect.width > 0 && rect.height > 0 ? rect : null;
}

String _describe(Widget widget) => switch (widget) {
  RichText(:final text) => '"${text.toPlainText()}"',
  _ => widget.toStringShort(),
};

void main() {
  late AlambicDatabase database;
  late SampleServices samples;
  late int capitalsId;
  late int firstCardId;

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  /// The sample groups, with enough cards in "Capitales" for every list to
  /// scroll.
  Future<void> seed(WidgetTester tester) => tester.runAsync(() async {
    samples = SampleServices(database, FixedClock(sampleNow));
    capitalsId = await seedSampleData(samples);
    for (var index = 1; index <= 16; index++) {
      await samples.card('Pays $index', 'Capitale $index', groupId: capitalsId);
    }
    firstCardId = (await CardRepository(database).getCardsOfGroup(capitalsId))
        .first
        .id;
  });

  List<Override> overrides() => [
    ...screenOverrides(database, sampleNow),
    alarmSchedulerProvider.overrideWithValue(FakeAlarmScheduler()),
    notificationPresenterProvider.overrideWithValue(FakePresenter()),
    interfaceSettingsStoreProvider.overrideWithValue(
      FakeInterfaceSettingsStore(),
    ),
    initialInterfaceSettingsProvider.overrideWithValue(
      const InterfaceSettings(onboardingDone: true),
    ),
  ];

  Future<void> checkScreen(WidgetTester tester, Widget screen) async {
    await seed(tester);
    await pumpUnderSystemBars(tester, screen, overrides: overrides());
    await expectClearOfSystemBars(tester);
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.runAsync(() async {
      await tester.tap(finder);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
  }

  group('every tab', () {
    for (final tab in ['Accueil', 'Groupes', 'Statistiques', 'Réglages']) {
      testWidgets(tab, (tester) async {
        await seed(tester);
        await pumpUnderSystemBars(
          tester,
          const MainShell(),
          overrides: overrides(),
        );
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        await expectClearOfSystemBars(tester);
      });
    }
  });

  group('every screen', () {
    testWidgets('group detail', (tester) async {
      await seed(tester);
      await pumpUnderSystemBars(
        tester,
        GroupDetailScreen(groupId: capitalsId),
        overrides: overrides(),
      );
      await expectClearOfSystemBars(tester);
    });

    testWidgets('group settings', (tester) async {
      await seed(tester);
      await pumpUnderSystemBars(
        tester,
        GroupSettingsScreen(groupId: capitalsId),
        overrides: overrides(),
      );
      await expectClearOfSystemBars(tester);
    });

    testWidgets('distill', (tester) async {
      await seed(tester);
      await pumpUnderSystemBars(
        tester,
        DistillScreen(groupId: capitalsId),
        overrides: overrides(),
      );
      await expectClearOfSystemBars(tester);
    });

    testWidgets('card editor', (tester) async {
      await seed(tester);
      await pumpUnderSystemBars(
        tester,
        CardEditorScreen(initialGroupId: capitalsId),
        overrides: overrides(),
      );
      await expectClearOfSystemBars(tester);
    });

    testWidgets('bulk add', (tester) async {
      await seed(tester);
      await pumpUnderSystemBars(
        tester,
        BulkAddScreen(initialGroupId: capitalsId),
        overrides: overrides(),
      );
      await expectClearOfSystemBars(tester);
    });

    testWidgets('bulk add keeps its button above the keyboard', (tester) async {
      const keyboardHeight = 300.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: keyboardHeight);
      await seed(tester);
      await pumpUnderSystemBars(
        tester,
        BulkAddScreen(initialGroupId: capitalsId),
        overrides: overrides(),
      );
      final button = tester.getRect(find.byType(FilledButton));
      expect(
        button.bottom,
        lessThanOrEqualTo(phoneSize.height - keyboardHeight),
      );
    });

    testWidgets('card sheet', (tester) async {
      await seed(tester);
      await pumpUnderSystemBars(
        tester,
        CardSheetScreen(cardId: firstCardId),
        overrides: overrides(),
      );
      await expectClearOfSystemBars(tester);
    });

    testWidgets('presets', (tester) async {
      await checkScreen(tester, const PresetsScreen());
    });

    testWidgets('preset editor', (tester) async {
      await seed(tester);
      final standard = await tester.runAsync(
        () async =>
            (await PresetRepository(database).loadCatalog()).globalPreset,
      );
      await pumpUnderSystemBars(
        tester,
        PresetEditorScreen(initialPreset: standard!),
        overrides: overrides(),
      );
      await expectClearOfSystemBars(tester);
    });

    testWidgets('notification guards', (tester) async {
      await checkScreen(tester, const NotificationGuardsScreen());
    });

    testWidgets('session, before and after the answer is shown', (
      tester,
    ) async {
      await seed(tester);
      await pumpUnderSystemBars(
        tester,
        SessionScreen(
          items: [SessionItem(cardId: firstCardId, askedSide: CardSide.front)],
        ),
        overrides: overrides(),
      );
      await expectClearOfSystemBars(tester);
      await tester.tap(find.text('Afficher la réponse'));
      await tester.pumpAndSettle();
      await expectClearOfSystemBars(tester);
      await tapAndSettle(tester, find.text('Correct'));
      expect(find.text('Session terminée'), findsOneWidget);
      await expectClearOfSystemBars(tester);
    });

    testWidgets('the three onboarding screens', (tester) async {
      await checkScreen(tester, const OnboardingScreen());
      await tester.tap(find.text('Commencer'));
      await tester.pumpAndSettle();
      await expectClearOfSystemBars(tester);
      await tapAndSettle(tester, find.text('Continuer'));
      await expectClearOfSystemBars(tester);
    });
  });

  group('every sheet', () {
    /// A page with a single button that opens a sheet.
    Future<void> openSheet(
      WidgetTester tester,
      Future<void> Function(BuildContext context) open,
    ) async {
      await seed(tester);
      await pumpUnderSystemBars(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => open(context),
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
        overrides: overrides(),
      );
      await tapAndSettle(tester, find.text('Ouvrir'));
    }

    testWidgets('preset picker', (tester) async {
      await openSheet(tester, (context) async {
        final catalog = await PresetRepository(database).loadCatalog();
        if (context.mounted) {
          await showPresetPicker(
            context,
            presets: catalog.presetsById.values.toList(),
            selectedPresetId: null,
            inheritedPreset: catalog.globalPreset,
          );
        }
      });
      await expectClearOfSystemBars(tester);
    });

    testWidgets('group picker', (tester) async {
      await openSheet(tester, (context) async {
        final groups = await GroupRepository(database).watchAll().first;
        if (context.mounted) {
          await showGroupPicker(
            context,
            groups: groups,
            selectedGroupId: capitalsId,
          );
        }
      });
      await expectClearOfSystemBars(tester);
    });

    testWidgets('review soon', (tester) async {
      await openSheet(
        tester,
        (context) => showReviewSoonSheet(
          context,
          cardId: firstCardId,
          front: 'Mongolie',
          defaultTime: const ClockTime(18, 0),
        ),
      );
      await expectClearOfSystemBars(tester);
    });
  });
}
