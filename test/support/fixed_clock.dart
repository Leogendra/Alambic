/// A clock the test moves by hand.
class FixedClock {
  FixedClock(this.now);

  DateTime now;

  DateTime call() => now;
}
