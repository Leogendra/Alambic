/// Grade of an answer in FSRS. The app only asks for two: "Correct" is
/// [good] and "Again" is [again].
enum FsrsRating {
  again(1),
  hard(2),
  good(3),
  easy(4);

  const FsrsRating(this.grade);

  /// Value of the rating in the FSRS formulas.
  final int grade;
}
