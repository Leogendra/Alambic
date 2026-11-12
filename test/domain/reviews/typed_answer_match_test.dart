import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/reviews/typed_answer_match.dart';

void main() {
  TypedAnswerMatch compare(String typed, String expected) =>
      TypedAnswerMatch.compare(typed, expected);

  test('ignores case, accents and spaces', () {
    expect(compare('canberra', 'Canberra'), TypedAnswerMatch.exact);
    expect(
      compare('  ile de france ', 'Île-de-France'),
      TypedAnswerMatch.exact,
    );
    expect(compare('Bogota', 'Bogotá'), TypedAnswerMatch.exact);
    expect(compare('oulan bator', 'Oulan Bator'), TypedAnswerMatch.exact);
    expect(compare('OulanBator', 'Oulan Bator'), TypedAnswerMatch.exact);
    expect(compare('coeur', 'cœur'), TypedAnswerMatch.exact);
    expect(compare('lAustralie', "l'Australie"), TypedAnswerMatch.exact);
  });

  test('forgives one typo', () {
    expect(compare('canbera', 'Canberra'), TypedAnswerMatch.oneTypo);
    expect(compare('canberrra', 'Canberra'), TypedAnswerMatch.oneTypo);
    expect(compare('canbarra', 'Canberra'), TypedAnswerMatch.oneTypo);
    expect(compare('cnaberra', 'Canberra'), TypedAnswerMatch.oneTypo);
    expect(compare('anberra', 'Canberra'), TypedAnswerMatch.oneTypo);
    expect(compare('Canberr', 'Canberra'), TypedAnswerMatch.oneTypo);
  });

  test('refuses two typos or another word', () {
    expect(compare('canbara', 'Canberra'), TypedAnswerMatch.wrong);
    expect(compare('Sydney', 'Canberra'), TypedAnswerMatch.wrong);
    expect(compare('', 'Canberra'), TypedAnswerMatch.wrong);
    expect(compare('', '  '), TypedAnswerMatch.wrong);
  });

  test('wants short answers and numbers exact', () {
    expect(compare('Lim', 'Lim'), TypedAnswerMatch.exact);
    expect(compare('Lia', 'Lim'), TypedAnswerMatch.wrong);
    expect(compare('Lma', 'Lima'), TypedAnswerMatch.oneTypo);
    expect(compare('1788', '1789'), TypedAnswerMatch.wrong);
    expect(compare('1798', '1789'), TypedAnswerMatch.wrong);
    expect(compare('178', '1789'), TypedAnswerMatch.wrong);
    expect(compare('en 1789', 'En 1789'), TypedAnswerMatch.exact);
    expect(compare('an 1789', 'En 1789'), TypedAnswerMatch.oneTypo);
  });
}
