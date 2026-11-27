import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/asked_side_draw.dart';
import 'package:alambic/domain/cards/card_side.dart';
import 'package:alambic/domain/groups/asked_sides.dart';
import 'package:alambic/domain/groups/card_group.dart';

import '../test_groups.dart';

void main() {
  CardGroup group(AskedSides askedSides) => testGroup(askedSides: askedSides);

  List<CardSide> draws(CardGroup group) {
    final random = Random(7);
    return [
      for (var index = 0; index < 40; index++)
        AskedSideDraw.draw(group, random),
    ];
  }

  test('set to the front, the front is always asked', () {
    expect(draws(group(AskedSides.front)), everyElement(CardSide.front));
  });

  test('set to the back, the back is always asked', () {
    expect(draws(group(AskedSides.back)), everyElement(CardSide.back));
  });

  test('set to random, each display draws the front or the back', () {
    final sides = draws(group(AskedSides.random));
    expect(sides, contains(CardSide.front));
    expect(sides, contains(CardSide.back));
  });

  test('the answer is the face opposite the asked one', () {
    expect(CardSide.front.opposite, CardSide.back);
    expect(CardSide.back.opposite, CardSide.front);
  });
}
