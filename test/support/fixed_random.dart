import 'dart:math';

/// Random draws decided by the test: every [nextBool] returns [coin], so a
/// group with the back enabled always asks the back when it is `true`.
class FixedRandom implements Random {
  FixedRandom({this.coin = true});

  bool coin;

  @override
  bool nextBool() => coin;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}
