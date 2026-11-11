import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/app/theme/remanence_theme.dart';
import 'package:remanence/l10n/generated/app_localizations.dart';

/// Phone-sized surface matching the mockup artboards (390 x 844).
const Size phoneSize = Size(390, 844);

/// Pumps [screen] inside the app theme and French localizations, at phone size.
Future<void> pumpGolden(
  WidgetTester tester,
  Widget screen, {
  Brightness brightness = Brightness.light,
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
            ? RemanenceTheme.light()
            : RemanenceTheme.dark(),
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
