import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/asked_side_draw.dart';
import 'package:alambic/domain/cards/card_side.dart';
import 'package:alambic/domain/groups/card_group.dart';

import '../test_groups.dart';

void main() {
  CardGroup group({required bool reverseEnabled}) =>
      testGroup(reverseEnabled: reverseEnabled);

  List<CardSide> draws(CardGroup group) {
    final random = Random(7);
    return [
      for (var index = 0; index < 40; index++)
        AskedSideDraw.draw(group, random),
    ];
  }

  test('without the back, the front is always asked', () {
    expect(draws(group(reverseEnabled: false)), everyElement(CardSide.front));
  });

  test('with the back, each display draws the front or the back', () {
    final sides = draws(group(reverseEnabled: true));
    expect(sides, contains(CardSide.front));
    expect(sides, contains(CardSide.back));
  });

  test('the answer is the face opposite the asked one', () {
    expect(CardSide.front.opposite, CardSide.back);
    expect(CardSide.back.opposite, CardSide.front);
  });
}
