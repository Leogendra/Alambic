import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/app/formatting/reminder_labels.dart';
import 'package:alambic/domain/presets/interval_unit.dart';
import 'package:alambic/domain/presets/preset_interval.dart';
import 'package:alambic/domain/scheduling/card_progress.dart';
import 'package:alambic/domain/scheduling/fsrs/fsrs_memory.dart';
import 'package:alambic/l10n/generated/app_localizations.dart';

void main() {
  final french = lookupAppLocalizations(const Locale('fr'));
  final english = lookupAppLocalizations(const Locale('en'));

  test('the label is taken from the interval, not from the step', () {
    expect(
      french.reminderLabel(const PresetInterval(1, IntervalUnit.day)),
      'J1',
    );
    expect(
      french.reminderLabel(const PresetInterval(2, IntervalUnit.day)),
      'J2',
    );
    expect(
      french.reminderLabel(const PresetInterval(1, IntervalUnit.week)),
      'S1',
    );
    expect(
      french.reminderLabel(const PresetInterval(3, IntervalUnit.month)),
      'M3',
    );
  });

  test('English letters are D, W and M', () {
    expect(
      english.reminderLabel(const PresetInterval(1, IntervalUnit.day)),
      'D1',
    );
    expect(
      english.reminderLabel(const PresetInterval(1, IntervalUnit.week)),
      'W1',
    );
    expect(
      english.reminderLabel(const PresetInterval(6, IntervalUnit.month)),
      'M6',
    );
  });

  test('an interval below a day reads as a duration', () {
    expect(
      french.reminderLabel(const PresetInterval(10, IntervalUnit.minute)),
      '10 min',
    );
    expect(
      french.reminderLabel(const PresetInterval(1, IntervalUnit.hour)),
      '1 h',
    );
  });

  test('a new card and a card followed by FSRS have no label', () {
    expect(french.progressLabel(const NewProgress()), isNull);
    expect(
      french.progressLabel(
        const AdaptiveProgress(
          memory: FsrsMemory(stability: 3, difficulty: 5),
          intervalDays: 3,
        ),
      ),
      isNull,
    );
  });
}
