/// Which face is asked: the front (answer on the back) or the reverse.
enum DirectionSense {
  frontToBack,
  backToFront;

  DirectionSense get opposite => switch (this) {
    DirectionSense.frontToBack => DirectionSense.backToFront,
    DirectionSense.backToFront => DirectionSense.frontToBack,
  };
}
