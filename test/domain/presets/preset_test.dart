import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/presets/failure_behavior.dart';
import 'package:alambic/domain/presets/interval_unit.dart';
import 'package:alambic/domain/presets/preset.dart';
import 'package:alambic/domain/presets/preset_interval.dart';

void main() {
  const tenMinutes = PresetInterval(10, IntervalUnit.minute);
  const oneDay = PresetInterval(1, IntervalUnit.day);
  const threeDays = PresetInterval(3, IntervalUnit.day);
  const oneWeek = PresetInterval(1, IntervalUnit.week);
  const oneMonth = PresetInterval(1, IntervalUnit.month);

  Preset presetOf(List<PresetInterval> intervals) => Preset(
    id: 1,
    name: 'Test',
    builtInKey: null,
    intervals: intervals,
    failureBehavior: FailureBehavior.stepBack,
  );

  group('withStep', () {
    test('puts the new step between its nearest and furthest neighbours', () {
      final preset = presetOf([oneDay, oneWeek, oneMonth]).withStep(threeDays);
      expect(preset.intervals, [oneDay, threeDays, oneWeek, oneMonth]);
    });

    test('puts a step shorter than all the others first', () {
      final preset = presetOf([oneDay, oneWeek]).withStep(tenMinutes);
      expect(preset.intervals, [tenMinutes, oneDay, oneWeek]);
    });

    test('puts a step longer than all the others last', () {
      final preset = presetOf([tenMinutes, oneDay]).withStep(oneMonth);
      expect(preset.intervals, [tenMinutes, oneDay, oneMonth]);
    });

    test('ranks steps by length whatever their unit', () {
      const nineDays = PresetInterval(9, IntervalUnit.day);
      const twoHours = PresetInterval(2, IntervalUnit.hour);
      final preset = presetOf([oneWeek]).withStep(nineDays).withStep(twoHours);
      expect(preset.intervals, [twoHours, oneWeek, nineDays]);
    });

    test('does not change the preset it is called on', () {
      final preset = presetOf([oneDay, oneMonth]);
      preset.withStep(oneWeek);
      expect(preset.intervals, [oneDay, oneMonth]);
    });
  });

  group('withoutStep', () {
    test('removes the step at the index', () {
      final preset = presetOf([oneDay, oneWeek, oneMonth]).withoutStep(1);
      expect(preset.intervals, [oneDay, oneMonth]);
    });

    test('puts back in order a sequence that was not', () {
      final preset = presetOf([oneMonth, oneDay, oneWeek]).withoutStep(2);
      expect(preset.intervals, [oneDay, oneMonth]);
    });
  });
}
