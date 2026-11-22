import 'dart:async';
import 'dart:io';
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/app/theme/alambic_theme.dart';
import 'package:alambic/l10n/generated/app_localizations.dart';

/// Phone-sized surface matching the mockup artboards (390 x 844).
const Size phoneSize = Size(390, 844);

/// The English texts, the language of the screens under test by default.
final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

/// Pumps [screen] inside the app theme and the localizations of [locale]
/// (English by default), at phone size.
Future<void> pumpGolden(
  WidgetTester tester,
  Widget screen, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = phoneSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light
            ? AlambicTheme.light()
            : AlambicTheme.dark(),
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Whether this run writes the screen captures: `--dart-define=shots=true`.
const bool writeShots = bool.fromEnvironment('shots');

/// Writes the image of the widget found by [finder] to `build/shots/[name].png`
/// when the run asks for it ([writeShots]), and does nothing otherwise. The
/// captures are for looking at the screens, not for comparing them: nothing
/// fails on a pixel.
Future<void> captureShot(
  WidgetTester tester,
  Finder finder,
  String name,
) async {
  if (!writeShots) return;
  var renderObject = tester.element(finder).renderObject!;
  while (!renderObject.isRepaintBoundary) {
    renderObject = renderObject.parent!;
  }
  final layer = renderObject.debugLayer! as OffsetLayer;
  await tester.runAsync(() async {
    final image = await layer.toImage(renderObject.paintBounds);
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    image.dispose();
    final file = File('build/shots/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}

/// Decodes the image file at [path] into the image cache. A widget test does
/// no real I/O outside [WidgetTester.runAsync]: an image shown before being
/// cached would never load.
Future<void> precacheImageFile(WidgetTester tester, String path) =>
    tester.runAsync(() async {
      final loaded = Completer<void>();
      final stream = FileImage(File(path)).resolve(ImageConfiguration.empty);
      final listener = ImageStreamListener(
        (image, synchronousCall) => loaded.complete(),
        onError: loaded.completeError,
      );
      stream.addListener(listener);
      await loaded.future;
      stream.removeListener(listener);
    });
