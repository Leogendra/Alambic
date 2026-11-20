import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

/// A [testWidgets] that unmounts its screen at the end, even when the test
/// fails. flutter_test leaves the widgets of a failed test mounted: a
/// database closed in `tearDown` under their open streams then never
/// finishes closing. Every widget test that opens a database goes through it.
@isTest
void testScreen(String description, WidgetTesterCallback callback) =>
    testWidgets(description, (tester) async {
      try {
        await callback(tester);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
