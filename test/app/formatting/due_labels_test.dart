import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/app/formatting/due_labels.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';
import 'package:alambic/l10n/generated/app_localizations.dart';

void main() {
  const calendar = SchedulingCalendar();
  final english = lookupAppLocalizations(const Locale('en'));
  final french = lookupAppLocalizations(const Locale('fr'));
  final now = DateTime(2026, 11, 10, 9);

  String label(AppLocalizations strings, int days) => strings.dueInLabel(
    DateTime(2026, 11, 10 + days, 9),
    now: now,
    calendar: calendar,
  );

  test('a card due later today reads its time, a late one reads "Due"', () {
    final later = DateTime(2026, 11, 10, 15, 17);
    expect(english.dueInLabel(later, now: now, calendar: calendar), 'at 15:17');
    final late = now.subtract(const Duration(hours: 1));
    expect(english.dueInLabel(late, now: now, calendar: calendar), 'Due');
  });

  test('tomorrow reads one day, and the days stay days up to 29', () {
    expect(label(english, 1), '1 d');
    expect(label(french, 1), '1 j');
    expect(label(english, 29), '29 d');
  });

  test('from 30 days the delay rounds to the month', () {
    expect(label(english, 30), '1 mo');
    expect(label(english, 46), '2 mo');
    expect(label(french, 90), '3 mois');
  });

  test('from 365 days the delay rounds to the year', () {
    expect(label(english, 365), '1 yr');
    expect(label(french, 730), '2 ans');
    expect(label(french, 365), '1 an');
  });
}
